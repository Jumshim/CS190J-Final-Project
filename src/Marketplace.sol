// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ContractStruct.sol";

contract Marketplace {
    enum AccountType {
        None,
        Employer,
        Freelancer,
        Escrow
    }

    mapping(address => AccountType) public accounts;
    mapping(uint256 => ContractStruct.JobContract) private jobContracts;
    uint256 private contractCount;

    function registerAsEmployer() external {
        require(
            accounts[msg.sender] == AccountType.None,
            "Already registered as another role"
        );
        accounts[msg.sender] = AccountType.Employer;
    }

    function registerAsFreelancer() external {
        require(
            accounts[msg.sender] == AccountType.None,
            "Already registered as another role"
        );
        accounts[msg.sender] = AccountType.Freelancer;
    }

    function registerAsEscrow() external {
        require(
            accounts[msg.sender] == AccountType.None,
            "Already registered as another role"
        );
        accounts[msg.sender] = AccountType.Escrow;
    }

    function sendContract(
        address _freelancer,
        uint256 _deadlineDate
    ) external payable {
        require(
            accounts[msg.sender] == AccountType.Employer,
            "Only employers can send contracts"
        );
        require(
            accounts[_freelancer] == AccountType.Freelancer,
            "Can only send contracts to freelancers"
        );
        require(msg.value > 0, "Must send ether to fund the contract");
        uint256 contractId = contractCount++;
        jobContracts[contractId] = ContractStruct.JobContract({
            id: contractId,
            value: msg.value,
            dateAssigned: block.timestamp,
            deadlineDate: _deadlineDate,
            employer: msg.sender,
            freelancer: _freelancer,
            status: ContractStruct.Status.Created
        });
    }

    function acceptContract(uint256 _contractId) external {
        ContractStruct.JobContract storage jobContract = jobContracts[
            _contractId
        ];
        require(
            msg.sender == jobContract.freelancer,
            "Only the assigned freelancer can accept this contract"
        );
        require(
            jobContract.status == ContractStruct.Status.Created,
            "Contract is not in a valid state for acceptance"
        );
        jobContract.status = ContractStruct.Status.Accepted;
    }

    function rejectContract(uint256 _contractId) external {
        ContractStruct.JobContract storage jobContract = jobContracts[
            _contractId
        ];
        require(
            msg.sender == jobContract.freelancer,
            "Only the assigned freelancer can reject this contract"
        );
        require(
            jobContract.status == ContractStruct.Status.Created,
            "Contract is not in a valid state for rejection"
        );
        jobContract.status = ContractStruct.Status.Rejected;
        // Refund the contract value to the employer
        payable(jobContract.employer).transfer(jobContract.value);
    }

    function satisfyContract(uint256 _contractId) external {
        ContractStruct.JobContract storage jobContract = jobContracts[
            _contractId
        ];
        require(
            msg.sender == jobContract.freelancer,
            "Only the assigned freelancer can complete this contract"
        );
        require(
            jobContract.status == ContractStruct.Status.Accepted,
            "Contract is not in a valid state for completion"
        );
        jobContract.status = ContractStruct.Status.Completed;
        // Release the contract value to the freelancer
        payable(jobContract.freelancer).transfer(jobContract.value);
    }

    function viewContract(
        uint256 _contractId
    ) external view returns (ContractStruct.JobContract memory) {
        return jobContracts[_contractId];
    }

    function registerAddress(address _user) external {
        require(
            accounts[msg.sender] == AccountType.Escrow,
            "Only escrow accounts can register addresses"
        );
        require(accounts[_user] == AccountType.None, "User already registered");
        accounts[_user] = AccountType.None;
    }

    function checkContracts() external view returns (uint256[] memory) {
        require(
            accounts[msg.sender] == AccountType.Escrow,
            "Only escrow accounts can check contracts"
        );
        uint256[] memory ids = new uint256[](contractCount);
        for (uint256 i = 0; i < contractCount; i++) {
            ids[i] = i;
        }
        return ids;
    }

    function payoutContracts(uint256 _contractId) external {
        require(
            accounts[msg.sender] == AccountType.Escrow,
            "Only escrow accounts can payout contracts"
        );
        ContractStruct.JobContract storage jobContract = jobContracts[
            _contractId
        ];
        require(
            jobContract.status == ContractStruct.Status.Completed,
            "Contract is not completed"
        );
        payable(jobContract.freelancer).transfer(jobContract.value);
    }
}
