//SPDX-License-Identifier:MIT

pragma solidity ^0.8.30;
import {Script} from "forge-std/Script.sol";
import {Voucher} from "../src/Voucher.sol";


contract DeployVoucher is Script {
    function run () external {
        vm.startBroadcast();
        Voucher voucher = new Voucher();
        vm.stopBroadcast();
    }
}