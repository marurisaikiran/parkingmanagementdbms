-- ============================================================
-- PARKING MANAGEMENT SYSTEM — Database Schema
-- DBMS: MySQL 8.x
-- ============================================================

DROP DATABASE IF EXISTS parking_management;
CREATE DATABASE parking_management;
USE parking_management;

-- ============================================================
-- 1. FACILITY — each parking facility / garage
-- ============================================================
CREATE TABLE Facility (
    facility_id   INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    address       VARCHAR(255) NOT NULL,
    city          VARCHAR(60)  NOT NULL,
    state         VARCHAR(40)  NOT NULL,
    zip_code      VARCHAR(10)  NOT NULL,
    total_floors  INT          NOT NULL DEFAULT 1,
    created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 2. PARKING_SLOT — individual slot inside a facility
-- ============================================================
CREATE TABLE Parking_Slot (
    slot_id       INT AUTO_INCREMENT PRIMARY KEY,
    facility_id   INT NOT NULL,
    floor_number  INT NOT NULL DEFAULT 1,
    slot_number   VARCHAR(10) NOT NULL,
    slot_type     ENUM('Compact', 'Regular', 'Large', 'Handicapped', 'EV') NOT NULL DEFAULT 'Regular',
    is_occupied   BOOLEAN NOT NULL DEFAULT FALSE,
    hourly_rate   DECIMAL(6,2) NOT NULL DEFAULT 20.00,
    UNIQUE (facility_id, floor_number, slot_number),
    FOREIGN KEY (facility_id) REFERENCES Facility(facility_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- 3. USER — registered users of the system
-- ============================================================
CREATE TABLE User (
    user_id       INT AUTO_INCREMENT PRIMARY KEY,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    phone         VARCHAR(15),
    license_no    VARCHAR(20)  UNIQUE,
    membership    ENUM('Basic', 'Premium', 'VIP') NOT NULL DEFAULT 'Basic',
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 4. VEHICLE — vehicles owned by users
-- ============================================================
CREATE TABLE Vehicle (
    vehicle_id      INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    license_plate   VARCHAR(20) NOT NULL UNIQUE,
    vehicle_type    ENUM('Two-Wheeler', 'Compact', 'Sedan', 'SUV', 'Truck') NOT NULL,
    brand           VARCHAR(50),
    model           VARCHAR(50),
    color           VARCHAR(30),
    FOREIGN KEY (user_id) REFERENCES User(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- 5. RESERVATION — advance slot booking
-- ============================================================
CREATE TABLE Reservation (
    reservation_id  INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    slot_id         INT NOT NULL,
    vehicle_id      INT NOT NULL,
    reserved_from   DATETIME NOT NULL,
    reserved_until  DATETIME NOT NULL,
    status          ENUM('Active', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Active',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)    REFERENCES User(user_id)          ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (slot_id)    REFERENCES Parking_Slot(slot_id)  ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES Vehicle(vehicle_id)    ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- 6. PARKING_RECORD — actual entry / exit log
-- ============================================================
CREATE TABLE Parking_Record (
    record_id       INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id      INT NOT NULL,
    slot_id         INT NOT NULL,
    entry_time      DATETIME NOT NULL,
    exit_time       DATETIME,
    duration_hours  DECIMAL(5,2) GENERATED ALWAYS AS (
        CASE WHEN exit_time IS NOT NULL
             THEN TIMESTAMPDIFF(MINUTE, entry_time, exit_time) / 60.0
             ELSE NULL
        END
    ) STORED,
    FOREIGN KEY (vehicle_id) REFERENCES Vehicle(vehicle_id)   ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (slot_id)    REFERENCES Parking_Slot(slot_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- 7. PAYMENT — payment for each parking session
-- ============================================================
CREATE TABLE Payment (
    payment_id     INT AUTO_INCREMENT PRIMARY KEY,
    record_id      INT NOT NULL UNIQUE,
    user_id        INT NOT NULL,
    amount         DECIMAL(8,2) NOT NULL,
    payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'UPI', 'Wallet') NOT NULL,
    payment_status ENUM('Pending', 'Completed', 'Refunded') NOT NULL DEFAULT 'Pending',
    paid_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (record_id) REFERENCES Parking_Record(record_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (user_id)   REFERENCES User(user_id)             ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- 8. STAFF — employees managing facilities
-- ============================================================
CREATE TABLE Staff (
    staff_id      INT AUTO_INCREMENT PRIMARY KEY,
    facility_id   INT NOT NULL,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    role          ENUM('Manager', 'Attendant', 'Security', 'Maintenance') NOT NULL,
    phone         VARCHAR(15),
    salary        DECIMAL(10,2),
    hire_date     DATE NOT NULL,
    FOREIGN KEY (facility_id) REFERENCES Facility(facility_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- INDEXES for common queries
-- ============================================================
CREATE INDEX idx_slot_facility   ON Parking_Slot(facility_id, is_occupied);
CREATE INDEX idx_vehicle_user    ON Vehicle(user_id);
CREATE INDEX idx_record_entry    ON Parking_Record(entry_time);
CREATE INDEX idx_payment_status  ON Payment(payment_status);
