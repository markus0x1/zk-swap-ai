// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "safe-contracts/contracts/Safe.sol";
import {ISafeProtocolManager} from "safe-core-protocol/contracts/interfaces/Manager.sol";
import "./CPAMM.sol";

interface ISafeManager is ISafeProtocolManager {
    // Events
    event ActionsExecuted(address indexed safe, bytes32 metadataHash, uint256 nonce);
    event RootAccessActionExecuted(address indexed safe, bytes32 metadataHash);
    event PluginEnabled(address indexed safe, address indexed plugin, bool allowRootAccess);
    event PluginDisabled(address indexed safe, address indexed plugin);

    // Errors
    error PluginRequiresRootAccess(address sender);
    error PluginNotEnabled(address plugin);
    error PluginEnabledOnlyForRootAccess(address plugin);
    error PluginAccessMismatch(address plugin, bool requiresRootAccess, bool providedValue);
    error ActionExecutionFailed(address safe, bytes32 metadataHash, uint256 index);
    error RootAccessActionExecutionFailed(address safe, bytes32 metadataHash);
    error PluginAlreadyEnabled(address safe, address plugin);
    error InvalidPluginAddress(address plugin);
    error InvalidPrevPluginAddress(address plugin);
    error ZeroPageSizeNotAllowed();
    error InvalidToFieldInSafeProtocolAction(address safe, bytes32 metadataHash, uint256 index);

    function enablePlugin(address plugin, bool allowRootAccess) external;
    function registry() external view returns (address);
}

contract DeployManager is Safe {
    CPAMM immutable dexA;
    CPAMM immutable dexB;
    IERC20 immutable weth;
    IERC20 immutable dai;

    constructor(IERC20 _weth, IERC20 _dai, CPAMM _dexA, CPAMM _dexB) {
        weth = _weth;
        dai = _dai;
        dexA = _dexA;
        dexB = _dexB;
    }

    function deployEnableModule(address module) public {
        // Module address cannot be null or sentinel.
        require(module != address(0) && module != SENTINEL_MODULES, "GS101");
        // Module cannot be added twice.
        require(modules[module] == address(0), "GS102");
        modules[module] = modules[SENTINEL_MODULES];
        modules[SENTINEL_MODULES] = module;
        emit EnabledModule(module);
    }

    function enablePlugins(ISafeManager manager, address plugin) public returns (bool) {
        deployEnableModule(address(manager));
        manager.enablePlugin(plugin, false);

        weth.approve(address(dexA), type(uint256).max);
        dai.approve(address(dexA), type(uint256).max);
        weth.approve(address(dexB), type(uint256).max);
        weth.approve(address(dexB), type(uint256).max);

        return true;
    }
}
