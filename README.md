# CS 190J Final Project

## Intro

Our project is a smart contract application that aims to allow employers to securely commission work from freelancers, with the added security benefit of an Escrow Account to hold funds while a contract is being worked on.

## How to use our application

Forge is needed to use our application. Once it's set up, a user needs to register as either an employer or freelancer.
- Follow the steps for forge: https://book.getfoundry.sh/getting-started/installation
- within the main project directory, run `forge test`

If they register as an employer, they can send contracts to freelancers as well as satisfy the contract when the freelancer has completed work

If they register as a freelancer, they can accept or reject any contracts that they are sent, as well as satisfy their contracts when they've been completed.

### Specific
Using the `vm` operator from `StdUtils`, set up mock addresses / accounts relevant to the functionalities you want to test

i.e:
```
address public employer = address(0x1);
address public freelancer = address(0x2);
address public escrow = address(0x3);
```

Deal an X amount of ether funds to the relevant accounts using `vm.deal(address, # ether)` 

Create a Marketplace instance and interact with the project through the various APIs. Try out different simulations 

Assign roles to the relevant addresses and utilize the `vm.prank` function to masquerade your actions under a specific address
- Creating a UI was not in the scope of this project, so interacting with the project should be done through Foundry's testing / utility suite!

## APIs

### 1. registerAsEmployer
- **Description**: Registers the caller as an employer.
- **How to call**: function registerAsEmployer() external;
- **Returns**: Nothing.
- **Notes**: Only accounts that have not been registered as another role can register as an employer.

### 2. registerAsFreelancer
- **Description**: Registers the caller as a freelancer.
- **How to call**: function registerAsFreelancer() external;
- **Returns**: Nothing.
- **Notes**: Only accounts that have not been registered as another role can register as a freelancer.

### 3. registerAsEscrow
- **Description**: Registers the caller as the escrow account.
- **How to call**: function registerAsEscrow() external;
- **Returns**: Nothing.
- **Notes**: Only the designated escrow address can register as escrow.

### 4. sendContract
- **Description**: Sends a contract to a freelancer.
- **How to call**: function sendContract(address _freelancer, uint256 _days) external payable;
- **Returns**: Nothing.
- **Notes**: Only employers can send contracts. The call must include a positive number of days and an Ether value to fund the contract.

### 5. acceptContract
- **Description**: Accepts a contract by the assigned freelancer.
- **How to call**: function acceptContract(uint256 _contractId) external;
- **Returns**: Nothing.
- **Notes**: Only the assigned freelancer can accept the contract.

### 6. rejectContract
- **Description**: Rejects a contract by the assigned freelancer.
- **How to call**: function rejectContract(uint256 _contractId) external;
- **Returns**: Nothing.
- **Notes**: Only the assigned freelancer can reject the contract.

### 7. freelancerSatisfyContract
- **Description**: Marks the contract as satisfied by the freelancer.
- **How to call**: function freelancerSatisfyContract(uint256 _contractId) external;
- **Returns**: Nothing.
- **Notes**: Only the assigned freelancer can mark the contract as complete.

### 8. employerSatisfyContract
- **Description**: Marks the contract as satisfied by the employer.
- **How to call**: function employerSatisfyContract(uint256 _contractId) external;
- **Returns**: Nothing.
- **Notes**: Only the employer can mark the contract as complete.

### 9. checkContracts
- **Description**: Checks the status of all contracts and returns lists of contracts to refund and payout.
- **How to call**: function checkContracts() external onlyEscrow returns (uint256[] memory, uint256[] memory);
- **Returns**: Two arrays: one for contracts to refund and one for contracts to payout.
- **Notes**: Only the escrow account can call this function.

### 10. viewContract
- **Description**: Views the details of a specific contract.
- **How to call**: function viewContract(uint256 _contractId) external view returns (ContractStruct.JobContract memory);
- **Returns**: The details of the specified contract.
- **Notes**: Any account can view contract details.

## Components

### 1. Marketplace Contract
The main contract that handles the registration of employers, freelancers, and escrow, as well as the sending, accepting, rejecting, and satisfying of contracts.

### 2. ContractStruct Library
Defines the structure of a job contract and the possible statuses.

## User Roles

### 1. Employer
- **Role**: Initiates contracts with freelancers.
- **Capabilities**:
    - Register as an employer.
    - Send contracts.
    - Satisfy contracts.

### 2. Freelancer
- **Role**: Accepts and completes work from employers.
- **Capabilities**:
    - Register as a freelancer.
    - Accept contracts.
    - Reject contracts.
    - Satisfy contracts.

### 3. Escrow
- **Role**: Manages the funds and ensures fair transactions.
- **Capabilities**:
    - Register as escrow.
    - Check contracts to determine which need to be refunded or paid out.


## Security Considerations

- **Block Timestamp Manipulation**: By making contracts last days, we can ensure that small manipulations of the block timestamp (+- 15 seconds) will have little to no effect on our application
- **Access Control**: Only authorized roles can perform certain actions.
- **Arithmetic Safety**: Using Solidity ^0.8.0 to prevent overflow and underflow issues.
- **Reentrancy Protection**: Ensures that no function is vulnerable to reentrancy attacks.
