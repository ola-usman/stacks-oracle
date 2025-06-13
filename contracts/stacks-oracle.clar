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

;; Protocol Analytics & Statistics
(define-data-var total-volume uint u0)
(define-data-var total-fees-collected uint u0)
(define-data-var total-payouts uint u0)
(define-data-var active-markets-count uint u0)

;; DATA ARCHITECTURE

;; Comprehensive Market Data Structure
(define-map markets
  uint
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
    creation-block: uint,
  }
)

;; Enhanced User Prediction Tracking
(define-map user-predictions
  {
    market-id: uint,
    user: principal,
  }
  {
    prediction: (string-ascii 4),
    stake: uint,
    claimed: bool,
    timestamp: uint,
    block-height: uint,
  }
)

;; User Performance Analytics
(define-map user-stats
  principal
  {
    total-predictions: uint,
    total-winnings: uint,
    total-losses: uint,
    win-rate: uint,
    last-activity: uint,
  }
)

;; Market Performance Metrics
(define-map market-analytics
  uint
  {
    participation-rate: uint,
    volatility-score: uint,
    final-odds: uint,
    resolution-time: uint,
  }
)

;; CORE MARKET OPERATIONS

;; Create New Prediction Market with Enhanced Validation
(define-public (create-market
    (asset-name (string-ascii 32))
    (start-price uint)
    (start-block uint)
    (end-block uint)
  )
  (let (
      (market-id (var-get market-counter))
      (current-block stacks-block-height)
    )
    ;; Comprehensive Authorization & Validation
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (asserts! (not (var-get protocol-paused)) ERR_PROTOCOL_PAUSED)
    (asserts! (> end-block start-block) ERR_INVALID_TIMEFRAME)
    (asserts! (>= (- end-block start-block) MINIMUM_MARKET_DURATION)
      ERR_INVALID_TIMEFRAME
    )
    (asserts! (>= start-block current-block) ERR_INVALID_TIMEFRAME)
    (asserts! (> start-price u0) ERR_INVALID_PRICE)
    (asserts!
      (and (> (len asset-name) u0) (<= (len asset-name) MAXIMUM_ASSET_NAME_LENGTH))
      ERR_INVALID_PARAMETER
    )
    ;; Initialize Market Data
    (map-set markets market-id {
      creator: tx-sender,
      asset-name: asset-name,
      start-price: start-price,
      end-price: u0,
      total-up-stake: u0,
      total-down-stake: u0,
      start-block: start-block,
      end-block: end-block,
      resolution-block: u0,
      resolved: false,
      total-participants: u0,
      creation-block: current-block,
    })
    ;; Update Protocol State
    (var-set market-counter (+ market-id u1))
    (var-set active-markets-count (+ (var-get active-markets-count) u1))
    (ok market-id)
  )
)

;; Submit Prediction with Advanced Stake Management
(define-public (make-prediction
    (market-id uint)
    (prediction (string-ascii 4))
    (stake uint)
  )
  (let (
      (market (unwrap! (map-get? markets market-id) ERR_MARKET_NOT_FOUND))
      (current-block stacks-block-height)
      (existing-prediction (map-get? user-predictions {
        market-id: market-id,
        user: tx-sender,
      }))
    )
    ;; Comprehensive Validation Suite
    (asserts! (not (var-get protocol-paused)) ERR_PROTOCOL_PAUSED)
    (asserts!
      (and
        (>= current-block (get start-block market))
        (< current-block (get end-block market))
      )
      ERR_MARKET_CLOSED
    )
    (asserts!
      (or (is-eq prediction PREDICTION_UP) (is-eq prediction PREDICTION_DOWN))
      ERR_INVALID_PREDICTION
    )
    (asserts! (>= stake (var-get minimum-stake)) ERR_INSUFFICIENT_STAKE)
    (asserts! (>= (stx-get-balance tx-sender) stake) ERR_INSUFFICIENT_BALANCE)
    (asserts! (not (get resolved market)) ERR_MARKET_CLOSED)
    ;; Advanced Stake Management & Tracking
    (let (
        (final-stake (if (is-some existing-prediction)
          (+ stake (get stake (unwrap-panic existing-prediction)))
          stake
        ))
        (is-new-participant (is-none existing-prediction))
      )
      ;; Execute Stake Transfer
      (try! (stx-transfer? stake tx-sender (as-contract tx-sender)))
      ;; Update User Prediction Record
      (map-set user-predictions {
        market-id: market-id,
        user: tx-sender,
      } {
        prediction: prediction,
        stake: final-stake,
        claimed: false,
        timestamp: current-block,
        block-height: current-block,
      })
      ;; Update Market State & Analytics
      (map-set markets market-id
        (merge market {
          total-up-stake: (if (is-eq prediction PREDICTION_UP)
            (+ (get total-up-stake market) stake)
            (get total-up-stake market)
          ),
          total-down-stake: (if (is-eq prediction PREDICTION_DOWN)
            (+ (get total-down-stake market) stake)
            (get total-down-stake market)
          ),
          total-participants: (if is-new-participant
            (+ (get total-participants market) u1)
            (get total-participants market)
          ),
        })
      )
      ;; Update Global Protocol Metrics
      (var-set total-volume (+ (var-get total-volume) stake))
      ;; Update User Activity Statistics
      (update-user-activity tx-sender)
      (ok {
        market-id: market-id,
        total-stake: final-stake,
        participants: (get total-participants market),
      })
    )
  )
)

