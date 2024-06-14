// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/src/Test.sol";
import {Marketplace} from "../src/Marketplace.sol";

contract SelfDestruct2Test is Test {
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

    function testSelfDestructIntoEscrow() public {
        // Deploy a self-destructing contract
        address selfDestructing = address(new SelfDestructing());

        // Fund the self-destructing contract
        vm.deal(selfDestructing, 1 ether);

        // Self-destruct into the escrow account
        SelfDestructing(selfDestructing).destroy(payable(address(escrow)));

        // No specific revert is expected here, but we check for unexpected balance changes or state changes
        uint256 escrowBalance = address(escrow).balance;
        assertEq(
            escrowBalance,
            10001 ether,
            "Escrow account should have 10001 ether from self-destruct"
        );
    }
}

contract SelfDestructing {
    function destroy(address payable recipient) external {
        selfdestruct(recipient);
    }
}
