// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract XCoin is ERC20 {
    constructor() ERC20("Xcoin", "XCOIN"){
        _mint(msg.sender, 1000000 ether);
    }
}


