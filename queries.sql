-- ============================================================
-- PARKING MANAGEMENT SYSTEM — Comprehensive SQL Queries
-- Covers: DDL, DML, DRL, TCL, DCL, Joins, Subqueries,
--         Aggregate Functions, Views, Triggers, Procedures,
--         Cursors, and Window Functions
-- ============================================================

USE parking_management;

-- ************************************************************
-- SECTION 1: BASIC SELECT / DRL QUERIES
-- ************************************************************

-- Q1: List all facilities
SELECT * FROM Facility;

-- Q2: Show all available (unoccupied) parking slots
SELECT s.slot_id, f.name AS facility, s.floor_number, s.slot_number, s.slot_type, s.hourly_rate
FROM Parking_Slot s
JOIN Facility f ON s.facility_id = f.facility_id
WHERE s.is_occupied = FALSE
ORDER BY f.name, s.floor_number;

-- Q3: Get all users with Premium or VIP membership
SELECT user_id, CONCAT(first_name, ' ', last_name) AS full_name, email, membership
FROM User
WHERE membership IN ('Premium', 'VIP');

-- Q4: List all vehicles along with owner details
SELECT v.license_plate, v.vehicle_type, v.brand, v.model, v.color,
       CONCAT(u.first_name, ' ', u.last_name) AS owner
FROM Vehicle v
JOIN User u ON v.user_id = u.user_id;

-- Q5: Show currently parked vehicles (exit_time IS NULL)
SELECT pr.record_id, v.license_plate, v.brand, v.model,
       f.name AS facility, ps.slot_number, pr.entry_time
FROM Parking_Record pr
JOIN Vehicle v ON pr.vehicle_id = v.vehicle_id
JOIN Parking_Slot ps ON pr.slot_id = ps.slot_id
JOIN Facility f ON ps.facility_id = f.facility_id
WHERE pr.exit_time IS NULL;

-- ************************************************************
-- SECTION 2: AGGREGATE FUNCTIONS & GROUP BY
-- ************************************************************

-- Q6: Count of total, occupied, and available slots per facility
SELECT f.name AS facility,
       COUNT(*)                          AS total_slots,
       SUM(s.is_occupied)               AS occupied,
       SUM(NOT s.is_occupied)           AS available
FROM Parking_Slot s
JOIN Facility f ON s.facility_id = f.facility_id
GROUP BY f.facility_id, f.name;

-- Q7: Total revenue per facility
SELECT f.name AS facility, COALESCE(SUM(p.amount), 0) AS total_revenue
FROM Payment p
JOIN Parking_Record pr ON p.record_id = pr.record_id
JOIN Parking_Slot ps   ON pr.slot_id  = ps.slot_id
JOIN Facility f        ON ps.facility_id = f.facility_id
WHERE p.payment_status = 'Completed'
GROUP BY f.facility_id, f.name
ORDER BY total_revenue DESC;

-- Q8: Average parking duration per facility (in hours)
SELECT f.name AS facility,
       ROUND(AVG(pr.duration_hours), 2) AS avg_hours
FROM Parking_Record pr
JOIN Parking_Slot ps ON pr.slot_id = ps.slot_id
JOIN Facility f ON ps.facility_id = f.facility_id
WHERE pr.exit_time IS NOT NULL
GROUP BY f.facility_id, f.name;

-- Q9: Revenue breakdown by payment method
SELECT payment_method,
       COUNT(*)       AS transaction_count,
       SUM(amount)    AS total_amount,
       AVG(amount)    AS avg_amount
FROM Payment
WHERE payment_status = 'Completed'
GROUP BY payment_method
ORDER BY total_amount DESC;

-- Q10: Number of vehicles per user
SELECT CONCAT(u.first_name, ' ', u.last_name) AS owner,
       COUNT(v.vehicle_id) AS vehicle_count
FROM User u
LEFT JOIN Vehicle v ON u.user_id = v.user_id
GROUP BY u.user_id
HAVING vehicle_count > 0
ORDER BY vehicle_count DESC;

