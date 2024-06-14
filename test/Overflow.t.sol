// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/src/Test.sol";
import {Marketplace} from "../src/Marketplace.sol";

contract OverflowTest is Test {
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

    function testOverflow() public {
        uint256 largeValue = type(uint256).max;
        uint256 smallValue = 1;

        // Attempt to cause overflow
        vm.prank(employer);
        vm.expectRevert();
        unchecked {
            marketplace.sendContract{value: largeValue + smallValue}(
                freelancer,
                10
            );
        }

        // Attempt to cause underflow
        vm.prank(employer);
        vm.expectRevert();
        unchecked {
            marketplace.sendContract{value: smallValue - largeValue}(
                freelancer,
                10
            );
        }
    }
}
