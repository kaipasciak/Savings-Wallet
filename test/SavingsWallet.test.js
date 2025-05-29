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

    it("Should only allow one withdrawal per user per day", async function () {
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

    // TODO: Ensure Bob can only withdraw once per day
    // TODO: Check functionality of Alice toggling Bob's permissions
    // TODO: Make sure both can withdraw any amount together
});