-- ************************************************************
-- SECTION 3: JOINS (INNER, LEFT, RIGHT, CROSS, SELF)
-- ************************************************************

-- Q11: INNER JOIN — Users who have made payments
SELECT DISTINCT CONCAT(u.first_name, ' ', u.last_name) AS customer,
       u.email, p.amount, p.payment_method
FROM User u
INNER JOIN Payment p ON u.user_id = p.user_id;

-- Q12: LEFT JOIN — All users and their reservations (including users with no reservations)
SELECT CONCAT(u.first_name, ' ', u.last_name) AS customer,
       r.reservation_id, r.reserved_from, r.status
FROM User u
LEFT JOIN Reservation r ON u.user_id = r.user_id
ORDER BY u.user_id;

-- Q13: RIGHT JOIN — All slots and their parking records
SELECT ps.slot_number, f.name AS facility, pr.record_id, pr.entry_time, pr.exit_time
FROM Parking_Record pr
RIGHT JOIN Parking_Slot ps ON pr.slot_id = ps.slot_id
JOIN Facility f ON ps.facility_id = f.facility_id
ORDER BY f.name, ps.slot_number;

-- Q14: CROSS JOIN — All possible user-facility combinations (for marketing)
SELECT CONCAT(u.first_name, ' ', u.last_name) AS user_name, f.name AS facility
FROM User u
CROSS JOIN Facility f
LIMIT 20;

-- Q15: SELF JOIN — Staff members working at the same facility
SELECT CONCAT(s1.first_name, ' ', s1.last_name) AS staff_1,
       CONCAT(s2.first_name, ' ', s2.last_name) AS staff_2,
       f.name AS facility
FROM Staff s1
JOIN Staff s2 ON s1.facility_id = s2.facility_id AND s1.staff_id < s2.staff_id
JOIN Facility f ON s1.facility_id = f.facility_id;

-- ************************************************************
-- SECTION 4: SUBQUERIES
-- ************************************************************

-- Q16: Users who have spent more than the average payment amount
SELECT CONCAT(u.first_name, ' ', u.last_name) AS big_spender, p.amount
FROM Payment p
JOIN User u ON p.user_id = u.user_id
WHERE p.amount > (SELECT AVG(amount) FROM Payment WHERE payment_status = 'Completed');

-- Q17: Facility with the highest occupancy rate
SELECT f.name,
       ROUND(SUM(s.is_occupied) * 100.0 / COUNT(*), 1) AS occupancy_pct
FROM Parking_Slot s
JOIN Facility f ON s.facility_id = f.facility_id
GROUP BY f.facility_id, f.name
HAVING occupancy_pct = (
    SELECT MAX(occ) FROM (
        SELECT ROUND(SUM(is_occupied) * 100.0 / COUNT(*), 1) AS occ
        FROM Parking_Slot
        GROUP BY facility_id
    ) AS sub
);

-- Q18: Slots that have never been used
SELECT ps.slot_id, f.name AS facility, ps.slot_number
FROM Parking_Slot ps
JOIN Facility f ON ps.facility_id = f.facility_id
WHERE ps.slot_id NOT IN (SELECT DISTINCT slot_id FROM Parking_Record);

-- Q19: Correlated subquery — Users whose total spend exceeds 500
SELECT CONCAT(u.first_name, ' ', u.last_name) AS customer,
       (SELECT SUM(p.amount) FROM Payment p WHERE p.user_id = u.user_id AND p.payment_status = 'Completed') AS total_spent
FROM User u
HAVING total_spent > 500;

-- ************************************************************
-- SECTION 5: SET OPERATIONS
-- ************************************************************

-- Q20: UNION — Users who either have a reservation OR a payment
SELECT user_id, 'Reservation' AS activity FROM Reservation
UNION
SELECT user_id, 'Payment' AS activity FROM Payment;

