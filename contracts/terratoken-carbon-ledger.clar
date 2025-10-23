(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-registered (err u101))
(define-constant err-already-registered (err u102))
(define-constant err-insufficient-credits (err u103))
(define-constant err-project-not-found (err u104))
(define-constant err-invalid-amount (err u105))
(define-constant err-unauthorized (err u106))
(define-constant err-not-verified (err u107))
(define-constant err-already-verified (err u108))
(define-constant err-invalid-price (err u109))
(define-constant err-listing-not-found (err u110))
(define-constant err-cannot-buy-own (err u111))
(define-constant err-project-inactive (err u112))

(define-data-var next-user-id uint u1)
(define-data-var next-project-id uint u1)
(define-data-var next-listing-id uint u1)
(define-data-var total-carbon-credits uint u0)
(define-data-var total-offsets-retired uint u0)
(define-data-var registration-fee uint u10000)
(define-data-var verification-fee uint u50000)
(define-data-var platform-fee-rate uint u50)

(define-map carbon-users principal {
    id: uint,
    name: (string-ascii 256),
    user-type: (string-ascii 32),
    location: (string-ascii 128),
    carbon-credits: uint,
    credits-issued: uint,
    credits-retired: uint,
    reputation: uint,
    join-block: uint,
    active: bool
})

(define-map carbon-projects uint {
    id: uint,
    title: (string-ascii 256),
    description: (string-ascii 512),
    project-type: (string-ascii 64),
    location: (string-ascii 128),
    developer: principal,
    total-credits: uint,
    credits-issued: uint,
    credits-available: uint,
    verification-status: (string-ascii 32),
    created-block: uint,
    verified-block: uint,
    methodology: (string-ascii 128),
    active: bool
})

(define-map credit-listings uint {
    id: uint,
    seller: principal,
    project-id: uint,
    credits-amount: uint,
    price-per-credit: uint,
    total-price: uint,
    listing-block: uint,
    active: bool,
    sold: bool
})

(define-map offset-retirements uint {
    user: principal,
    project-id: uint,
    credits-retired: uint,
    retirement-reason: (string-ascii 256),
    retirement-block: uint,
    certificate-hash: (string-ascii 64)
})

(define-map verification-requests uint {
    project-id: uint,
    verifier: principal,
    requested-block: uint,
    completed: bool,
    verification-data: (string-ascii 512),
    fee-paid: uint
})

(define-map trading-transactions uint {
    buyer: principal,
    seller: principal,
    project-id: uint,
    credits-traded: uint,
    price-per-credit: uint,
    total-amount: uint,
    transaction-block: uint,
    platform-fee: uint
})

(define-data-var next-retirement-id uint u1)
(define-data-var next-verification-id uint u1)
(define-data-var next-transaction-id uint u1)

(define-public (register-user (name (string-ascii 256)) (user-type (string-ascii 32)) (location (string-ascii 128)))
    (let ((user-id (var-get next-user-id)))
        (asserts! (is-none (map-get? carbon-users tx-sender)) err-already-registered)
        (try! (stx-transfer? (var-get registration-fee) tx-sender (as-contract tx-sender)))
        (map-set carbon-users tx-sender {
            id: user-id,
            name: name,
            user-type: user-type,
            location: location,
            carbon-credits: u0,
            credits-issued: u0,
            credits-retired: u0,
            reputation: u100,
            join-block: stacks-block-height,
            active: true
        })
        (var-set next-user-id (+ user-id u1))
        (ok user-id)
    )
)

(define-public (register-carbon-project 
    (title (string-ascii 256))
    (description (string-ascii 512))
    (project-type (string-ascii 64))
    (location (string-ascii 128))
    (total-credits uint)
    (methodology (string-ascii 128))
)
    (let ((project-id (var-get next-project-id)))
        (asserts! (is-some (map-get? carbon-users tx-sender)) err-not-registered)
        (asserts! (> total-credits u0) err-invalid-amount)
        (map-set carbon-projects project-id {
            id: project-id,
            title: title,
            description: description,
            project-type: project-type,
            location: location,
            developer: tx-sender,
            total-credits: total-credits,
            credits-issued: u0,
            credits-available: u0,
            verification-status: "pending",
            created-block: stacks-block-height,
            verified-block: u0,
            methodology: methodology,
            active: true
        })
        (var-set next-project-id (+ project-id u1))
        (ok project-id)
    )
)

