# CS 190J Final Project

## Intro

Our project is a smart contract application that aims to allow employers to securely commission work from freelancers, with the added security benefit of an Escrow Account to hold funds while a contract is being worked on.

## How to use our application

Forge is needed to use our application. Once it's set up, a user needs to register as either an employer or freelancer.

If they register as an employer, they can send contracts to freelancers as well as satisfy the contract when the freelancer has completed work

If they register as a freelancer, they can accept or reject any contracts that they are sent, as well as satisfy their contracts when they've been completed.

## APIs

We have a JobContract that holds all details of a contract between an employer and a freelancer, including the employer address, freelancer address, date assigned, deadline, value, and status.

The main functionality of our application is in Marketplace.sol. In this contract, users can send, accept, reject, satisfy, and view jobContracts, depending on their role.

## Security

Many common solidity security vulnerabilities aren't present in our application simply due to the mechanics in which funds are transferred and held. However, we made sure to perform any necessary checks at the beginning of functions to prevent any unnecessary security risks such as reentrancy.
