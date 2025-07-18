// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "../interfaces/AggregatorV3Interface.sol";

contract MockChainlinkOracle is AggregatorV3Inteface {
    int256 public price = 2000e8;

    function setPrice(int256 _price) external {
        price = _price;
    }

    function latestRound() external view override returns (uint80, int256 answer, uint256, uint256, uint80) {
        return (0, price, 0, 0, 0);
    }
}
