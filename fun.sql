CREATE OR REPLACE FUNCTION add_num(a INT, b INT)
RETURNS INT AS $$
BEGIN
    RETURN a+b;
END;
$$ LANGUAGE plpgsql;

SELECT add_num(10, 20)


--Create a transaction journey flow (how data will be stored in these tables)

--deno_value : total amnt (200)
--deno_label : $200
--deno_count : total notes / coins (2) like 2 100USD notes : 2
--deno_code : unique identifier

/*
1. Branch?  -> Branch_Id
2. Transaction_id (Tran_deno) referring to Transaction_id (Tran_master) but no txn_id in Txn_Master  -> changed txn_master to txns
3. Till id of Txn Deno should refer to till id of till master? what is user till master then  -> till id in utm is fk to tm
4. Currency code is fk used but that's not primary key in currency master (currency id is pk) -> make ccode pk and remove cid
5. Amount in transaction details
6. Comments? in Transactions (to store Y, N or comment content?) -> flag, may not be required
7.provider? user? (in session master) 0> provider : validator, user -> customer
8.Tenant, Branch pk? in tillmaster, transaction_master  -> composite keys
1. Transaction_Denomination -> Transaction_id is primary key and foreign key at the same time?  -> okay
2. UserTillMaster -> TillId is foreign key and primary too?  -> okay
3. Denominations? JSON combination of FK and data -> check constraint/serialize it
4. Denomination_value?
5. Primary keys combination in some tables? -> make composite keys but txn_id should be mandatory -> ask shrujan  -> make composite
- 6. user_provider? etc in user till master
- 7. Created_By? Created_by_provider etc in Transactions?

TBD
- Create a transaction journey flow (how data will be stored in these tables)
- Session master account json?

25th November
--in case of OBO, we'll have to close the session once txn is done (to avoid callback Y issue)
*/



-- CREATE TABLE till_master_t (
--     tenant VARCHAR(50) NOT NULL,
--     branch_id INTEGER NOT NULL,
--     till_id SERIAL NOT NULL,
--     till_status CHAR(1) CHECK (till_status IN ('O', 'C')),         --(O - Open, C - Close)
--     till_type VARCHAR(20) CHECK (till_type IN ('Till', 'vault', 'chief teller', 'cash centre')),
--     currency_code VARCHAR(5) NOT NULL,
--     denomination_code INTEGER NOT NULL,
--     denominations JSONB,  --{denom_code (FK): denomination code (denomination_master), denom_count: Count of denominations}
--     CHECK (
--         denominations ? 'denom_code' AND
--         denominations ? 'denom_count' AND
--         (denominations->>'denom_code')::INT = denomination_code
--     ),
--     amount NUMERIC(12, 2) GENERATED ALWAYS AS (
--         (SELECT SUM(
--             (value->>'denom_count')::INTEGER * 
--             (SELECT denomination_value 
--              FROM denomination_master 
--              WHERE denomination_master.denomination_code = (value->>'denom_code')::INTEGER)
--         )
--          FROM jsonb_each(denominations) AS deno(value)
--         )
--     ) STORED,
--     PRIMARY KEY (tenant, branch_id, till_id, denomination_code), -- Composite PK ensures unique entries per denomination in each till
--     FOREIGN KEY (currency_code) REFERENCES currency_master(currency_code),
--     FOREIGN KEY (denomination_code) REFERENCES denomination_master(denomination_code)
-- );


-- CREATE TABLE till_master_2 (
--     tenant VARCHAR(50),
--     branch_id INT,
--     till_id INT,
--     till_status CHAR(1) CHECK (till_status IN ('O', 'C')),         --(O - Open, C - Close)
--     till_type VARCHAR(20) CHECK (till_type IN ('Till', 'vault', 'chief teller', 'cash centre')),
--     currency_code VARCHAR(5),
--     denomination_code INT,
--     denominations JSONB,  --{denom_code (FK): denomination code (denomination_master), denom_count: Count of denominations}
--     denomination_value INT,
--     amount INT,
--     PRIMARY KEY (tenant, branch_id, till_id, denomination_code),
--     FOREIGN KEY (currency_code) REFERENCES currency_Master(currency_code),
--     FOREIGN KEY (denomination_code) REFERENCES denomination_master(denomination_code),
--     CHECK (
--         denominations ? 'denom_code' AND
--         denominations ? 'denom_count' AND
--         (denominations->>'denom_code')::INT = denomination_code
--     )
-- );

