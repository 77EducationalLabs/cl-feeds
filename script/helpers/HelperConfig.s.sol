// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Script, console2 } from "forge-std/Script.sol";
import { Vm } from "forge-std/Vm.sol";

/**
    *@title Configurations Helper
    *@notice Contract to store core information that will be used upon deployments
*/
contract HelperConfig is Script {
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    /**
        *@notice Struct to store base information for deployment
        * Update it with the variables you will need.
    */
    struct NetworkConfig {
        address admin;
        address multisig;
        address employee;
        address dataFeeds;
    }

    ///@notice Magic Number Removal
    uint256 constant LOCAL_CHAIN_ID = 31337;
    ///@notice Update with the chains you plan to use
    uint256 constant BASE_SEPOLIA_CHAIN_ID = 84532;
    uint256 constant SEPOLIA_CHAIN_ID = 11155111;

    ///@notice Local network state variables
    NetworkConfig public s_localNetworkConfig;
    ///@notice store the testnet/mainnet infos
    mapping(uint256 chainId => NetworkConfig) public s_networkConfigs;

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error HelperConfig__InvalidChainId();


    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    constructor() {
        ///@notice initialize Testnet/Mainnet only
        s_networkConfigs[BASE_SEPOLIA_CHAIN_ID] = getSepoliaBaseConfig();
        s_networkConfigs[SEPOLIA_CHAIN_ID] = getSepoliaConfig();
    }

    /**
        *@notice Function to access chain configuration based on `chainId`
    */
    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    /**
        *@notice function to update information based on deployments happening on main scripts
        *@notice it will update base on chainId
    */
    function setConfig(uint256 chainId, NetworkConfig memory networkConfig) public {
        s_networkConfigs[chainId] = networkConfig;
    }

    /**
        *@notice function to query chain information by chainId
        *@notice if it doesn't exist, it will create
    */
    function getConfigByChainId(uint256 _chainId) public returns (NetworkConfig memory) {
        if (_chainId != LOCAL_CHAIN_ID) {
            return s_networkConfigs[_chainId];
            ///@notice check for a specific part of your protocol that will not break the rest of the conditionals
        } else if(s_networkConfigs[_chainId].dataFeeds != address(0)) {
            return s_networkConfigs[_chainId];
        } else if (_chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getSepoliaConfig() public view returns (NetworkConfig memory sepoliaNetworkConfig) {
        ///@notice update the values with the real values from the main network
        sepoliaNetworkConfig = NetworkConfig({
            ///@notice vm.envAddress("NAME_OF_THE_VARIABLE_ON_.ENV_FILE")
            admin: vm.envAddress("ADMIN_TESTNET_PUBLIC_KEY"), 
            multisig: address(0),
            employee: 0x430d63511142f22534eAda6C50B5d183771F2390,
            dataFeeds: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
    }

    function getSepoliaBaseConfig() public view returns (NetworkConfig memory sepoliaBaseNetworkConfig) {
        ///@notice update the values with the real values from the test network
        sepoliaBaseNetworkConfig = NetworkConfig({
            ///@notice vm.envAddress("NAME_OF_THE_VARIABLE_ON_.ENV_FILE")
            admin: vm.envAddress("ADMIN_TESTNET_PUBLIC_KEY"),
            multisig: address(0),
            employee: address(0),
            dataFeeds: address(0)
        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {

        ///@notice deploy mocks, if need. Like: Chainlink Routers, Feeds, etc.
        ///@notice add the deployed mock on the above config before calling it.
        s_localNetworkConfig = NetworkConfig({
            ///@notice you can create address like this, on you testing. So you can use this params
            admin: address(77),
            multisig: address(777),
            employee: address(2),
            dataFeeds: address(0) //need to deploy a mock to simulate it
        });

        return s_localNetworkConfig;
    }
}