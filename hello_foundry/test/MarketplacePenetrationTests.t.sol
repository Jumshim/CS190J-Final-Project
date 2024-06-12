// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Marketplace} from "../src/Marketplace.sol";
import {SelfDestructAttack} from "./attack/SelfDestruct.sol";
import {ReentrancyAttack} from "./attack/Reentrancy.sol";

contract MarketplacePenetrationTests is Test {
    address public owner = address(0x01);
    address public user = address(0x02);
    address public escrow = address(0x03);
    address public freelancer = address(0x04);

    function testSurvivesSelfDestruct() public {
        // Setup
        vm.startPrank(owner);
        Marketplace marketplace = new Marketplace();
        SelfDestructAttack attacker = new SelfDestructAttack();
        vm.stopPrank();

        vm.deal(user, 1 ether);

        // Act
        vm.prank(user);
        attacker.attack(address(marketplace));

        // Assert
        uint256 exists;
        assembly {
            exists := extcodesize(marketplace)
        }
        assertEq(exists, 0, "Contract survived!");
    }

    function testSelfDestructEtherStillValid() public {
        // Setup
        vm.startPrank(owner);
        Marketplace marketplace = new Marketplace();
        SelfDestructAttack attacker = new SelfDestructAttack();
        vm.stopPrank();

        vm.deal(user, 1 ether);

        // Act
        vm.prank(user);
        attacker.attack{value: 1 ether}(payable(address(marketplace)));

        // Assess
        uint256 exists;
        assembly {
            exists := extcodesize(marketplace)
        }
        assertEq(exists, 0, "Contract survived!");

        uint256 balance = address(marketplace).balance;
        assertEq(balance, 1 ether, "Contract did not receive either");
    }

    function testReentrancyAttack() public {
        // Setup
        vm.startPrank(owner);
        Marketplace marketplace = new Marketplace();
        vm.stopPrank();

        vm.startPrank(owner);
        marketplace.registerAsEmployer();
        vm.stopPrank();

        vm.startPrank(user);
        ReentrancyAttack reentrancyAttack = new ReentrancyAttack(
            address(marketplace)
        );
        vm.stopPrank();

        // vm.deal(marketplace, 10 ether);
        vm.deal(user, 1 ether);

        // Act
        vm.prank(user);
        reentrancyAttack.attack{value: 1 ether}();

        // Assert
        uint256 balance = address(marketplace).balance;
        assertEq(balance, 0, "Reentrancy attack did not drain the contract");
        // May need to change 0 to a larger value, and set marketplace with a greater
    }

    function testArithmeticOverflow() public {
        // ??
    }
}
