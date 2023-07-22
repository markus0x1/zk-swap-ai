// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "./Constants.sol";

import "../src/DeployManager.sol";
import "../src/Plugin.sol";
import "../src/groth16_verifier.sol";
import {ExecutableMockContract} from "safe-core-protocol-demo/contracts/contracts/Imports.sol";

// reference:
// https://book.getfoundry.sh/tutorials/solidity-scripting

// 1 DEPLOY MOCK CONTRACTS
contract DeployMock is Script {
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.addr(privateKey);

    function run() external {
        vm.startBroadcast(privateKey);

        // deploy
        Token weth = new Token("Wrapped Eth", "WETH");
        Token dai = new Token("Dai Stablecoin", "DAI");
        CPAMM dexA = new CPAMM(address(weth), address(dai));
        CPAMM dexB = new CPAMM(address(weth), address(dai));

        // prepare
        weth.mint(deployer, 1_000e18);
        dai.mint(deployer, 100_000e18);

        weth.approve(address(dexA), type(uint256).max);
        weth.approve(address(dexB), type(uint256).max);
        dai.approve(address(dexA), type(uint256).max);
        dai.approve(address(dexB), type(uint256).max);

        dexA.addLiquidity(90e18, 10_000e18);
        dexB.addLiquidity(100e18, 10_000e18);

        vm.stopBroadcast();

        console.log("address constant WETH_ADDRESS = address(%s);", address(weth));
        console.log("address constant DAI_ADDRESS = address(%s);", address(dai));
        console.log("address constant DEX_A_ADDRESS = address(%s);", address(dexA));
        console.log("address constant DEX_B_ADDRESS = address(%s);", address(dexB));
    }
}

// 1 DEPLOY PLUGIN
contract DeployPlugin is Script {
    // setup
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.addr(privateKey);
    address[] owners = [deployer];

    function run() external {
        (Token weth, Token dai, CPAMM dexA, CPAMM dexB,,,, ISafeManager safeProtocolManager,,,) =
            Constants.getContracts();

        vm.startBroadcast(privateKey);

        // deploy verifier contract
        Groth16Verifier verifier = new Groth16Verifier();
        Plugin plugin = new Plugin(dexA, dexB, address(weth), address(dai), verifier, safeProtocolManager);

        vm.stopBroadcast();

        console.log("address constant VERIFIER = address(%s);", address(verifier));
        console.log("address constant PLUGIN = address(%s);", address(plugin));
    }
}

// 2 DEPLOY SAFE

contract DeploySafe is Script {
    //external dependencies
    uint256 SALT = uint256(keccak256(abi.encode(block.timestamp)));

    // setup
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.addr(privateKey);
    address[] owners = [deployer];

    function run() external {
        (
            Token weth,
            Token dai,
            CPAMM dexA,
            CPAMM dexB,
            Safe impl,
            SafeProxyFactory factory,
            IRegistry registry,
            ISafeManager safeProtocolManager,
            ,
            Plugin plugin,
        ) = Constants.getContracts();

        vm.startBroadcast(privateKey);

        // create safe prpxy
        bytes memory initializer = new bytes(0);
        SafeProxy proxy = factory.createProxyWithNonce(address(impl), initializer, SALT);

        // 3. List the hook
        address aPlugin = address(plugin);
        registry.addIntegration(aPlugin, IntegrationType.Plugin);

        // 1., 2., 4. Deploy a Safe && call enableModule
        DeployManager deploymanager = new DeployManager(IERC20(address(weth)), IERC20(address(dai)), dexA, dexB);
        Safe safe = Safe(payable(proxy));
        safe.setup(
            owners, // signers
            1, // threshold
            address(deploymanager), // to target
            abi.encodeCall(deploymanager.enablePlugins, (safeProtocolManager, aPlugin)), // enableModule
            address(0), // fallbackHandler
            address(0), // paymentToken,
            0, // payment,
            payable(0) // paymentReceiver)
        );

        vm.stopBroadcast();

        console.log("address constant SAFE_ADDRESS = address(%s);", address(safe));
    }
}
