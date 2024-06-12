// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Marketplace} from "../src/Marketplace.sol";
import {ContractStruct} from "../src/ContractStruct.sol";

contract FrontrunningTest is Test {
    Marketplace public marketplace;

    address public employer = address(0x1);
    address public freelancer = address(0x2);
    address public frontrunner = address(0x4);

    function setUp() public {
        marketplace = new Marketplace(address(0x3));  // Escrow address

        vm.deal(employer, 1000 ether);
        vm.deal(freelancer, 1000 ether);
        vm.deal(frontrunner, 1000 ether);
    }

    function testFrontrunning() public {
        // Register employer and freelancer
        vm.prank(employer);
        marketplace.registerAsEmployer();
        vm.prank(freelancer);
        marketplace.registerAsFreelancer();

        // Send a contract
        vm.prank(employer);
        marketplace.sendContract{value: 5 ether}(freelancer, 10); // 10 days

        // Accept the contract
        vm.prank(freelancer);
        marketplace.acceptContract(0);

        // Frontrunner tries to manipulate the contract
        vm.prank(frontrunner);
        vm.expectRevert();  // Expect revert since the frontrunner shouldn't be able to manipulate contract acceptance or satisfaction
        marketplace.acceptContract(0);

        // Verify freelancer can complete the contract correctly
        vm.prank(freelancer);
        marketplace.freelancerSatisfyContract(0);

        vm.prank(employer);
        marketplace.employerSatisfyContract(0);

        ContractStruct.JobContract memory jobContract = marketplace.viewContract(0);
        assertEq(uint(jobContract.status), uint(ContractStruct.Status.Completed), "Contract status should be Completed");
    }
}
