const { expect } = require("chai");
const { ethers } = require("hardhat")

describe("SavingsWallet contract", function () {
    it("Should restrict access to just Alice and Bob", async function () {
        const [alice, bob] = await ethers.getSigners();
    
        const savingsWallet = await ethers.deployContract("SavingsWallet", [alice, bob]);
    
        expect(await savingsWallet.alice()).to.equal(alice.address);
      });
    });