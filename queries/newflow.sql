-- Active: 1732686745279@@127.0.0.1@5432@postgres

-- function checking denom_code valid or not
CREATE OR REPLACE FUNCTION denom_validate_till_master_ex2()
RETURNS TRIGGER AS $$
DECLARE
    denom_code TEXT;
BEGIN 
    -- Check if denominations is NULL or not JSONB
    IF NEW.denominations IS NULL THEN
        RAISE EXCEPTION 'Denominations cannot be NULL.';
    END IF;

    -- Loop through all keys (denom_codes) in the denominations JSONB column
    FOR denom_code IN 
        SELECT key
        FROM jsonb_each_text(NEW.denominations)
    LOOP
        -- Check if the denom_code exists in the denomination_master table
        IF NOT EXISTS (
            SELECT 1 FROM denomination_master 
            WHERE denomination_code = denom_code::INT
            AND currency_code = NEW.currency_code
        ) THEN
            RAISE EXCEPTION 'Invalid denom_code: % for currency %', denom_code, NEW.currency_code;
        END IF;
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--trigger for denomination validation
CREATE TRIGGER trigger_denom_validate_till_master_ex2
BEFORE INSERT OR UPDATE ON till_master_ex
FOR EACH ROW
EXECUTE FUNCTION denom_validate_till_master_ex2();

--function checking user's till access
CREATE OR REPLACE FUNCTION validate_user_till_access()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM user_till_master
        WHERE till_id = NEW.till_id
          AND userid = NEW.userid
    ) THEN
        RAISE EXCEPTION 'Access Denied: User % does not have access to till %', NEW.userid, NEW.till_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Trigger for user till acess validation
CREATE TRIGGER validate_access_trigger
BEFORE INSERT ON audit_log_txns
FOR EACH ROW
EXECUTE FUNCTION validate_user_till_access();

--Till update function
CREATE OR REPLACE FUNCTION amnt_compute_till_master_ex6(
    tenant_p VARCHAR(50),
    branch_id_p INT,
    till_id_p INT,
    till_status_p CHAR(1),
    till_type_p VARCHAR(20),
    currency_code_p VARCHAR(5),
    denominations_p JSONB,
    userid INT
) 
RETURNS VOID AS $$
DECLARE
    denom_code INT;
    denom_count INT;
    denom_value INT;
    total_amount INT := 0;
    existing_denominations JSONB;
    updated_denominations JSONB := '{}'::JSONB;
    row_exists BOOLEAN;
    transactionid INT := 7;
BEGIN
--checking if that row exists or not
    SELECT EXISTS (
        SELECT 1
        FROM till_master_ex
        WHERE tenant = tenant_p
        AND branch_id = branch_id_p
        AND till_id = till_id_p
        AND currency_code = currency_code_p
    ) INTO row_exists;

    IF row_exists THEN
-- Fetch existing denominations
        SELECT denominations INTO existing_denominations
        FROM till_master_ex
        WHERE tenant = tenant_p
        AND branch_id = branch_id_p
        AND till_id = till_id_p
        AND currency_code = currency_code_p;
--Storing new denominations
        FOR denom_code, denom_count IN
            SELECT (key)::INT, (value)::INT  --19,1 ||20,2
            FROM jsonb_each_text(denominations_p)  -- Use jsonb_each_text to extract as text, then cast
--Updating denominations 
        LOOP
            updated_denominations := updated_denominations || jsonb_build_object(
            denom_code::TEXT, 
            COALESCE((existing_denominations ->> denom_code::TEXT)::INT, 0) + denom_count
); 
        END LOOP;
--Retaining denominations that are not updated
        FOR denom_code, denom_count IN
            SELECT (key)::INT, (value)::INT 
            FROM jsonb_each(existing_denominations)
        LOOP
            IF NOT (denominations_p ? denom_code::TEXT) THEN --19:2, 20:2, 21:1
                updated_denominations := updated_denominations || jsonb_build_object(
                    denom_code::TEXT, denom_count
                );
            END IF;
        END LOOP;
--If row does not exist
    ELSE 
        updated_denominations := denominations_p;
    END IF;
--Done with denominations now calculate amount
    FOR denom_code, denom_count IN
        SELECT (key)::INT, (value)::INT FROM jsonb_each(updated_denominations)
    LOOP
        SELECT denomination_value INTO denom_value
        FROM denomination_master
        WHERE denomination_code = denom_code;

        total_amount := total_amount + (denom_count * denom_value);
    END LOOP;

