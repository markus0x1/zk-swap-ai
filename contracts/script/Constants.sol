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
    // factory contracts (on gnosis chain!!!)
    address constant SAFE_IMPL = address(0x41675C099F32341bf84BFc5382aF534df5C7461a);
    address constant SAFE_FACTORY = address(0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67);
    address constant REGISTRY_CONTRACT = address(0xDecaE7fF9355417Ceb65603730527812E5b76Cb4);
    address constant SAFE_PROTOCOL_MANAGER = address(0x1f6d70F4e71e95D68D61D89e6E13ed4091b980a5);

    // mock contracts
    address constant WETH_ADDRESS = address(0x320ef4c3b08E55ba0836db61Ee90E0064e151e16);
    address constant DAI_ADDRESS = address(0xb9B1a58F222bAD3f3ce57B1Ca2Bf6542D385464C);
    address constant DEX_A_ADDRESS = address(0x3e07e4EaB2e1D43083ba8C097ac72a282bc506D6);
    address constant DEX_B_ADDRESS = address(0x98D52889180a164b90e36C02a912eCFaC5E512F5);

    // safe contracts
    address constant VERIFIER = address(0xB93487089afA862b9249bA637595d5c01ea8ece2);
    address constant PLUGIN = address(0x1f0d1D6C2077BC4dF72cC06C043e6Efd3dd86780);
    address constant SAFE_ADDRESS = address(0x18e62d71d54ACbA0C3B3159389cc699147fE55cb);
    
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
            Plugin plugin,
            Groth16Verifier verifier
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
        verifier = Groth16Verifier(VERIFIER);

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
