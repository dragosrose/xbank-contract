// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract XBank {
    address private owner;

    IERC20 xcoin;
    IERC20 weth = IERC20(0xc778417E063141139Fce010982780140Aa0cD5Ab);

    address[] private debters;
    address[] private stakers;

    mapping (address => uint) private stakedBalance;
    mapping (address => bool) private isStaking;
    mapping (address => uint) private owedBalance;
    mapping (address => bool) private isDebter;
    mapping (address => uint) private rewardsBalance;

    uint private staked = 0;
    uint private owed = 0;
    uint private rewards = 0;

    uint public collateralMultiplier = 150;
    uint private interestRate = 10;

    // How much time to pay off the loan.
    uint private loanDuration = 300; // 5 minutes

    constructor(address xcoinAddr) {
        owner = msg.sender;
        xcoin = IERC20(xcoinAddr);
    }

    function getStakedAmount() public view returns (uint) {
        return stakedBalance[msg.sender];
    }

    function getTotalStaked() public view returns (uint) {
        return staked;
    }

    function getOwedAmount() public view returns (uint) {
        return owedBalance[msg.sender];
    }

    function getTotalOwed() public view returns (uint) {
        return owed;
    }

    function getRewardsAmount() public view returns (uint) {
        return rewardsBalance[msg.sender];
    }

    function getTotalRewards() public view returns (uint) {
        return rewards;
    }

    function stake(uint _amount) public payable {
        require(_amount > 0, "No token was sent for staking.");
        require(xcoin.transferFrom(msg.sender, address(this), _amount), "Staking transfer has failed.");

        stakedBalance[msg.sender] += _amount;
        staked += _amount;

        if (!isStaking[msg.sender]) {
            stakers.push(msg.sender);
            isStaking[msg.sender] = true;
        }
    }

    function withdraw(uint _amount) public {
        require(_amount <= stakedBalance[msg.sender], "Can't withdraw more than you have staked.");
        require(xcoin.transfer(msg.sender, _amount), "Withdrawal failed.");

        stakedBalance[msg.sender] -= _amount;
        staked -= _amount;

        if (stakedBalance[msg.sender] == 0) {
            removeAddress(stakers, msg.sender);
            isStaking[msg.sender] = false;
        }
    }

    function claim() public {
        // TODO
    }

    function liquidateCollaterals() public payable {
        // TODO
    }

    function requestLoan(uint amount) public payable {
        require(amount > 0, "Amount to lend must be greater than 0.");
        require(owedBalance[msg.sender] == 0, "You must pay all your debts to borrow more.");

        uint collateralAmount = amount;
        debters.push(msg.sender);

        require(weth.transferFrom(msg.sender, address(this), collateralAmount), "Collateral transfer has failed.");
        require(xcoin.transferFrom(address(this), msg.sender, amount), "Lending XCOIN has failed.");

        owedBalance[msg.sender] = amount + amount * interestRate;
    }

    function payDebt() public payable {
        require(msg.value >= owedBalance[msg.sender], "You must pay your loan in full.");
        // TODO
    }

    function removeAddress(address[] storage arr, address toRemove) private {
        uint i;
        for (i = 0; i < arr.length; i++) {
            if (arr[i] == toRemove) {
                break;
            }
        }

        for (; i < arr.length - 1; i++) {
            arr[i] = arr[i + 1];
        }

        arr.pop();
    }
}
