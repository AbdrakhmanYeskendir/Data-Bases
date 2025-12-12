-- ============================================
-- BONUS LABORATORY WORK: BANKING TRANSACTION SYSTEM
-- Student: Abdrakhman Yeskendir
-- Date: 12.12.2025
-- ============================================

-- PART 1: DATABASE SCHEMA CREATION
-- ============================================

-- Drop existing tables (if any) for clean setup
DROP TABLE IF EXISTS audit_log CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS accounts CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS exchange_rates CASCADE;

-- 1. customers table
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    tin CHAR(12) UNIQUE NOT NULL CHECK (tin ~ '^[0-9]{12}$'),
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    status VARCHAR(10) NOT NULL CHECK (status IN ('active', 'blocked', 'frozen')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    daily_limit_kzt DECIMAL(15,2) DEFAULT 1000000.00
);

-- 2. accounts table
CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id) ON DELETE CASCADE,
    account_number VARCHAR(34) UNIQUE NOT NULL CHECK (account_number ~ '^KZ[0-9]{2}[A-Z]{4}[0-9]{20}$'),
    currency VARCHAR(3) NOT NULL CHECK (currency IN ('KZT', 'USD', 'EUR', 'RUB')),
    balance DECIMAL(15,2) DEFAULT 0.00 CHECK (balance >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP
);

-- 3. exchange_rates table
CREATE TABLE exchange_rates (
    rate_id SERIAL PRIMARY KEY,
    from_currency VARCHAR(3) NOT NULL CHECK (from_currency IN ('KZT', 'USD', 'EUR', 'RUB')),
    to_currency VARCHAR(3) NOT NULL CHECK (to_currency IN ('KZT', 'USD', 'EUR', 'RUB')),
    rate DECIMAL(10,6) NOT NULL,
    valid_from TIMESTAMP NOT NULL,
    valid_to TIMESTAMP,
    CHECK (from_currency <> to_currency)
);

-- 4. transactions table
CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    from_account_id INTEGER REFERENCES accounts(account_id),
    to_account_id INTEGER REFERENCES accounts(account_id),
    amount DECIMAL(15,2) NOT NULL CHECK (amount > 0),
    currency VARCHAR(3) NOT NULL CHECK (currency IN ('KZT', 'USD', 'EUR', 'RUB')),
    exchange_rate DECIMAL(10,6) DEFAULT 1.0,
    amount_kzt DECIMAL(15,2) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('transfer', 'deposit', 'withdrawal')),
    status VARCHAR(10) NOT NULL CHECK (status IN ('pending', 'completed', 'failed', 'reversed')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    description TEXT
);

-- 5. audit_log table
CREATE TABLE audit_log (
    log_id SERIAL PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    record_id INTEGER NOT NULL,
    action VARCHAR(10) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_values JSONB,
    new_values JSONB,
    changed_by VARCHAR(100) DEFAULT CURRENT_USER,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address INET
);

-- ============================================
-- PART 2: SAMPLE DATA INSERTION (Min 10 records each)
-- ============================================

-- Insert customers
INSERT INTO customers (tin, full_name, phone, email, status, daily_limit_kzt) VALUES
('123456789012', 'Aisultan Sarsenov', '+77011234567', 'aisultan@email.com', 'active', 1500000.00),
('234567890123', 'Mariya Ivanova', '+77022345678', 'mariya@email.com', 'active', 2000000.00),
('345678901234', 'Dmitry Petrov', '+77033456789', 'dmitry@email.com', 'active', 1000000.00),
('456789012345', 'Alina Kim', '+77044567890', 'alina@email.com', 'blocked', 500000.00),
('567890123456', 'Sergey Smirnov', '+77055678901', 'sergey@email.com', 'active', 3000000.00),
('678901234567', 'Zhanar Kuanysh', '+77066789012', 'zhanar@email.com', 'active', 1000000.00),
('789012345678', 'Arman Zhunusov', '+77077890123', 'arman@email.com', 'frozen', 500000.00),
('890123456789', 'Elena Voronova', '+77088901234', 'elena@email.com', 'active', 2500000.00),
('901234567890', 'Kairat Nurgaliev', '+77099012345', 'kairat@email.com', 'active', 1500000.00),
('012345678901', 'Anara Bektur', '+77100123456', 'anara@email.com', 'active', 1000000.00);