-- Q21: Users with both reservations and payments (simulated INTERSECT)
SELECT CONCAT(u.first_name, ' ', u.last_name) AS customer
FROM User u
WHERE u.user_id IN (SELECT user_id FROM Reservation)
  AND u.user_id IN (SELECT user_id FROM Payment);

-- ************************************************************
-- SECTION 6: DML — INSERT, UPDATE, DELETE
-- ************************************************************

-- Q22: INSERT a new user
INSERT INTO User (first_name, last_name, email, phone, license_no, membership)
VALUES ('Kiran', 'Maruri', 'kiran.maruri@email.com', '9999999999', 'TS-10-2026-0001', 'Premium');

-- Q23: UPDATE — Mark a parking slot as occupied
UPDATE Parking_Slot
SET is_occupied = TRUE
WHERE slot_id = 3;

-- Q24: UPDATE — Change user membership
UPDATE User
SET membership = 'VIP'
WHERE email = 'amit.patel@email.com';

-- Q25: DELETE — Remove cancelled reservations older than today
DELETE FROM Reservation
WHERE status = 'Cancelled' AND reserved_until < NOW();

-- ************************************************************
-- SECTION 7: VIEWS
-- ************************************************************

-- Q26: View — Facility Occupancy Dashboard
CREATE OR REPLACE VIEW vw_facility_occupancy AS
SELECT f.facility_id, f.name AS facility, f.city,
       COUNT(s.slot_id) AS total_slots,
       SUM(s.is_occupied) AS occupied_slots,
       COUNT(s.slot_id) - SUM(s.is_occupied) AS available_slots,
       ROUND(SUM(s.is_occupied) * 100.0 / COUNT(s.slot_id), 1) AS occupancy_pct
FROM Facility f
JOIN Parking_Slot s ON f.facility_id = s.facility_id
GROUP BY f.facility_id, f.name, f.city;

SELECT * FROM vw_facility_occupancy;

-- Q27: View — Revenue Summary
CREATE OR REPLACE VIEW vw_revenue_summary AS
SELECT f.name AS facility,
       COUNT(p.payment_id) AS total_transactions,
       SUM(p.amount) AS total_revenue,
       ROUND(AVG(p.amount), 2) AS avg_transaction
FROM Payment p
JOIN Parking_Record pr ON p.record_id = pr.record_id
JOIN Parking_Slot ps ON pr.slot_id = ps.slot_id
JOIN Facility f ON ps.facility_id = f.facility_id
WHERE p.payment_status = 'Completed'
GROUP BY f.facility_id, f.name;

SELECT * FROM vw_revenue_summary;

-- Q28: View — Active Parking Sessions
CREATE OR REPLACE VIEW vw_active_sessions AS
SELECT pr.record_id, v.license_plate, v.brand, v.model,
       CONCAT(u.first_name, ' ', u.last_name) AS owner,
       f.name AS facility, ps.slot_number, ps.slot_type,
       pr.entry_time,
       ROUND(TIMESTAMPDIFF(MINUTE, pr.entry_time, NOW()) / 60.0, 2) AS hours_parked,
       ROUND(TIMESTAMPDIFF(MINUTE, pr.entry_time, NOW()) / 60.0 * ps.hourly_rate, 2) AS estimated_bill
FROM Parking_Record pr
JOIN Vehicle v ON pr.vehicle_id = v.vehicle_id
JOIN User u ON v.user_id = u.user_id
JOIN Parking_Slot ps ON pr.slot_id = ps.slot_id
JOIN Facility f ON ps.facility_id = f.facility_id
WHERE pr.exit_time IS NULL;

SELECT * FROM vw_active_sessions;

-- ************************************************************
-- SECTION 8: STORED PROCEDURES
-- ************************************************************

