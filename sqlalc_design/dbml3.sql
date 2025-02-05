Table transaction_master {
    transaction_code varchar(50) [pk]
    transaction_desc varchar(200) [not null]
    
}

Table transaction_branch_mapping {
    tenant varchar(50) [not null]
    branch_id int [not null]
    transaction_code varchar(50)
}
Table branch_master {
    tenant varchar(50) [not null]
    branch_id int [pk]
    branch_name varchar(50) [not null]
    branch_type varchar(200)
}

Table session_master {
    tenant varchar(50) [not null]
    branch_id int [not null]
    sessionid varchar(36) [pk, note: 'UUID stored as string (CHAR(36))']
    customer_rep char(1) [not null, note: "Allowed values: 'C', 'R'"]
    authentication_method varchar(20) [note: "Allowed values: 'Card', 'CIF', 'Account number', 'NID', 'Passport', 'DL'"]
    cif varchar(50) [not null]
    account_no json
    session_start timestamp
    session_end timestamp
    userid int
    provider_name varchar(50)
    username varchar(100)
    id_type varchar(20)
    id_no varchar(50)
    first_name varchar(50)
    last_name varchar(50)
    dob date
    gender char(1) [note: "Allowed values: 'M', 'F', 'O'"]
}

Table currency_master {
    currency_code varchar(5) [pk]
    currency_name varchar(50)
}

Table currency_branch_mapping{
    tenant varchar(50) [not null]
    branch_id int [not null]
    currency_code varchar(5)
}

Table denomination_master {
    denomination_code serial [pk]
    denomination_label varchar(50)
    denomination_value int [not null]
}

Table denomination_branch_mapping {
    tenant varchar(50) [not null]
    branch_id int [not null]
    currency_code varchar(5) [not null]
    denomination_code serial
}

Table transactions {
    tenant varchar(50) [not null]
    branch_id int [not null]
    transaction_id varchar(50) [pk, not null]
    transaction_code varchar(100) [not null]
    transaction_status char(1) [note: "Allowed values: 'D', 'I', 'B', 'S', 'F', 'R'"]
    auth_status char(1) [note: "Allowed values: 'A', 'U', 'R'"]
    sessionid varchar(36) [note: 'UUID stored as string (CHAR(36))']
    created_by varchar(50)
    created_by_user_id int
    created_by_provider varchar(50)
    create_timestamp timestamp
    last_updated_user varchar(50)
    last_updated_user_id int
    last_updated_user_provider varchar(50)
    last_updated_timestamp timestamp
    comments char(1) [note: "Allowed values: 'Y', 'N'"]
    data_table jsonb
    callback_done char(1) [note: "Allowed values: 'Y', 'N'"]
}

Table financial_transactions {
    tenant varchar(50) [not null]
    branch_id int [not null]
    sessionid varchar(36) [note: 'UUID stored as string (CHAR(36))']
    transaction_id varchar(50) [pk]
    denom_tracking char(1) [note: "Allowed values: 'Y', 'N'"]
    from_account varchar(50)
    to_account varchar(50)
    from_currency varchar(50) [not null]
    to_currency varchar(50) [not null]
    from_amount int [not null]
    to_amount int [not null]
    source_of_funds varchar(100)
    purpose varchar(100)
    remarks1 varchar(200)
    remarks2 varchar(200)
    exchange_rate_type varchar(50)
    exchange_rate varchar(50)
    special_rate char(1) [note: "Allowed values: 'Y', 'N'"]
    treasury_remarks varchar(50)
    treasury_approved char(1) [note: "Allowed values: 'Y', 'N'"]
    treasury_approved_date timestamp
    instrument_type varchar(50)
    instrument_date timestamp
    instrument_number varchar(50)
    value_date timestamp
}

Table comments {
    tenant varchar(50) [not null]
    branch_id int [not null]
    sessionid varchar(36) [not null, note: 'UUID stored as string (CHAR(36))']
    transaction_id varchar(50) [not null]
    sequence_number int [pk]
    user_provider varchar(50)
    username varchar(100) [not null]
    userid int [not null]
    comments varchar(200) [not null]
    comments_date timestamp [not null]
}

Table till_master {
    tenant varchar(50) [not null]
    branch_id int [not null]
    till_id int [not null]
    till_status char(1) [note: "Allowed values: 'O', 'C'"]
    till_type varchar(20) [note: "Allowed values: 'Till', 'vault', 'chief teller', 'cash centre'"]
    currency_code varchar(5) [not null]
    denominations jsonb
    balance int
    Indexes {
        (branch_id, till_id, currency_code) [pk]
    }
}

Table user_till_master {
    tenant varchar(50) [not null]
    branch_id int [not null]
    user_provider varchar(50)
    username varchar(100) [not null]
    userid int [not null, unique]
    till_id int [unique]
    aprover_provider varchar(20)
    aprover_id int [not null]
    aprover_name varchar(20)
    Indexes {
        (branch_id, userid) [pk]
    }
}

Table transaction_denomination {
    tenant varchar(50) [not null]
    branch_id int [not null]
    transaction_id varchar(50) [pk]
    till_id int [not null]
    currency_code varchar(50) [not null]
    related_account varchar(50)
    amount int [not null]
    denominations jsonb [not null]
}
Ref: transaction_branch_mapping.branch_id > branch_master.branch_id
Ref: transaction_branch_mapping.transaction_code > transaction_master.transaction_code

Ref: currency_branch_mapping.branch_id > branch_master.branch_id
Ref: currency_branch_mapping.currency_code > currency_master.currency_code

Ref: denomination_branch_mapping.currency_code > currency_master.currency_code
Ref: denomination_branch_mapping.branch_id > branch_master.branch_id
Ref: denomination_branch_mapping.denomination_code > denomination_master.denomination_code

Ref: session_master.branch_id > branch_master.branch_id

Ref: transactions.branch_id > branch_master.branch_id
Ref: transactions.transaction_code > transaction_master.transaction_code
Ref: transactions.sessionid > session_master.sessionid

Ref: financial_transactions.transaction_id > transactions.transaction_id
Ref: financial_transactions.sessionid > session_master.sessionid
Ref: comments.sessionid > session_master.sessionid
Ref: comments.branch_id > branch_master.branch_id
Ref: comments.transaction_id > transactions.transaction_id
Ref: till_master.currency_code > currency_master.currency_code
Ref: transaction_denomination.transaction_id > transactions.transaction_id
Ref: transaction_denomination.till_id > till_master.till_id
Ref: transaction_denomination.currency_code > currency_master.currency_code
Ref: transaction_denomination.branch_id > branch_master.branch_id
Ref: user_till_master.till_id > till_master.till_id
