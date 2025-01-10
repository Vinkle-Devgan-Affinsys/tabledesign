
INSERT INTO branch_master
VALUES 
( 'fcbsmartbranch', 1, 'B001', 'branchtype1'),
( 'fcbsmartbranch', 2, 'B002', 'branchtype2'),
( 'fcbsmartbranch', 3, 'B003', 'branchtype3'),
( 'fcbsmartbranch', 4, 'B004', 'branchtype4'),
( 'fcbsmartbranch', 5, 'B005', 'branchtype5');

INSERT INTO currency_master
VALUES 
( 'fcbsmartbranch', 1, 'USD', 'American Dollars'),
( 'fcbsmartbranch', 1, 'INR', 'Indian Rupee');

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


INSERT INTO till_master
VALUES
    ('fcbsmartbranch', 1, 1, 'O', 'Till', 'INR', '{"12": 2, "18": 1, "20": 2}'::JSONB, 452),
    ('fcbsmartbranch', 1, 1, 'O', 'Till', 'USD', '{"1": 2, "8": 1, "2": 2}'::JSONB, 1012),
    ('fcbsmartbranch', 1, 2, 'C', 'Till', 'INR', '{"19": 2, "22": 2}'::JSONB, 2200),
    ('fcbsmartbranch', 1, 2, 'C', 'Till', 'USD', '{"3": 2, "4": 1, "6": 2}'::JSONB, 245);


INSERT INTO user_till_master
VALUES
    ('fcbsmartbranch', 1, 'u_provider','u_name', 1, 1, 'a_provider', 1, 'a_name'),
    ('fcbsmartbranch', 1, 'u_provider','u_name', 2, 2, 'a_provider', 2, 'a_name');


