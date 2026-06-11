-- ============================================================
-- PARKING MANAGEMENT SYSTEM
-- ER Diagram Description & Normalization to BCNF
-- ============================================================

-- ============================================================
-- ER DIAGRAM — ENTITIES, ATTRIBUTES & RELATIONSHIPS
-- ============================================================
/*
ENTITIES:
---------
1. Facility       (facility_id PK, name, address, city, state, zip_code, total_floors)
2. Parking_Slot   (slot_id PK, facility_id FK, floor_number, slot_number, slot_type, is_occupied, hourly_rate)
3. User           (user_id PK, first_name, last_name, email, phone, license_no, membership)
4. Vehicle        (vehicle_id PK, user_id FK, license_plate, vehicle_type, brand, model, color)
5. Reservation    (reservation_id PK, user_id FK, slot_id FK, vehicle_id FK, reserved_from, reserved_until, status)
6. Parking_Record (record_id PK, vehicle_id FK, slot_id FK, entry_time, exit_time, duration_hours)
7. Payment        (payment_id PK, record_id FK, user_id FK, amount, payment_method, payment_status, paid_at)
8. Staff          (staff_id PK, facility_id FK, first_name, last_name, role, phone, salary, hire_date)

RELATIONSHIPS:
--------------
  Facility  ---< 1:M >---  Parking_Slot    (A facility HAS MANY slots)
  Facility  ---< 1:M >---  Staff           (A facility EMPLOYS MANY staff)
  User      ---< 1:M >---  Vehicle         (A user OWNS MANY vehicles)
  User      ---< 1:M >---  Reservation     (A user MAKES MANY reservations)
  User      ---< 1:M >---  Payment         (A user MAKES MANY payments)
  Vehicle   ---< 1:M >---  Parking_Record  (A vehicle HAS MANY parking records)
  Parking_Slot --< 1:M >-- Parking_Record  (A slot HAS MANY records over time)
  Parking_Slot --< 1:M >-- Reservation     (A slot HAS MANY reservations)
  Vehicle   ---< 1:M >---  Reservation     (A vehicle HAS MANY reservations)
  Parking_Record -< 1:1 >- Payment         (Each record HAS ONE payment)

CARDINALITY SUMMARY:
  Facility    1 ---- M  Parking_Slot
  Facility    1 ---- M  Staff
  User        1 ---- M  Vehicle
  User        1 ---- M  Reservation
  User        1 ---- M  Payment
  Vehicle     1 ---- M  Parking_Record
  Vehicle     1 ---- M  Reservation
  Parking_Slot 1 --- M  Parking_Record
  Parking_Slot 1 --- M  Reservation
  Parking_Record 1 - 1  Payment
*/

-- ============================================================
-- NORMALIZATION — Step-by-step to BCNF
-- ============================================================
/*

--------------------------------------------------------------
STEP 1: FIRST NORMAL FORM (1NF)
--------------------------------------------------------------
Requirements:
  - All attributes must be atomic (no multi-valued or composite attributes)
  - Each row must be uniquely identifiable (primary key exists)
  - No repeating groups

Our schema satisfies 1NF:
  ✓ All columns store single atomic values
  ✓ Every table has a primary key (AUTO_INCREMENT INT)
  ✓ No arrays, lists, or repeating groups
  ✓ Names split into first_name / last_name (atomic)

--------------------------------------------------------------
STEP 2: SECOND NORMAL FORM (2NF)
--------------------------------------------------------------
Requirements:
  - Must be in 1NF
  - No partial dependency (non-key attribute depends on part of a composite key)

Our schema satisfies 2NF:
  ✓ All primary keys are single-column (AUTO_INCREMENT)
  ✓ Since no composite primary keys exist, partial dependency is impossible
  ✓ Every non-key attribute depends on the FULL primary key

--------------------------------------------------------------
STEP 3: THIRD NORMAL FORM (3NF)
--------------------------------------------------------------
Requirements:
  - Must be in 2NF
  - No transitive dependency (non-key → non-key)

Potential violation check:

  Facility table:
    city → state?  Not always (multiple states can have same city name)
    ✓ No transitive dependency

  User table:
    email → (first_name, last_name)?  email is a candidate key, not a non-key
    ✓ No transitive dependency

  Parking_Slot table:
    slot_type → hourly_rate?  Different facilities may have different rates for same type
    ✓ No transitive dependency (rate depends on slot_id, not slot_type alone)

  Payment table:
    record_id → user_id?  This could be derived from record→vehicle→user
    However, storing user_id directly avoids expensive joins and is an accepted
    denormalization for performance. If strict 3NF is required, remove user_id
    from Payment and derive it via joins.

  ✓ Schema is in 3NF (with one minor accepted denormalization in Payment)

--------------------------------------------------------------
STEP 4: BOYCE-CODD NORMAL FORM (BCNF)
--------------------------------------------------------------
Requirements:
  - Must be in 3NF
  - For every functional dependency X → Y, X must be a superkey

Functional Dependencies per table:

  Facility:
    facility_id → name, address, city, state, zip_code, total_floors
    ✓ facility_id is a superkey

  Parking_Slot:
    slot_id → facility_id, floor_number, slot_number, slot_type, is_occupied, hourly_rate
    (facility_id, floor_number, slot_number) → slot_id  [candidate key via UNIQUE constraint]
    ✓ Both determinants are superkeys

  User:
    user_id → first_name, last_name, email, phone, license_no, membership
    email → user_id  [candidate key via UNIQUE constraint]
    license_no → user_id  [candidate key via UNIQUE constraint]
    ✓ All determinants are superkeys

  Vehicle:
    vehicle_id → user_id, license_plate, vehicle_type, brand, model, color
    license_plate → vehicle_id  [candidate key]
    ✓ All determinants are superkeys

  Reservation:
    reservation_id → user_id, slot_id, vehicle_id, reserved_from, reserved_until, status
    ✓ reservation_id is a superkey

  Parking_Record:
    record_id → vehicle_id, slot_id, entry_time, exit_time, duration_hours
    ✓ record_id is a superkey

  Payment:
    payment_id → record_id, user_id, amount, payment_method, payment_status, paid_at
    record_id → payment_id  [candidate key via UNIQUE constraint]
    ✓ All determinants are superkeys

  Staff:
    staff_id → facility_id, first_name, last_name, role, phone, salary, hire_date
    ✓ staff_id is a superkey

CONCLUSION: All tables satisfy BCNF.
  Every functional dependency has a superkey as its determinant.
  The schema is fully normalized to BCNF.
*/