-- CREATE VIEW till_master_amount_comput AS
-- SELECT
--     tm.tenant,
--     tm.branch_id,
--     tm.till_id,
--     tm.till_status,
--     tm.till_type,
--     tm.currency_code,
--     tm.denomination_code,
--     tm.denominations,
--     (
--         SELECT SUM(
--         (tm.denominations->>'denom_count')::INT * 
--         (SELECT denomination_value
--          FROM denomination_master
--          WHERE denomination_master.denomination_code = (tm.denominations->>'denom_code')::INT)
--     )
--     ) AS amount
-- FROM till_master_new tm
-- GROUP BY
--     tm.tenant,
--     tm.branch_id,
--     tm.till_id,
--     tm.till_status,
--     tm.till_type,
--     tm.currency_code,
--     tm.denomination_code,
--     tm.denominations;


-- INSERT INTO till_master_new (
--     tenant, branch_id, till_status, till_type, currency_code, denomination_code, denominations
-- ) VALUES (
--     'fcbsmartbranch', 1, 'O', 'Till', 'INR', 19,
--     '{"denom_code": "19", "denom_count": "1"}'::JSONB
-- );

-- SELECT * FROM till_master_amount_comput WHERE till_id = 2;


--     -- transaction_code VARCHAR(50),
--     -- transaction_desc VARCHAR(200),
--     -- amount NUMERIC,
--     -- currency_code VARCHAR(5),
--     -- till_id VARCHAR(50),
--     -- denominations JSONB,
--     -- remarks TEXT,
--     -- created_by_user VARCHAR(50),
--     -- created_by_provider VARCHAR(50)


-- --Function to insert into transaction_master
-- CREATE OR REPLACE FUNCTION transaction_master_creation (
--     tenant VARCHAR(50),
--     branch_id INT,
--     transaction_code VARCHAR(50),
--     transaction_desc VARCHAR(500)
-- )
-- RETURNS TEXT AS $$
-- BEGIN
--     INSERT INTO transaction_master 
--         VALUES (
--             tenant, branch_id, transaction_code, transaction_desc
--         );    
--     RETURN 'inserted into transaction master'
-- EXCEPTION
--     WHEN OTHERS THEN
--         RETURN 'Transaction insertion failed. Error: ' || SQLERRM;
-- END;
-- $$ LANGUAGE plpgsql;

-- --Function to insert into transaction_denomination
-- CREATE OR REPLACE FUNCTION transaction_deno_creation (
--     tenant VARCHAR(50),
--     branch_id INT,
--     transaction_id VARCHAR(50),
--     till_id VARCHAR(50),
--     currency_code VARCHAR(50),
--     related_account VARCHAR(50),
--     amount VARCHAR(50),
--     denomination_code INT,
--     denominations JSONB,
-- )
-- RETURNS TEXT AS $$
-- BEGIN
--     INSERT INTO transaction_master 
--         VALUES (
--             tenant, branch_id, transaction_code, transaction_desc
--         );    
--     RETURN 'inserted into transaction master'
-- EXCEPTION
--     WHEN OTHERS THEN
--         RETURN 'Transaction insertion failed. Error: ' || SQLERRM;
-- END;
-- $$ LANGUAGE plpgsql;



-- INSERT INTO till_master (
--     tenant, branch_id, till_status, till_type, currency_code, denomination_code, denominations
-- ) VALUES (
--     'fcbsmartbranch', 1, 'O', 'Till', 'USD', 5,
--     '{"denom_code": 5, "denom_count": 2}'
-- );

