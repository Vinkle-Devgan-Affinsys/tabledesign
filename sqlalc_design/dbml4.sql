Table transaction_master {
    transaction_code varchar(50) [pk]
    transaction_desc varchar(200) [not null]
    transaction_type varchar(50)  //stores if fin_txn or not
    
}

Table transaction_branch_mapping {
    id int [pk]
    branch_id varchar(50) [not null]
    transaction_code varchar(50)
}
Table branch_master {
    branch_id varchar(50) [pk]
    branch_name varchar(255) [not null]
    branch_type varchar(200)
}

Table session {
    branch_id varchar(50) [not null]
    // branch_type varchar(200) [not null]
    sessionid varchar(36) [pk, note: 'UUID stored as string (CHAR(36))']
    customer_rep char(1) [not null, note: "Allowed values: 'C', 'R'"]
    authentication_method varchar(20) [note: "Allowed values: 'Card', 'CIF', 'Account number', 'Phone number', 'NID', 'Passport', 'DL'"]
    cif varchar(50) [not null]
    account_no json
    session_start timestamp
    session_end timestamp
    userid varchar(50) //teller id
    approver_provider varchar(50) //auth_provider
    username varchar(255)  // teller name
    -- customer_data jsonb
    representative_data jsonb
    // id_no varchar(50)
    // first_name varchar(50)
    // last_name varchar(50)
    // dob date
    // gender char(1) [note: "Allowed values: 'M', 'F', 'O'"]
    // not to store timestamp inside jsonb 
}

Table currency_master {
    currency_code varchar(3) [pk]
    currency_name varchar(100)
}

Table currency_branch_mapping{
    id int [pk]
    branch_id varchar(50) [not null]
    currency_code varchar(3)
}

Table denomination_master {
    denomination_code varchar(50) [pk]
    denomination_label varchar(100)
    denomination_value int [not null]
}

Table denomination_branch_mapping {
    id int [pk]
    branch_id varchar(50) [not null]
    currency_code varchar(3) [not null]
    denomination_code varchar(50)
}

Table transactions {
    transaction_reference_no varchar(50) [pk, not null]
    transaction_code varchar(50) [not null]
    transaction_status char(1) [note: "Allowed values: 'D', 'I', 'B', 'S', 'F', 'R'"]
    auth_status char(1) [note: "Allowed values: 'A', 'U', 'R'"]
    sessionid varchar(36) [note: 'UUID stored as string (CHAR(36))']
    created_at_branch_id varchar(50)
    // created_at_branch_type varchar(200)
    present_at_branch_id varchar(50)
    // present_at_branch_type varchar(200)
    created_by_username varchar(255)
    created_by_user_id varchar(50)
    approver_provider varchar(50)
    create_timestamp timestamp
    last_updated_username varchar(255)
    last_updated_user_id varchar(50)
    last_updated_approver_provider varchar(50)
    last_updated_timestamp timestamp
    screen_data jsonb //static screen data
    additional_data jsonb //derived data to be filled by pydantic validator per txn
    callback_done char(1) [note: "Allowed values: 'Y', 'N'"]
}


// Table financial_transactions {
//     // tenant varchar(50) [not null]
//     branch_id int [not null]
//     sessionid varchar(36) [note: 'UUID stored as string (CHAR(36))']
//     transaction_id varchar(50) [pk]
//     denom_tracking char(1) [note: "Allowed values: 'Y', 'N'"]
//     from_account varchar(50)
//     to_account varchar(50)
//     from_currency varchar(50) [not null]
//     to_currency varchar(50) [not null]
//     from_amount int [not null]
//     to_amount int [not null]
//     source_of_funds varchar(100)
//     purpose varchar(100)
//     remarks1 varchar(200)
//     remarks2 varchar(200)
//     exchange_rate_type varchar(50)
//     exchange_rate varchar(50)
//     special_rate char(1) [note: "Allowed values: 'Y', 'N'"]
//     treasury_remarks varchar(50)
//     treasury_approved char(1) [note: "Allowed values: 'Y', 'N'"]
//     treasury_approved_date timestamp
//     instrument_type varchar(50)
//     instrument_date timestamp
//     instrument_number varchar(50)
//     value_date timestamp
// store all remarks in comments only
// }

