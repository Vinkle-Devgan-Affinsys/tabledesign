-- Active: 1732686745279@@127.0.0.1@5432@postgres@public

--inserting data into tables to test

INSERT INTO transaction_master
VALUES 
( 'tn3', 1, 'T002', 'Cash withdrawal');

INSERT INTO currency_master
VALUES (
    'tn1', 1, 'USD', 'US Dollars'
);

TRUNCATE TABLE transaction_master CASCADE;

TRUNCATE TABLE currency_master CASCADE;


INSERT INTO branch_master
VALUES 
( 'tn1', 1, 'B001', 'branchtype1');

INSERT INTO session_master
VALUES 
( 'tn1', 1, 'S001', 'C', 'Card', '1234', '{"Acc1": "USD", "Acc2": "INR"}', '2024-11-21 10:30:00' , '2024-11-21 11:30:00', 'User 001', 'Vinkle', 'Aditi', 'NID', '1234567', 'Aditi', 'Sharma', '2024-09-01', 'F', 'Y' );

INSERT INTO denomination_master
VALUES 
( 'tn1', 1, 'USD', 2, 'D001', '210' );

INSERT INTO denomination_master
VALUES 
( 'tn1', 1, 'USD', 1, 'D001', '210' );

INSERT INTO denomination_master
VALUES 
( 'tn1', 1, 'USD', 3, 'D001', '210' );

INSERT INTO denomination_master (tenant, branch_id, currency_code, denomination_label, denomination_value)
VALUES 
( 'tn1', 1, 'USD', 'D001', '210' );

TRUNCATE TABLE denomination_master CASCADE;

INSERT INTO denomination_master (tenant, branch_id, currency_code, denomination_label, denomination_value)
VALUES 
( 'tn1', 1, 'USD', 'D001', '210' );

INSERT INTO denomination_master (tenant, branch_id, currency_code, denomination_label, denomination_value)
VALUES 
( 'tn1', 1, 'USD', 'D002', '1010' );

INSERT INTO till_master
VALUES 
( 'tn1', 1, 'Till002', 'C', 'vault','USD', 5, '{"Denom_code": 5 , "Denom_count" : 22}' , 230 );

INSERT INTO user_till_master
VALUES 
( 'tn1', 1, 'Vinkle', 'Aditi', 'U001','Till001','Agent', 'Agent', 'Agent' );

INSERT INTO transactions
VALUES 
( 'tn1', 1, 'TI001', 'T002', 'D', 'U', 'S001', 'Aditi', '12345','Vinkle', '2024-11-21 10:30:00' , 'V', 'User01', 'Vinkle', '2024-11-21 12:30:00', 'Y', 'Table1');


INSERT INTO transaction_denomination (tenant, branch_id, transaction_id, till_id, currency_code, related_account, amount, denominations)
VALUES 
( 'tn1', 1, 'TI001', 'Till001', 'USD', 'No', '12345', '{"Denom_code": 6 , "Denom_count" : 22}' );


TRUNCATE TABLE transaction_denomination CASCADE;


--adding not null constraint
ALTER TABLE transaction_denomination
ALTER COLUMN denomination_code SET NOT NULL;

ALTER TABLE till_master
ALTER COLUMN denomination_code SET NOT NULL;

INSERT INTO transaction_denomination (tenant, branch_id, transaction_id, till_id, currency_code, related_account, amount, denomination_code, denominations)
VALUES 
( 'tn1', 1, 'TI001', 'Till001', 'USD', 'No', '12345', 5, '{"Denom_code": 5 , "Denom_count" : 22}' );


TRUNCATE TABLE session_master CASCADE;


--------25th November

--Auto-populating branch master, CCY Master, deno master, till master
INSERT INTO branch_master
VALUES 
( 'fcbsmartbranch', 1, 'B001', 'branchtype1'),
( 'fcbsmartbranch', 2, 'B002', 'branchtype2'),
( 'fcbsmartbranch', 3, 'B003', 'branchtype3'),
( 'fcbsmartbranch', 4, 'B004', 'branchtype4'),
( 'fcbsmartbranch', 5, 'B005', 'branchtype5');

--into currency
INSERT INTO currency_master
VALUES 
( 'fcbsmartbranch', 1, 'USD', 'American Dollars'),
( 'fcbsmartbranch', 1, 'INR', 'Indian Rupee');

--into deno master
INSERT INTO denomination_master(tenant, branch_id, currency_code, denomination_label, denomination_value)
VALUES 
( 'fcbsmartbranch', 1, 'USD', '$100', 100),
( 'fcbsmartbranch', 1, 'INR', 'R200', 200);

ALTER TABLE financial_transactions
ALTER COLUMN instrument_date SET DATA TYPE DATE USING instrument_date::DATE;

ALTER TABLE financial_transactions
ALTER COLUMN value_date SET DATA TYPE DATE USING value_date::DATE;

INSERT INTO till_master
VALUES 
( 'fcbsmartbranch', 1, 'Till1', 'O', 'vault', 'USD', 1, '{"Denom_code": "1", "Denom_count" : 5}', 500),
( 'fcbsmartbranch', 1, 'Till2', 'C', 'vault', 'INR', 2, '{"Denom_code": "2", "Denom_count" : 2}', 200);

TRUNCATE TABLE till_master CASCADE;

