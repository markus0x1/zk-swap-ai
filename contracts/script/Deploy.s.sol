// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "./Constants.sol";

import "../src/DeployManager.sol";
import {ExecutableMockContract} from "safe-core-protocol-demo/contracts/contracts/Imports.sol";

// reference:
// https://book.getfoundry.sh/tutorials/solidity-scripting

    
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

        dexA.addLiquidity(100e18, 10_000e18);
        dexB.addLiquidity(100e18, 10_000e18);

        vm.stopBroadcast();

        console.log("address constant WETH_ADDRESS = address(%s);", address(weth));
        console.log("address constant DAI_ADDRESS = address(%s);", address(dai));
        console.log("address constant DEX_A_ADDRESS = address(%s);", address(dexA));
        console.log("address constant DEX_B_ADDRESS = address(%s);", address(dexB));
    }
}


contract DeploySafe is Script {
    //external dependencies
    uint256 constant SALT = 4564456456864564856;
 
    // setup 
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.addr(privateKey);
    address[] owners = [deployer];

    function run() external {
        (,,,, Safe impl, SafeProxyFactory factory, IRegistry registry ,ISafeManager safeProtocolManager ) = Constants.getContracts();
 
        vm.startBroadcast(privateKey);

        // deploy plugin
        address mockPlugin = address(new ExecutableMockContract());
        registry.addIntegration(mockPlugin, IntegrationType.Plugin);

        // create safe prpxy
        bytes memory initializer = new bytes(0);
        SafeProxy proxy = factory.createProxyWithNonce(address(impl), initializer, SALT);

        // setup safe
        DeployManager deploymanager = new DeployManager();
        Safe safe = Safe(payable(proxy));
        safe.setup(
            owners, // signers
            1, // threshold
            address(deploymanager), // to target
            abi.encodeCall(deploymanager.enablePlugins, (safeProtocolManager, mockPlugin)), // enableModule
            address(0), // fallbackHandler
            address(0), // paymentToken,
            0, // payment,
            payable(0) // paymentReceiver)
        );

        vm.stopBroadcast();

        console.log("address constant SAFE_ADDRESS = address(%s);", address(safe));

    }
}
