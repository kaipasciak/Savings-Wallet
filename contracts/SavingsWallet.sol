// SPDX-License-Identifier: MIT
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
    uint256 public constant DAILY_LIMIT_PERCENT = 1; // As a percent
    uint256 public constant DAILY_SECONDS = 24 * 60 * 60;

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
    * @param _alice address Alice's address
    * @param _bob address Bob's address
    */
    constructor(address _alice, address _bob){
        require(_alice != address(0));
        require(_bob != address(0));
        require(_bob != _alice);
        alice = _alice;
        bob = _bob;
        bobCanWithdraw = true;
    }

    /* Deposit ether to this contract's balance
    */
    receive() external payable {
        emit Deposited(msg.sender, msg.value);
    }

    /* Get the withdrawal limit for today
    * @return A uint of the amount allowed to withdraw
    */
    function getLimit() public view returns (uint256) {
        return (address(this).balance * DAILY_LIMIT_PERCENT) / 100;
    }

    /* Check if specified user can withdraw at current time
    *
    * @param user address The address for the user trying to withdraw
    * @return A boolean indicating whether they can
    */
    function canWithdraw(address user) internal view returns (bool) {
        uint256 currentDay = block.timestamp / DAILY_SECONDS;
        uint256 lastWithdrawalDay = lastWithdrawal[user] / DAILY_SECONDS;
        if (currentDay > lastWithdrawalDay) 
            return true;
        return false;

    }

    /* Alice may withdraw one percent of account balance daily
    * @param recipient address Address to send funds to
    */ 
    function aliceWithdraw(address payable recipient) external onlyAlice {
        require(recipient != address(0), "Invalid recipient address");
        require(canWithdraw(alice), "Already withdrawn today");
        uint256 amount = getLimit();
        lastWithdrawal[alice] = block.timestamp;
        recipient.transfer(amount);
        emit Withdrawn(alice, recipient, amount);
    }

    /* Bob may withdraw one percent daily if privileges are enabled
    * @param recipient address Address to send funds to
    */
    function bobWithdraw(address payable recipient) external onlyBob {
        require(recipient != address(0), "Invalid recipient address");
        require(canWithdraw(bob), "Already withdrawn today");
        require(bobCanWithdraw == true, "Bob cannot withdraw");
        uint256 amount = getLimit();
        lastWithdrawal[bob] = block.timestamp;
        recipient.transfer(amount);
        emit Withdrawn(bob, recipient, amount);
    }

    /* Bob can call a function with a signed message from Alice to move funds in larger amounts
    *
    * Using elliptic curve signer recovery method from Solidity documentation
    * https://docs.soliditylang.org/en/v0.8.30/solidity-by-example.html
    * @param recipient address payable Account address to send funds to
    * @param amount uint256 amount of ether to be transferred
    * @aliceSignature bytes memory Alice's signature
    */
    function withdrawTogether(address payable recipient, uint256 amount, bytes memory aliceSignature) external onlyBob {
        require(recipient != address(0), "Invalid recipient");
        require(amount > 0 && amount <= address(this).balance, "Invalid amount");

        // Verify Alice's signature
        bytes32 messageHash = keccak256(abi.encodePacked(recipient, amount, address(this), block.chainid));
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
        address signer = recoverSigner(ethSignedMessageHash, aliceSignature);
        require(signer == alice, "Invalid Alice signature");

        recipient.transfer(amount);
        emit Withdrawn(msg.sender, recipient, amount);
    }

    /* Helper function to recover signer from signature
    *
    * @param _ethSignedMessageHash
    * @return A tuple containing split message
    */
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) internal pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    /* Helper function to split signature into v, r, s components
    * @param sig bytes memory Signature of message
    * @return A tuple containing the three split components to the signature
    */
    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65, "Invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        if (v < 27) v += 27; // Adjust v for Ethereum compatibility
        return (v, r, s);
    }

    /* Revoke Bob's withdrawal permissions
    *
    */
    function disableBobWithdraw() external onlyAlice {
        require(bobCanWithdraw, "Bob's withdraw permissions are already disabled");
        bobCanWithdraw = false;
    }

    /* Revoke Bob's withdrawal permissions
    *
    */
    function enableBobWithdraw() external onlyAlice {
        require(bobCanWithdraw == false, "Bob's withdraw permissions are already enabled");
        bobCanWithdraw = true;
    }

    /* Get contract balance
    *
    * @return uint256 of balance on the contract
    */
    function getBalance() external view onlyAliceOrBob returns (uint256) {
        return address(this).balance;
    }

}