// SPDX-License-Identifer: MIT
pragma solidity ^0.8.20;

/**
 * @title SavingsWallet

 * @dev Implementation of example savings wallet functionality from Ethereum's whitepaper
 * @dev https://ethereum.org/en/whitepaper/
 */
  
contract SavingsWallet {
    
    // State variables
    address public alice;
    address public bob;
    bool public bobCanWithdraw;
    mapping(address => uint256) public lastWithdrawal; // Time of most recent withdrawal for both Alice and Bob

    // Constants
    uint256 public constant dailyWithdrawalLimit = 1; // As a percent
    uint256 public constant dailySeconds = 24 * 60 * 60;

    // Events
    event Deposited(address sender, uint256 amount);
    event Withdrawn(address caller, address recipient, uint256 amount);

    // Modifiers
    modifier onlyAlice() {
        require(msg.sender == alice, "Only Alice can call this function");
        _;
    }

    modifier onlyBob() {
        require(msg.sender == bob, "Only Bob can call this function");
        _;
    }

    modifier onlyAliceOrBob() {
        require(msg.sender == alice || msg.sender == bob);
        _;
    }

    /* bobCanWithdraw set to true by default
    * Validate addresses passed as arguments 
    * (Alice and Bob shouldn't be the same or null)
    * @param _alice Alice's address
    * @param _bob Bob's address
    */
    constructor(address _alice, address _bob){
        require(_alice != address(0));
        require(_bob != address(0));
        require(_bob != _alice);
        alice = _alice;
        bob = _bob;

    }









}