-- Q29: Procedure — Park a vehicle
DELIMITER //
CREATE PROCEDURE sp_park_vehicle(
    IN p_vehicle_id INT,
    IN p_slot_id INT
)
BEGIN
    DECLARE v_occupied BOOLEAN;

    SELECT is_occupied INTO v_occupied
    FROM Parking_Slot WHERE slot_id = p_slot_id;

    IF v_occupied = TRUE THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Slot is already occupied';
    ELSE
        INSERT INTO Parking_Record (vehicle_id, slot_id, entry_time)
        VALUES (p_vehicle_id, p_slot_id, NOW());

        UPDATE Parking_Slot SET is_occupied = TRUE WHERE slot_id = p_slot_id;

        SELECT 'Vehicle parked successfully' AS message;
    END IF;
END //
DELIMITER ;

-- Q30: Procedure — Exit vehicle and generate bill
DELIMITER //
CREATE PROCEDURE sp_exit_vehicle(
    IN p_record_id INT,
    IN p_payment_method VARCHAR(20)
)
BEGIN
    DECLARE v_slot_id INT;
    DECLARE v_user_id INT;
    DECLARE v_rate DECIMAL(6,2);
    DECLARE v_hours DECIMAL(5,2);
    DECLARE v_amount DECIMAL(8,2);

    UPDATE Parking_Record SET exit_time = NOW() WHERE record_id = p_record_id;

    SELECT pr.slot_id, v.user_id, ps.hourly_rate,
           ROUND(TIMESTAMPDIFF(MINUTE, pr.entry_time, NOW()) / 60.0, 2)
    INTO v_slot_id, v_user_id, v_rate, v_hours
    FROM Parking_Record pr
    JOIN Vehicle v ON pr.vehicle_id = v.vehicle_id
    JOIN Parking_Slot ps ON pr.slot_id = ps.slot_id
    WHERE pr.record_id = p_record_id;

    SET v_amount = ROUND(v_hours * v_rate, 2);
    IF v_amount < v_rate THEN SET v_amount = v_rate; END IF;

    INSERT INTO Payment (record_id, user_id, amount, payment_method, payment_status)
    VALUES (p_record_id, v_user_id, v_amount, p_payment_method, 'Completed');

    UPDATE Parking_Slot SET is_occupied = FALSE WHERE slot_id = v_slot_id;

    SELECT v_amount AS bill_amount, v_hours AS total_hours, p_payment_method AS method;
END //
DELIMITER ;

-- Q31: Procedure — Get facility report
DELIMITER //
CREATE PROCEDURE sp_facility_report(IN p_facility_id INT)
BEGIN
    SELECT f.name, f.address, f.city, f.total_floors,
           COUNT(s.slot_id) AS total_slots,
           SUM(s.is_occupied) AS occupied,
           (SELECT COUNT(*) FROM Staff st WHERE st.facility_id = f.facility_id) AS staff_count,
           (SELECT COALESCE(SUM(p.amount), 0) FROM Payment p
            JOIN Parking_Record pr ON p.record_id = pr.record_id
            JOIN Parking_Slot ps ON pr.slot_id = ps.slot_id
            WHERE ps.facility_id = f.facility_id AND p.payment_status = 'Completed') AS total_revenue
    FROM Facility f
    JOIN Parking_Slot s ON f.facility_id = s.facility_id
    WHERE f.facility_id = p_facility_id
    GROUP BY f.facility_id;
END //
DELIMITER ;

-- ************************************************************
-- SECTION 9: TRIGGERS
-- ************************************************************

-- Q32: Trigger — Auto-update is_occupied when a parking record is inserted
DELIMITER //
CREATE TRIGGER trg_after_park
AFTER INSERT ON Parking_Record
FOR EACH ROW
BEGIN
    UPDATE Parking_Slot SET is_occupied = TRUE WHERE slot_id = NEW.slot_id;
END //
DELIMITER ;

-- Q33: Trigger — Auto-free slot when exit_time is updated
DELIMITER //
CREATE TRIGGER trg_after_exit
AFTER UPDATE ON Parking_Record
FOR EACH ROW
BEGIN
    IF OLD.exit_time IS NULL AND NEW.exit_time IS NOT NULL THEN
        UPDATE Parking_Slot SET is_occupied = FALSE WHERE slot_id = NEW.slot_id;
    END IF;
