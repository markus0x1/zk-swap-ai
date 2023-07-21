// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/Token.sol";
import "../src/CPAMM.sol";

import "forge-std/Vm.sol";

library Constants {
    address constant WETH_ADDRESS = address(0x1684F4DF5e32a946fBbaEb3059353c83Ff075E31);
    address constant DAI_ADDRESS = address(0xDAFA240382BE6e8Fb5b13D1516d3d220Cf5A1622);
    address constant DEX_A_ADDRESS = address(0x2B416973a8F73B2f5acc99A0A6Af7001Cc02efBa);
    address constant DEX_B_ADDRESS = address(0x985d28f8e5834D9b9048CFb39c9F76aaF2cB5bA0);

    function getContracts() internal view returns (Token weth, Token dai, CPAMM dexA, CPAMM dexB) {
        weth = Token(WETH_ADDRESS);
        dai = Token(DAI_ADDRESS);
        dexA = CPAMM(DEX_A_ADDRESS);
        dexB = CPAMM(DEX_B_ADDRESS);

        require(address(weth) != address(0), "WETH address is zero");
        require(address(dai) != address(0), "DAI address is zero");
        require(address(dexA) != address(0), "DEX A address is zero");
        require(address(dexB) != address(0), "DEX B address is zero");

        require(isContract(address(weth)), "WETH is not a contract");
        require(isContract(address(dai)), "DAI is not a contract");
        require(isContract(address(dexA)), "DEX A is not a contract");
        require(isContract(address(dexB)), "DEX B is not a contract");
    }

    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }
}
