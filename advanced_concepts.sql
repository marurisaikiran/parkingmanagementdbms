-- ============================================================
-- PARKING MANAGEMENT SYSTEM — Advanced Concepts
-- Covers: ACID Demonstration, Cursors, ALTER TABLE,
--         Functions, Error Handling, Isolation Levels
-- ============================================================

USE parking_management;

-- ************************************************************
-- SECTION 1: ACID PROPERTIES — Demonstrated with Queries
-- ************************************************************

-- -------------------------------------------------------
-- ATOMICITY: All-or-nothing
-- If any step fails, the ENTIRE transaction rolls back
-- -------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_atomic_demo()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Transaction ROLLED BACK — Atomicity preserved' AS result;
    END;

    START TRANSACTION;
        -- Step 1: Free slot 2
        UPDATE Parking_Slot SET is_occupied = FALSE WHERE slot_id = 2;

        -- Step 2: Occupy slot 3
        UPDATE Parking_Slot SET is_occupied = TRUE WHERE slot_id = 3;

        -- Step 3: Move vehicle record to new slot
        UPDATE Parking_Record SET slot_id = 3
        WHERE record_id = 1 AND exit_time IS NOT NULL;

        -- If ALL succeed → commit
    COMMIT;
    SELECT 'Transaction COMMITTED — All steps succeeded' AS result;
END //
DELIMITER ;

-- CALL sp_atomic_demo();

-- -------------------------------------------------------
-- CONSISTENCY: Database always moves from one valid state
-- to another. Constraints prevent invalid data.
-- -------------------------------------------------------

-- Trying to insert a vehicle with non-existent user → FK violation
-- INSERT INTO Vehicle (user_id, license_plate, vehicle_type)
-- VALUES (999, 'XX-00-YY-0000', 'Sedan');
-- ERROR: Cannot add or update a child row: a foreign key constraint fails

-- Trying to insert duplicate email → UNIQUE violation
-- INSERT INTO User (first_name, last_name, email)
-- VALUES ('Test', 'User', 'rahul.sharma@email.com');
-- ERROR: Duplicate entry 'rahul.sharma@email.com' for key 'email'

-- -------------------------------------------------------
-- ISOLATION: Concurrent transactions don't interfere
-- -------------------------------------------------------

-- Check current isolation level
SELECT @@transaction_isolation AS current_isolation_level;

-- Set isolation level for the session
-- SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;  -- MySQL default
-- SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- Isolation Demo: Two users booking the same slot
-- Session 1:
--   START TRANSACTION;
--   SELECT is_occupied FROM Parking_Slot WHERE slot_id = 14 FOR UPDATE;
--   -- This locks the row; Session 2 must wait
--   UPDATE Parking_Slot SET is_occupied = TRUE WHERE slot_id = 14;
--   COMMIT;

-- Session 2 (runs concurrently):
--   START TRANSACTION;
--   SELECT is_occupied FROM Parking_Slot WHERE slot_id = 14 FOR UPDATE;
--   -- WAITS until Session 1 commits or rolls back
--   -- After Session 1 commits, Session 2 sees is_occupied = TRUE
--   ROLLBACK;  -- Slot already taken

-- -------------------------------------------------------
-- DURABILITY: Once committed, data survives system crash
-- InnoDB uses Write-Ahead Logging (WAL / redo log)
-- -------------------------------------------------------

-- After this COMMIT, even if MySQL crashes, the payment is saved
START TRANSACTION;
    -- Simulating a durable payment
    SELECT 'After COMMIT, this data is written to disk (redo log)' AS durability_note;
    SELECT 'Even a power failure cannot lose committed data' AS explanation;
COMMIT;


-- ************************************************************
-- SECTION 2: CURSORS — Row-by-row processing
-- ************************************************************

