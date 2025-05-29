# Savings-Wallet

This project is an implementation of an example usage of smart contracts running on the Ethereum Virtual Machine briefly
mentioned in Ethereum's Whitepaper, which is a savings wallet. The required features mentioned by the whitepaper are as follows:

"Suppose that Alice wants to keep her funds safe, but is worried that she will lose or someone will hack her private key. She puts ether into a contract with Bob, a bank, as follows:

Alice alone can withdraw a maximum of 1% of the funds per day.
Bob alone can withdraw a maximum of 1% of the funds per day, but Alice has the ability to make a transaction with her key shutting off this ability.
Alice and Bob together can withdraw anything."
(ethereum.org/en/whitepaper/)

One simplification made is that in addition to a maximum daily withdrawal of 1% of the wallet's balance, it can only be withdrawn all at
once.

For following style guidelines, I referenced the USDT contract @ 0xdAC17F958D2ee523a2206206994597C13D831ec7 that I had been looking 
through out of curiosity.

This will be developed using Hardhat and tested with a javascript program and remix IDE.

# Testing process
The test file is found in test/SavingsWallet.test.js
