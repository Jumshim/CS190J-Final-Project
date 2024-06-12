// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Marketplace} from "../src/Marketplace.sol";
import {ContractStruct} from "../src/ContractStruct.sol";

contract Reentrancy1Test is Test {
    Marketplace public marketplace;

    address public employer = address(0x1);
    address public freelancer = address(0x2);
    address public escrow = address(0x3);
    address public attacker = address(0x4);

    function setUp() public {
        marketplace = new Marketplace(escrow);

        vm.deal(employer, 1000 ether);
        vm.deal(freelancer, 1000 ether);
        vm.deal(escrow, 10000 ether);  // Ensure escrow account has sufficient funds
        vm.deal(attacker, 1000 ether);  // Fund the attacker account
    }

    function testReentrancyAttack() public {
        // Register employer and freelancer
        vm.prank(employer);
        marketplace.registerAsEmployer();
        vm.prank(freelancer);
        marketplace.registerAsFreelancer();

        // Send a contract
        vm.prank(employer);
        marketplace.sendContract{value: 5 ether}(freelancer, 1); // 1 day

        // Accept the contract
        vm.prank(freelancer);
        marketplace.acceptContract(0);

        // Warp time to make the contract expire
        vm.warp(block.timestamp + 2 days);

        // Deploy malicious contract
        MaliciousContract malicious = new MaliciousContract(address(marketplace));

        // Attempt reentrancy attack during escrow check
        vm.prank(attacker);
        vm.expectRevert();
        malicious.attack();
    }
}

contract MaliciousContract {
    Marketplace public marketplace;
    address public owner;

    constructor(address _marketplace) {
        marketplace = Marketplace(_marketplace);
        owner = msg.sender;
    }

    // Function to receive Ether during reentrancy attack
    receive() external payable {
        if (address(marketplace).balance > 0) {
            marketplace.checkContracts(); // Reentrancy attempt
        }
    }

    // Function to start the attack
    function attack() external {
        marketplace.checkContracts(); // Initial call to trigger reentrancy
    }
}
