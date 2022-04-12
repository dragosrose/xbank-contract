// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Lend.sol";

contract XBank {
    address public owner;

    address public xcoin = 0x848052231C98DbB712b4cff5704a7CAedE08a0F9;

    address[] public stakers;

    mapping(address => uint) public stakingBalance;
    // When stake holders can withdraw their stakes.
    mapping(address => uint) public stakeDueDate;

    // When stake holders can claim their rewards.
    mapping(address => uint) public rewardsDueDate;

    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    address public weth = 0xc778417E063141139Fce010982780140Aa0cD5Ab;

    uint public collateralMultiplier = 150;
    uint collateral;

    // At the moment we suppose they go 1 for 1.
    // It is from ETH to XCoin.
    uint public conversionRate = 1;

    // Interest rate: 10%, set to 110 because of future division.
    uint public interestRate = 110;

    uint payoff;

    // How much time to pay off the loan.
    uint public loanDuration = 300; // 5 minutes

    // How much time staked tokens are held.
    uint public stakeLockDuration = 600; // 10 minutes

    // How much time until stake holders can claim their rewards.
    uint public stakePayoutRate = 900; // 15 minutes

    // Will generate lend contract for each customer when criterias are met.
    Lend lend;

    // Total sum sent for staking.
    uint public totalDebtSum;

    constructor() {
        totalDebtSum = 0;
        owner = msg.sender;
    }

    function stake(uint _amount) public {
        require(_amount > 0, "No token was sent for staking.");

        // Transaction reverted: function call to a non-contract account.
        // Tested from sample-test.js. Either tests should be configured from
        // hardhat or try to test the already deployed contract, but from
        // localhost website. (Remix and Etherscan are cringe :( )
        require(IERC20(xcoin).transferFrom(msg.sender, address(this), _amount), "Staking transfer has failed.");

        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
            hasStaked[msg.sender] = true;
        }

        // Whenever a stake is added, the stake and rewards due date are initialized.
        stakeDueDate[msg.sender] = block.timestamp + stakeLockDuration;
        rewardsDueDate[msg.sender] = block.timestamp + stakePayoutRate;
        isStaking[msg.sender] = true;
    }

    function withdraw() public {
        uint balance = stakingBalance[msg.sender];
        require(block.timestamp >= stakeDueDate[msg.sender], "Stake tokens can't be withdrawin yet.");
        require(balance > 0, "Token balance to withdraw must be greater than 0.");

        IERC20(xcoin).transfer(msg.sender, balance);
        stakingBalance[msg.sender] -= balance;
        isStaking[msg.sender] = false;
    }

    function claim() public {
        require(block.timestamp >= rewardsDueDate[msg.sender], "Reward tokens can't be claimed yet.");

        // Division because of the conversion rate direction (ETH => XCoin).
        uint reward = stakingBalance[msg.sender] / totalDebtSum / conversionRate;
        IERC20(xcoin).transfer(msg.sender, reward);

        // Reset reward due date.
        rewardsDueDate[msg.sender] += stakePayoutRate;
    }

    function requestLoan(uint amount) public payable {
        require(amount > 0, "Amount to lend must be greater than 0.");

        collateral = amount * conversionRate * collateralMultiplier / 100;
        payoff = amount * conversionRate * interestRate / 100;

        require(IERC20(weth).transfer(address(this), collateral), "Collateral transfer has failed.");
        lend = new Lend(address(this), xcoin, collateral, amount, payoff, loanDuration);

        totalDebtSum += payoff;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}
