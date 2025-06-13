;; StacksOracle - Bitcoin-Secured Prediction Markets Protocol
;;
;; Title: StacksOracle Protocol v1.0
;;
;; Summary: A trustless, Bitcoin-secured prediction market protocol leveraging 
;; Stacks Layer 2 technology for transparent, decentralized price forecasting 
;; with cryptographic proof settlement.
;;
;; Description: StacksOracle harnesses the security of Bitcoin through Stacks' 
;; unique Proof-of-Transfer consensus to create immutable prediction markets. 
;; Participants stake STX tokens on asset price movements within defined time 
;; windows, with winners earning proportional rewards from the total pool. 
;; Oracle-verified price feeds ensure tamper-proof settlement, while built-in 
;; governance mechanisms enable community-driven protocol evolution. Every 
;; prediction is cryptographically anchored to Bitcoin's blockchain, providing 
;; unparalleled security and transparency for decentralized forecasting.
;;
;; Key Innovations:
;; - Bitcoin-anchored security through Stacks Proof-of-Transfer
;; - Permissionless market creation with customizable time horizons
;; - Cryptographic oracle integration for tamper-proof price resolution
;; - Proportional reward distribution with anti-manipulation safeguards
;; - Gas-efficient smart contracts optimized for Layer 2 performance
;; - Decentralized governance framework for protocol upgrades
;; - Real-time market analytics and participant statistics
;;

;; PROTOCOL CONSTANTS & ERROR HANDLING

;; Protocol Identity & Governance
(define-constant CONTRACT_OWNER tx-sender)
(define-constant PROTOCOL_NAME "StacksOracle")
(define-constant PROTOCOL_VERSION "1.0.0")

;; Authorization & Access Control Errors
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_OWNER_ONLY (err u101))
(define-constant ERR_ORACLE_ONLY (err u102))
(define-constant ERR_PROTOCOL_PAUSED (err u103))

;; Market Lifecycle Errors
(define-constant ERR_MARKET_NOT_FOUND (err u200))
(define-constant ERR_INVALID_PREDICTION (err u201))
(define-constant ERR_MARKET_CLOSED (err u202))
(define-constant ERR_MARKET_NOT_RESOLVED (err u203))
(define-constant ERR_ALREADY_CLAIMED (err u204))
(define-constant ERR_ALREADY_RESOLVED (err u205))
(define-constant ERR_MARKET_ACTIVE (err u206))

;; Financial Transaction Errors
(define-constant ERR_INSUFFICIENT_BALANCE (err u300))
(define-constant ERR_INSUFFICIENT_STAKE (err u301))
(define-constant ERR_TRANSFER_FAILED (err u302))
(define-constant ERR_INVALID_AMOUNT (err u303))
(define-constant ERR_WITHDRAWAL_LIMIT (err u304))

;; Input Validation Errors
(define-constant ERR_INVALID_PARAMETER (err u400))
(define-constant ERR_INVALID_TIMEFRAME (err u401))
(define-constant ERR_INVALID_PRICE (err u402))
(define-constant ERR_INVALID_ADDRESS (err u403))
(define-constant ERR_STRING_TOO_LONG (err u404))

;; Business Logic Constants
(define-constant PREDICTION_UP "up")
(define-constant PREDICTION_DOWN "down")
(define-constant MAX_FEE_PERCENTAGE u10) ;; 10% maximum fee cap
(define-constant MINIMUM_MARKET_DURATION u144) ;; ~24 hours in blocks
(define-constant MAXIMUM_ASSET_NAME_LENGTH u32) ;; Asset name character limit
(define-constant BLOCKS_PER_DAY u144) ;; Approximate blocks per day

;; PROTOCOL STATE MANAGEMENT

;; Core Configuration Variables
(define-data-var oracle-address principal 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
(define-data-var minimum-stake uint u1000000) ;; 1 STX minimum stake
(define-data-var platform-fee-percentage uint u2) ;; 2% platform fee
(define-data-var market-counter uint u0)
(define-data-var protocol-paused bool false)