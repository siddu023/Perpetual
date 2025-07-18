// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/PerpEngine.sol";
import "../src/Vault.sol";
import "../src/PositionManager.sol";
import "../src/Liquidation.sol";
import "../src/mocks/MockERC20.sol";
import "../src/mocks/MockChainlinkOracle.sol";

contract PerpEngineTest is Test {
    PerpEngine engine;
    Vault vault;
    PositionManager positionManager;
    Liquidation liquidation;
    MockERC20 collateral;
    MockChainlinkOracle oracle;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        collateral = new MockERC20("USDC", "USDC");
        oracle = new MockChainlinkOracle();

        vault = new Vault(address(collateral));
        positionManager = new PositionManager(address(oracle));
        liquidation = new Liquidation(address(oracle), address(vault), address(positionManager));
    }
}
