// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "safe-contracts/contracts/Safe.sol";
import {ISafeProtocolManager} from "safe-core-protocol/contracts/interfaces/Manager.sol";

interface ISafeManager is ISafeProtocolManager {
    function enablePlugin(address plugin, bool allowRootAccess) external;
    function registry() external view returns (address);
}

contract DeployManager is Safe {
    function deployEnableModule(address module) public {
        // Module address cannot be null or sentinel.
        require(module != address(0) && module != SENTINEL_MODULES, "GS101");
        // Module cannot be added twice.
        require(modules[module] == address(0), "GS102");
        modules[module] = modules[SENTINEL_MODULES];
        modules[SENTINEL_MODULES] = module;
        emit EnabledModule(module);        
    }

    function enablePlugins(ISafeManager manager, address plugin ) public returns (bool) {
        deployEnableModule(address(manager));
        manager.enablePlugin(plugin, false);
        return true;
    }
}