END //
DELIMITER ;

-- Q34: Trigger — Prevent deleting a user who has active parking
DELIMITER //
CREATE TRIGGER trg_before_user_delete
BEFORE DELETE ON User
FOR EACH ROW
BEGIN
    DECLARE v_active INT;
    SELECT COUNT(*) INTO v_active
    FROM Parking_Record pr
    JOIN Vehicle v ON pr.vehicle_id = v.vehicle_id
    WHERE v.user_id = OLD.user_id AND pr.exit_time IS NULL;

    IF v_active > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete user with active parking sessions';
    END IF;
END //
DELIMITER ;

-- ************************************************************
-- SECTION 10: WINDOW FUNCTIONS
-- ************************************************************

-- Q35: Rank facilities by revenue
SELECT f.name AS facility,
       SUM(p.amount) AS revenue,
       RANK() OVER (ORDER BY SUM(p.amount) DESC) AS revenue_rank
FROM Payment p
JOIN Parking_Record pr ON p.record_id = pr.record_id
JOIN Parking_Slot ps ON pr.slot_id = ps.slot_id
JOIN Facility f ON ps.facility_id = f.facility_id
WHERE p.payment_status = 'Completed'
GROUP BY f.facility_id, f.name;

-- Q36: Running total of payments over time
SELECT payment_id, paid_at, amount,
       SUM(amount) OVER (ORDER BY paid_at) AS running_total
FROM Payment
WHERE payment_status = 'Completed';

-- Q37: Rank users by total spending
SELECT CONCAT(u.first_name, ' ', u.last_name) AS customer,
       SUM(p.amount) AS total_spent,
       DENSE_RANK() OVER (ORDER BY SUM(p.amount) DESC) AS spend_rank
FROM Payment p
JOIN User u ON p.user_id = u.user_id
WHERE p.payment_status = 'Completed'
GROUP BY u.user_id;

-- ************************************************************
-- SECTION 11: TCL — Transaction Control
-- ************************************************************

-- Q38: Transaction — Atomic slot transfer (move vehicle from one slot to another)
START TRANSACTION;

    UPDATE Parking_Slot SET is_occupied = FALSE WHERE slot_id = 2;
    UPDATE Parking_Slot SET is_occupied = TRUE  WHERE slot_id = 3;
    UPDATE Parking_Record SET slot_id = 3 WHERE record_id = 1;

COMMIT;

-- Q39: Transaction with SAVEPOINT
START TRANSACTION;

    SAVEPOINT before_update;

    UPDATE User SET membership = 'VIP' WHERE user_id = 7;

    -- Rollback to savepoint if needed
    -- ROLLBACK TO before_update;

COMMIT;

-- ************************************************************
-- SECTION 12: DCL — Data Control Language
-- ************************************************************

-- Q40: GRANT and REVOKE examples (run as root)
-- CREATE USER 'parking_admin'@'localhost' IDENTIFIED BY 'admin123';
-- GRANT ALL PRIVILEGES ON parking_management.* TO 'parking_admin'@'localhost';

-- CREATE USER 'parking_viewer'@'localhost' IDENTIFIED BY 'viewer123';
-- GRANT SELECT ON parking_management.* TO 'parking_viewer'@'localhost';

-- REVOKE INSERT, UPDATE, DELETE ON parking_management.* FROM 'parking_viewer'@'localhost';

-- FLUSH PRIVILEGES;

-- ************************************************************
-- SECTION 13: ADVANCED QUERIES
-- ************************************************************

-- Q41: Find peak parking hours
SELECT HOUR(entry_time) AS hour_of_day,
       COUNT(*) AS entries
FROM Parking_Record
GROUP BY HOUR(entry_time)
ORDER BY entries DESC;

