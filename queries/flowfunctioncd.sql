-- Active: 1732169896911@@127.0.0.1@5432@postgres

--till master amount computation
CREATE OR REPLACE FUNCTION compute_amount()
RETURNS TRIGGER AS $$
BEGIN
    NEW.amount := (
        SELECT SUM(
            (NEW.denominations->>'denom_count')::INT * 
            (SELECT denomination_value
             FROM denomination_master
             WHERE denomination_master.denomination_code = (NEW.denominations->>'denom_code')::INT)
        )
    );
    SELECT denomination_value
    INTO NEW.denomination_value
    FROM denomination_master
    WHERE denomination_master.denomination_code = NEW.denomination_code;
    -- Returning new row
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Trigger for amount computation
CREATE TRIGGER update_amount_trigger
BEFORE INSERT OR UPDATE ON till_master
FOR EACH ROW
EXECUTE FUNCTION compute_amount();

INSERT INTO till_master (
    tenant, branch_id, till_id, till_status, till_type, currency_code, denomination_code, denominations
) VALUES (
    'fcbsmartbranch', 1, 1, 'O', 'Till', 'USD', 5,
    '{"denom_code": 5, "denom_count": 2}'
);

INSERT INTO till_master (
    tenant, branch_id, till_id, till_status, till_type, currency_code, denomination_code, denominations
) VALUES (
    'fcbsmartbranch', 1, 1, 'O', 'Till', 'INR', 19,
    '{"denom_code": "19", "denom_count": "1"}'
);

INSERT INTO till_master (
    tenant, branch_id, till_id, till_status, till_type, currency_code, denomination_code, denominations
) VALUES (
    'fcbsmartbranch', 1, 2, 'O', 'Till', 'INR', 20,
    '{"denom_code": "20", "denom_count": "2"}'
);

--MAIN flow function
CREATE OR REPLACE FUNCTION flow(
    tenant VARCHAR(50),
    branch_id INT, 
    cif VARCHAR(50),
)
RETURNS TEXT AS $$
DECLARE
    sessionid1 UUID;
BEGIN
--session creation

    SELECT sm.sessionid
    INTO sessionid1
    FROM session_master sm
    WHERE sm.tenant = flow.tenant AND sm.branch_id = flow.branch_id AND sm.cif = flow.cif;
    -- If no session exists, create a new session
    IF sessionid1 IS NULL THEN
        sessionid1 := uuid_generate_v4();
        INSERT INTO session_master (
            tenant, branch_id, sessionid, customer_rep, authentication_method, cif, account_no, session_start, userid, provider_name, username, id_type, id_no, first_name, last_name, dob, gender, callback_done
        )
        VALUES (
            tenant, branch_id, sessionid1, 'C','Card', cif, '{"Acc1": "USD", "Acc2": "INR"}' , CURRENT_TIMESTAMP,  'User 002', 'Vinkle', 'Aditi', 'NID', '1234567', 'Aditi', 'Sharma', '2024-09-01', 'F', 'Y'
        );
    -- if session exists with same cif, use existing session id
    ELSE
        sessionid1 := session_master.sessionid;
    END IF;

--checking if callback done or not
    IF (SELECT sm.callback_done 
        FROM session_master sm 
        WHERE sm.sessionid = sessionid1) = 'Y' THEN

--txn type + data (transactions)
        INSERT INTO transactions ( tenant, branch_id, transaction_code, transaction_status, auth_status, sessionid, created_by, created_by_user_id, created_by_provider, create_timestamp, last_updated_user, last_updated_user_id, last_updated_user_provider, last_updated_timestamp, comments, data_table)
        VALUES 
        ( tenant, branch_id, 'TX001', 'D', 'U', sessionid1, 'Aditi', '12345', 'Vinkle', '2024-11-25 10:30:00', 'V', 'User01', 'Vinkle', '2024-11-25 12:30:00', 'Y', '{"data": "values"}');

--denomination
        INSERT INTO transaction_denomination (tenant, branch_id, transaction_id, till_id, currency_code, related_account, amount, denominations )
        VALUES (
            tenant, branch_id, 1, 1, 'INR', 'NA', '200', '{"20": 1}'
        );

--till update


        --fin txns

        --need a flag here for credit/debit transaction type

        INSERT INTO financial_transactions
        VALUES (
            tenant, branch_id, sessionid1, 'TXI002', 'Y', 'ACC2', 'ACC1', 'INR', 'INR', '200', '200', 'Income', 'Saving', 'R1', 'R2', 'NA', 'NA', 'Y', 'NA', 'Y', '2024-11-22 11:30:00', 'Inst2', '2024/11/22', 'I1', '2024/11/22'
        );

    END IF;    

    RETURN 'Flow Completed';
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Flow processing failed. Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;  


--till master amount computation new
-- CREATE OR REPLACE FUNCTION compute_till_amount() 
-- RETURNS TRIGGER AS $$
-- DECLARE
--     denom_code INT;
--     denom_count INT;
--     denom_value INT;
--     total_amount INT := 0;
-- BEGIN
--     -- Loop through the denominations JSONB object
--     FOR denom_code, denom_count IN
--         SELECT (key)::INT, (value)::INT FROM jsonb_each(NEW.denominations)
--     LOOP
--         -- Fetch the denomination value from the denomination_master table
--         SELECT denomination_value INTO denom_value
--         FROM denomination_master
--         WHERE denomination_code = denom_code;

--         -- Calculate the total amount based on denom_count and denomination_value
--         total_amount := total_amount + (denom_count * denom_value);
--     END LOOP;

--     -- Set the computed total amount in the NEW record
--     NEW.amount := total_amount;
    
--     -- Return the modified NEW record to insert/update it
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- CREATE OR REPLACE FUNCTION validate_denom_code()
-- RETURNS TRIGGER AS $$
-- DECLARE
--     denom_code INT;
-- BEGIN
--     -- Loop through all keys (denom_codes) in the denominations JSONB column
--     FOR denom_code IN 
--         SELECT (key)::INT
--         FROM jsonb_each(NEW.denominations)
--     LOOP
--         -- Check if the denom_code exists in the denomination_master table
--         IF NOT EXISTS (SELECT 1 FROM denomination_master WHERE denomination_code = denom_code) THEN
--             RAISE EXCEPTION 'Invalid denom_code: %', denom_code;
--         END IF;
--     END LOOP;
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;


-- CREATE TRIGGER trigger_compute_till_amount
-- BEFORE INSERT OR UPDATE ON till_master_new
-- FOR EACH ROW
-- EXECUTE FUNCTION compute_till_amount();

-- CREATE TRIGGER validate_denom_codes_trigger
-- BEFORE INSERT OR UPDATE ON till_master_new
-- FOR EACH ROW
-- EXECUTE FUNCTION validate_denom_code();

