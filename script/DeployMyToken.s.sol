// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script,console2} from "forge-std/Script.sol";
import {MyToken} from "../src/MyToken.sol";
contract DeployMyToken is Script{
    uint256 public constant INITIAL_SUPPLY = 1_000_000 ether; // 1 million tokens with 18 decimal places
    function run() external returns (MyToken){
        vm.startBroadcast();
        MyToken token = new MyToken(INITIAL_SUPPLY);
        vm.stopBroadcast();
        return (token);
    }
}