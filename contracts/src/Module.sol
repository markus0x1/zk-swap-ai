// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "safe-core-protocol-demo/contracts/contracts/Plugins.sol";
import "./CPAMM.sol";
import "./Token.sol";
import "./groth16_verifier.sol";


contract ZkTrader is RelayPlugin {
    Groth16Verifier immutable verifier;
    CPAMM immutable dexA;
    CPAMM immutable dexB;
    address immutable weth;
    address immutable dai;
    address immutable owner;

    constructor(CPAMM _dexA, CPAMM _dexB, address _weth, address _dai, Groth16Verifier _verifier) {
        dexA = _dexA;
        dexB = _dexB;
        weth = _weth;
        dai = _dai;
        verifier = _verifier;
        owner = msg.sender;
    }

    struct State {
        uint256 xA;
        uint256 yA;
        uint256 xB;
        uint256 yB;
    }

    function getState(bool daiForEth) public view returns (State memory state) {
        // @audit-issue can frontrun the tx to invalidate a trade
        // solution: use the state from the previous block via an block state oracle
        if (daiForEth) {
            state = State(dexA.reserve0(), dexA.reserve1(), dexB.reserve0(), dexB.reserve1());
        } else {
            state = State(dexA.reserve1(), dexA.reserve0(), dexB.reserve1(), dexB.reserve0());
        }
    }

    struct UserData {
        address inToken;
        address outToken;
        uint256 dx;
        uint256 minDy;
        bytes signature;
    }

    struct Solution {
        uint256 dxA;
        uint256 dxB;
        uint256[2] _pA;
        uint256[2][2] _pB;
        uint256[2] _pC;
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

    struct Received {
        uint256 dyA;
        uint256 dyB;
    }

    function _executeIntent(UserData calldata intent, Solution calldata solution)
        internal
        returns (Received memory received)
    {
        uint256 dyA = solution.dxA > 0 ? dexA.swap(intent.inToken, solution.dxA) : 0;
        uint256 dyB = solution.dxB > 0 ? dexB.swap(intent.inToken, solution.dxB) : 0;
        require(dyA + dyB >= intent.minDy, "min dy");
        received = Received(dyA, dyB);
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

    function tradeWithIntent(UserData calldata intent, Solution calldata solution) public {
        // validate intent
        bool daiForEth = validateIntent(intent);

        // pre state
        State memory preState = getState(daiForEth);

        // execute intent
        Received memory received = _executeIntent(intent, solution);

        // validate solution
        validateSolution(intent, solution, preState, received);
    }

    // utils
    error ReturnReceived(Received received);

    function simulateExecution(UserData calldata intent, Solution calldata solution)
        public
        returns (Received memory _received)
    {
        Received memory received = _executeIntent(intent, solution);
        revert ReturnReceived(received);
    }
}