-- Cursor to calculate total pending charges for all active sessions
DELIMITER //
CREATE PROCEDURE sp_pending_charges_cursor()
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_record_id INT;
    DECLARE v_plate VARCHAR(20);
    DECLARE v_facility VARCHAR(100);
    DECLARE v_hours DECIMAL(10,2);
    DECLARE v_rate DECIMAL(6,2);
    DECLARE v_charge DECIMAL(8,2);
    DECLARE v_total DECIMAL(10,2) DEFAULT 0;

    DECLARE cur_active CURSOR FOR
        SELECT pr.record_id, v.license_plate, f.name,
               ROUND(TIMESTAMPDIFF(MINUTE, pr.entry_time, NOW()) / 60.0, 2),
               ps.hourly_rate
        FROM Parking_Record pr
        JOIN Vehicle v ON pr.vehicle_id = v.vehicle_id
        JOIN Parking_Slot ps ON pr.slot_id = ps.slot_id
        JOIN Facility f ON ps.facility_id = f.facility_id
        WHERE pr.exit_time IS NULL;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    -- Temporary table to store results
    DROP TEMPORARY TABLE IF EXISTS temp_pending;
    CREATE TEMPORARY TABLE temp_pending (
        record_id INT,
        license_plate VARCHAR(20),
        facility VARCHAR(100),
        hours_parked DECIMAL(10,2),
        hourly_rate DECIMAL(6,2),
        pending_charge DECIMAL(8,2)
    );

    OPEN cur_active;

    read_loop: LOOP
        FETCH cur_active INTO v_record_id, v_plate, v_facility, v_hours, v_rate;
        IF v_done THEN
            LEAVE read_loop;
        END IF;

        SET v_charge = ROUND(v_hours * v_rate, 2);
        IF v_charge < v_rate THEN
            SET v_charge = v_rate;
        END IF;

        INSERT INTO temp_pending VALUES
            (v_record_id, v_plate, v_facility, v_hours, v_rate, v_charge);

        SET v_total = v_total + v_charge;
    END LOOP;

    CLOSE cur_active;

    -- Display individual charges
    SELECT * FROM temp_pending;

    -- Display total
    SELECT v_total AS total_pending_revenue;

    DROP TEMPORARY TABLE IF EXISTS temp_pending;
END //
DELIMITER ;

-- CALL sp_pending_charges_cursor();


-- ************************************************************
-- SECTION 3: USER-DEFINED FUNCTIONS
-- ************************************************************

-- Function to calculate parking fee
DELIMITER //
CREATE FUNCTION fn_calculate_fee(
    p_entry_time DATETIME,
    p_exit_time DATETIME,
    p_hourly_rate DECIMAL(6,2),
    p_membership ENUM('Basic', 'Premium', 'VIP')
)
RETURNS DECIMAL(8,2)
DETERMINISTIC
BEGIN
    DECLARE v_hours DECIMAL(5,2);
    DECLARE v_amount DECIMAL(8,2);

    SET v_hours = TIMESTAMPDIFF(MINUTE, p_entry_time, p_exit_time) / 60.0;
    IF v_hours < 1 THEN SET v_hours = 1; END IF;

    SET v_amount = ROUND(v_hours * p_hourly_rate, 2);

    -- Apply membership discount
    CASE p_membership
        WHEN 'VIP'     THEN SET v_amount = ROUND(v_amount * 0.80, 2);
        WHEN 'Premium' THEN SET v_amount = ROUND(v_amount * 0.90, 2);
        ELSE SET v_amount = v_amount;
    END CASE;

    RETURN v_amount;
END //
DELIMITER ;

-- Usage:
SELECT fn_calculate_fee('2026-06-10 09:00:00', '2026-06-10 17:00:00', 30.00, 'VIP')
    AS vip_fee;
-- 8 hours × 30 = 240, VIP 20% off = 192.00

SELECT fn_calculate_fee('2026-06-10 09:00:00', '2026-06-10 17:00:00', 30.00, 'Basic')
    AS basic_fee;
-- 8 hours × 30 = 240, no discount = 240.00

-- Function to get slot availability status as text
DELIMITER //
CREATE FUNCTION fn_slot_status(p_slot_id INT)
RETURNS VARCHAR(50)
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE v_occupied BOOLEAN;
    DECLARE v_type VARCHAR(20);

    SELECT is_occupied, slot_type INTO v_occupied, v_type
    FROM Parking_Slot WHERE slot_id = p_slot_id;

    IF v_occupied THEN
        RETURN CONCAT(v_type, ' - OCCUPIED');
    ELSE
        RETURN CONCAT(v_type, ' - AVAILABLE');
    END IF;
END //
DELIMITER ;

-- Usage:
SELECT slot_id, slot_number, fn_slot_status(slot_id) AS status
FROM Parking_Slot WHERE facility_id = 1;


-- ************************************************************
-- SECTION 4: ALTER TABLE — Schema Modifications (DDL)
-- ************************************************************

-- Add a new column
ALTER TABLE Facility ADD COLUMN contact_phone VARCHAR(15);

-- Modify column data type
ALTER TABLE Facility MODIFY COLUMN contact_phone VARCHAR(20);

-- Add a CHECK constraint (MySQL 8.0.16+)
ALTER TABLE Parking_Slot ADD CONSTRAINT chk_rate CHECK (hourly_rate >= 0);

-- Add a new column with default
ALTER TABLE User ADD COLUMN is_active BOOLEAN DEFAULT TRUE;

-- Rename a column
ALTER TABLE Staff CHANGE COLUMN phone contact_number VARCHAR(15);

-- Drop a column
ALTER TABLE Facility DROP COLUMN contact_phone;
ALTER TABLE User DROP COLUMN is_active;
ALTER TABLE Staff CHANGE COLUMN contact_number phone VARCHAR(15);


