// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "safe-core-protocol-demo/contracts/contracts/Base.sol";
import "./CPAMM.sol";
import "./Token.sol";
import "./groth16_verifier.sol";
import "./DeployManager.sol";

import "safe-core-protocol/contracts/interfaces/Accounts.sol";
import "safe-core-protocol/contracts/DataTypes.sol";

contract Module is BasePluginWithEventMetadata {
    Groth16Verifier immutable verifier;
    CPAMM immutable dexA;
    CPAMM immutable dexB;
    address immutable weth;
    address immutable dai;
    address immutable owner;
    ISafeManager immutable safeProtocolManager;

    constructor(
        CPAMM _dexA,
        CPAMM _dexB,
        address _weth,
        address _dai,
        Groth16Verifier _verifier,
        ISafeManager _safeProtocolManager
    )
        BasePluginWithEventMetadata(
            PluginMetadata({
                name: "Relay Plugin",
                version: "1.0.0",
                requiresRootAccess: false,
                iconUrl: "",
                appUrl: "https://5afe.github.io/safe-core-protocol-demo/#/relay/${plugin}"
            })
        )
    {
        dexA = _dexA;
        dexB = _dexB;
        weth = _weth;
        dai = _dai;
        verifier = _verifier;
        owner = msg.sender; // @todo replace by gnosis multisig signer
        safeProtocolManager = _safeProtocolManager;
    }

    struct State {
        uint256 xA;
        uint256 yA;
        uint256 xB;
        uint256 yB;
    }

    struct UserData {
        ISafe safe;
        address inToken;
        address outToken;
        uint256 dx;
        uint256 minDy;
        uint256 nonce;
        bytes signature;
    }

    struct Solution {
        uint256 dxA;
        uint256 dxB;
        uint256[2] _pA;
        uint256[2][2] _pB;
        uint256[2] _pC;
    }

    struct Received {
        uint256 dyA;
        uint256 dyB;
    }

    // function approve(address _weth, address _dai, Safe safe) public { // @audit-issue verify caller
    //     SafeProtocolAction[] memory safeActions = new SafeProtocolAction[](1);
    //     safeActions[0] = SafeProtocolAction(payable(address(_weth)), 0, abi.encodeCall(ERC20.approve, (address(dexA), type(uint256).max)));
    //     // safeActions[1] = SafeProtocolAction(payable(address(_weth)), 0, abi.encodeCall(ERC20.approve, (address(dexB), type(uint256).max)));

    //     // safeActions[2] = SafeProtocolAction(payable(address(_dai)), 0, abi.encodeCall(ERC20.approve, (address(dexA), type(uint256).max)));
    //     // safeActions[3] = SafeProtocolAction(payable(address(_dai)), 0, abi.encodeCall(ERC20.approve, (address(dexB), type(uint256).max)));

    //     SafeTransaction memory safeTransaction = SafeTransaction(safeActions, 0, bytes32(0));

    //     safeProtocolManager.executeTransaction(ISafe(address(safe)),safeTransaction);
    // }

    function executeIntent(UserData calldata intent, uint256 dxA, uint256 dxB)
        public
        returns (Received memory received)
    {
        SafeProtocolAction[] memory safeActions;
        if (dxA > 0 && dxB > 0) {
            safeActions = new SafeProtocolAction[](2);
            safeActions[0] =
                SafeProtocolAction(payable(address(dexA)), 0, abi.encodeCall(CPAMM.swap, (intent.inToken, dxA)));
            safeActions[1] =
                SafeProtocolAction(payable(address(dexB)), 0, abi.encodeCall(CPAMM.swap, (intent.inToken, dxB)));
        } else {
            safeActions = new SafeProtocolAction[](1);
            if (dxA > 0 && dxB == 0) {
                safeActions[0] =
                    SafeProtocolAction(payable(address(dexA)), 0, abi.encodeCall(CPAMM.swap, (intent.inToken, dxA)));
            } else if (dxA == 0 && dxB > 0) {
                safeActions[0] =
                    SafeProtocolAction(payable(address(dexB)), 0, abi.encodeCall(CPAMM.swap, (intent.inToken, dxB)));
            }
        }

        // @todo check amounts returned
        // require(dyA + dyB >= intent.minDy, "min dy"); dont care
        received = Received(0, 0);

        SafeTransaction memory safeTransaction = SafeTransaction(safeActions, intent.nonce, bytes32(0));
        //console.log("safeTransaction", safeTransaction);
        safeProtocolManager.executeTransaction(intent.safe, safeTransaction);
    }

    function tradeWithIntent(UserData calldata intent, Solution calldata solution) public {
        // validate intent
        // bool daiForEth = validateIntent(intent);

        // pre state
        // State memory preState = getState(daiForEth);

        // execute intent
        Received memory received = executeIntent(intent, solution.dxA, solution.dxB);

        // validate solution
        // validateSolution(intent, solution, preState, received);
    }

    /**
     *  VIEWERS *******************************
     */
    function getState(bool daiForEth) public view returns (State memory state) {
        // @audit-issue can frontrun the tx to invalidate a trade
        // solution: use the state from the previous block via an block state oracle
        if (daiForEth) {
            state = State(dexA.reserve0(), dexA.reserve1(), dexB.reserve0(), dexB.reserve1());
        } else {
            state = State(dexA.reserve1(), dexA.reserve0(), dexB.reserve1(), dexB.reserve0());
        }
    }

    function validateIntent(UserData calldata intent) public view returns (bool daiForEth) {
        // validate signature on relevant arguments. not safe against replay
        bytes32 structHash = keccak256(abi.encode(intent.inToken, intent.outToken, intent.dx, intent.minDy));
        address signer = ECDSA.recover(structHash, intent.signature);
        if (signer != owner) {
            revert("invalid signature");
        }

        // validate token arguments
        require(
            intent.inToken == weth && intent.outToken == dai || intent.inToken == dai && intent.outToken == weth,
            "unsupported pair"
        );

        return intent.inToken == dai;
    }

    function validateSolution(
        UserData calldata intent,
        Solution calldata solution,
        State memory s,
        Received memory received
    ) public view {
        // validate token arguments
        require(solution.dxA + solution.dxB == intent.dx, "dx mismatch");

        // public signals are of the form
        // 1 , xA, yA, xB, yB, dxA, dyA, dxB, dyB;
        uint256[9] memory pubSignals =
            [1, s.xA, s.yA, s.xB, s.yB, solution.dxA, received.dyA, solution.dxB, received.dyB];
        require(verifier.verifyProof(solution._pA, solution._pB, solution._pC, pubSignals), "proof failed");
    }

    error ReturnReceived(Received received);

    function simulateExecution(UserData calldata intent, Solution calldata solution)
        public
        returns (Received memory _received)
    {
        Received memory received = executeIntent(intent, solution.dxA, solution.dxB);
        revert ReturnReceived(received);
    }
}
