// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "./Constants.sol";

// https://book.getfoundry.sh/tutorials/solidity-scripting
// anvil
// forge script script/Deploy.s.sol:Deploy --fork-url http://localhost:8545 --broadcast

contract Trade1 is Script {
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.addr(privateKey);

    function run() external {
        vm.startBroadcast(privateKey);

        (Token weth, Token dai, CPAMM dexA, CPAMM dexB, , , ,) = Constants.getContracts();
        uint256 daiOut = dexA.swap(address(weth), 1e18);
        dexB.swap(address(dai), daiOut);

        vm.stopBroadcast();
    }
}

contract Trade2 is Script {
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.addr(privateKey);

    function run() external {
        vm.startBroadcast(privateKey);

        (Token weth, Token dai, CPAMM dexA, CPAMM dexB, , , , ) = Constants.getContracts();

        uint256 ethOut = dexA.swap(address(dai), 1_000e18);
        dexB.swap(address(weth), ethOut);

        vm.stopBroadcast();
    }
}
