CREATE TABLE transaction_master (
    tenant VARCHAR(50) NOT NULL,
    branch_id INT NOT NULL,
    transaction_code VARCHAR(50) PRIMARY KEY,
    transaction_desc VARCHAR(200) NOT NULL
);

CREATE TABLE branch_master (
    tenant VARCHAR(50) NOT NULL,
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(50) NOT NULL,
    branch_type VARCHAR(200)
);

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE session_master (
    tenant VARCHAR(50) NOT NULL,
    branch_id INT NOT NULL,
    sessionid UUID DEFAULT uuid_generate_v4(),
    customer_rep CHAR(1) CHECK (customer_rep IN ('C', 'R')) NOT NULL,
    authentication_method VARCHAR(20) CHECK (authentication_method IN ('Card', 'CIF', 'Account number', 'NID', 'Passport', 'DL')),
    cif VARCHAR(50) NOT NULL,
    account_no JSON,
    session_start TIMESTAMP WITH TIME ZONE,
    session_end TIMESTAMP WITH TIME ZONE,
    userid INT, --UserId: user id (current session owner)
    provider_name VARCHAR(50),
    username VARCHAR(100),
    id_type VARCHAR(20),
    id_no VARCHAR(50),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    dob DATE,
    gender CHAR(1) CHECK (gender IN ('M', 'F', 'O')),
    PRIMARY KEY (sessionid)
);

CREATE TABLE currency_master (
    tenant VARCHAR(50) NOT NULL,
    branch_id INT NOT NULL,
    currency_code VARCHAR(5) PRIMARY KEY,
    currency_name VARCHAR(50)
);

CREATE TABLE denomination_master (
    tenant VARCHAR(50) NOT NULL,
    branch_id INT NOT NULL,
    currency_code VARCHAR(5) NOT NULL,
    denomination_code Serial PRIMARY KEY,
    denomination_label VARCHAR(50),
    denomination_value INT NOT NULL,
    FOREIGN KEY (currency_code) REFERENCES currency_master(currency_code)
);

CREATE TABLE transactions (
    tenant VARCHAR(50) NOT NULL,
    branch_id INT NOT NULL,
    transaction_id VARCHAR(50) UNIQUE NOT NULL,
    transaction_code VARCHAR(100) NOT NULL,
    transaction_status CHAR(1) CHECK (transaction_status IN ('D', 'I', 'B', 'S', 'F', 'R')),        --(D = Draft, I = Initiated, B = Submitted, S = Success, F = Failed, R = Reversed)
    auth_status CHAR(1) CHECK (auth_status IN ('A', 'U', 'R')),                                     --(A = Auth, U = Unauthorised, R = Refered)
    sessionid UUID,
    created_by VARCHAR(50),
    created_by_user_id INT,
    created_by_provider VARCHAR(50),
    create_timestamp TIMESTAMP WITH TIME ZONE,
    last_updated_user VARCHAR(50),
    last_updated_user_id INT,
    last_updated_user_provider VARCHAR(50),
    last_updated_timestamp TIMESTAMP WITH TIME ZONE,
    comments CHAR(1) CHECK (comments IN ('Y', 'N')),
    data_table JSONB,                           --whole transaction screen json
    callback_done CHAR(1) CHECK (callback_done IN ('Y', 'N')),
    PRIMARY KEY (transaction_id, transaction_status),
    FOREIGN KEY (transaction_code) REFERENCES transaction_master(transaction_code),
    FOREIGN KEY (sessionid) REFERENCES session_master(sessionid)
);

CREATE TABLE financial_transactions (
    tenant VARCHAR(50) NOT NULL,
    branch_id INT NOT NULL,
    sessionid UUID,
    transaction_id VARCHAR(50) PRIMARY KEY,
    denom_tracking CHAR(1) CHECK (Denom_tracking IN ('Y', 'N')),
    from_account VARCHAR(50),
    to_account VARCHAR(50),
    from_currency VARCHAR(50) NOT NULL,
    to_currency VARCHAR(50) NOT NULL,
    from_amount INT NOT NULL,
    to_amount INT NOT NULL,
    source_of_funds VARCHAR(100),
    purpose VARCHAR(100),
    remarks1 VARCHAR(200),
    remarks2 VARCHAR(200),
    exchange_rate_type VARCHAR(50),
    exchange_rate VARCHAR(50),
    special_rate CHAR(1) CHECK (special_rate IN ('Y', 'N')),
    treasury_remarks VARCHAR(50),
    treasury_approved CHAR(1) CHECK (treasury_approved IN ('Y', 'N')),
    treasury_approved_date TIMESTAMP WITH TIME ZONE,
    instrument_type VARCHAR(50),
    instrument_date TIMESTAMP WITH TIME ZONE,
    instrument_number VARCHAR(50),
    value_date TIMESTAMP WITH TIME ZONE,                  --instrument value date
    FOREIGN KEY (sessionid) REFERENCES session_master(sessionid),
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);