--Now update/insert denos and amount in table
    IF row_exists THEN  --UPDATING if exists

    --Updating the audit log
        INSERT INTO audit_log_txns
        VALUES (tenant_p, branch_id_p, 1, transactionid, 1, 'INR', total_amount, updated_denominations, CURRENT_TIMESTAMP, userid, 'Teller Name');

    --Updating till_master
        UPDATE till_master
        SET denominations = updated_denominations,
            amount = total_amount
        WHERE tenant = tenant_p 
        AND branch_id = branch_id_p 
        AND till_id = till_id_p 
        AND currency_code = currency_code_p;


    ELSE  --INSERTING if NOT

    --Updating the audit log
        INSERT INTO audit_log_txns
        VALUES (tenant_p, branch_id_p, 1, transactionid, 1, 'INR', total_amount, updated_denominations, CURRENT_TIMESTAMP, userid, 'Teller Name');

    --Updating till_master
        INSERT INTO till_master (tenant, branch_id, till_id, till_status, till_type, currency_code, denominations, amount)
        VALUES (tenant_p, branch_id_p, till_id_p, till_status_p, till_type_p, currency_code_p, updated_denominations, total_amount);

    END IF;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END;
$$ LANGUAGE plpgsql;

--MAIN flow function
CREATE OR REPLACE FUNCTION flow(
    tenant VARCHAR(50),
    branch_id INT, 
    cif VARCHAR(50),
    userid INT,         --teller
    customer_rep CHAR(1)
)
RETURNS TEXT AS $$
DECLARE
    sessionid1 UUID;
    session_exists BOOLEAN;
    denom_code INT;
    denom_count INT;
    existing_denom_count INT;
    denom_value INT;
    updated_denominations JSONB := '{}'::JSONB;
    total_amount INT := 0;
BEGIN
--session creation
    SELECT EXISTS (
        SELECT 1
        FROM session_master as sm
        WHERE sm.tenant = flow.tenant
        AND sm.branch_id = flow.branch_id
        AND sm.cif = flow.cif
    ) INTO session_exists;

    IF session_exists THEN
        SELECT sessionid INTO sessionid1
        FROM session_master as sm
        WHERE sm.tenant = flow.tenant
        AND sm.branch_id = flow.branch_id
        AND sm.cif = flow.cif;
    ELSE
        sessionid1 := uuid_generate_v4();
        INSERT INTO session_master (
            tenant, branch_id, sessionid, customer_rep, authentication_method, cif, account_no, session_start, userid, provider_name, username, id_type, id_no, first_name, last_name, dob, gender, callback_done
        )
        VALUES (
            tenant, branch_id, sessionid1, 'C','Card', cif, '{"Acc1": "USD", "Acc2": "INR"}' , CURRENT_TIMESTAMP,  'User 001', 'Vinkle', 'Aditi', 'NID', '1234567', 'Aditi', 'Sharma', '2024-09-01', 'F', 'Y'
        );
    END IF;

--checking if callback done or not
    IF (SELECT sm.callback_done 
        FROM session_master sm 
        WHERE sm.sessionid = sessionid1) = 'Y' THEN

--txn type + data (transactions)
        INSERT INTO transactions ( tenant, branch_id, transaction_id, transaction_code, transaction_status, auth_status, sessionid, created_by, created_by_user_id, created_by_provider, create_timestamp, last_updated_user, last_updated_user_id, last_updated_user_provider, last_updated_timestamp, comments, data_table)
        VALUES 
        ( tenant, branch_id, 7, 'TX001', 'D', 'U', sessionid1, 'Aditi', '111', 'Vinkle', CURRENT_TIMESTAMP, 'V', 'User04', 'Vinkle', '2024-11-26 12:30:00', 'N', '{"data": "values"}');

--if comments present push to comments table
        IF EXISTS(
            SELECT 1
            FROM transactions txns 
            WHERE txns.sessionid = sessionid1
            AND txns.comments = 'Y'
        ) THEN
            INSERT INTO comments
            VALUES (tenant, branch_id, sessionid1, 7, 3, 'Vinkle', 'Aditi', '111', 'this is also a comment', CURRENT_TIMESTAMP);
        END IF;

--denomination
        INSERT INTO transaction_denomination_ex (tenant, branch_id, transaction_id, till_id, currency_code, related_account, amount, denominations )
        VALUES (
            tenant, branch_id, 7, 1, 'USD', 'NA', '200', '{"20":1}'
        );

--till update + audit log
        PERFORM amnt_compute_till_master_ex6(tenant, branch_id, 1, 'O', 'Till', 'USD', '{"20":1}'::JSONB, userid);

--fin txns
        --need a flag here for credit/debit transaction type
        INSERT INTO financial_transactions
        VALUES (
            tenant, branch_id, sessionid1, 7, 'Y', 'ACC2', 'ACC1', 'USD', 'USD', '200', '200', 'Income', 'Saving', 'R1', 'R2', 'NA', 'NA', 'Y', 'NA', 'Y', '2024-11-28 14:30:00+05:30', 'Inst2', '2024-11-28 14:30:00+05:30', 'I1', '2024-11-28 14:30:00+05:30'
        );
    END IF;    
    COMMIT;
    RETURN 'Flow Completed';
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RETURN 'Flow processing failed. Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;  

SELECT flow('fcbsmartbranch', 1, '7890CIF', 1);