INSERT INTO till_master
VALUES 
( 'fcbsmartbranch', 1, 'Till001', 'O', 'vault', 'USD', 1, '{"Denom_code": "1", "Denom_count" : 5}', 500),
( 'fcbsmartbranch', 1, 'Till002', 'C', 'vault', 'INR', 2, '{"Denom_code": "2", "Denom_count" : 2}', 200);

TRUNCATE TABLE session_master CASCADE;
TRUNCATE TABLE financial_transactions CASCADE;
TRUNCATE TABLE transactions CASCADE;
TRUNCATE TABLE transaction_master CASCADE;
TRUNCATE TABLE denomination_master CASCADE;

-- V3

INSERT INTO denomination_master (tenant, branch_id, currency_code, denomination_code, denomination_label, denomination_value)
VALUES
    ('fcbsmartbranch', 1, 'USD', 1, '1 Cent', 1),
    ('fcbsmartbranch', 1, 'USD', 2, '5 Cents', 5),
    ('fcbsmartbranch', 1, 'USD', 3, '10 Cents', 10),
    ('fcbsmartbranch', 1, 'USD', 4, '25 Cents', 25),
    ('fcbsmartbranch', 1, 'USD', 5, '50 Cents', 50),
    ('fcbsmartbranch', 1, 'USD', 6, '1 Dollar', 100),
    ('fcbsmartbranch', 1, 'USD', 7, '5 Dollars', 500),
    ('fcbsmartbranch', 1, 'USD', 8, '10 Dollars', 1000),
    ('fcbsmartbranch', 1, 'USD', 9, '20 Dollars', 2000),
    ('fcbsmartbranch', 1, 'USD', 10, '50 Dollars', 5000),
    ('fcbsmartbranch', 1, 'USD', 11, '100 Dollars', 10000),
    ('fcbsmartbranch', 1, 'INR', 12, '1 Rupee Coin', 1),
    ('fcbsmartbranch', 1, 'INR', 13, '2 Rupees Coin', 2),
    ('fcbsmartbranch', 1, 'INR', 14, '5 Rupees Coin', 5),
    ('fcbsmartbranch', 1, 'INR', 15, '10 Rupees Coin', 10),
    ('fcbsmartbranch', 1, 'INR', 16, '10 Rupees Note', 10),
    ('fcbsmartbranch', 1, 'INR', 17, '20 Rupees Note', 20),
    ('fcbsmartbranch', 1, 'INR', 18, '50 Rupees Note', 50),
    ('fcbsmartbranch', 1, 'INR', 19, '100 Rupees Note', 100),
    ('fcbsmartbranch', 1, 'INR', 20, '200 Rupees Note', 200),
    ('fcbsmartbranch', 1, 'INR', 21, '500 Rupees Note', 500),
    ('fcbsmartbranch', 1, 'INR', 22, '2000 Rupees Note', 2000);


INSERT INTO transaction_master
VALUES
    ('fcbsmartbranch', 1, 'TX001', 'Cash Deposit Same Currency'),
    ('fcbsmartbranch', 1, 'TX002', 'Cash Deposit Cross Currency'),
    ('fcbsmartbranch', 1, 'TX003', 'Cash Withdrawal Same Currency'),
    ('fcbsmartbranch', 1, 'TX004', 'Cash Withdrawal Cross Currency'),
    ('fcbsmartbranch', 1, 'TX005', 'Posting of Internal Transfer Same Currency'),
    ('fcbsmartbranch', 1, 'TX006', 'Posting of Internal Transfer Same Currency'),
    ('fcbsmartbranch', 1, 'TX007', 'FCY Cash Sale'),
    ('fcbsmartbranch', 1, 'TX008', 'FCY Cash Buy'),
    ('fcbsmartbranch', 1, 'TX009', 'MTA Payments'),
    ('fcbsmartbranch', 1, 'TX010', 'Account Balance Inquiry'),
    ('fcbsmartbranch', 1, 'TX011', 'In-House Cheque Deposit Same Currency'),
    ('fcbsmartbranch', 1, 'TX012', 'In-House Cheque Deposit Cross Currency');

-- 26th Nov

TRUNCATE TABLE till_master_new CASCADE;
INSERT INTO till_master_3 (tenant, branch_id, till_id, till_status, till_type, currency_code, denominations)
VALUES ('fcbsmartbranch', 1, 2, 'O', 'Till', 'INR', '{"19": 1, "20":  2}'::JSONB);

INSERT INTO till_master_new (tenant, branch_id, till_id, till_status, till_type, currency_code, denominations)
VALUES ('fcbsmartbranch', 1, 1, 'O', 'Till', 'INR', '{"17": 2, "18":  1, "16": 1}'::JSONB);

INSERT INTO till_master_new (tenant, branch_id, till_id, till_status, till_type, currency_code, denominations)
VALUES ('fcbsmartbranch', 1, 3, 'O', 'Till', 'USD', '{"5": 2, "4":  2}'::JSONB);

INSERT INTO till_master_new (tenant, branch_id, till_id, till_status, till_type, currency_code, denominations)
VALUES ('fcbsmartbranch', 1, 3, 'O', 'Till', 'INR', '{"16": 2, "17":  2}'::JSONB);

--inserting into user till master


INSERT INTO user_till_master (tenant, branch_id, user_provider, username, userid, till_id, aprover_provider, aprover_is, aprover_name)
VALUES ('fcbsmartbranch', 1, 'user provider', 'Teller Name', '1', 1, 'Approver Provider', 'Approver1', 'Approver Name');