-- ************************************************************
-- SECTION 5: TRANSACTION ERROR HANDLING
-- ************************************************************

-- Procedure with proper error handling and rollback
DELIMITER //
CREATE PROCEDURE sp_safe_transfer_slot(
    IN p_record_id INT,
    IN p_new_slot_id INT
)
BEGIN
    DECLARE v_old_slot INT;
    DECLARE v_new_occupied BOOLEAN;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'ERROR: Slot transfer failed. Transaction rolled back.' AS result;
    END;

    START TRANSACTION;

        -- Get current slot
        SELECT slot_id INTO v_old_slot
        FROM Parking_Record
        WHERE record_id = p_record_id AND exit_time IS NULL;

        IF v_old_slot IS NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No active parking record found';
        END IF;

        -- Check if new slot is free
        SELECT is_occupied INTO v_new_occupied
        FROM Parking_Slot WHERE slot_id = p_new_slot_id;

        IF v_new_occupied = TRUE THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Target slot is already occupied';
        END IF;

        -- Perform transfer
        UPDATE Parking_Slot SET is_occupied = FALSE WHERE slot_id = v_old_slot;
        UPDATE Parking_Slot SET is_occupied = TRUE  WHERE slot_id = p_new_slot_id;
        UPDATE Parking_Record SET slot_id = p_new_slot_id WHERE record_id = p_record_id;

    COMMIT;
    SELECT CONCAT('SUCCESS: Vehicle moved from slot ', v_old_slot,
                  ' to slot ', p_new_slot_id) AS result;
END //
DELIMITER ;

-- CALL sp_safe_transfer_slot(6, 14);


-- ************************************************************
-- SECTION 6: LOCKING — FOR UPDATE & LOCK IN SHARE MODE
-- ************************************************************

-- Pessimistic locking: Lock a slot row before booking
-- (prevents double-booking in concurrent environments)

-- SELECT ... FOR UPDATE (exclusive lock)
-- START TRANSACTION;
-- SELECT * FROM Parking_Slot WHERE slot_id = 14 FOR UPDATE;
-- -- Other transactions trying to read/write this row will WAIT
-- UPDATE Parking_Slot SET is_occupied = TRUE WHERE slot_id = 14;
-- COMMIT;

-- SELECT ... LOCK IN SHARE MODE (shared lock — read-only)
-- START TRANSACTION;
-- SELECT * FROM Parking_Slot WHERE facility_id = 1 LOCK IN SHARE MODE;
-- -- Others can read but NOT write to these rows
-- COMMIT;


-- ************************************************************
-- SECTION 7: ADDITIONAL USEFUL QUERIES
-- ************************************************************

-- Conditional aggregation with IF()
SELECT f.name AS facility,
       COUNT(IF(s.slot_type = 'Regular', 1, NULL))     AS regular,
       COUNT(IF(s.slot_type = 'Compact', 1, NULL))     AS compact,
       COUNT(IF(s.slot_type = 'Large', 1, NULL))        AS large,
       COUNT(IF(s.slot_type = 'Handicapped', 1, NULL)) AS handicapped,
       COUNT(IF(s.slot_type = 'EV', 1, NULL))           AS ev
FROM Parking_Slot s
JOIN Facility f ON s.facility_id = f.facility_id
GROUP BY f.facility_id, f.name;

-- COALESCE and IFNULL
SELECT pr.record_id,
       pr.entry_time,
       COALESCE(pr.exit_time, 'Still Parked') AS exit_status,
       IFNULL(pr.duration_hours, 0) AS hours
FROM Parking_Record pr;

-- Date functions
SELECT record_id,
       entry_time,
       DAYNAME(entry_time)  AS day_of_week,
       MONTHNAME(entry_time) AS month_name,
       DATEDIFF(COALESCE(exit_time, NOW()), entry_time) AS days_parked
FROM Parking_Record;

-- String functions
SELECT user_id,
       UPPER(CONCAT(first_name, ' ', last_name)) AS full_name_upper,
       LENGTH(email) AS email_length,
       SUBSTRING(email, 1, LOCATE('@', email) - 1) AS email_username,
       REVERSE(first_name) AS name_reversed
FROM User;

-- BETWEEN and LIKE
SELECT * FROM Payment
WHERE amount BETWEEN 100 AND 500
  AND payment_method LIKE '%Card%';

-- ANY and ALL
SELECT first_name, last_name FROM User
WHERE user_id = ANY (
    SELECT user_id FROM Payment WHERE amount > 300
);

SELECT first_name, last_name FROM User
WHERE user_id IN (
    SELECT user_id FROM Payment
    GROUP BY user_id
    HAVING SUM(amount) > ALL (
        SELECT SUM(amount) FROM Payment
        GROUP BY user_id
        HAVING COUNT(*) = 1
    )
);
