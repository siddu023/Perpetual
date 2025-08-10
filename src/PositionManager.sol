// SPDX-License-Identifier: SEE LICENSE IN LICENSE

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IOracle.sol";

contract PositionManager is Ownable {
    enum Side {
        Long,
        Short
    }

    struct Position {
        uint256 size;
        uint256 entryPrice;
        Side side;
        bool isOpen;
    }

    mapping(address => Position) internal _positions;

    IOracle public oracle;

    event PositionOpened(address indexed user, uint256 size, Side side, uint256 entryPrice);
    event PositionClosed(address indexed user, int256 pnl, uint256 exitPrice);
    event OracleUpdated(address indexed newOracle);

    error InvalidSide();
    error PositionAlreadyOpen();
    error PositionNotOpen();
    error InvalidOraclePrice();
    error ZeroSize();

    constructor(address _oracle) Ownable(msg.sender) {
 
require(_oracle != address(0), "Zero oracle address");
        oracle = IOracle(_oracle);
    }

    function openPosition(uint256 size, Side side) external {
        if (size == 0) revert ZeroSize();
        if (_positions[msg.sender].isOpen) revert PositionAlreadyOpen();

        uint256 price = oracle.getPrice();
        if (price == 0) revert InvalidOraclePrice();

        _positions[msg.sender] = Position({size: size, entryPrice: price, side: side, isOpen: true});

        emit PositionOpened(msg.sender, size, side, price);
    }

    function closePosition() external returns (int256 pnl) {
        Position storage pos = _positions[msg.sender];
        if (!pos.isOpen) revert PositionNotOpen();

        uint256 exitPrice = oracle.getPrice();
        if (exitPrice == 0) revert InvalidOraclePrice();

        pnl = _calculatePnL(pos.size, pos.entryPrice, exitPrice, pos.side);

        delete _positions[msg.sender];

        emit PositonClosed(msg.sender, pnl, exitPrice);

}


    function _calculatePnL(uint256 size, uint256 entry, uint256 exit, Side side) internal pure returns (int256) {
        if (side == Side.Long) {
            return int256(size) * (int256(exit) - int256(entry)) / int256(entry);
        } else {
            return int256(size) * (int256(entry) - int256(exit)) / int256(entry);
        }
    }

    function setOracle(address newOracle) external onlyOwner {
        require(newOracle != address(0), "Zero address");
        oracle = IOracle(newOracle);
        emit OracleUpdated(newOracle);
    }

    function positions(address user) external view returns (Position memory) {
        return _positions[user];
    }
}
