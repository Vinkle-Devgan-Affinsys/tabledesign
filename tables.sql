CREATE TABLE Transaction_Master (
    Tenant VARCHAR(50),
    Branch INT(50),
    Transaction_Code VARCHAR(50) PRIMARY KEY,
    Transaction_Desc VARCHAR(200)
);

CREATE TABLE Branch_Master (
    Tenant VARCHAR(50),
    Branch_Id INT(50) PRIMARY KEY,
    Branch_Name VARCHAR(50),
    Branch_Type VARCHAR(200)
);

CREATE TABLE Session_Master (
    Tenant VARCHAR(50),
    Branch INT(50),
    SessionId VARCHAR(50) PRIMARY KEY,
    Customer_Rep CHAR(1) CHECK (Customer_Rep IN ('C', 'R')),
    Authentication_Method VARCHAR(20) CHECK (Authentication_Method IN ('Card', 'CIF', 'Account number', 'NID', 'Passport', 'DL')),
    CIF VARCHAR(50),
    Account_No JSON,
    Session_Start TIMESTAMP,
    Session_End TIMESTAMP,
    User VARCHAR(50),
    Provider_Name VARCHAR(50),
    Username VARCHAR(100),
    Id_Type VARCHAR(20),
    Id_No VARCHAR(50),
    First_Name VARCHAR(50),
    Last_Name VARCHAR(50),
    DOB DATE,
    Gender CHAR(1) CHECK (Gender IN ('M', 'F', 'O')),
    Callback_Done CHAR(1) CHECK (Callback_Done IN ('Y', 'N')) 

);

CREATE TABLE Currency_Master (
    Tenant VARCHAR(50),
    Branch INT(50),
    Currency_Id VARCHAR(50) PRIMARY KEY,    --Currency key
    Currency_Code VARCHAR(5),
    Currency_Name VARCHAR(50)
);

CREATE TABLE Denomination_Master (
    Tenant VARCHAR(50),
    Branch INT(50),
    Currency_Code VARCHAR(5),
    Denomination_Code VARCHAR(50) PRIMARY KEY,
    Denomination_Label VARCHAR(50),
    Denomination_Value VARCHAR(50),
    FOREIGN KEY (Currency_Code) REFERENCES Currency_Master(Currency_Code)
);

CREATE TABLE Till_Master (
    Tenant VARCHAR(50),
    Branch INT(50),
    Till_Id VARCHAR(50) PRIMARY KEY,
    Till_Type VARCHAR(20) CHECK (Till_Type IN ('Till', 'vault', 'chief teller', 'cash centre')),
    Currency_Code VARCHAR(5),
    Denominations JSON,  --{Denom_code (FK): Denomination code (Denomination master), Denom_count: Count of denominations}
    Denomination_Value VARCHAR(50),
    FOREIGN KEY (Currency_Code) REFERENCES Currency_Master(Currency_Code)
);

CREATE TABLE User_Till_Master (
    Tenant VARCHAR(50),
    Branch INT(50),
    User_Provider VARCHAR(50),
    Username VARCHAR(100),
    UserId VARCHAR(50),
    Till_Id VARCHAR(50) PRIMARY KEY,
    Aprover_Provider VARCHAR(20),
    Aprover_Is VARCHAR(20),
    Aprover_Name VARCHAR(20)
);

CREATE TABLE Transactions (
    Tenant VARCHAR(50),
    Branch INT(50),
    Transaction_Id VARCHAR(50) PRIMARY KEY,
    Transaction_Code VARCHAR(100),
    Transaction_Status CHAR(1) CHECK (Transaction_Status IN ('D', 'I', 'B', 'S', 'F', 'R')),        --(D = Draft, I = Initiated, B = Submitted, S = Success, F = Failed, R = Reversed)
    Auth_Status CHAR(1) CHECK (Auth_Status IN ('A', 'U', 'R')),                                     --(A = Auth, U = Unauthorised, R = Refered)
    Created_By VARCHAR(50),
    Created_By_User_Id VARCHAR(50),
    Created_By_Provider VARCHAR(50),
    Create_Timestamp DATETIME,
    Last_Updated_User VARCHAR(50),
    Last_Updated_User_Id VARCHAR(50),
    Last_Updated_User_Provider VARCHAR(50),
    Last_Updated_Timestamp DATETIME,
    Comments CHAR(1) CHECK (Comments IN ('Y', 'N')),
    Data_Table VARCHAR(50),
    FOREIGN KEY (Tenant, Branch) REFERENCES Session_Master(Tenant, Branch),
    FOREIGN KEY (Transaction_Code) REFERENCES Transaction_Master(Transaction_Code)
);

