// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "./Constants.sol";
import "../src/Plugin.sol";
import "../src/groth16_verifier.sol";

// https://book.getfoundry.sh/tutorials/solidity-scripting
// anvil
// forge script script/Deploy.s.sol:Deploy --fork-url http://localhost:8545 --broadcast

contract Trade1 is Script {
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.addr(privateKey);

    function run() external {
        vm.startBroadcast(privateKey);

        (Token weth, Token dai, CPAMM dexA, CPAMM dexB,,,,,,,) = Constants.getContracts();
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

        (Token weth, Token dai,,,,,,, Safe safe,,) = Constants.getContracts();

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

        (Token weth, Token dai, CPAMM dexA, CPAMM dexB,,,,,,,) = Constants.getContracts();

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

        (Token weth, Token dai,,,,,,, Safe safe, Plugin plugin,) = Constants.getContracts();

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

contract VerifyProof is Script {
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.addr(privateKey);

    function run() external {
        vm.startBroadcast(privateKey);

        (,,,,,,,,,, Groth16Verifier verifier) = Constants.getContracts();

        uint256[2] memory _pA = [
            20836310258634364044365197857521970082021831843525405728573281059330301158915,
            4219407202856264169898296985642612540218684612147463453069245220663837202596
        ];
        uint256[2][2] memory _pB = [
            [
                1613000024070446628165457792202849578598821094045497048785316705224224629772,
                1463796399586782453813903429453191485933656699378358257568221470067023580211
            ],
            [
                2175511442034818313303054381053422453464861741302068833918391880555761080463,
                13592063895482381862064758204473000159528446757996051001130033797524237001298
            ]
        ];

        uint256[2] memory _pC = [
            7523008592258599487055925238262603394612478052933551206115597681835456670576,
            20455956501749758701240592410210298585090951733949832144024866257378409126099
        ];
        uint256[9] memory _pubSignals = [
            uint256(1),
            uint256(10000),
            uint256(10),
            uint256(15000),
            uint256(10),
            uint256(1000),
            uint256(1),
            uint256(0),
            uint256(0)
        ];

        require(verifier.verifyProof(_pA, _pB, _pC, _pubSignals), "failed proof");

        // verifier
        vm.stopBroadcast();
    }
}
