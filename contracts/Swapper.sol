//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract Swapper {
    function swap() public payable {
        address[] memory path = new address[](2);
        path[0] = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); //WETH
        path[1] = address(0xdAC17F958D2ee523a2206206994597C13D831ec7); //USDT
        IUniswapV2Router01(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D).swapExactETHForTokens {value: msg.value} (10000, path, msg.sender, block.timestamp + 86400);
    }
}
