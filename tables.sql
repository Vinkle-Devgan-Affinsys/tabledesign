CREATE TABLE TransactionMaster (
    Tenant VARCHAR(100),                            --Tenant
    Branch VARCHAR(100),                            --Bank Branch / SOL ID
    Transaction_code VARCHAR(50) UNIQUE,            --Unique Transaction code (PRIMARY KEY)
    Transaction_desc VARCHAR(200)                   --Transaction Description
);

CREATE TABLE BranchMaster (
    Tenant VARCHAR(100),                            --Tenant
    Branch_id INT(50) UNIQUE,                              --Bank Branch / SOL ID (PRIMARY KEY)
    Branch_name VARCHAR(50),                 --branch / SOL name 
    Branch_type VARCHAR(200)                        --Branch type
);