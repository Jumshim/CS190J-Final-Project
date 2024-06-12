// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Marketplace} from "../src/Marketplace.sol";
import {ContractStruct} from "../src/ContractStruct.sol";

contract MarketplaceTest is Test {
    Marketplace public marketplace;

    address public employer = address(0x1);
    address public freelancer = address(0x2);
    address public escrow = address(0x3);

    function setUp() public {
        marketplace = new Marketplace();

        vm.deal(employer, 1000 ether);
        vm.deal(freelancer, 1000 ether);
        vm.deal(escrow, 1000 ether);
    }

    function testRegisterAsEmployer() public {
        vm.prank(employer);
        marketplace.registerAsEmployer();
        Marketplace.AccountType accountType = marketplace.accounts(employer);
        assertEq(uint(accountType), uint(Marketplace.AccountType.Employer), "Account type should be Employer");
    }

    function testRegisterAsFreelancer() public {
        vm.prank(freelancer);
        marketplace.registerAsFreelancer();
        Marketplace.AccountType accountType = marketplace.accounts(freelancer);
        assertEq(uint(accountType), uint(Marketplace.AccountType.Freelancer), "Account type should be Freelancer");
    }

    function testRegisterAsEscrow() public {
        vm.prank(escrow);
        marketplace.registerAsEscrow();
        Marketplace.AccountType accountType = marketplace.accounts(escrow);
        assertEq(uint(accountType), uint(Marketplace.AccountType.Escrow), "Account type should be Escrow");
    }

    function testSendContract() public {
        vm.prank(employer);
        marketplace.registerAsEmployer();

        vm.prank(freelancer);
        marketplace.registerAsFreelancer();

        vm.prank(employer);
        marketplace.sendContract{value: 5 ether}(freelancer, 1650938400);

        ContractStruct.JobContract memory jobContract = marketplace.viewContract(0);

        assertEq(jobContract.employer, employer, "Employer address mismatch");
        assertEq(jobContract.freelancer, freelancer, "Freelancer address mismatch");
        assertEq(jobContract.value, 5 ether, "Contract value mismatch");
        assertEq(uint(jobContract.status), uint(ContractStruct.Status.Created), "Contract status should be Created");
    }

    function testAcceptContract() public {
        vm.prank(employer);
        marketplace.registerAsEmployer();

        vm.prank(freelancer);
        marketplace.registerAsFreelancer();

        vm.prank(employer);
        marketplace.sendContract{value: 5 ether}(freelancer, 1650938400);

        vm.prank(freelancer);
        marketplace.acceptContract(0);

        ContractStruct.JobContract memory jobContract = marketplace.viewContract(0);

        assertEq(uint(jobContract.status), uint(ContractStruct.Status.Accepted), "Contract status should be Accepted");
    }

    function testSatisfyContract() public {
        vm.prank(employer);
        marketplace.registerAsEmployer();

        vm.prank(freelancer);
        marketplace.registerAsFreelancer();

        vm.prank(employer);
        marketplace.sendContract{value: 5 ether}(freelancer, 1650938400);

        vm.prank(freelancer);
        marketplace.acceptContract(0);

        uint256 balanceBefore = freelancer.balance;
        vm.prank(freelancer);
        marketplace.satisfyContract(0);
        uint256 balanceAfter = freelancer.balance;

        ContractStruct.JobContract memory jobContract = marketplace.viewContract(0);

        assertEq(uint(jobContract.status), uint(ContractStruct.Status.Completed), "Contract status should be Completed");
        assertEq(balanceAfter, balanceBefore + 5 ether, "Freelancer balance mismatch");
    }
}
