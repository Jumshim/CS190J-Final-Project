// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/src/Test.sol";
import {Marketplace} from "../src/Marketplace.sol";
import {ContractStruct} from "../src/ContractStruct.sol";

contract DoSTest is Test {
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

    function testAddManyContracts() public {
        vm.prank(employer);
        marketplace.registerAsEmployer();

        vm.prank(freelancer);
        marketplace.registerAsFreelancer();

        uint256 numContracts = 1000;

        for (uint256 i = 0; i < numContracts; i++) {
            vm.prank(employer);
            marketplace.sendContract{value: 1 ether}(freelancer, 10);
        }

        // Verify the last contract was added
        ContractStruct.JobContract memory jobContract = marketplace
            .viewContract(numContracts - 1);
        assertEq(
            jobContract.employer,
            employer,
            "Employer address mismatch for the last contract"
        );
        assertEq(
            jobContract.freelancer,
            freelancer,
            "Freelancer address mismatch for the last contract"
        );
        assertEq(
            jobContract.value,
            1 ether,
            "Contract value mismatch for the last contract"
        );
    }
}
