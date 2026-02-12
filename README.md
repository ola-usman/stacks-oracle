# StacksOracle Protocol v1.0

## Bitcoin-Secured Prediction Markets Protocol

StacksOracle is a trustless, Bitcoin-secured prediction market protocol leveraging Stacks Layer 2 technology for transparent, decentralized price forecasting with cryptographic proof settlement.

## Table of Contents

- [Overview](#overview)
- [Key Innovations](#key-innovations)
- [System Architecture](#system-architecture)
- [Contract Architecture](#contract-architecture)
- [Data Flow](#data-flow)
- [Core Features](#core-features)
- [Getting Started](#getting-started)
- [API Reference](#api-reference)
- [Governance](#governance)
- [Security Model](#security-model)
- [Contributing](#contributing)

## Overview

StacksOracle harnesses the security of Bitcoin through Stacks' unique Proof-of-Transfer consensus to create immutable prediction markets. Participants stake STX tokens on asset price movements within defined time windows, with winners earning proportional rewards from the total pool. Oracle-verified price feeds ensure tamper-proof settlement, while built-in governance mechanisms enable community-driven protocol evolution.

Every prediction is cryptographically anchored to Bitcoin's blockchain, providing unparalleled security and transparency for decentralized forecasting.

## Key Innovations

- **Bitcoin-anchored Security**: Leverages Stacks Proof-of-Transfer for ultimate security
- **Permissionless Market Creation**: Customizable time horizons and asset predictions
- **Cryptographic Oracle Integration**: Tamper-proof price resolution system
- **Proportional Reward Distribution**: Fair payout system with anti-manipulation safeguards
- **Gas-efficient Smart Contracts**: Optimized for Layer 2 performance
- **Decentralized Governance**: Community-driven protocol upgrades
- **Real-time Analytics**: Comprehensive market and participant statistics

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Bitcoin Blockchain                       │
│                  (Security Anchor)                         │
└─────────────────────┬───────────────────────────────────────┘
                      │ Proof-of-Transfer
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                  Stacks Layer 2                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │            StacksOracle Protocol                   │   │
│  │                                                     │   │
│  │  ┌──────────────┐  ┌──────────────┐                │   │
│  │  │   Market     │  │    Oracle    │                │   │
│  │  │  Management  │  │  Integration │                │   │
│  │  └──────────────┘  └──────────────┘                │   │
│  │                                                     │   │
│  │  ┌──────────────┐  ┌──────────────┐                │   │
│  │  │ Prediction   │  │  Governance  │                │   │
│  │  │   Engine     │  │   System     │                │   │
│  │  └──────────────┘  └──────────────┘                │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Contract Architecture

### Core Components

#### 1. Market Management

- **Market Creation**: Permissionless market creation with validation
- **Market Resolution**: Oracle-based price settlement
- **Market Analytics**: Real-time statistics and performance metrics

#### 2. Prediction Engine

- **Stake Management**: User prediction tracking and validation
- **Reward Distribution**: Proportional payout system
- **Anti-manipulation**: Built-in safeguards against gaming

#### 3. Oracle Integration

- **Price Feeds**: Cryptographically verified external data
- **Settlement**: Tamper-proof market resolution
- **Validation**: Multi-layer price verification

#### 4. Governance System

- **Protocol Configuration**: Owner-controlled parameters
- **Emergency Controls**: Circuit breakers and pause mechanisms
- **Fee Management**: Revenue collection and distribution

### Data Structures

```clarity
;; Market Data
{
  creator: principal,
  asset-name: (string-ascii 32),
  start-price: uint,
  end-price: uint,
  total-up-stake: uint,
  total-down-stake: uint,
  start-block: uint,
  end-block: uint,
  resolution-block: uint,
  resolved: bool,
  total-participants: uint,
  creation-block: uint
}

;; User Predictions
{
  prediction: (string-ascii 4),
  stake: uint,
  claimed: bool,
  timestamp: uint,
  block-height: uint
}

;; User Statistics
{
  total-predictions: uint,
  total-winnings: uint,
  total-losses: uint,
  win-rate: uint,
  last-activity: uint
}
```

## Data Flow

### Market Creation Flow

```
1. Owner creates market → 2. Validation checks → 3. Market initialization → 4. State update
```

### Prediction Flow

```
1. User submits prediction → 2. Stake validation → 3. STX transfer → 4. Prediction recording → 5. Market update
```

### Resolution Flow

```
1. Oracle submits price → 2. Market resolution → 3. Winner determination → 4. Payout calculation → 5. Analytics update
```

### Claim Flow

```
1. Winner claims → 2. Eligibility check → 3. Payout calculation → 4. STX transfer → 5. Statistics update
```

## Core Features

### Market Operations

- **Create Market**: Deploy new prediction markets with custom parameters
- **Make Prediction**: Stake STX on price direction (up/down)
- **Resolve Market**: Oracle-based settlement with verified price feeds
- **Claim Winnings**: Automated reward distribution to winners

### Analytics & Insights

- **Market Details**: Comprehensive market information and statistics
- **User Analytics**: Individual performance tracking and metrics
- **Platform Statistics**: Protocol-wide analytics and health metrics
- **Market Analytics**: Volatility, participation, and performance data

### Governance & Administration

- **Oracle Management**: Configure trusted price feed sources
- **Fee Configuration**: Adjust platform fees (capped at 10%)
- **Emergency Controls**: Protocol pause mechanisms
- **Revenue Management**: Fee collection and withdrawal

## Getting Started

### Prerequisites

- Stacks wallet with STX tokens
- Access to Stacks network (mainnet/testnet)
- Basic understanding of prediction markets

### Deployment

```bash
# Deploy contract to Stacks network
clarinet deployments apply --network=<network>
```

### Basic Usage

#### Creating a Market (Owner Only)

```clarity
(contract-call? .stacksoracle create-market 
  "BTC-USD" 
  u50000 
  u1000 
  u2000)
```

#### Making a Prediction

```clarity
(contract-call? .stacksoracle make-prediction 
  u1 
  "up" 
  u1000000)
```

#### Claiming Winnings

```clarity
(contract-call? .stacksoracle claim-winnings u1)
```

## API Reference

### Public Functions

| Function | Description | Parameters | Returns |
|----------|-------------|------------|---------|
| `create-market` | Create new prediction market | asset-name, start-price, start-block, end-block | market-id |
| `make-prediction` | Submit prediction with stake | market-id, prediction, stake | prediction-details |
| `resolve-market` | Resolve market with end price | market-id, end-price | resolution-info |
| `claim-winnings` | Claim winnings from resolved market | market-id | payout-details |

### Read-Only Functions

| Function | Description | Returns |
|----------|-------------|---------|
| `get-market-details` | Comprehensive market information | market-data |
| `get-user-prediction-details` | User prediction analytics | prediction-data |
| `get-user-stats` | User performance metrics | user-statistics |
| `get-platform-stats` | Protocol-wide analytics | platform-data |
| `get-platform-config` | Current protocol configuration | config-data |

## Governance

### Protocol Configuration

- **Oracle Address**: Trusted price feed source
- **Minimum Stake**: Minimum prediction amount (default: 1 STX)
- **Platform Fee**: Revenue percentage (capped at 10%, default: 2%)
- **Market Duration**: Minimum market timeframe (24 hours)

### Emergency Controls

- **Protocol Pause**: Emergency stop mechanism
- **Fee Withdrawal**: Protocol revenue management (max 50% per withdrawal)
- **Parameter Updates**: Dynamic configuration management

## Security Model

### Bitcoin Security

- **Proof-of-Transfer**: Inherits Bitcoin's security through Stacks consensus
- **Immutable Records**: All predictions anchored to Bitcoin blockchain
- **Cryptographic Verification**: Oracle data cryptographically secured

### Smart Contract Security

- **Input Validation**: Comprehensive parameter checking
- **Access Controls**: Role-based function restrictions
- **Reentrancy Protection**: Secure token transfer patterns
- **Integer Overflow Prevention**: Safe arithmetic operations

### Economic Security

- **Anti-manipulation**: Proportional reward distribution
- **Fee Caps**: Maximum platform fee limits
- **Withdrawal Limits**: Revenue extraction restrictions
- **Minimum Stakes**: Spam prevention mechanisms

## Risk Considerations

- **Oracle Dependency**: Relies on trusted price feed sources
- **Market Manipulation**: Large stakes can influence odds
- **Smart Contract Risk**: Code vulnerabilities and bugs
- **Stacks Network Risk**: Layer 2 dependency and performance

## Contributing

We welcome contributions to the StacksOracle Protocol! Please read our contributing guidelines and submit pull requests for:

- Bug fixes and security improvements
- New features and enhancements
- Documentation updates
- Testing and validation
