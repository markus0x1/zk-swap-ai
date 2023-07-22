// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "./Constants.sol";
import "../src/Plugin.sol";

// https://book.getfoundry.sh/tutorials/solidity-scripting
// anvil
// forge script script/Deploy.s.sol:Deploy --fork-url http://localhost:8545 --broadcast

contract Trade1 is Script {
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.addr(privateKey);

    function run() external {
        vm.startBroadcast(privateKey);

        (Token weth, Token dai, CPAMM dexA, CPAMM dexB,,,,,,) = Constants.getContracts();
        uint256 daiOut = dexA.swap(address(weth), 1e18);
        dexB.swap(address(dai), daiOut);

        vm.stopBroadcast();
    }
}

contract Mint is Script {
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.addr(privateKey);

    function run() external {
        vm.startBroadcast(privateKey);

        (Token weth, Token dai,,,,,,, Safe safe,) = Constants.getContracts();

        weth.mint(address(safe), 1_000e18);
        dai.mint(address(safe), 100_000e18);

        vm.stopBroadcast();
    }
}

contract Trade2 is Script {
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.addr(privateKey);

    function run() external {
        vm.startBroadcast(privateKey);

        (Token weth, Token dai, CPAMM dexA, CPAMM dexB,,,,,,) = Constants.getContracts();

        uint256 ethOut = dexA.swap(address(dai), 1_000e18);
        dexB.swap(address(weth), ethOut);

        vm.stopBroadcast();
    }
}

contract TradeIntent is Script {
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.addr(privateKey);

    function run() external {
        vm.startBroadcast(privateKey);

        (Token weth, Token dai,,,,,,, Safe safe, Plugin plugin) = Constants.getContracts();

        // vm.sign(spenderPrivateKey, digest);
        Plugin.UserData memory intent = Plugin.UserData({
            safe: ISafe(address(safe)),
            inToken: address(weth),
            outToken: address(dai),
            dx: 1e18,
            minDy: 1e18,
            nonce: 0,
            signature: bytes("") // todo: verify signatures
        });

        Plugin.Solution memory solution = Plugin.Solution({
            dxA: 1e18,
            dxB: 0,
            _pA: [
                3993751688615872534373337630453297756478321619160500648136349198203275519167,
                8584110642634779619545547968659167718332505614253301785067671669771642131340
            ],
            _pB: [
                [
                    7230224512238358857357839997801890056083077953974333728884275160377353162701,
                    13216692223818468102201200019143294358321540894747571114913840477285067306918
                ],
                [
                    4499649094932395313491033912183848902416480744767733726531283257959567362062,
                    12301186710163432270342675719237504003754813836951115842892197755431494034613
                ]
            ],
            _pC: [
                5017159971739915853389176512635513006051127634560316982090271143776976333111,
                2331706596664733946788574123193317153091591945326340438613374689851394836004
            ]
        });

        plugin.tradeWithIntent(intent, solution);

        vm.stopBroadcast();
    }
}