(define-public (verify-carbon-project (project-id uint) (verification-data (string-ascii 512)))
    (let ((project (unwrap! (map-get? carbon-projects project-id) err-project-not-found))
          (verification-id (var-get next-verification-id)))
        (asserts! (is-some (map-get? carbon-users tx-sender)) err-not-registered)
        (asserts! (is-eq (get verification-status project) "pending") err-already-verified)
        (try! (stx-transfer? (var-get verification-fee) tx-sender (as-contract tx-sender)))
        (map-set verification-requests verification-id {
            project-id: project-id,
            verifier: tx-sender,
            requested-block: stacks-block-height,
            completed: false,
            verification-data: verification-data,
            fee-paid: (var-get verification-fee)
        })
        (map-set carbon-projects project-id (merge project {
            verification-status: "verified",
            verified-block: stacks-block-height,
            credits-available: (get total-credits project)
        }))
        (var-set next-verification-id (+ verification-id u1))
        (ok verification-id)
    )
)

(define-public (issue-carbon-credits (project-id uint) (credits-amount uint))
    (let ((project (unwrap! (map-get? carbon-projects project-id) err-project-not-found))
          (user (unwrap! (map-get? carbon-users tx-sender) err-not-registered)))
        (asserts! (is-eq tx-sender (get developer project)) err-unauthorized)
        (asserts! (is-eq (get verification-status project) "verified") err-not-verified)
        (asserts! (<= (+ (get credits-issued project) credits-amount) (get total-credits project)) err-invalid-amount)
        (map-set carbon-projects project-id (merge project {
            credits-issued: (+ (get credits-issued project) credits-amount),
            credits-available: (- (get credits-available project) credits-amount)
        }))
        (map-set carbon-users tx-sender (merge user {
            carbon-credits: (+ (get carbon-credits user) credits-amount),
            credits-issued: (+ (get credits-issued user) credits-amount)
        }))
        (var-set total-carbon-credits (+ (var-get total-carbon-credits) credits-amount))
        (ok credits-amount)
    )
)

(define-public (list-credits-for-sale (project-id uint) (credits-amount uint) (price-per-credit uint))
    (let ((listing-id (var-get next-listing-id))
          (user (unwrap! (map-get? carbon-users tx-sender) err-not-registered))
          (project (unwrap! (map-get? carbon-projects project-id) err-project-not-found)))
        (asserts! (>= (get carbon-credits user) credits-amount) err-insufficient-credits)
        (asserts! (> price-per-credit u0) err-invalid-price)
        (map-set credit-listings listing-id {
            id: listing-id,
            seller: tx-sender,
            project-id: project-id,
            credits-amount: credits-amount,
            price-per-credit: price-per-credit,
            total-price: (* credits-amount price-per-credit),
            listing-block: stacks-block-height,
            active: true,
            sold: false
        })
        (map-set carbon-users tx-sender (merge user {
            carbon-credits: (- (get carbon-credits user) credits-amount)
        }))
        (var-set next-listing-id (+ listing-id u1))
        (ok listing-id)
    )
)

(define-public (buy-carbon-credits (listing-id uint))
    (let ((listing (unwrap! (map-get? credit-listings listing-id) err-listing-not-found))
          (buyer (unwrap! (map-get? carbon-users tx-sender) err-not-registered))
          (seller (unwrap! (map-get? carbon-users (get seller listing)) err-not-registered))
          (platform-fee (* (get total-price listing) (var-get platform-fee-rate)))
          (seller-amount (- (get total-price listing) (/ platform-fee u1000)))
          (transaction-id (var-get next-transaction-id)))
        (asserts! (not (is-eq tx-sender (get seller listing))) err-cannot-buy-own)
        (asserts! (get active listing) err-listing-not-found)
        (asserts! (not (get sold listing)) err-listing-not-found)
        (try! (stx-transfer? (get total-price listing) tx-sender (as-contract tx-sender)))
        (try! (as-contract (stx-transfer? seller-amount tx-sender (get seller listing))))
        (map-set credit-listings listing-id (merge listing {
            active: false,
            sold: true
        }))
        (map-set carbon-users tx-sender (merge buyer {
            carbon-credits: (+ (get carbon-credits buyer) (get credits-amount listing))
        }))
        (map-set trading-transactions transaction-id {
            buyer: tx-sender,
            seller: (get seller listing),
            project-id: (get project-id listing),
            credits-traded: (get credits-amount listing),
            price-per-credit: (get price-per-credit listing),
            total-amount: (get total-price listing),
            transaction-block: stacks-block-height,
            platform-fee: (/ platform-fee u1000)
        })
        (var-set next-transaction-id (+ transaction-id u1))
        (ok transaction-id)
    )
)

