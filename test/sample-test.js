const { expect } = require("chai");
const { parseEther } = require("ethers/lib/utils");
const { ethers } = require("hardhat");


describe("Swapping to WETH then testing XBank", function () {
  // it("Swap to WETH", async function () {
  //   const [owner] = await ethers.getSigners();

  //   const Swapper = await ethers.getContractFactory("Swapper");
  //   const swapper = await Swapper.deploy();
  //   await swapper.deployed();

  //   const swapTx = await swapper.swap({value: parseEther("1")});
  //   await swapTx.wait();

    
  // });

  it("XBank - Stake, Withdraw, Claim, RequestLoan", async function() {
    const XBank = await ethers.getContractFactory("XBank");
    const xbank = await XBank.deploy();
    await xbank.deployed();
            
    const stake = await xbank.stake(parseEther("1000"));
    await stake.wait();

    const requestLoan = await xbank.requestLoan(parseEther("200"));
    await requestLoan.wait();

    const claim = await xbank.claim();
    await claim.wait();

    const withdraw = await xbank.withdraw();
    await withdraw.wait();
  });
});
