// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.7;

import "./Loan.sol";

contract Lend {
    address public weth; // must be set
    address public xbank;
    address public borrower;
    address public xcoin;
    uint public collateral;
    uint public loanAmount;
    uint public payoff;
    uint public loanPeriod;

    Loan public loan;


    constructor (address _xbank, address _xcoin, uint _collateral, uint _loanAmount, uint _payoff, uint _loanPeriod){
        borrower = msg.sender;
        xcoin = _xcoin;
        xbank = _xbank;
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