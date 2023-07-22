// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/Token.sol";
import "../src/CPAMM.sol";
import "safe-contracts/contracts/Safe.sol";
import "safe-contracts/contracts/proxies/SafeProxyFactory.sol";
import "safe-contracts/contracts/Safe.sol";
import "../src/DeployManager.sol";
import "../src/Plugin.sol";

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
    // factory contracts
    address constant SAFE_IMPL = address(0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552);
    address constant SAFE_FACTORY = address(0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2);
    address constant REGISTRY_CONTRACT = address(0x3745FA7226c031D9Dd4B2c0ab9cB9fF2378b67Af);
    address constant SAFE_PROTOCOL_MANAGER = address(0xab2E9E1745dFa94054079bCFB7049B1365f92002);

    // mock contracts
    address constant WETH_ADDRESS = address(0x80c44EDDC8273bfc979935566a931849a7f99623);
    address constant DAI_ADDRESS = address(0xb7e045C84F6655752F492Fd0331BfB251aB777B9);
    address constant DEX_A_ADDRESS = address(0xedAEFA74b35DB5aB40F8a79679731B68c6407455);
    address constant DEX_B_ADDRESS = address(0x6C61c9668FAEa7c4bdaD4E72b1090f54aC8A8405);

    // safe contracts
    address constant VERIFIER = address(0xD533fA21a99d250B7D0f81ac4E4B8F489dbDfC01);
    address constant PLUGIN = address(0xecc5d5B29C82d4D91d25aA93177F474bA47e82b5);
    address constant SAFE_ADDRESS = address(0x12E730b6f8FFd9dcAb7F2C7e8b715F1c8F51efF7);

    function getContracts()
        internal
        view
        returns (
            Token weth,
            Token dai,
            CPAMM dexA,
            CPAMM dexB,
            Safe impl,
            SafeProxyFactory factory,
            IRegistry registry,
            ISafeManager manager,
            Safe safe,
            Plugin plugin
        )
    {
        weth = Token(WETH_ADDRESS);
        dai = Token(DAI_ADDRESS);
        dexA = CPAMM(DEX_A_ADDRESS);
        dexB = CPAMM(DEX_B_ADDRESS);
        impl = Safe(payable(SAFE_IMPL));
        factory = SafeProxyFactory(SAFE_FACTORY);
        registry = IRegistry(REGISTRY_CONTRACT);
        manager = ISafeManager(SAFE_PROTOCOL_MANAGER);
        safe = Safe(payable(SAFE_ADDRESS));
        plugin = Plugin(payable(PLUGIN));

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