-- Q42: Monthly revenue trend
SELECT DATE_FORMAT(p.paid_at, '%Y-%m') AS month,
       COUNT(*) AS transactions,
       SUM(p.amount) AS revenue
FROM Payment p
WHERE p.payment_status = 'Completed'
GROUP BY DATE_FORMAT(p.paid_at, '%Y-%m')
ORDER BY month;

-- Q43: Slot utilization — times each slot has been used
SELECT ps.slot_id, f.name AS facility, ps.slot_number, ps.slot_type,
       COUNT(pr.record_id) AS times_used
FROM Parking_Slot ps
LEFT JOIN Parking_Record pr ON ps.slot_id = pr.slot_id
JOIN Facility f ON ps.facility_id = f.facility_id
GROUP BY ps.slot_id, f.name, ps.slot_number, ps.slot_type
ORDER BY times_used DESC;

-- Q44: Staff salary report per facility
SELECT f.name AS facility,
       COUNT(s.staff_id) AS staff_count,
       SUM(s.salary) AS total_salary_expense,
       ROUND(AVG(s.salary), 2) AS avg_salary,
       MAX(s.salary) AS highest_salary,
       MIN(s.salary) AS lowest_salary
FROM Staff s
JOIN Facility f ON s.facility_id = f.facility_id
GROUP BY f.facility_id, f.name;

-- Q45: EV slot availability across all facilities
SELECT f.name AS facility,
       COUNT(CASE WHEN s.slot_type = 'EV' THEN 1 END) AS total_ev_slots,
       COUNT(CASE WHEN s.slot_type = 'EV' AND s.is_occupied = FALSE THEN 1 END) AS available_ev_slots
FROM Facility f
JOIN Parking_Slot s ON f.facility_id = s.facility_id
GROUP BY f.facility_id, f.name;

-- Q46: Users with multiple vehicles
SELECT CONCAT(u.first_name, ' ', u.last_name) AS owner, COUNT(*) AS vehicle_count,
       GROUP_CONCAT(v.license_plate SEPARATOR ', ') AS plates
FROM User u
JOIN Vehicle v ON u.user_id = v.user_id
GROUP BY u.user_id
HAVING vehicle_count > 1;

-- Q47: Longest parking session ever
SELECT pr.record_id, v.license_plate, f.name AS facility,
       pr.entry_time, pr.exit_time, pr.duration_hours
FROM Parking_Record pr
JOIN Vehicle v ON pr.vehicle_id = v.vehicle_id
JOIN Parking_Slot ps ON pr.slot_id = ps.slot_id
JOIN Facility f ON ps.facility_id = f.facility_id
WHERE pr.exit_time IS NOT NULL
ORDER BY pr.duration_hours DESC
LIMIT 1;

-- Q48: Revenue per slot type
SELECT ps.slot_type,
       COUNT(p.payment_id) AS bookings,
       SUM(p.amount) AS revenue
FROM Payment p
JOIN Parking_Record pr ON p.record_id = pr.record_id
JOIN Parking_Slot ps ON pr.slot_id = ps.slot_id
WHERE p.payment_status = 'Completed'
GROUP BY ps.slot_type
ORDER BY revenue DESC;

-- Q49: CASE-based membership discount simulation
SELECT CONCAT(u.first_name, ' ', u.last_name) AS customer,
       u.membership,
       p.amount AS original_amount,
       CASE u.membership
           WHEN 'VIP'     THEN ROUND(p.amount * 0.80, 2)
           WHEN 'Premium' THEN ROUND(p.amount * 0.90, 2)
           ELSE p.amount
       END AS discounted_amount
FROM Payment p
JOIN User u ON p.user_id = u.user_id
WHERE p.payment_status = 'Completed';

-- Q50: EXISTS — Facilities that have at least one EV slot
SELECT f.name
FROM Facility f
WHERE EXISTS (
    SELECT 1 FROM Parking_Slot ps
    WHERE ps.facility_id = f.facility_id AND ps.slot_type = 'EV'
);