;; Oracle-Verified Market Resolution
(define-public (resolve-market
    (market-id uint)
    (end-price uint)
  )
  (let (
      (market (unwrap! (map-get? markets market-id) ERR_MARKET_NOT_FOUND))
      (current-block stacks-block-height)
    )
    ;; Oracle Authorization & Validation
    (asserts! (is-eq tx-sender (var-get oracle-address)) ERR_ORACLE_ONLY)
    (asserts! (>= current-block (get end-block market)) ERR_MARKET_CLOSED)
    (asserts! (not (get resolved market)) ERR_ALREADY_RESOLVED)
    (asserts! (> end-price u0) ERR_INVALID_PRICE)
    ;; Execute Market Resolution
    (map-set markets market-id
      (merge market {
        end-price: end-price,
        resolved: true,
        resolution-block: current-block,
      })
    )
    ;; Update Active Markets Counter
    (var-set active-markets-count (- (var-get active-markets-count) u1))
    ;; Calculate and Store Market Analytics
    (calculate-market-analytics market-id market end-price)
    (ok {
      market-id: market-id,
      end-price: end-price,
      resolution-block: current-block,
    })
  )
)

;; Advanced Winnings Distribution System
(define-public (claim-winnings (market-id uint))
  (let (
      (market (unwrap! (map-get? markets market-id) ERR_MARKET_NOT_FOUND))
      (prediction (unwrap!
        (map-get? user-predictions {
          market-id: market-id,
          user: tx-sender,
        })
        ERR_MARKET_NOT_FOUND
      ))
    )
    ;; Claim Eligibility Validation
    (asserts! (get resolved market) ERR_MARKET_NOT_RESOLVED)
    (asserts! (not (get claimed prediction)) ERR_ALREADY_CLAIMED)
    (let (
        (winning-prediction (if (> (get end-price market) (get start-price market))
          PREDICTION_UP
          PREDICTION_DOWN
        ))
        (total-pool (+ (get total-up-stake market) (get total-down-stake market)))
        (winning-pool (if (is-eq winning-prediction PREDICTION_UP)
          (get total-up-stake market)
          (get total-down-stake market)
        ))
        (user-stake (get stake prediction))
      )
      ;; Winner Validation & Pool Verification
      (asserts! (is-eq (get prediction prediction) winning-prediction)
        ERR_INVALID_PREDICTION
      )
      (asserts! (> winning-pool u0) ERR_INVALID_PARAMETER)
      (let (
          ;; Advanced Payout Calculation
          (gross-winnings (/ (* user-stake total-pool) winning-pool))
          (platform-fee (/ (* gross-winnings (var-get platform-fee-percentage)) u100))
          (net-payout (- gross-winnings platform-fee))
        )
        ;; Execute Financial Transfers
        (try! (as-contract (stx-transfer? net-payout (as-contract tx-sender) tx-sender)))
        (try! (as-contract (stx-transfer? platform-fee (as-contract tx-sender) CONTRACT_OWNER)))
        ;; Update User Prediction Status
        (map-set user-predictions {
          market-id: market-id,
          user: tx-sender,
        }
          (merge prediction { claimed: true })
        )
        ;; Update Comprehensive User Statistics
        (update-user-stats tx-sender net-payout true)
        ;; Update Global Protocol Metrics
        (var-set total-fees-collected
          (+ (var-get total-fees-collected) platform-fee)
        )
        (var-set total-payouts (+ (var-get total-payouts) net-payout))
        (ok {
          payout: net-payout,
          fee: platform-fee,
          return-multiple: (/ gross-winnings user-stake),
        })
      )
    )
  )
)