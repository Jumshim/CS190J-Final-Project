// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/src/Test.sol";
import {Marketplace} from "../src/Marketplace.sol";
import {ContractStruct} from "../src/ContractStruct.sol";

contract Reentrancy3Test is Test {
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

    function testReentrancyAttackDuringSendContract() public {
        // Register employer and freelancer
        vm.prank(employer);
        marketplace.registerAsEmployer();
        vm.prank(freelancer);
        marketplace.registerAsFreelancer();

        // Deploy malicious contract
        MaliciousContract3 malicious = new MaliciousContract3(
            address(marketplace)
        );

        // Attempt reentrancy attack during contract sending
        vm.prank(attacker);
        vm.expectRevert();
        malicious.attackSendContract(freelancer, 10);
    }
}

contract MaliciousContract3 {
    Marketplace public marketplace;
    address public owner;

    constructor(address _marketplace) {
        marketplace = Marketplace(_marketplace);
        owner = msg.sender;
    }

    // Function to receive Ether during reentrancy attack
    receive() external payable {
        if (address(marketplace).balance > 0) {
            marketplace.sendContract{value: 1 ether}(owner, 10); // Reentrancy attempt
        }
    }

    // Function to start the attack
    function attackSendContract(
        address _freelancer,
        uint256 _days
    ) external payable {
        marketplace.sendContract{value: msg.value}(_freelancer, _days); // Initial call to trigger reentrancy
    }
}
