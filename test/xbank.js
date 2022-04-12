const { expect } = require("chai");
const { parseEther, formatEther } = require("ethers/lib/utils");
const { ethers } = require("hardhat");


describe("XBank", function () {
  let xcoin;
  let xbank;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async () => {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    const xcoinFactory = await ethers.getContractFactory("XCoin");
    const xcoin = await xcoinFactory.attach("0x848052231C98DbB712b4cff5704a7CAedE08a0F9");

    const xbankFactory = await ethers.getContractFactory("XBank");

    xbank = await xbankFactory.deploy();
    await xbank.deployed();

    await xcoin.transfer(addr1.address, parseEther('1000'));
    await xcoin.transfer(addr2.address, parseEther('1000'));
  });

  it("should be empty after creation", async () => {
    expect(await xbank.getTotalStaked()).to.equal(0);
    expect(await xbank.getTotalOwed()).to.equal(0);
    expect(await xbank.getTotalRewards()).to.equal(0);
  });

  it("should have some value after staking", async () => {
    await xcoin.connect(owner).approve(xbank.address, parseEther("0.01"));
    await xbank.stake(parseEther("0.01"));
    expect(formatEther(await xbank.getTotalStaked())).to.equal("0.01");
    expect(formatEther(await xbank.getStakedAmount())).to.equal("0.01");

    await xcoin.connect(addr1).approve(xbank.address, parseEther("0.02"));
    await xbank.connect(addr1).stake(parseEther("0.02"));
    expect(formatEther(await xbank.getTotalStaked())).to.equal("0.03");
    expect(formatEther(await xbank.connect(addr1).getStakedAmount())).to.equal("0.02");
  });

  it("should be able to withdraw staked tokens", async () => {
    await xcoin.connect(owner).approve(xbank.address, parseEther("0.01"));
    await xbank.stake(parseEther("0.01"));

    await xbank.withdraw(parseEther("0.01"));
    expect(formatEther(await xbank.getTotalStaked())).to.equal("0.0");
  });

  it("should know prices", async () => {
    await xbank.liquidateCollaterals();
  });
});