-- Insert accounts
INSERT INTO accounts (customer_id, account_number, currency, balance, is_active) VALUES
(1, 'KZ12345678901234567890', 'KZT', 5000000.00, true),
(1, 'KZ09876543210987654321', 'USD', 50000.00, true),
(2, 'KZ23456789012345678901', 'KZT', 3000000.00, true),
(2, 'KZ98765432109876543210', 'EUR', 20000.00, true),
(3, 'KZ34567890123456789012', 'KZT', 1000000.00, true),
(4, 'KZ45678901234567890123', 'KZT', 500000.00, false),
(5, 'KZ56789012345678901234', 'KZT', 7000000.00, true),
(6, 'KZ67890123456789012345', 'USD', 30000.00, true),
(7, 'KZ78901234567890123456', 'KZT', 100000.00, true),
(8, 'KZ89012345678901234567', 'EUR', 15000.00, true),
(9, 'KZ90123456789012345678', 'KZT', 4000000.00, true),
(10, 'KZ01234567890123456789', 'KZT', 2000000.00, true);

-- Insert exchange rates
INSERT INTO exchange_rates (from_currency, to_currency, rate, valid_from, valid_to) VALUES
('USD', 'KZT', 450.00, '2024-01-01 00:00:00', NULL),
('EUR', 'KZT', 500.00, '2024-01-01 00:00:00', NULL),
('RUB', 'KZT', 5.00, '2024-01-01 00:00:00', NULL),
('KZT', 'USD', 0.002222, '2024-01-01 00:00:00', NULL),
('KZT', 'EUR', 0.002000, '2024-01-01 00:00:00', NULL),
('USD', 'EUR', 0.90, '2024-01-01 00:00:00', NULL),
('EUR', 'USD', 1.11, '2024-01-01 00:00:00', NULL),
('USD', 'KZT', 455.00, '2024-02-01 00:00:00', '2024-02-28 23:59:59'),
('EUR', 'KZT', 510.00, '2024-02-01 00:00:00', '2024-02-28 23:59:59'),
('RUB', 'KZT', 5.50, '2024-02-01 00:00:00', '2024-02-28 23:59:59');

-- Insert sample transactions
INSERT INTO transactions (from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, type, status, description) VALUES
(1, 3, 100000.00, 'KZT', 1.0, 100000.00, 'transfer', 'completed', 'Monthly rent payment'),
(2, 4, 1000.00, 'USD', 450.0, 450000.00, 'transfer', 'completed', 'International transfer'),
(3, 5, 50000.00, 'KZT', 1.0, 50000.00, 'transfer', 'completed', 'Gift'),
(NULL, 1, 200000.00, 'KZT', 1.0, 200000.00, 'deposit', 'completed', 'Cash deposit'),
(5, NULL, 30000.00, 'KZT', 1.0, 30000.00, 'withdrawal', 'completed', 'ATM withdrawal'),
(1, 6, 500.00, 'USD', 450.0, 225000.00, 'transfer', 'completed', 'Test transfer 2'),
(3, 8, 100.00, 'EUR', 500.0, 50000.00, 'transfer', 'completed', 'Test transfer 3'),
(5, 6, 50.00, 'USD', 450.0, 22500.00, 'transfer', 'completed', 'Test transfer 4'),
(7, 8, 1000.00, 'EUR', 500.0, 500000.00, 'transfer', 'completed', 'Test transfer 5'),
(9, 10, 20000.00, 'KZT', 1.0, 20000.00, 'transfer', 'completed', 'Test transfer 6');

-- ============================================
-- PART 3: AUDIT LOGGING TRIGGER
-- ============================================

CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_log (table_name, record_id, action, old_values, new_values)
        VALUES (TG_TABLE_NAME, NEW.account_id, 'INSERT', NULL, row_to_json(NEW));
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_log (table_name, record_id, action, old_values, new_values)
        VALUES (TG_TABLE_NAME, NEW.account_id, 'UPDATE', row_to_json(OLD), row_to_json(NEW));
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_log (table_name, record_id, action, old_values, new_values)
        VALUES (TG_TABLE_NAME, OLD.account_id, 'DELETE', row_to_json(OLD), NULL);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER accounts_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON accounts
FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

-- ============================================
-- PART 4: TASK 1 - TRANSACTION MANAGEMENT
-- ============================================

CREATE OR REPLACE PROCEDURE process_transfer(
    p_from_account_number VARCHAR(34),
    p_to_account_number VARCHAR(34),
    p_amount DECIMAL(15,2),
    p_currency VARCHAR(3),
    p_description TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_from_account_id INTEGER;
    v_to_account_id INTEGER;
    v_from_customer_id INTEGER;
    v_to_customer_id INTEGER;
    v_from_currency VARCHAR(3);
    v_to_currency VARCHAR(3);
    v_from_balance DECIMAL(15,2);
    v_exchange_rate DECIMAL(10,6);
    v_amount_kzt DECIMAL(15,2);
    v_daily_spent DECIMAL(15,2);
    v_customer_status VARCHAR(10);
    v_daily_limit DECIMAL(15,2);
    v_error_code INTEGER;
BEGIN
    -- Initialize error tracking
    v_error_code := 0;
    
    -- Start transaction
    BEGIN
        -- Lock both accounts to prevent race conditions
        SELECT account_id, customer_id, currency, balance
        INTO v_from_account_id, v_from_customer_id, v_from_currency, v_from_balance
        FROM accounts 
        WHERE account_number = p_from_account_number AND is_active = TRUE
        FOR UPDATE;
        
        IF v_from_account_id IS NULL THEN
            RAISE EXCEPTION 'ERR001: Source account not found or inactive';
        END IF;
        
        SELECT account_id, customer_id, currency
        INTO v_to_account_id, v_to_customer_id, v_to_currency
        FROM accounts 
        WHERE account_number = p_to_account_number AND is_active = TRUE
        FOR UPDATE;
        
        IF v_to_account_id IS NULL THEN
            RAISE EXCEPTION 'ERR002: Destination account not found or inactive';
        END IF;
        
        -- Check customer status
        SELECT status, daily_limit_kzt INTO v_customer_status, v_daily_limit
        FROM customers WHERE customer_id = v_from_customer_id;
        
        IF v_customer_status != 'active' THEN
            RAISE EXCEPTION 'ERR003: Source customer is %', v_customer_status;
        END IF;
        
        -- Check sufficient balance
        IF v_from_balance < p_amount THEN
            RAISE EXCEPTION 'ERR004: Insufficient funds. Available: %, Requested: %', 
                           v_from_balance, p_amount;
        END IF;
        
        -- Calculate amount in KZT for daily limit check
        IF p_currency = 'KZT' THEN
            v_amount_kzt := p_amount;
            v_exchange_rate := 1.0;
        ELSE
            -- Get exchange rate
            SELECT rate INTO v_exchange_rate
            FROM exchange_rates 
            WHERE from_currency = p_currency 
                AND to_currency = 'KZT'
                AND valid_to IS NULL;
            
            IF v_exchange_rate IS NULL THEN
                RAISE EXCEPTION 'ERR005: Exchange rate not available for % to KZT', p_currency;
            END IF;
            
            v_amount_kzt := p_amount * v_exchange_rate;
        END IF;
        
        -- Check daily transaction limit
        SELECT COALESCE(SUM(amount_kzt), 0) INTO v_daily_spent
        FROM transactions 
        WHERE from_account_id = v_from_account_id 
            AND status = 'completed'
            AND DATE(created_at) = CURRENT_DATE;
        
        IF (v_daily_spent + v_amount_kzt) > v_daily_limit THEN
            RAISE EXCEPTION 'ERR006: Daily limit exceeded. Spent: %, Limit: %, This transaction: %',
                           v_daily_spent, v_daily_limit, v_amount_kzt;
        END IF;
        
        -- Create transaction record
        INSERT INTO transactions (
            from_account_id, to_account_id, amount, currency, 
            exchange_rate, amount_kzt, type, status, description
        ) VALUES (
            v_from_account_id, v_to_account_id, p_amount, p_currency,
            v_exchange_rate, v_amount_kzt, 'transfer', 'pending', p_description
        )
        RETURNING transaction_id INTO v_error_code;
        
        -- Handle currency conversion if needed
        IF v_from_currency != v_to_currency THEN
            -- Convert amount to destination currency
            DECLARE
                v_conversion_rate DECIMAL(10,6);
                v_converted_amount DECIMAL(15,2);
            BEGIN
                -- Set savepoint for currency conversion
                SAVEPOINT currency_conversion;
                
                SELECT rate INTO v_conversion_rate
                FROM exchange_rates 
                WHERE from_currency = v_from_currency 
                    AND to_currency = v_to_currency
                    AND valid_to IS NULL;
                    
                IF v_conversion_rate IS NULL THEN
                    -- Try reverse conversion
                    SELECT 1/rate INTO v_conversion_rate
                    FROM exchange_rates 
                    WHERE from_currency = v_to_currency 
                        AND to_currency = v_from_currency
                        AND valid_to IS NULL;
                        
                    IF v_conversion_rate IS NULL THEN
                        RAISE EXCEPTION 'ERR007: No exchange rate available from % to %', 
                                       v_from_currency, v_to_currency;
                    END IF;
                END IF;
                
                v_converted_amount := p_amount * v_conversion_rate;
                
                -- Update balances
                UPDATE accounts SET balance = balance - p_amount 
                WHERE account_id = v_from_account_id;
                
                UPDATE accounts SET balance = balance + v_converted_amount 
                WHERE account_id = v_to_account_id;
                
            EXCEPTION
                WHEN OTHERS THEN
                    ROLLBACK TO SAVEPOINT currency_conversion;
                    RAISE;
            END;
        ELSE
            -- Same currency transfer
            UPDATE accounts SET balance = balance - p_amount 
            WHERE account_id = v_from_account_id;
            
            UPDATE accounts SET balance = balance + p_amount 
            WHERE account_id = v_to_account_id;
        END IF;
        
        -- Update transaction status to completed
        UPDATE transactions 
        SET status = 'completed', completed_at = CURRENT_TIMESTAMP
        WHERE transaction_id = v_error_code;
        
        -- Log successful transaction
        INSERT INTO audit_log (table_name, record_id, action, old_values, new_values, changed_by)
        VALUES ('transactions', v_error_code, 'INSERT', NULL, 
                jsonb_build_object('status', 'completed', 'amount', p_amount), 
                'process_transfer');
        
        -- Commit transaction
        COMMIT;
        
        RAISE NOTICE 'Transfer completed successfully. Transaction ID: %', v_error_code;
        
    EXCEPTION
        WHEN OTHERS THEN
            -- Log failed attempt
            INSERT INTO audit_log (table_name, record_id, action, old_values, new_values, changed_by)
            VALUES ('transactions', COALESCE(v_error_code, 0), 'INSERT', NULL, 
                    jsonb_build_object('error', SQLERRM, 'status', 'failed'), 
                    'process_transfer');
            
            -- Update transaction status if record was created
            IF v_error_code > 0 THEN
                UPDATE transactions 
                SET status = 'failed', description = COALESCE(description, '') || ' | Error: ' || SQLERRM
                WHERE transaction_id = v_error_code;
            END IF;
            
            RAISE;
    END;
END;
$$;

-- ============================================
-- PART 5: TASK 2 - VIEWS FOR REPORTING
-- ============================================

-- View 1: customer_balance_summary
CREATE OR REPLACE VIEW customer_balance_summary AS
WITH customer_balances AS (
    SELECT 
        c.customer_id,
        c.full_name,
        c.tin,
        c.status as customer_status,
        c.daily_limit_kzt,
        a.account_id,
        a.account_number,
        a.currency,
        a.balance,
        COALESCE(er.rate, 1.0) as exchange_rate_to_kzt,
        CASE 
            WHEN a.currency = 'KZT' THEN a.balance
            ELSE a.balance * COALESCE(er.rate, 1.0)
        END as balance_kzt
    FROM customers c
    JOIN accounts a ON c.customer_id = a.customer_id AND a.is_active = TRUE
    LEFT JOIN exchange_rates er ON er.from_currency = a.currency 
        AND er.to_currency = 'KZT' 
        AND er.valid_to IS NULL
)
SELECT 
    customer_id,
    full_name,
    tin,
    customer_status,
    jsonb_agg(jsonb_build_object(
        'account_number', account_number,
        'currency', currency,
        'balance', balance,
        'balance_kzt', balance_kzt
    )) as accounts,
    SUM(balance_kzt) as total_balance_kzt,
    daily_limit_kzt,
    ROUND(
        CASE 
            WHEN daily_limit_kzt > 0 THEN 
                (SUM(balance_kzt) / daily_limit_kzt * 100)
            ELSE 0 
        END, 2
    ) as limit_utilization_percent,
    RANK() OVER (ORDER BY SUM(balance_kzt) DESC) as balance_rank
FROM customer_balances
GROUP BY customer_id, full_name, tin, customer_status, daily_limit_kzt;

-- View 2: daily_transaction_report
CREATE OR REPLACE VIEW daily_transaction_report AS
WITH daily_stats AS (
    SELECT 
        DATE(created_at) as transaction_date,
        type,
        COUNT(*) as transaction_count,
        SUM(amount_kzt) as total_volume_kzt,
        AVG(amount_kzt) as avg_amount_kzt,
        SUM(SUM(amount_kzt)) OVER (
            PARTITION BY type 
            ORDER BY DATE(created_at)
        ) as running_total_by_type,
        SUM(COUNT(*)) OVER (
            PARTITION BY type 
            ORDER BY DATE(created_at)
        ) as running_count_by_type
    FROM transactions
    WHERE status = 'completed'
    GROUP BY DATE(created_at), type
)
SELECT 
    transaction_date,
    type,
    transaction_count,
    total_volume_kzt,
    avg_amount_kzt,
    running_total_by_type,
    running_count_by_type,
    LAG(total_volume_kzt, 1) OVER (
        PARTITION BY type 
        ORDER BY transaction_date
    ) as previous_day_volume,
    ROUND(
        CASE 
            WHEN LAG(total_volume_kzt, 1) OVER (PARTITION BY type ORDER BY transaction_date) > 0
            THEN ((total_volume_kzt - LAG(total_volume_kzt, 1) OVER (PARTITION BY type ORDER BY transaction_date)) 
                  / LAG(total_volume_kzt, 1) OVER (PARTITION BY type ORDER BY transaction_date) * 100)
            ELSE NULL
        END, 2
    ) as day_over_day_growth_percent
FROM daily_stats
ORDER BY transaction_date DESC, type;

-- View 3: suspicious_activity_view (WITH SECURITY BARRIER)
CREATE OR REPLACE VIEW suspicious_activity_view WITH (security_barrier = true) AS
WITH large_transactions AS (
    SELECT 
        t.transaction_id,
        t.amount_kzt,
        t.created_at,
        t.from_account_id,
        t.to_account_id,
        'Large Transaction' as flag_type
    FROM transactions t
    WHERE t.amount_kzt > 5000000
    AND t.status = 'completed'
),
frequent_transactions AS (
    SELECT 
        c.customer_id,
        c.full_name,
        DATE_TRUNC('hour', t.created_at) as hour_window,
        COUNT(*) as transaction_count,
        'High Frequency' as flag_type
    FROM transactions t
    JOIN accounts a ON t.from_account_id = a.account_id
    JOIN customers c ON a.customer_id = c.customer_id
    WHERE t.status = 'completed'
    GROUP BY c.customer_id, c.full_name, DATE_TRUNC('hour', t.created_at)
    HAVING COUNT(*) > 10
),
rapid_transfers AS (
    SELECT 
        t1.transaction_id,
        t1.from_account_id,
        t1.created_at as first_transfer_time,
        t2.created_at as second_transfer_time,
        EXTRACT(EPOCH FROM (t2.created_at - t1.created_at)) as seconds_between,
        'Rapid Sequential Transfer' as flag_type
    FROM transactions t1
    JOIN transactions t2 ON t1.from_account_id = t2.from_account_id
        AND t1.transaction_id < t2.transaction_id
        AND t2.created_at - t1.created_at < INTERVAL '1 minute'
    WHERE t1.status = 'completed' AND t2.status = 'completed'
)
SELECT 
    'Large Transaction' as activity_type,
    jsonb_build_object(
        'transaction_id', lt.transaction_id,
        'amount_kzt', lt.amount_kzt,
        'created_at', lt.created_at
    ) as details
FROM large_transactions lt

UNION ALL

SELECT 
    'High Frequency' as activity_type,
    jsonb_build_object(
        'customer_id', ft.customer_id,
        'customer_name', ft.full_name,
        'hour_window', ft.hour_window,
        'transaction_count', ft.transaction_count
    ) as details
FROM frequent_transactions ft

UNION ALL

SELECT 
    'Rapid Sequential Transfer' as activity_type,
    jsonb_build_object(
        'transaction_id', rt.transaction_id,
        'time_between_seconds', rt.seconds_between,
        'first_transfer', rt.first_transfer_time,
        'second_transfer', rt.second_transfer_time
    ) as details
FROM rapid_transfers rt;

-- ============================================
-- PART 6: TASK 3 - PERFORMANCE OPTIMIZATION WITH INDEXES
-- ============================================

-- 1. B-tree index on frequently queried columns
CREATE INDEX idx_accounts_customer_id ON accounts(customer_id);
CREATE INDEX idx_transactions_created_at ON transactions(created_at DESC);
CREATE INDEX idx_transactions_from_account ON transactions(from_account_id, status, created_at);

-- 2. Hash index for exact matches on phone numbers
CREATE INDEX idx_customers_phone_hash ON customers USING hash(phone);

-- 3. Composite covering index for common query pattern
CREATE INDEX idx_transactions_covering ON transactions
    (from_account_id, status, created_at)
    INCLUDE (amount, currency, amount_kzt);

-- 4. Partial index for active accounts only
CREATE INDEX idx_accounts_active ON accounts(account_number, balance)
    WHERE is_active = TRUE;

-- 5. Expression index for case-insensitive email search
CREATE INDEX idx_customers_email_lower ON customers(LOWER(email));

-- 6. GIN index on audit_log JSONB columns
CREATE INDEX idx_audit_log_jsonb ON audit_log USING gin((old_values || new_values));

-- 7. B-tree index for exchange rates lookup
CREATE INDEX idx_exchange_rates_lookup ON exchange_rates(from_currency, to_currency, valid_to);

-- ============================================
-- PART 7: TASK 4 - ADVANCED PROCEDURE: BATCH PROCESSING
-- ============================================

CREATE OR REPLACE PROCEDURE process_salary_batch(
    p_company_account_number VARCHAR(34),
    p_payments JSONB,
    OUT p_successful_count INTEGER,
    OUT p_failed_count INTEGER,
    OUT p_failed_details JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_company_account_id INTEGER;
    v_company_balance DECIMAL(15,2);
    v_total_batch_amount DECIMAL(15,2) := 0;
    v_payment_record JSONB;
    v_payment_iin VARCHAR(12);
    v_payment_amount DECIMAL(15,2);
    v_payment_description TEXT;
    v_employee_account_id INTEGER;
    v_employee_account_number VARCHAR(34);
    v_successful INTEGER := 0;
    v_failed INTEGER := 0;
    v_failed_json JSONB := '[]'::JSONB;
    v_lock_id BIGINT;
BEGIN
    -- Generate advisory lock ID from account number hash
    v_lock_id := abs(hashtext(p_company_account_number)) % 2147483647;
    
    -- Acquire advisory lock to prevent concurrent processing
    IF NOT pg_try_advisory_lock(v_lock_id) THEN
        RAISE EXCEPTION 'ERR101: Batch processing already in progress for this company';
    END IF;
    
    BEGIN
        -- Get company account details with FOR UPDATE lock
        SELECT account_id, balance INTO v_company_account_id, v_company_balance
        FROM accounts 
        WHERE account_number = p_company_account_number AND is_active = TRUE
        FOR UPDATE;
        
        IF v_company_account_id IS NULL THEN
            RAISE EXCEPTION 'ERR102: Company account not found or inactive';
        END IF;
        
        -- Calculate total batch amount
        FOR v_payment_record IN SELECT * FROM jsonb_array_elements(p_payments)
        LOOP
            v_total_batch_amount := v_total_batch_amount + 
                (v_payment_record->>'amount')::DECIMAL;
        END LOOP;
        
        -- Validate company balance
        IF v_company_balance < v_total_batch_amount THEN
            RAISE EXCEPTION 'ERR103: Insufficient company balance. Required: %, Available: %',
                           v_total_batch_amount, v_company_balance;
        END IF;
        
        -- Start main transaction
        BEGIN
            -- Process each payment
            FOR v_payment_record IN SELECT * FROM jsonb_array_elements(p_payments)
            LOOP
                -- Extract payment details
                v_payment_iin := v_payment_record->>'iin';
                v_payment_amount := (v_payment_record->>'amount')::DECIMAL;
                v_payment_description := v_payment_record->>'description';
                
                -- Set savepoint for each individual payment
                SAVEPOINT individual_payment;
                
                BEGIN
                    -- Find employee account by IIN (assuming IIN is stored in customers.tin)
                    SELECT a.account_id, a.account_number 
                    INTO v_employee_account_id, v_employee_account_number
                    FROM customers c
                    JOIN accounts a ON c.customer_id = a.customer_id
                    WHERE c.tin = v_payment_iin 
                        AND a.is_active = TRUE
                        AND a.currency = 'KZT';
                    
                    IF v_employee_account_id IS NULL THEN
                        RAISE EXCEPTION 'ERR104: Employee account not found for IIN: %', v_payment_iin;
                    END IF;
                    
                    -- Create salary transfer (bypassing daily limits via special handling)
                    INSERT INTO transactions (
                        from_account_id, to_account_id, amount, currency,
                        exchange_rate, amount_kzt, type, status, description
                    ) VALUES (
                        v_company_account_id, v_employee_account_id, v_payment_amount, 'KZT',
                        1.0, v_payment_amount, 'transfer', 'completed', 
                        COALESCE(v_payment_description, 'Salary Payment')
                    );
                    
                    -- Update employee balance (company balance will be updated atomically later)
                    UPDATE accounts 
                    SET balance = balance + v_payment_amount
                    WHERE account_id = v_employee_account_id;
                    
                    v_successful := v_successful + 1;
                    
                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK TO SAVEPOINT individual_payment;
                        v_failed := v_failed + 1;
                        
                        -- Record failure details
                        v_failed_json := v_failed_json || jsonb_build_object(
                            'iin', v_payment_iin,
                            'amount', v_payment_amount,
                            'error', SQLERRM
                        );
                END;
            END LOOP;
            
            -- Update company balance atomically (not one-by-one)
            UPDATE accounts 
            SET balance = balance - v_total_batch_amount
            WHERE account_id = v_company_account_id;
            
            -- Log batch completion
            INSERT INTO audit_log (table_name, record_id, action, old_values, new_values, changed_by)
            VALUES ('batch_processing', v_company_account_id, 'INSERT', NULL,
                    jsonb_build_object(
                        'total_amount', v_total_batch_amount,
                        'successful', v_successful,
                        'failed', v_failed,
                        'failed_details', v_failed_json
                    ), 'process_salary_batch');
            
            -- Set output parameters
            p_successful_count := v_successful;
            p_failed_count := v_failed;
            p_failed_details := v_failed_json;
            
            COMMIT;
            
            RAISE NOTICE 'Batch processing completed. Successful: %, Failed: %', 
                        v_successful, v_failed;
                        
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                RAISE;
        END;
        
    EXCEPTION
        WHEN OTHERS THEN
            -- Release advisory lock
            PERFORM pg_advisory_unlock(v_lock_id);
            RAISE;
    END;
    
    -- Release advisory lock
    PERFORM pg_advisory_unlock(v_lock_id);
END;
$$;

-- Materialized view for salary batch summary
CREATE MATERIALIZED VIEW salary_batch_summary AS
SELECT 
    DATE(b.changed_at) as processing_date,
    b.new_values->>'total_amount' as total_amount,
    (b.new_values->>'successful')::INTEGER as successful_count,
    (b.new_values->>'failed')::INTEGER as failed_count,
    b.new_values->'failed_details' as failed_details,
    b.changed_by as processed_by
FROM audit_log b
WHERE b.table_name = 'batch_processing'
AND b.action = 'INSERT'
ORDER BY b.changed_at DESC;

-- Create index on materialized view
CREATE INDEX idx_salary_batch_date ON salary_batch_summary(processing_date DESC);

-- ============================================
-- PART 8: TEST CASES AND DEMONSTRATION
-- ============================================

-- Test 1: Successful transfer
CALL process_transfer(
    'KZ12345678901234567890', 
    'KZ34567890123456789012', 
    50000.00, 
    'KZT', 
    'Test transfer 1'
);

-- Test 2: Failed transfer - insufficient funds
CALL process_transfer(
    'KZ34567890123456789012', 
    'KZ12345678901234567890', 
    2000000.00, 
    'KZT', 
    'Should fail - insufficient funds'
);

-- Test 3: Failed transfer - inactive account
CALL process_transfer(
    'KZ45678901234567890123',  -- Inactive account
    'KZ12345678901234567890', 
    10000.00, 
    'KZT', 
    'Should fail - inactive account'
);

-- Test 4: Currency conversion transfer
CALL process_transfer(
    'KZ09876543210987654321',  -- USD account
    'KZ12345678901234567890',  -- KZT account
    100.00, 
    'USD', 
    'USD to KZT conversion'
);

-- Test 5: Batch processing test
DO $$
DECLARE
    v_successful INTEGER;
    v_failed INTEGER;
    v_failed_details JSONB;
BEGIN
    CALL process_salary_batch(
        'KZ12345678901234567890',
        '[
            {"iin": "234567890123", "amount": 250000, "description": "January Salary"},
            {"iin": "345678901234", "amount": 300000, "description": "January Salary"},
            {"iin": "999999999999", "amount": 200000, "description": "Invalid IIN"}
        ]'::JSONB,
        v_successful,
        v_failed,
        v_failed_details
    );
    
    RAISE NOTICE 'Batch Results: Successful: %, Failed: %', 
                v_successful, v_failed;
    RAISE NOTICE 'Failed Details: %', v_failed_details;
END $$;

-- ============================================
-- PART 9: EXPLAIN ANALYZE EXAMPLES
-- ============================================

-- Example 1: Show index usage for customer lookup
EXPLAIN ANALYZE
SELECT * FROM customers 
WHERE LOWER(email) = 'aisultan@email.com';

-- Example 2: Show covering index usage
EXPLAIN ANALYZE
SELECT from_account_id, amount, currency
FROM transactions
WHERE from_account_id = 1 
    AND status = 'completed'
    AND created_at >= CURRENT_DATE - INTERVAL '30 days';

-- Example 3: Show partial index usage
EXPLAIN ANALYZE
SELECT account_number, balance
FROM accounts
WHERE is_active = TRUE
AND balance > 1000000;

-- Example 4: Show JSONB index usage
EXPLAIN ANALYZE
SELECT * FROM audit_log
WHERE old_values @> '{"status": "active"}'::JSONB;

-- Example 5: Show composite index usage
EXPLAIN ANALYZE
SELECT * FROM exchange_rates
WHERE from_currency = 'USD' 
    AND to_currency = 'KZT'
    AND valid_to IS NULL;

-- ============================================
-- PART 10: ДОКУМЕНТАЦИЯ И ОТЧЕТЫ
-- ============================================

-- Refresh materialized view for reporting
REFRESH MATERIALIZED VIEW salary_batch_summary;

-- Display sample reports
SELECT * FROM customer_balance_summary LIMIT 5;
SELECT * FROM daily_transaction_report WHERE transaction_date >= CURRENT_DATE - 7;
SELECT * FROM suspicious_activity_view LIMIT 5;
SELECT * FROM salary_batch_summary;
