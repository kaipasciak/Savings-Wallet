const { expect } = require("chai");
const { ethers } = require("hardhat")

describe("SavingsWallet contract", function () {
    let savingsWallet, alice, bob;
    
    beforeEach(async function (){
        
        // Deploy
        [alice, bob] = await ethers.getSigners();
        const SavingsWallet = await ethers.getContractFactory("SavingsWallet");
        savingsWallet = await SavingsWallet.deploy(alice.address, bob.address);
        await savingsWallet.waitForDeployment();
        console.log("Alice address:", alice.address);
        console.log("Bob address:", bob.address);
        console.log("Contract address:", savingsWallet.getAddress());
        console.log("Ethers.js version:", ethers.version);
    });
    
    it("Should set first address to Alice and second to Bob", async function () {
        expect(await savingsWallet.alice()).to.equal(alice.address);
        expect(await savingsWallet.bob()).to.equal(bob.address);
    });

    it("Should allow exactly one withdrawal per day by Alice", async function () {
        // Deposit ETH to test withdrawals and wait for event
        await expect(alice.sendTransaction({
            to: savingsWallet.getAddress(),
            value: ethers.parseEther("10"),
        })
        ).to.emit(savingsWallet, "Deposited")
        .withArgs(alice.address, ethers.parseEther("10"));
        
        // Calculate expected withdrawal amount (1% of 10 ETH = 0.1 ETH)
        const expectedAmount = ethers.parseEther("0.1");

        // Alice's first withdrawal should succeed, second should fail
        await expect(savingsWallet.connect(alice).aliceWithdraw(alice.address))
            .to.emit(savingsWallet, "Withdrawn")
            .withArgs(alice.address, alice.address, expectedAmount);

        // Second withdrawal attempt by Alice
        await expect(savingsWallet.connect(alice).aliceWithdraw(alice.address))
        .to.be.revertedWith("Already withdrawn today");

    });

    it("Should allow exactly one withdrawal per day by Bob", async function () {
        // Deposit ETH to test withdrawals and wait for event
        await expect(alice.sendTransaction({
            to: savingsWallet.getAddress(),
            value: ethers.parseEther("10"),
        })
        ).to.emit(savingsWallet, "Deposited")
        .withArgs(alice.address, ethers.parseEther("10"));

        // Calculate expected withdrawal amount (1% of 10 ETH = 0.1 ETH)
        const expectedAmount = ethers.parseEther("0.1");

        // Bob's first withdrawal should succeed, second should fail
        await expect(savingsWallet.connect(bob).bobWithdraw(bob.address))
            .to.emit(savingsWallet, "Withdrawn")
            .withArgs(bob.address, bob.address, expectedAmount);

        // Second withdrawal attempt by Bob (regardless of dest. addr.)
        await expect(savingsWallet.connect(bob).bobWithdraw(bob.address))
        .to.be.revertedWith("Already withdrawn today");

    });

    // TODO: Check functionality of Alice toggling Bob's permissions
    it("Should allow Alice to toggle Bob's withdrawal permissions", async function () {
        // Deposit ETH to test withdrawals and wait for event
        await expect(alice.sendTransaction({
            to: savingsWallet.getAddress(),
            value: ethers.parseEther("10"),
        })
        ).to.emit(savingsWallet, "Deposited")
        .withArgs(alice.address, ethers.parseEther("10"));

        // Set bobCanWithdraw to false through Alice's address
        await savingsWallet.connect(alice).disableBobWithdraw();

        // Bob's attempt to withdraw should be unsuccessful
        await expect(savingsWallet.connect(bob).bobWithdraw(bob.address))
        .to.be.revertedWith("Bob cannot withdraw");

        // Set bobCanWithdraw to true 
        await savingsWallet.connect(alice).enableBobWithdraw();

        // Bob should be able to withdraw
        const expectedAmount = ethers.parseEther("0.1");

        // Bob's first withdrawal should succeed, second should fail
        await expect(savingsWallet.connect(bob).bobWithdraw(bob.address))
            .to.emit(savingsWallet, "Withdrawn")
            .withArgs(bob.address, bob.address, expectedAmount);

    });

    // TODO: Make sure both can withdraw any amount together
    
});