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
    address constant WETH_ADDRESS = address(0xB1a5A5053c6C5BC2dC2887C1dcACF5a967f3A7D7);
    address constant DAI_ADDRESS = address(0xf041eCF7fef85b5AE2F5f4c8C674293Ee087E30A);
    address constant DEX_A_ADDRESS = address(0x090d1f489d873dd2E4a496a43094C0C354B43AD7);
    address constant DEX_B_ADDRESS = address(0x91B6E90292Eb74cbC970547CD49EE356221e0652);

    // safe contracts
    address constant VERIFIER = address(0xeE4E2545928b564a28DcEa68BE629FE88f43B18E);
    address constant PLUGIN = address(0x327Dce0E5b5BBb7cF9e3A7865005714479A41Ed8);
    address constant SAFE_ADDRESS = address(0x1367D7E411Df11c261e0Dd5a632c2f5d0245A095);    
    
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