CREATE TABLE Financial_Transactions (
    Tenant VARCHAR(50),
    Branch INT(50),
    SessionId VARCHAR(50),
    Transaction_Id VARCHAR(50) PRIMARY KEY,
    Denom_Tracking CHAR(1) CHECK (Comments IN ('Y', 'N')),
    From_Account VARCHAR(50),
    To_Account VARCHAR(50),
    From_Currency VARCHAR(50),
    To_Currency VARCHAR(50),
    From_Amount VARCHAR(50),
    To_Amount VARCHAR(50),
    Source_Of_Funds VARCHAR(100),
    Purpose VARCHAR(100),
    Remarks1 VARCHAR(200),
    Remarks2 VARCHAR(200),
    Exchange_Rate_Type VARCHAR(50),
    Exchange_Rate VARCHAR(50),
    Special_Rate CHAR(1) CHECK (Comments IN ('Y', 'N')),
    Treasury_Remarks VARCHAR(50),
    Treasury_Approved CHAR(1) CHECK (Comments IN ('Y', 'N')),
    Treasury_Approved_Date DATETIME,
    Instrument_Type VARCHAR(50),
    Instrument_Date VARCHAR(50),
    Instrument_Number VARCHAR(50),
    Value_Date VARCHAR(50),                                    --instrument value date
    FOREIGN KEY (SessionId) REFERENCES Session_Master(SessionId)
);

CREATE TABLE Comments (
    Tenant VARCHAR(50),
    Branch INT(50),
    SessionId VARCHAR(50),
    Transaction_Id VARCHAR(50),
    Sequence_Number INT(100) PRIMARY KEY,        --approval flow sequence no
    User_Provider VARCHAR(50),
    Username VARCHAR(100),
    UserId VARCHAR(50),
    Comments VARCHAR(200),
    Comments_Date DATETIME,
    FOREIGN KEY (SessionId) REFERENCES Session_Master(SessionId)
    FOREIGN KEY (Transaction_Id) REFERENCES Transactions(Transaction_Id)
);

CREATE TABLE Transactions (
    Tenant VARCHAR(50),
    Branch INT(50),
    Transaction_Id VARCHAR(50) PRIMARY KEY,
    Transaction_Code VARCHAR(100),
    Transaction_Status CHAR(1) CHECK (Transaction_Status IN ('D', 'I', 'B', 'S', 'F', 'R')),        --(D = Draft, I = Initiated, B = Submitted, S = Success, F = Failed, R = Reversed)
    Auth_Status CHAR(1) CHECK (Auth_Status IN ('A', 'U', 'R')),                                     --(A = Auth, U = Unauthorised, R = Refered)
    Created_By VARCHAR(50),
    Created_By_User_Id VARCHAR(50),
    Created_By_Provider VARCHAR(50),
    Create_Timestamp DATETIME,
    Last_Updated_User VARCHAR(50),
    Last_Updated_User_Id VARCHAR(50),
    Last_Updated_User_Provider VARCHAR(50),
    Last_Updated_Timestamp DATETIME,
    Comments CHAR(1) CHECK (Comments IN ('Y', 'N')),
    Data_Table VARCHAR(50),
    FOREIGN KEY (Tenant, Branch) REFERENCES Session_Master(Tenant, Branch),
    FOREIGN KEY (Transaction_Code) REFERENCES Transaction_Master(Transaction_Code)
);

CREATE TABLE Transaction_Denomination (
    Tenant VARCHAR(50),
    Branch INT(50),
    Transaction_Id VARCHAR(50) PRIMARY KEY,
    Till_Id VARCHAR(50),
    Currency_Code VARCHAR(50),
    Related_Account VARCHAR(50),          --Offset account (customer’s or other till /valut account)
    Amount VARCHAR(50),                   --transaction amount (in the currency of transaction)
    Denominations JSON,  --{Denom_code (FK): Denomination code (Denomination master), Denom_count: Count of denominations}
    FOREIGN KEY (Currency_Code) REFERENCES Currency_Master(Currency_Code)
    FOREIGN KEY (Transaction_Id) REFERENCES Transactions(Transaction_Id)
    FOREIGN KEY (Till_Id) REFERENCES Till_Master(Till_Id)
);

/*
- Branch? 
- Transaction_id (Tran_deno) referring to Transaction_id (Tran_master) but no txn_id in Txn_Master
- Till id of Txn Deno should refer to till id of till master? what is user till master then
- Currency code is fk used but that's not primary key in currency master (currency id is pk)
- Denominations? JSON combination of FK and data
- Amount in transaction details
- Primary keys combination in some tables?
- Comments? in Transactions (to store Y, N or comment content?)

*/