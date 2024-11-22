CREATE TABLE transaction_master (
    tenant VARCHAR(50),
    branch_id INT,
    transaction_code VARCHAR(50) PRIMARY KEY,
    transaction_desc VARCHAR(200)
);

CREATE TABLE branch_master (
    tenant VARCHAR(50),
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(50),
    branch_type VARCHAR(200)
);

CREATE TABLE session_master (
    tenant VARCHAR(50),
    branch_id INT,
    sessionid VARCHAR(50) PRIMARY KEY,
    customer_rep CHAR(1) CHECK (customer_rep IN ('C', 'R')),
    authentication_method VARCHAR(20) CHECK (authentication_method IN ('Card', 'CIF', 'Account number', 'NID', 'Passport', 'DL')),
    cif VARCHAR(50),
    account_no JSON,
    session_start TIMESTAMP,
    session_end TIMESTAMP,
    userid VARCHAR(50), --UserId: user id (current session owner)
    provider_name VARCHAR(50),
    username VARCHAR(100),
    id_type VARCHAR(20),
    id_no VARCHAR(50),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    dob DATE,
    gender CHAR(1) CHECK (gender IN ('M', 'F', 'O')),
    callback_done CHAR(1) CHECK (callback_done IN ('Y', 'N')) 
);

CREATE TABLE currency_master (
    tenant VARCHAR(50),
    branch_id INT,
    -- currency_id VARCHAR(50) PRIMARY KEY,    --Currency key
    currency_code VARCHAR(5) PRIMARY KEY,
    currency_name VARCHAR(50)
);

CREATE TABLE denomination_master (
    tenant VARCHAR(50),
    branch_id INT,
    currency_code VARCHAR(5),
    denomination_code Serial PRIMARY KEY,
    denomination_label VARCHAR(50),   -----
    denomination_value INT,
    FOREIGN KEY (currency_code) REFERENCES currency_master(currency_code)
);

CREATE TABLE till_master (
    tenant VARCHAR(50),
    branch_id INT,
    till_id VARCHAR(50) UNIQUE,
    till_status CHAR(1) CHECK (till_status IN ('O', 'C')),         --(O - Open, C - Close)
    till_type VARCHAR(20) CHECK (till_type IN ('Till', 'vault', 'chief teller', 'cash centre')),
    currency_code VARCHAR(5),
    denomination_code INT,
    denominations JSONB,  --{denom_code (FK): denomination code (denomination_master), denom_count: Count of denominations}
    denomination_value INT,
    PRIMARY KEY (tenant, branch_id, till_id),
    FOREIGN KEY (currency_code) REFERENCES currency_Master(currency_code),
    FOREIGN KEY (denomination_code) REFERENCES denomination_master(denomination_code),
    CHECK (
        denominations ? 'Denom_code' AND
        denominations ? 'Denom_count' AND
        (denominations->>'Denom_code')::INT = denomination_code
    )
);


CREATE TABLE user_till_master (
    tenant VARCHAR(50),
    branch_id INT,
    user_provider VARCHAR(50),
    username VARCHAR(100),
    userid VARCHAR(50),
    till_id VARCHAR(50) PRIMARY KEY,
    aprover_provider VARCHAR(20),
    aprover_is VARCHAR(20),
    aprover_name VARCHAR(20),
    FOREIGN KEY (till_Id) REFERENCES till_master(till_id)
);

CREATE TABLE transactions (
    tenant VARCHAR(50),
    branch_id INT,
    transaction_id VARCHAR(50) UNIQUE,
    transaction_code VARCHAR(100),
    transaction_status CHAR(1) CHECK (transaction_status IN ('D', 'I', 'B', 'S', 'F', 'R')),        --(D = Draft, I = Initiated, B = Submitted, S = Success, F = Failed, R = Reversed)
    auth_status CHAR(1) CHECK (auth_status IN ('A', 'U', 'R')),                                     --(A = Auth, U = Unauthorised, R = Refered)
    sessionid VARCHAR(50),
    created_by VARCHAR(50),
    created_by_user_id VARCHAR(50),
    created_by_provider VARCHAR(50),
    create_timestamp TIMESTAMP,
    last_updated_user VARCHAR(50),
    last_updated_user_id VARCHAR(50),
    last_updated_user_provider VARCHAR(50),
    last_updated_timestamp TIMESTAMP,
    comments CHAR(1) CHECK (comments IN ('Y', 'N')),
    data_table VARCHAR(50),
    PRIMARY KEY (transaction_id, transaction_status),
    FOREIGN KEY (transaction_code) REFERENCES transaction_master(transaction_code),
    FOREIGN KEY (sessionid) REFERENCES session_master(sessionid)
);