-- INSERT INTO till_master (
--     tenant, branch_id, till_status, till_type, currency_code, denomination_code, denominations
-- ) VALUES (
--     'fcbsmartbranch', 1, 'O', 'Till', 'INR', 19,
--     '{"denom_code": "19", "denom_count": "1"}'
-- );

-- INSERT INTO till_master (
--     tenant, branch_id, till_status, till_type, currency_code, denomination_code, denominations
-- ) VALUES (
--     'fcbsmartbranch', 1, 'O', 'Till', 'INR', 20,
--     '{"denom_code": "20", "denom_count": "2"}'
-- );


-- CREATE OR REPLACE FUNCTION update_till_master(
--     p_tenant VARCHAR(50),
--     p_branch_id INT,
--     p_till_id INT,
--     p_currency_code VARCHAR(5),
--     p_new_denominations JSONB
-- )
-- RETURNS VOID AS $$
-- DECLARE
--     denom_code INT;
--     denom_count INT;
--     existing_denom_count INT;
--     denom_value INT;
--     updated_denominations JSONB := '{}'::JSONB;
--     total_amount INT := 0;
-- BEGIN
--     -- Loop through each denomination in the new input
--     FOR denom_code, denom_count IN 
--         SELECT (key)::INT, (value)::INT 
--         FROM jsonb_each(p_new_denominations)
--     LOOP
--         -- Check if the denomination already exists in the till_master table
--         SELECT COALESCE((denominations->>denom_code::TEXT)::INT, 0)
--         INTO existing_denom_count
--         FROM till_master
--         WHERE tenant = p_tenant AND branch_id = p_branch_id AND till_id = p_till_id AND currency_code = p_currency_code;

--         -- Add the new count to the existing count
--         updated_denominations := updated_denominations || jsonb_build_object(
--             denom_code::TEXT,
--             existing_denom_count + denom_count
--         );
--     END LOOP;

--     -- Merge updated denominations with existing ones
--     FOR denom_code, denom_count IN 
--         SELECT (key)::INT, (value)::INT 
--         FROM jsonb_each((SELECT denominations FROM till_master WHERE tenant = p_tenant AND branch_id = p_branch_id AND till_id = p_till_id AND currency_code = p_currency_code))
--     LOOP
--         IF NOT (p_new_denominations ? denom_code::TEXT) THEN
--             updated_denominations := updated_denominations || jsonb_build_object(
--                 denom_code::TEXT,
--                 denom_count
--             );
--         END IF;
--     END LOOP;

--     -- Recalculate the total amount
--     FOR denom_code, denom_count IN 
--         SELECT (key)::INT, (value)::INT 
--         FROM jsonb_each(updated_denominations)
--     LOOP
--         -- Get the denomination value
--         SELECT denomination_value INTO denom_value
--         FROM denomination_master
--         WHERE denomination_code = denom_code;

--         -- Add to total amount
--         total_amount := total_amount + (denom_count * denom_value);
--     END LOOP;

--     -- Update the till_master table
--     UPDATE till_master
--     SET denominations = updated_denominations,
--         amount = total_amount
--     WHERE tenant = p_tenant AND branch_id = p_branch_id AND till_id = p_till_id AND currency_code = p_currency_code;

-- END;
-- $$ LANGUAGE plpgsql;


-- CREATE OR REPLACE FUNCTION compute_till_amount() 
-- RETURNS TRIGGER AS $$
-- DECLARE
--     denom_code INT;
--     denom_count INT;
--     denom_value INT;
--     existing_denom_count INT;
--     updated_denominations JSONB := '{}'::JSONB;
--     total_amount INT := 0;
--     row_exists BOOLEAN;
-- BEGIN
--     -- Check if the row for the given till_id and currency_code exists
--     SELECT EXISTS (
--         SELECT 1
--         FROM till_master
--         WHERE tenant = NEW.tenant 
--           AND branch_id = NEW.branch_id 
--           AND till_id = NEW.till_id 
--           AND currency_code = NEW.currency_code
--     ) INTO row_exists;

