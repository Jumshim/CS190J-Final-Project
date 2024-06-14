// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/src/Test.sol";
import {Marketplace} from "../src/Marketplace.sol";
import {ContractStruct} from "../src/ContractStruct.sol";

contract AccessControlTest is Test {
    Marketplace public marketplace;

    address public employer = address(0x1);
    address public freelancer = address(0x2);
    address public unauthorized = address(0x4);
    address public escrow = address(0x3);

    function setUp() public {
        marketplace = new Marketplace(escrow);

        vm.deal(employer, 1000 ether);
        vm.deal(freelancer, 1000 ether);
        vm.deal(unauthorized, 1000 ether);
        vm.deal(escrow, 10000 ether); // Ensure escrow account has sufficient funds
    }

    function testUnauthorizedSendContract() public {
        // Register employer and freelancer
        vm.prank(employer);
        marketplace.registerAsEmployer();

        vm.prank(freelancer);
        marketplace.registerAsFreelancer();

        // Attempt to send a contract from an unauthorized address
        vm.prank(unauthorized);
        vm.expectRevert("Only employers can send contracts");
        marketplace.sendContract{value: 5 ether}(freelancer, 10); // 10 days
    }

    function testUnauthorizedCheckContracts() public {
        // Register employer and freelancer
        vm.prank(employer);
        marketplace.registerAsEmployer();

        vm.prank(freelancer);
        marketplace.registerAsFreelancer();

        // Send a contract
        vm.prank(employer);
        marketplace.sendContract{value: 5 ether}(freelancer, 10); // 10 days

        // Attempt to check contracts from an unauthorized address
        vm.prank(unauthorized);
        vm.expectRevert("Only the escrow account can call this function");
        marketplace.checkContracts();
    }
}
