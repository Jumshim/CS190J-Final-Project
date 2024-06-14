// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ContractStruct.sol";

contract Marketplace {
    enum AccountType { None, Employer, Freelancer, Escrow }

    address public escrow;  // Address of the escrow account

    mapping(address => AccountType) public accounts;
    mapping(uint256 => ContractStruct.JobContract) private jobContracts;
    uint256 private contractCount;

    modifier onlyEscrow() {
        require(msg.sender == escrow, "Only the escrow account can call this function");
        _;
    }

    constructor(address _escrow) {
        escrow = _escrow;
    }

    function registerAsEmployer() external {
        require(accounts[msg.sender] == AccountType.None, "Already registered as another role");
        accounts[msg.sender] = AccountType.Employer;
    }

    function registerAsFreelancer() external {
        require(accounts[msg.sender] == AccountType.None, "Already registered as another role");
        accounts[msg.sender] = AccountType.Freelancer;
    }

    function registerAsEscrow() external {
        require(accounts[msg.sender] == AccountType.None, "Already registered as another role");
        require(msg.sender == escrow, "Only the designated escrow address can register as escrow");
        accounts[msg.sender] = AccountType.Escrow;
    }

    function sendContract(address _freelancer, uint256 _days) external payable {
        require(accounts[msg.sender] == AccountType.Employer, "Only employers can send contracts");
        require(accounts[_freelancer] == AccountType.Freelancer, "Can only send contracts to freelancers");
        require(msg.value > 0, "Must send ether to fund the contract");
        require(_days > 0, "Must specify a positive number of days");

        uint256 contractId = contractCount++;
        uint256 deadlineDate = block.timestamp + (_days * 1 days);
        jobContracts[contractId] = ContractStruct.JobContract({
            id: contractId,
            value: msg.value,
            dateAssigned: block.timestamp,
            deadlineDate: deadlineDate,
            employer: msg.sender,
            freelancer: _freelancer,
            status: ContractStruct.Status.Created,
            freelancerSatisfied: false,
            employerSatisfied: false
        });

        // Transfer the funds to the escrow account
        payable(escrow).transfer(msg.value);
    }

    function acceptContract(uint256 _contractId) external {
        ContractStruct.JobContract storage jobContract = jobContracts[_contractId];
        require(msg.sender == jobContract.freelancer, "Only the assigned freelancer can accept this contract");
        require(jobContract.status == ContractStruct.Status.Created, "Contract is not in a valid state for acceptance");
        jobContract.status = ContractStruct.Status.Accepted;
    }

    function rejectContract(uint256 _contractId) external {
        ContractStruct.JobContract storage jobContract = jobContracts[_contractId];
        require(msg.sender == jobContract.freelancer, "Only the assigned freelancer can reject this contract");
        require(jobContract.status == ContractStruct.Status.Created, "Contract is not in a valid state for rejection");
        jobContract.status = ContractStruct.Status.Rejected;
    }

    function freelancerSatisfyContract(uint256 _contractId) external {
        ContractStruct.JobContract storage jobContract = jobContracts[_contractId];
        require(msg.sender == jobContract.freelancer, "Only the assigned freelancer can mark this contract as complete");
        require(jobContract.status == ContractStruct.Status.Accepted, "Contract is not in a valid state for completion");
        jobContract.freelancerSatisfied = true;
        finalizeContract(_contractId);
    }

    function employerSatisfyContract(uint256 _contractId) external {
        ContractStruct.JobContract storage jobContract = jobContracts[_contractId];
        require(msg.sender == jobContract.employer, "Only the employer can mark this contract as complete");
        require(jobContract.status == ContractStruct.Status.Accepted, "Contract is not in a valid state for completion");
        jobContract.employerSatisfied = true;
        finalizeContract(_contractId);
    }

    function finalizeContract(uint256 _contractId) internal {
        ContractStruct.JobContract storage jobContract = jobContracts[_contractId];
        if (jobContract.freelancerSatisfied && jobContract.employerSatisfied) {
            jobContract.status = ContractStruct.Status.Completed;
        }
    }

    function checkContracts() external onlyEscrow returns (uint256[] memory, uint256[] memory) {
        uint256[] memory toRefund = new uint256[](contractCount);
        uint256[] memory toPayout = new uint256[](contractCount);
        uint256 refundCount = 0;
        uint256 payoutCount = 0;

        for (uint256 i = 0; i < contractCount; i++) {
            ContractStruct.JobContract storage jobContract = jobContracts[i];
            if ((jobContract.status == ContractStruct.Status.Accepted || jobContract.status == ContractStruct.Status.Created) && block.timestamp > jobContract.deadlineDate) {
                jobContract.status = ContractStruct.Status.Rejected;
                toRefund[refundCount] = i;
                refundCount++;
            } else if (jobContract.status == ContractStruct.Status.Completed) {
                toPayout[payoutCount] = i;
                payoutCount++;
            } else if (jobContract.status == ContractStruct.Status.Rejected) {
                toRefund[refundCount] = i;
                refundCount++;
            }
        }

        // Resize arrays to actual counts
        assembly {
            mstore(toRefund, refundCount)
            mstore(toPayout, payoutCount)
        }

        return (toRefund, toPayout);
    }

    function viewContract(uint256 _contractId) external view returns (ContractStruct.JobContract memory) {
        return jobContracts[_contractId];
    }
}