--     -- If the row exists, fetch the current denominations and merge them
--     IF row_exists THEN
--         FOR denom_code, denom_count IN
--             SELECT (key)::INT, (value)::INT FROM jsonb_each(NEW.denominations)
--         LOOP
--             -- Fetch the existing count of the denomination
--             SELECT COALESCE((denominations->>denom_code::TEXT)::INT, 0)
--             INTO existing_denom_count
--             FROM till_master
--             WHERE tenant = NEW.tenant 
--               AND branch_id = NEW.branch_id 
--               AND till_id = NEW.till_id 
--               AND currency_code = NEW.currency_code;

--             -- Update the denominations JSONB object with the new count
--             updated_denominations := updated_denominations || jsonb_build_object(
--                 denom_code::TEXT,
--                 existing_denom_count + denom_count
--             );
--         END LOOP;

--         -- Merge updated denominations with existing ones
--         FOR denom_code, denom_count IN
--             SELECT (key)::INT, (value)::INT 
--             FROM jsonb_each((SELECT denominations 
--                              FROM till_master 
--                              WHERE tenant = NEW.tenant 
--                                AND branch_id = NEW.branch_id 
--                                AND till_id = NEW.till_id 
--                                AND currency_code = NEW.currency_code))
--         LOOP
--             -- Retain existing denominations that are not part of the new input
--             IF NOT (NEW.denominations ? denom_code::TEXT) THEN
--                 updated_denominations := updated_denominations || jsonb_build_object(
--                     denom_code::TEXT,
--                     denom_count
--                 );
--             END IF;
--         END LOOP;

--     ELSE
--         -- If the row does not exist, simply use the new denominations
--         updated_denominations := NEW.denominations;
--     END IF;

--     -- Recalculate the total amount based on the updated denominations
--     FOR denom_code, denom_count IN
--         SELECT (key)::INT, (value)::INT FROM jsonb_each(updated_denominations)
--     LOOP
--         -- Fetch the denomination value
--         SELECT denomination_value INTO denom_value
--         FROM denomination_master
--         WHERE denomination_code = denom_code;

--         -- Add to the total amount
--         total_amount := total_amount + (denom_count * denom_value);
--     END LOOP;

--     -- Update or insert the row in the till_master table
--     IF row_exists THEN
--         -- Update the existing row
--         UPDATE till_master
--         SET denominations = updated_denominations,
--             amount = total_amount
--         WHERE tenant = NEW.tenant 
--           AND branch_id = NEW.branch_id 
--           AND till_id = NEW.till_id 
--           AND currency_code = NEW.currency_code;
--     ELSE
--         -- Insert a new row
--         INSERT INTO till_master (
--             tenant, branch_id, till_id, till_status, till_type, currency_code, denominations, amount
--         ) VALUES (
--             NEW.tenant, NEW.branch_id, NEW.till_id, 'O', 'Till', NEW.currency_code, updated_denominations, total_amount
--         );
--     END IF;

--     -- Return the modified NEW record
--     NEW.amount := total_amount;
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;


-- CREATE OR REPLACE FUNCTION amnt_compute_till_master_ex5(
--     tenant_p VARCHAR(50),
--     branch_id_p INT,
--     till_id_p INT,
--     till_status_p CHAR(1),
--     till_type_p VARCHAR(20),
--     currency_code_p VARCHAR(5),
--     denominations_p JSONB
-- ) 
-- RETURNS TEXT AS $$
-- DECLARE
--     denom_code INT;
--     denom_count INT;
--     denom_value INT;
--     total_amount INT := 0;
--     existing_denominations JSONB;
--     updated_denominations JSONB := '{}'::JSONB;
--     row_exists BOOLEAN;
-- BEGIN
--     -- Check if the row exists
--     SELECT EXISTS (
--         SELECT 1
--         FROM till_master_ex
--         WHERE tenant = tenant_p
--         AND branch_id = branch_id_p
--         AND till_id = till_id_p
--         AND currency_code = currency_code_p
--     ) INTO row_exists;

