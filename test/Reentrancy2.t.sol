// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/src/Test.sol";
import {Marketplace} from "../src/Marketplace.sol";
import {ContractStruct} from "../src/ContractStruct.sol";

contract Reentrancy2Test is Test {
    Marketplace public marketplace;

    address public employer = address(0x1);
    address public freelancer = address(0x2);
    address public escrow = address(0x3);
    address public attacker = address(0x4);

    function setUp() public {
        marketplace = new Marketplace(escrow);

        vm.deal(employer, 1000 ether);
        vm.deal(freelancer, 1000 ether);
        vm.deal(escrow, 10000 ether); // Ensure escrow account has sufficient funds
        vm.deal(attacker, 1000 ether); // Fund the attacker account
    }

    function testReentrancyAttackDuringAcceptContract() public {
        // Register employer and freelancer
        vm.prank(employer);
        marketplace.registerAsEmployer();
        vm.prank(freelancer);
        marketplace.registerAsFreelancer();

        // Send a contract
        vm.prank(employer);
        marketplace.sendContract{value: 5 ether}(freelancer, 10); // 10 days

        // Deploy malicious contract
        MaliciousContract2 malicious = new MaliciousContract2(
            address(marketplace)
        );

        // Attempt reentrancy attack during contract acceptance
        vm.prank(attacker);
        vm.expectRevert();
        malicious.attackAcceptContract(0);
    }
}

contract MaliciousContract2 {
    Marketplace public marketplace;
    address public owner;

    constructor(address _marketplace) {
        marketplace = Marketplace(_marketplace);
        owner = msg.sender;
    }

    // Function to receive Ether during reentrancy attack
    receive() external payable {
        if (address(marketplace).balance > 0) {
            marketplace.acceptContract(0); // Reentrancy attempt
        }
    }

    // Function to start the attack
    function attackAcceptContract(uint256 _contractId) external {
        marketplace.acceptContract(_contractId); // Initial call to trigger reentrancy
    }
}
