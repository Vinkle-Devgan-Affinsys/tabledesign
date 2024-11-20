-- Active: 1731998849796@@127.0.0.1@5432@postgres@public
INSERT INTO transaction_master
VALUES (
    'tenant_name1',     --tenant
    1,                  --branch
    'T001',             --txn code
    'Cash deposit'      --txn desc
);

INSERT INTO transactions
VALUES 
('ABC Corp', 101, 'TRX  ', 'T001', 'S', 'A', 'JohnDoe', 'JD123', 'Visa', '2024-11-19 10:00:00', 'JaneSmith', 'JS456', 'MasterCard', '2024-11-19 12:00:00', 'Y', 'Transactions2024');

INSERT INTO transactions
VALUES 
('ABC Corp', 101, 'TRX2', 'T001', 'S', 'A', 'JohnDoe', 'JD123', 'Visa', '2024-11-19 10:00:00', 'JaneSmith', 'JS456', 'MasterCard', '2024-11-19 12:00:00', 'Y', 'Transactions2024');