--     -- If the row exists, fetch existing denominations
--     IF row_exists THEN
--         SELECT denominations INTO existing_denominations
--         FROM till_master_ex
--         WHERE tenant = tenant_p
--         AND branch_id = branch_id_p
--         AND till_id = till_id_p
--         AND currency_code = currency_code_p;

--         -- Merge new denominations with existing ones
--         FOR denom_code, denom_count IN
--             SELECT (key)::INT, (value)::INT FROM jsonb_each_text(denominations_p)
--         LOOP
--             -- Add new or update existing denomination count
--             updated_denominations := updated_denominations || jsonb_build_object(
--                 denom_code::TEXT,
--                 COALESCE((existing_denominations ->> denom_code::TEXT)::INT, 0) + denom_count
--             );
--         END LOOP;

--         -- Retain denominations from the existing that are not in the input
--         FOR denom_code, denom_count IN
--             SELECT (key)::INT, (value)::INT FROM jsonb_each(existing_denominations)
--         LOOP
--             IF NOT (denominations_p ? denom_code::TEXT) THEN
--                 updated_denominations := updated_denominations || jsonb_build_object(
--                     denom_code::TEXT,
--                     denom_count
--                 );
--             END IF;
--         END LOOP;
--     ELSE
--         -- If the row does not exist, use the input denominations
--         updated_denominations := denominations_p;
--     END IF;

--     -- Calculate the total amount
--     FOR denom_code, denom_count IN
--         SELECT (key)::INT, (value)::INT FROM jsonb_each(updated_denominations)
--     LOOP
--         SELECT denomination_value INTO denom_value
--         FROM denomination_master
--         WHERE denomination_code = denom_code;

--         total_amount := total_amount + (denom_count * denom_value);
--     END LOOP;

--     -- Update or insert the row
--     IF row_exists THEN
--         UPDATE till_master_ex
--         SET denominations = updated_denominations,
--             amount = total_amount
--         WHERE tenant = tenant_p 
--         AND branch_id = branch_id_p 
--         AND till_id = till_id_p 
--         AND currency_code = currency_code_p;
--     ELSE
--         INSERT INTO till_master_ex (
--             tenant, branch_id, till_id, till_status, till_type, currency_code, denominations, amount
--         )
--         VALUES (
--             tenant_p, branch_id_p, till_id_p, till_status_p, till_type_p, currency_code_p, updated_denominations, total_amount
--         );
--     END IF;

--     RETURN 'FLOW COMPLETED';

-- EXCEPTION
--     WHEN OTHERS THEN
--         RETURN 'Flow processing failed. Error: ' || SQLERRM;
-- END;
-- $$ LANGUAGE plpgsql;



--function for computing amount and updating denomination
-- CREATE OR REPLACE FUNCTION amnt_compute_till_master_ex2() 
-- RETURNS TRIGGER AS $$
-- DECLARE
--     denom_code INT;
--     denom_count INT;
--     denom_value INT;
--     total_amount INT := 0;
-- BEGIN
--     -- Loop through the denominations JSONB object
--     FOR denom_code, denom_count IN
--         SELECT (key)::INT, (value)::INT 
--         FROM jsonb_each_text(NEW.denominations)  -- Use jsonb_each_text to extract as text, then cast
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


--trigger for amount and denominations update
-- CREATE TRIGGER trigger_amnt_compute_till_master_ex2
-- BEFORE INSERT OR UPDATE ON till_master_ex
-- FOR EACH ROW
-- EXECUTE FUNCTION amnt_compute_till_master_ex2();

-- -- Disable a specific trigger on a table
-- ALTER TABLE till_master_ex DISABLE TRIGGER trigger_amnt_compute_till_master_ex2;

--TEST insertion
-- INSERT INTO till_master_ex (tenant, branch_id, till_id, till_status, till_type, currency_code, denominations)
-- VALUES ('fcbsmartbranch', 1, 2, 'O', 'Till', 'USD', '{"1": 1, "2":  2}'::JSONB);