// Table transaction_comments {
//     // tenant varchar(50) [not null]
//     transaction_reference_no varchar(50) [not null]
//     comment_id int [pk]
    
// }

Table transaction_audit_log {
  id int [pk]
  branch_id varchar(50) [not null]
  transaction_reference_no varchar(50)
  old_json jsonb
  new_json jsonb
  change_summary text
  action varchar(100)
  approver_provider varchar(50)
  action_by_username varchar(255) [not null]
  action_by_userid varchar(50) [not null]
  comments text [not null]
  action_timestamp timestamp [not null]
}


Table till_master {
    branch_id varchar(50) [not null]
    till_id int [not null]
    currency_code varchar(3) [not null]
    current_denominations jsonb
    current_balance int
    opening_denominations jsonb
    opening_balance int
    Indexes {
        (branch_id, till_id, currency_code) [pk]
    }
}

Table till_type_mapping {
    till_id int [pk]
    till_type varchar(20) [note: "Allowed values: 'Till', 'vault', 'chief teller', 'cash centre'"]
}

Table user_till_master {
    branch_id varchar(50) [not null]
    // user_provider varchar(255)
    username varchar(255) [not null]
    userid varchar(50) [not null, unique]
    till_id int [unique]
    approver_provider varchar(50)
    aprover_id varchar(50) [not null]
    aprover_name varchar(255)
    Indexes {
        (branch_id, userid) [pk]
    }
}

Table transaction_denomination {
    branch_id varchar(50) [not null]
    transaction_reference_no varchar(50)
    till_id int [not null]
    currency_code varchar(3) [not null]
    related_account varchar(50)
    amount int [not null]
    denominations jsonb [not null]
    transaction_date timestamp [not null]
    Indexes {
        (transaction_reference_no, till_id, currency_code) [pk]
    }
}
Ref: transaction_branch_mapping.branch_id > branch_master.branch_id
Ref: transaction_branch_mapping.transaction_code > transaction_master.transaction_code
Ref: currency_branch_mapping.branch_id > branch_master.branch_id
Ref: currency_branch_mapping.currency_code > currency_master.currency_code
Ref: denomination_branch_mapping.currency_code > currency_master.currency_code
Ref: denomination_branch_mapping.branch_id > branch_master.branch_id
Ref: denomination_branch_mapping.denomination_code > denomination_master.denomination_code
Ref: session.branch_id > branch_master.branch_id
Ref: transactions.created_at_branch_id > branch_master.branch_id
Ref: transactions.present_at_branch_id > branch_master.branch_id
// Ref: transactions.created_at_branch_type > branch_master.branch_type
// Ref: transactions.present_at_branch_type > branch_master.branch_type
Ref: till_master.till_id > till_type_mapping.till_id
// Ref: session.branch_type > branch_master.branch_type
Ref: transactions.transaction_code > transaction_master.transaction_code
Ref: transactions.sessionid > session.sessionid
// Ref: financial_transactions.transaction_id > transactions.transaction_id
// Ref: financial_transactions.sessionid > session.sessionid
Ref: transaction_audit_log.branch_id > branch_master.branch_id
// Ref: transaction_comments.comment_id > transactions.comment_id
Ref: transaction_audit_log.transaction_reference_no > transactions.transaction_reference_no
Ref: till_master.currency_code > currency_master.currency_code
Ref: transaction_denomination.transaction_reference_no > transactions.transaction_reference_no
// Ref: transaction_audit_log.transaction_reference_no > transactions.transaction_reference_no
Ref: transaction_denomination.till_id > till_master.till_id
Ref: transaction_denomination.currency_code > currency_master.currency_code
Ref: transaction_denomination.branch_id > branch_master.branch_id
Ref: user_till_master.till_id > till_master.till_id
Ref: user_till_master.branch_id > branch_master.branch_id
