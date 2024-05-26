pragma solidity ^0.8.24;

library ContractStruct {
    struct JobContract {
        uint256 id;
        uint256 value;
        uint256 dateAssigned;
        uint256 deadlineDate;
        address employer;
        address freelancer;
        Status status;
    }

    enum Status { Created, Accepted, Rejected, Completed }
}