-- INSERT INTO till_master_ex (tenant, branch_id, till_id, till_status, till_type, currency_code, denominations)
-- VALUES ('fcbsmartbranch', 1, 2, 'O', 'Till', 'INR', '{"19": 1, "21":  1}'::JSONB);

-- SELECT amnt_compute_till_master_ex5('fcbsmartbranch', 1, 2, 'O', 'Till', 'INR', '{"18": 2, "19" : 1, "21" : 1}'::JSONB);




--     SELECT sm.sessionid
--     INTO sessionid1
--     FROM session_master sm
--     WHERE sm.tenant = flow.tenant AND sm.branch_id = flow.branch_id AND sm.cif = flow.cif;
--     -- If no session exists, create a new session
--     IF sessionid1 IS NULL THEN
--         sessionid1 := uuid_generate_v4();
--         INSERT INTO session_master (
--             tenant, branch_id, sessionid, customer_rep, authentication_method, cif, account_no, session_start, userid, provider_name, username, id_type, id_no, first_name, last_name, dob, gender, callback_done
--         )
--         VALUES (
--             tenant, branch_id, sessionid1, 'C','Card', cif, '{"Acc1": "USD", "Acc2": "INR"}' , CURRENT_TIMESTAMP,  'User 002', 'Vinkle', 'Aditi', 'NID', '1234567', 'Aditi', 'Sharma', '2024-09-01', 'F', 'Y'
--         );
--     -- if session exists with same cif, use existing session id
--     ELSE
--         sessionid1 := session_master.sessionid;
--     END IF;

-- SELECT EXISTS (
--     SELECT 1
--     FROM session_master as sm
--     WHERE sm.tenant = flow.tenant
--     AND sm.branch_id = flow.branch_id
--     AND sm.cif = flow.cif
-- ) INTO session_exists;

-- IF session_exists THEN
--     SELECT sessionid INTO sessionid1
--     FROM session_master as sm
--     WHERE sm.tenant = flow.tenant
--     AND sm.branch_id = flow.branch_id
--     AND sm.cif = flow.cif;
-- ELSE
--     sessionid1 := uuid_generate_v4();
--     INSERT INTO session_master (
--         tenant, branch_id, sessionid, customer_rep, authentication_method, cif, account_no, session_start, userid, provider_name, username, id_type, id_no, first_name, last_name, dob, gender, callback_done
--     )
--     VALUES (
--         tenant, branch_id, sessionid1, 'C','Card', cif, '{"Acc1": "USD", "Acc2": "INR"}' , CURRENT_TIMESTAMP,  'User 002', 'Vinkle', 'Aditi', 'NID', '1234567', 'Aditi', 'Sharma', '2024-09-01', 'F', 'Y'
--     );
-- END IF;

CREATE OR REPLACE FUNCTION flow(
    tenant VARCHAR(50),
    branch_id INT, 
    cif VARCHAR(50)
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
            tenant, branch_id, sessionid1, 'C','Card', cif, '{"Acc1": "USD", "Acc2": "INR"}' , CURRENT_TIMESTAMP,  'User 002', 'Vinkle', 'Aditi', 'NID', '1234567', 'Aditi', 'Sharma', '2024-09-01', 'F', 'Y'
        );
    END IF;

--checking if callback done or not
    IF (SELECT sm.callback_done 
        FROM session_master sm 
        WHERE sm.sessionid = sessionid1) = 'Y' THEN

--txn type + data (transactions)
        INSERT INTO transactions ( tenant, branch_id, transaction_id, transaction_code, transaction_status, auth_status, sessionid, created_by, created_by_user_id, created_by_provider, create_timestamp, last_updated_user, last_updated_user_id, last_updated_user_provider, last_updated_timestamp, comments, data_table)
        VALUES 
        ( tenant, branch_id, 5, 'TX001', 'D', 'U', sessionid1, 'Aditi', '321', 'Vinkle', '2024-11-26 10:30:00', 'V', 'User01', 'Vinkle', '2024-11-26 12:30:00', 'Y', '{"data": "values"}');

