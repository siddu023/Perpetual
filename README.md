# Perpetual Exchange Protocol

A fully-featured decentralized perpetual futures trading protocol built in Solidity. Inspired by industry leaders like GMX and dYdX, this protocol enables leveraged long and short positions on various assets with real-time price feeds, collateral management, and liquidation mechanisms.

---

## 💡 Overview

This project implements a robust, production-ready perpetual exchange smart contract system that supports:

- Opening, updating, and closing leveraged positions (long and short)
- On-chain collateral vault and margin accounting
- Real-time price data integration using Chainlink oracles
- Automated liquidation of undercollateralized positions with incentives
- Modular and upgradeable architecture designed for extensibility and security

---

## ⚙️ Core Features

| Feature                     | Description                                                      |
|----------------------------|------------------------------------------------------------------|
| ⚖️ Leverage Trading         | Users can open long or short positions with customizable leverage |
| 🏦 Collateral Vault         | Secure collateral management and accounting                      |
| 🔄 Position Lifecycle       | Full lifecycle support: open, update (increase/decrease), close  |
| 💰 PnL Calculation          | Real-time profit and loss calculations based on oracle prices    |
| 📉 Liquidations             | Incentivized liquidations to maintain system solvency            |
| 🔗 Chainlink Oracle         | Reliable external price feeds for asset valuations               |
| 🔐 Access Control & Errors  | Custom errors and ownership control for robustness               |

---

## 🧱 Architecture

### Core Contracts

| Contract            | Responsibility                                             |
|---------------------|------------------------------------------------------------|
| `PerpEngine.sol`    | Central orchestrator managing position lifecycle           |
| `Vault.sol`         | Handles collateral deposits, withdrawals, and balances     |
| `PositionManager.sol` | Tracks positions, computes PnL, and manages margin status   |
| `Liquidation.sol`   | Checks health factors and executes liquidations            |
| `interfaces/`       | External interfaces including `IOracle` and Chainlink APIs |
| `mocks/`            | Mock ERC20 tokens and Chainlink oracles for testing        |
| `utils/`            | Utility libraries for math and precision                    |

---

## 🧪 Testing (Foundry)

Comprehensive tests written in Foundry cover:

- Opening, modifying, and closing positions under various scenarios
- Liquidation triggers and rewards distribution
- Accurate PnL and margin calculations with price changes
- Oracle integration and error handling

### Run Tests

```bash
forge test -vv

🧾 Protocol Parameters
Parameter	Description	Example Value
Minimum Health Factor	Threshold for position liquidation	1e18 (normalized)
Liquidation Reward Basis Points	Bonus awarded to liquidators	500 (5%)
Oracle Price Feed	Chainlink aggregator addresses for assets	Configurable per asset

🔐 Security Considerations
Strict margin checks to prevent undercollateralized positions

Use of custom errors and events for clarity and gas efficiency

Oracle price sanity checks to avoid manipulation

Owner-only functions protected via OpenZeppelin’s Ownable

Modular design facilitates audits and upgrades

📁 Project Structure
bash
Copy
Edit
perp-exchange/
├── src/
│   ├── PerpEngine.sol
│   ├── Vault.sol
│   ├── PositionManager.sol
│   ├── Liquidation.sol
│   ├── interfaces/
│   ├── mocks/
│   └── utils/
├── test/
│   ├── PerpEngine.t.sol
│   ├── Liquidation.t.sol
├── script/
│   └── Deploy.s.sol
└── foundry.toml



👨‍💻 Author
Sai Siddush Thungathurthy
Blockchain Engineer | Smart Contract Developer
📧 thungasaisiddush@gmail.com
🌐 LinkedIn

🧾 License
Released under the MIT License.