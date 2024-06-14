// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/src/Test.sol";
import {Marketplace} from "../src/Marketplace.sol";
import {ContractStruct} from "../src/ContractStruct.sol";

contract BlockTimestampManipTest is Test {
    Marketplace public marketplace;

    address public employer = address(0x1);
    address public freelancer = address(0x2);
    address public escrow = address(0x3);

    function setUp() public {
        marketplace = new Marketplace(escrow);

        vm.deal(employer, 1000 ether);
        vm.deal(freelancer, 1000 ether);
        vm.deal(escrow, 10000 ether); // Ensure escrow account has sufficient funds
    }

    function testBlockTimestampManipulation() public {
        // Register employer and freelancer
        vm.prank(employer);
        marketplace.registerAsEmployer();
        vm.prank(freelancer);
        marketplace.registerAsFreelancer();

        // Send a contract
        vm.prank(employer);
        marketplace.sendContract{value: 5 ether}(freelancer, 1); // 1 day

        // Warp time forward to just before the deadline
        vm.warp(block.timestamp + 1 days - 1);

        // Try to expire the contract
        vm.prank(escrow);
        (uint256[] memory toRefund, uint256[] memory toPayout) = marketplace
            .checkContracts();

        assertEq(toRefund.length, 0, "No contracts should be expired yet");

        // Warp time forward to just after the deadline
        vm.warp(block.timestamp + 2);

        // Check again
        vm.prank(escrow);
        (toRefund, toPayout) = marketplace.checkContracts();

        assertEq(
            toRefund.length,
            1,
            "One contract should be expired and marked for refund"
        );

        ContractStruct.JobContract memory jobContract = marketplace
            .viewContract(0);
        assertEq(
            uint(jobContract.status),
            uint(ContractStruct.Status.Rejected),
            "Contract status should be Rejected"
        );
    }
}