--if comments present push to comments table
        IF (SELECT txns.comments 
        FROM transactions txns 
        WHERE txns.sessionid = sessionid1) = 'Y' THEN
            INSERT INTO comments
            VALUES (tenant, branch_id, sessionid1, 5, 1, 'Vinkle', 'Aditi', '4321', 'this is a comment', '2024-11-28 14:30:00+05:30');
        END IF;

--denomination
        INSERT INTO transaction_denomination_ex (tenant, branch_id, transaction_id, till_id, currency_code, related_account, amount, denominations )
        VALUES (
            tenant, branch_id, 5, 3, 'USD', 'NA', '12', '{"1":1}'
        );

--till update
        -- INSERT INTO till_master_new (tenant, branch_id, till_id, till_status, till_type, currency_code, denominations)
        -- VALUES ('fcbsmartbranch', 1, 1, 'O', 'Till', 'INR', '{"19": 1, "20":  2}'::JSONB);
        PERFORM amnt_compute_till_master_ex6(tenant, branch_id, 3, 'O', 'Till', 'USD', '{"1":1}'::JSONB);

--fin txns
        --need a flag here for credit/debit transaction type
        INSERT INTO financial_transactions
        VALUES (
            tenant, branch_id, sessionid1, 5, 'Y', 'ACC2', 'ACC1', 'USD', 'USD', '1', '1', 'Income', 'Saving', 'R1', 'R2', 'NA', 'NA', 'Y', 'NA', 'Y', '2024-11-28 14:30:00+05:30', 'Inst2', '2024-11-28 14:30:00+05:30', 'I1', '2024-11-28 14:30:00+05:30'
        );
    END IF;    
    RETURN 'Flow Completed';
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Flow processing failed. Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql; 


-- CREATE TABLE till_master (
--     tenant VARCHAR(50),
--     branch_id INT,
--     till_id INT UNIQUE,
--     till_status CHAR(1) CHECK (till_status IN ('O', 'C')),         --(O - Open, C - Close)
--     till_type VARCHAR(20) CHECK (till_type IN ('Till', 'vault', 'chief teller', 'cash centre')),
--     currency_code VARCHAR(5),
--     denomination_code INT,
--     denominations JSONB,  --{denom_code (FK): denomination code (denomination_master), denom_count: Count of denominations}
--     denomination_value INT,
--     PRIMARY KEY (tenant, branch_id, till_id),
--     FOREIGN KEY (currency_code) REFERENCES currency_Master(currency_code),
--     FOREIGN KEY (denomination_code) REFERENCES denomination_master(denomination_code),
--     CHECK (
--         denominations ? 'denom_code' AND
--         denominations ? 'denom_count' AND
--         (denominations->>'denom_code')::INT = denomination_code
--     )
-- );


-- CREATE TABLE transaction_denomination (
--     tenant VARCHAR(50),
--     branch_id INT,
--     transaction_id VARCHAR(50) UNIQUE,
--     till_id INT,
--     currency_code VARCHAR(50),
--     related_account VARCHAR(50),          --Offset account (customer’s or other till /valut account)
--     amount INT,                   --transaction amount (in the currency of transaction)
--     denomination_code INT,
--     denominations JSONB,                   --{Denom_code (FK): denomination code (denomination_master), denom_count: Count of denominations}
--     PRIMARY KEY (tenant, branch_id, transaction_id),
--     FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
--     FOREIGN KEY (till_id) REFERENCES till_master(till_id),
--     FOREIGN KEY (currency_code) REFERENCES currency_master(currency_code),
--     FOREIGN KEY (denomination_code) REFERENCES denomination_master(denomination_code),
--     CHECK (
--         denominations ? 'Denom_code' AND
--         denominations ? 'Denom_count' AND
--         (denominations->>'Denom_code')::INT = denomination_code
--     )
-- );

--TESTING