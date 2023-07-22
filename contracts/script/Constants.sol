// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/Token.sol";
import "../src/CPAMM.sol";
import "safe-contracts/contracts/Safe.sol";
import "safe-contracts/contracts/proxies/SafeProxyFactory.sol";
import "safe-contracts/contracts/Safe.sol";
import "../src/DeployManager.sol";


import "forge-std/Vm.sol";

enum IntegrationType {
    Plugin,
    Hooks,
    FunctionHandler
}

interface IRegistry {
    function check(address integration) external view returns (uint64 listedAt, uint64 flaggedAt);
    function addIntegration(address integration, IntegrationType integrationType) external;
}


library Constants {
    address constant WETH_ADDRESS = address(0x1684F4DF5e32a946fBbaEb3059353c83Ff075E31);
    address constant DAI_ADDRESS = address(0xDAFA240382BE6e8Fb5b13D1516d3d220Cf5A1622);
    address constant DEX_A_ADDRESS = address(0x2B416973a8F73B2f5acc99A0A6Af7001Cc02efBa);
    address constant DEX_B_ADDRESS = address(0x985d28f8e5834D9b9048CFb39c9F76aaF2cB5bA0);
    address constant SAFE_IMPL = address(0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552);
    address constant SAFE_FACTORY = address(0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2);
    address constant REGISTRY_CONTRACT = address(0x3745FA7226c031D9Dd4B2c0ab9cB9fF2378b67Af);
    address constant SAFE_PROTOCOL_MANAGER = address(0xab2E9E1745dFa94054079bCFB7049B1365f92002);
    address constant SAFE_ADDRESS = address(0xF34f2AC034cC16d31f0EAe2c05E69359579032fa);
    address constant MODULE = address(0x1911B66711161807bD6E0078364Bf04Ac60F7b95);
    
    function getContracts()
        internal
        view
        returns (Token weth, Token dai, CPAMM dexA, CPAMM dexB, Safe impl, SafeProxyFactory factory, IRegistry registry ,ISafeManager manager, Safe safe )
    {
        weth = Token(WETH_ADDRESS);
        dai = Token(DAI_ADDRESS);
        dexA = CPAMM(DEX_A_ADDRESS);
        dexB = CPAMM(DEX_B_ADDRESS);
        impl = Safe(payable(SAFE_IMPL));
        factory = SafeProxyFactory(SAFE_FACTORY);
        registry = IRegistry(REGISTRY_CONTRACT);
        manager = ISafeManager(address(0xab2E9E1745dFa94054079bCFB7049B1365f92002));
        safe = Safe(payable(SAFE_ADDRESS));


        require(isContract(address(weth)), "WETH is not a contract");
        require(isContract(address(dai)), "DAI is not a contract");
        require(isContract(address(dexA)), "DEX A is not a contract");
        require(isContract(address(dexB)), "DEX B is not a contract");
        require(isContract(address(impl)), "Safe is not a contract");
        require(isContract(address(factory)), "Factory is not a contract");
    }

    function isContract(address _addr) private view returns (bool) {
        require(address(_addr) != address(0), "WETH address is zero");
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }
}
