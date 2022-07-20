const { assert } = require("chai")
const { getNamedAccounts, network, ethers } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")

developmentChains.includes(network.name)
    ? describe.skip
    : describe("FundMe", async function () {
          let deployer
          let fundMe
          const sendValue = ethers.utils.parseEther("1")

          beforeEach(async function () {
              deployer = (await getNamedAccounts()).deployer
              fundMe = await ethers.getContract("FundMe", deployer)
          })
          it("allows users to fund and withdraw", async function () {
              await fundMe.fund({ value: sendValue })
              await fundMe.withdrawFunds()
              const contractBalance = await fundMe.provider.getBalance(
                  fundMe.address
              )
              assert.equal(contractBalance.toString(), "0")
          })
      })
