// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Vault is Ownable {
    IERC20 public collateralToken;

    event CollateralDeposited(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);

    error ZeroAmount();
    error InsufficientCollateral(uint256 requested, uint256 available);
    error Insufficientcollateral();

    mapping(address => uint256) public collateralBalance;

    constructor(address _collateralToken) Ownable(msg.sender) {
        require(_collateralToken != address(0), "zeroa address");
        collateralToken = IERC20(_collateralToken);
    }

    function depositCollateral(uint256 amount) external {
        if (amount == 0) revert ZeroAmount();

        bool success = collateralToken.transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer Failed");

        collateralBalance[msg.sender] += amount;

        emit CollateralDeposited(msg.sender, amount);
    }

    function withdrawCollateral(uint256 amount) external {
        uint256 userBalance = collateralBalance[msg.sender];
        if (amount == 0) revert ZeroAmount();
        if (userBalance < amount) revert InsufficientCollateral(amount, userBalance);

        collateralBalance[msg.sender] -= amount;

        bool success = collateralToken.transfer(msg.sender, amount);
        require(success, "Transfer failed");

        emit CollateralWithdrawn(msg.sender, amount);
    }

    function emergencyWithdraw(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Zero address");
        bool success = collateralToken.transfer(to, amount);
        require(success, "Transfer failed");
    }

    function adjustCollateral(address user, int256 pnl) external onlyOwner {
        if (pnl > 0) {
            collateralBalance[user] += uint256(pnl);
        } else {
            uint256 loss = uint256(-pnl);
            if (collateralBalance[user] < loss) revert Insufficientcollateral();
            collateralBalance[user] -= loss;
        }
    }

    function transferCollateral(address from, address to, uint256 amount) external onlyOwner {
        if (collateralBalance[from] < amount) revert InsufficientCollateral(amount, collateralBalance[from]);

        collateralBalance[from] -= amount;

        collateralToken.transfer(to, amount);
    }
}
