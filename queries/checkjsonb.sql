-- Active: 1732169896911@@127.0.0.1@5432@postgres@public

--inserting data into tables to test

INSERT INTO transaction_master
VALUES 
( 'tn3', 1, 'T002', 'Cash withdrawal');

INSERT INTO currency_master
VALUES (
    'tn1', 1, 'USD', 'US Dollars'
);

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
