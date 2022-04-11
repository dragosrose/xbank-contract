// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract XBank {

    address public owner;

    address public xcoin;

    address[] public stakers;

    mapping(address => uint) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    constructor(address _xcoin) {
        xcoin = _xcoin;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function stake(uint _amount) public {
        require(_amount > 0, "No token was sent for staking.");
        IERC20(xcoin).transferFrom(msg.sender, address(this), _amount);

        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        if(!hasStaked[msg.sender]){
            stakers.push(msg.sender);
            hasStaked[msg.sender] = true;
        }

        isStaking[msg.sender] = true;


    }

    function withdraw() public {
        uint balance = stakingBalance[msg.sender];

        require(balance > 0, "Token balance to withdraw must be greater than 0.");
        IERC20(xcoin).transfer(msg.sender, balance);
        stakingBalance[msg.sender] -= balance;
        isStaking[msg.sender] = false;
    }

    function claim() public onlyOwner{
        //TO-DO: Set rewards based on the interest rate
    }
}