CREATE TABLE comments (
    tenant VARCHAR(50) NOT NULL,
    branch_id INT NOT NULL,
    sessionid UUID NOT NULL,
    transaction_id VARCHAR(50) NOT NULL,
    sequence_number INT PRIMARY KEY,        --approval flow sequence number
    user_provider VARCHAR(50),
    username VARCHAR(100) NOT NULL,
    userid INT NOT NULL,
    comments VARCHAR(200) NOT NULL,
    comments_date TIMESTAMP WITH TIME ZONE NOT NULL,
    FOREIGN KEY (sessionid) REFERENCES session_master(sessionid),
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);

CREATE TABLE till_master(
    tenant VARCHAR(50) NOT NULL,
    branch_id INT NOT NULL,
    till_id INT UNIQUE NOT NULL,
    till_status CHAR(1) CHECK (till_status IN ('O', 'C')),         --(O - Open, C - Close)
    till_type VARCHAR(20) CHECK (till_type IN ('Till', 'vault', 'chief teller', 'cash centre')),
    currency_code VARCHAR(5) NOT NULL,
    denominations JSONB,  -- Changed to: { "denom_code": "denom_count", "denom_code": "denom_count" }
    balance INT,
    PRIMARY KEY (tenant, branch_id, till_id, currency_code),
    FOREIGN KEY (currency_code) REFERENCES currency_master(currency_code)
);

CREATE TABLE user_till_master (
    tenant VARCHAR(50) NOT NULL,
    branch_id INT NOT NULL,
    user_provider VARCHAR(50),
    username VARCHAR(100) NOT NULL,
    userid INT NOT NULL UNIQUE,
    till_id INT UNIQUE,
    aprover_provider VARCHAR(20),
    aprover_id INT NOT NULL,
    aprover_name VARCHAR(20),
    PRIMARY KEY (tenant, branch_id, userid)
    FOREIGN KEY (till_id) REFERENCES till_master(till_id)

);


CREATE TABLE transaction_denomination (
    tenant VARCHAR(50) NOT NULL,
    branch_id INT NOT NULL,
    transaction_id VARCHAR(50) UNIQUE,
    till_id INT NOT NULL,
    currency_code VARCHAR(50) NOT NULL,
    related_account VARCHAR(50),          --Offset account (customer’s or other till /valut account)
    amount INT NOT NULL,                   --transaction amount (in the currency of transaction)
    denominations JSONB NOT NULL,                   --{Denom_code (FK): denomination code (denomination_master), denom_count: Count of denominations}
    PRIMARY KEY (tenant, branch_id, till_id, transaction_id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    FOREIGN KEY (till_id) REFERENCES till_master(till_id),
    FOREIGN KEY (currency_code) REFERENCES currency_master(currency_code)
    -- FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    -- FOREIGN KEY (tenant, branch_id, till_id, currency_code) REFERENCES till_master(tenant, branch_id, till_id, currency_code)
);

-- CREATE TABLE audit_log_txns (
--     tenant VARCHAR(50) NOT NULL,
--     branch_id INT NOT NULL,
--     audit_id INT PRIMARY KEY,
--     transaction_id VARCHAR(50) NOT NULL,
--     till_id INT NOT NULL,
--     currency_code VARCHAR(50) NOT NULL,
--     amount INT NOT NULL,
--     updated_denominations JSONB NOT NULL,
--     update_date TIMESTAMP WITH TIME ZONE,
--     userid INT NOT NULL,            --user id making the change
--     username VARCHAR(50) NOT NULL,       --user making the change
--     FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
-- );