CREATE TABLE financial_transactions (
    tenant VARCHAR(50),
    branch_id INT,
    sessionid VARCHAR(50),
    transaction_id VARCHAR(50) PRIMARY KEY,
    denom_tracking CHAR(1) CHECK (Denom_tracking IN ('Y', 'N')),
    from_account VARCHAR(50),
    to_account VARCHAR(50),
    from_currency VARCHAR(50),
    to_currency VARCHAR(50),
    from_amount VARCHAR(50),
    to_amount VARCHAR(50),
    source_of_funds VARCHAR(100),
    purpose VARCHAR(100),
    remarks1 VARCHAR(200),
    remarks2 VARCHAR(200),
    exchange_rate_type VARCHAR(50),
    exchange_rate VARCHAR(50),
    special_rate CHAR(1) CHECK (special_rate IN ('Y', 'N')),
    treasury_remarks VARCHAR(50),
    treasury_approved CHAR(1) CHECK (treasury_approved IN ('Y', 'N')),
    treasury_approved_date TIMESTAMP,
    instrument_type VARCHAR(50),
    instrument_date VARCHAR(50),
    instrument_number VARCHAR(50),
    value_date VARCHAR(50),                  --instrument value date
    FOREIGN KEY (sessionid) REFERENCES session_master(sessionid)
);

CREATE TABLE comments (
    tenant VARCHAR(50),
    branch_id INT,
    sessionid VARCHAR(50),
    transaction_id VARCHAR(50),
    sequence_number INT PRIMARY KEY,        --approval flow sequence number
    user_provider VARCHAR(50),
    username VARCHAR(100),
    userid VARCHAR(50),
    comments VARCHAR(200),
    comments_date TIMESTAMP,
    FOREIGN KEY (sessionid) REFERENCES session_master(sessionid),
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);

CREATE TABLE transaction_denomination (
    tenant VARCHAR(50),
    branch_id INT,
    transaction_id VARCHAR(50) UNIQUE,
    till_id VARCHAR(50),
    currency_code VARCHAR(50),
    related_account VARCHAR(50),          --Offset account (customer’s or other till /valut account)
    amount VARCHAR(50),                   --transaction amount (in the currency of transaction)
    denomination_code INT,
    denominations JSONB,                   --{Denom_code (FK): denomination code (denomination_master), denom_count: Count of denominations}
    PRIMARY KEY (tenant, branch_id, transaction_id),
    FOREIGN KEY (currency_code) REFERENCES currency_master(currency_code),
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    FOREIGN KEY (till_id) REFERENCES till_master(till_id),
    FOREIGN KEY (denomination_code) REFERENCES denomination_master(denomination_code),
    CHECK (
        denominations ? 'Denom_code' AND
        denominations ? 'Denom_count' AND
        (denominations->>'Denom_code')::INT = denomination_code
    )
);

--Create a transaction journey flow (how data will be stored in these tables)

--deno_value : total amnt (200USD)
--deno_label : 200
--deno_count : total notes / coins (2) like 2 100USD notes

/*
1. Branch?  -> Branch_Id
2. Transaction_id (Tran_deno) referring to Transaction_id (Tran_master) but no txn_id in Txn_Master  -> changed txn_master to txns
3. Till id of Txn Deno should refer to till id of till master? what is user till master then  -> till id in utm is fk to tm
4. Currency code is fk used but that's not primary key in currency master (currency id is pk) -> make ccode pk and remove cid
5. Amount in transaction details
6. Comments? in Transactions (to store Y, N or comment content?) -> flag, may not be required
7.provider? user? (in session master) 0> provider : validator, user -> customer
8.Tenant, Branch pk? in tillmaster, transaction_master  -> composite keys
1. Transaction_Denomination -> Transaction_id is primary key and foreign key at the same time?  -> okay
2. UserTillMaster -> TillId is foreign key and primary too?  -> okay
3. Denominations? JSON combination of FK and data -> check constraint/serialize it
4. Denomination_value?
5. Primary keys combination in some tables? -> make composite keys but txn_id should be mandatory -> ask shrujan  -> make composite
- 6. user_provider? etc in user till master
- 7. Created_By? Created_by_provider etc in Transactions?

TBD
- Create a transaction journey flow (how data will be stored in these tables)
- Session master account json?
*/