// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "./Vault.sol";
import "./PositionManager.sol";
import "./interfaces/IOracle.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PerpEngine is Ownable {
    Vault public vault;
    PositionManager public positionManager;
    IOracle public oracle;

    event CollateralDeposited(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);
    event PositionOpened(address indexed user, uint256 size, uint256 price);
    event PositionClosed(address indexed user, int256 pnl);

    constructor(address _vault, address _positonManager, address _oracle) Ownable(msg.sender) {
        vault = Vault(_vault);
        positionManager = PositionManager(_positonManager);
        oracle = IOracle(_oracle);
    }

    function deposit(uint256 amount) external {
        vault.depositCollateral(amount);
        emit CollateralDeposited(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        vault.withdrawCollateral(amount);
        emit CollateralWithdrawn(msg.sender, amount);
    }

    function openPosition(uint256 size, PositionManager.Side side) external {
        uint256 price = oracle.getPrice();
        positionManager.openPosition(size, side);
        emit PositionOpened(msg.sender, size, price);
    }

    function closedPosition() external {
        int256 pnl = positionManager.closePosition();
        vault.adjustCollateral(msg.sender, pnl);

        emit PositionClosed(msg.sender, pnl);
    }
}
