// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IOracle.sol";
import "./Vault.sol";
import "./PositionManager.sol";

contract Liquidation is Ownable {
    IOracle public oracle;
    Vault public vault;
    PositionManager public positionManager;

    uint256 public constant MIN_HEALTH = 1e18;

    uint256 public constant LIQUIDATION_REWARD_BPS = 500;

    event PositionLiquidated(address indexed user, address indexed liquidator, int256 pnl, uint256 reward);

    error PositionHealthy();
    error InvalidOraclePrice();
    error ZeroAddress();

    constructor(address _oracle, address _vault, address _positionManager) Ownable(msg.sender) {
        if (_oracle == address(0) || _vault == address(0) || _positionManager == address(0)) {
            revert ZeroAddress();
        }

        oracle = IOracle(_oracle);
        vault = Vault(_vault);
        positionManager = PositionManager(_positionManager);
    }

    function liquidate(address user) external {
        PositionManager.Position memory pos = positionManager.positions(user);
        if (!pos.isOpen) revert PositionManager.PositionNotOpen();

        uint256 price = oracle.getPrice();
        if (price == 0) revert InvalidOraclePrice();

        int256 pnl = _calculatePnL(pos.size, pos.entryPrice, price, pos.side);

        uint256 collateral = vault.collateralBalance(user);
        int256 health = int256(collateral) + pnl;

        if (health * 1e18 / int256(pos.size) >= int256(MIN_HEALTH)) {
            revert PositionHealthy();
        }

        positionManager.closePosition();

        //reward to liquidator
        uint256 reward = (collateral * LIQUIDATION_REWARD_BPS) / 10000;
        vault.transferCollateral(user, msg.sender, reward); // we are sending form user account or deposit right?

        emit PositionLiquidated(user, msg.sender, pnl, reward);
    }

    function _calculatePnL(uint256 size, uint256 entry, uint256 exit, PositionManager.Side side)
        internal
        pure
        returns (int256)
    {
        if (side == PositionManager.Side.Long) {
            return int256(size) * (int256(exit) - int256(entry)) / int256(entry);
        } else {
            return int256(size) * (int256(entry) - int256(exit)) / int256(entry);
        }
    }

    function setVault(address _vault) external onlyOwner {
        if (_vault == address(0)) revert ZeroAddress();
        vault = Vault(_vault);
    }

    function setOracle(address _oracle) external onlyOwner {
        if (_oracle == address(0)) revert ZeroAddress();
        oracle = IOracle(_oracle);
    }
}
