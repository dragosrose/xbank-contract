// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.7;

import "./Loan.sol";
import "./XBank.sol";

contract Lend {
    address public weth = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
    address public xbank;
    address public borrower;
    address public xcoin = 0x848052231C98DbB712b4cff5704a7CAedE08a0F9;
    uint public collateral;
    uint public loanAmount;
    uint public payoff;
    uint public loanPeriod;

    Loan public loan;


    constructor (address _xbank, address _xcoin, uint _collateral, uint _loanAmount, uint _payoff, uint _loanPeriod){
        borrower = msg.sender;
        xbank = _xbank;
        xcoin = _xcoin;
        collateral = _collateral;
        loanAmount = _loanAmount;
        payoff = _payoff;
        loanPeriod = _loanPeriod;
        
    }

    function lendXcoin() public payable {
        require(msg.value == loanAmount, "Amount set incorrectly.");
        loan = new Loan(
            payable(msg.sender),
            payable(borrower),
            xcoin,
            collateral,
            payoff,
            loanPeriod
        );

        require(IERC20(weth).transferFrom(borrower, xbank, collateral), "Transfer from borrower failed.");

        payable(borrower).transfer(loanAmount);
    }

}