(define-public (retire-carbon-credits 
    (project-id uint) 
    (credits-amount uint) 
    (retirement-reason (string-ascii 256))
    (certificate-hash (string-ascii 64))
)
    (let ((user (unwrap! (map-get? carbon-users tx-sender) err-not-registered))
          (project (unwrap! (map-get? carbon-projects project-id) err-project-not-found))
          (retirement-id (var-get next-retirement-id)))
        (asserts! (>= (get carbon-credits user) credits-amount) err-insufficient-credits)
        (asserts! (get active project) err-project-inactive)
        (map-set offset-retirements retirement-id {
            user: tx-sender,
            project-id: project-id,
            credits-retired: credits-amount,
            retirement-reason: retirement-reason,
            retirement-block: stacks-block-height,
            certificate-hash: certificate-hash
        })
        (map-set carbon-users tx-sender (merge user {
            carbon-credits: (- (get carbon-credits user) credits-amount),
            credits-retired: (+ (get credits-retired user) credits-amount),
            reputation: (+ (get reputation user) (/ credits-amount u10))
        }))
        (var-set total-offsets-retired (+ (var-get total-offsets-retired) credits-amount))
        (var-set next-retirement-id (+ retirement-id u1))
        (ok retirement-id)
    )
)

(define-public (cancel-credit-listing (listing-id uint))
    (let ((listing (unwrap! (map-get? credit-listings listing-id) err-listing-not-found))
          (user (unwrap! (map-get? carbon-users tx-sender) err-not-registered)))
        (asserts! (is-eq tx-sender (get seller listing)) err-unauthorized)
        (asserts! (get active listing) err-listing-not-found)
        (asserts! (not (get sold listing)) err-listing-not-found)
        (map-set credit-listings listing-id (merge listing {active: false}))
        (map-set carbon-users tx-sender (merge user {
            carbon-credits: (+ (get carbon-credits user) (get credits-amount listing))
        }))
        (ok listing-id)
    )
)

(define-public (transfer-credits (recipient principal) (credits-amount uint))
    (let ((sender (unwrap! (map-get? carbon-users tx-sender) err-not-registered))
          (receiver (unwrap! (map-get? carbon-users recipient) err-not-registered)))
        (asserts! (>= (get carbon-credits sender) credits-amount) err-insufficient-credits)
        (map-set carbon-users tx-sender (merge sender {
            carbon-credits: (- (get carbon-credits sender) credits-amount)
        }))
        (map-set carbon-users recipient (merge receiver {
            carbon-credits: (+ (get carbon-credits receiver) credits-amount)
        }))
        (ok credits-amount)
    )
)

(define-public (deactivate-project (project-id uint))
    (let ((project (unwrap! (map-get? carbon-projects project-id) err-project-not-found)))
        (asserts! (is-eq tx-sender (get developer project)) err-unauthorized)
        (map-set carbon-projects project-id (merge project {active: false}))
        (ok project-id)
    )
)

(define-public (deactivate-user (user-principal principal))
    (let ((user (unwrap! (map-get? carbon-users user-principal) err-not-registered)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set carbon-users user-principal (merge user {active: false}))
        (ok true)
    )
)

(define-read-only (get-user (user-principal principal))
    (map-get? carbon-users user-principal)
)

(define-read-only (get-project (project-id uint))
    (map-get? carbon-projects project-id)
)

(define-read-only (get-credit-listing (listing-id uint))
    (map-get? credit-listings listing-id)
)

(define-read-only (get-retirement-record (retirement-id uint))
    (map-get? offset-retirements retirement-id)
)

(define-read-only (get-verification-request (verification-id uint))
    (map-get? verification-requests verification-id)
)

(define-read-only (get-trading-transaction (transaction-id uint))
    (map-get? trading-transactions transaction-id)
)

(define-read-only (get-platform-stats)
    (ok {
        total-users: (- (var-get next-user-id) u1),
        total-projects: (- (var-get next-project-id) u1),
        total-carbon-credits: (var-get total-carbon-credits),
        total-offsets-retired: (var-get total-offsets-retired),
        active-listings: (- (var-get next-listing-id) u1),
        total-transactions: (- (var-get next-transaction-id) u1),
        registration-fee: (var-get registration-fee),
        verification-fee: (var-get verification-fee),
        platform-fee-rate: (var-get platform-fee-rate)
    })
)

(define-read-only (get-user-credits (user-principal principal))
    (match (map-get? carbon-users user-principal)
        user (ok (get carbon-credits user))
        err-not-registered
    )
)

(define-read-only (get-project-credits-available (project-id uint))
    (match (map-get? carbon-projects project-id)
        project (ok (get credits-available project))
        err-project-not-found
    )
)