-- ============================================================
-- PARKING MANAGEMENT SYSTEM — Sample Data
-- ============================================================

USE parking_management;

-- -----------------------------------------------
-- Facilities
-- -----------------------------------------------
INSERT INTO Facility (name, address, city, state, zip_code, total_floors) VALUES
('City Center Parking', '123 MG Road', 'Hyderabad', 'Telangana', '500001', 4),
('Airport Parking Hub', '456 Shamshabad Road', 'Hyderabad', 'Telangana', '500108', 3),
('Tech Park Garage', '789 HITEC City', 'Hyderabad', 'Telangana', '500081', 5),
('Railway Station Lot', '101 Nampally', 'Hyderabad', 'Telangana', '500001', 2),
('Mall Parking Complex', '202 Banjara Hills', 'Hyderabad', 'Telangana', '500034', 3);

-- -----------------------------------------------
-- Parking Slots (6 slots per facility = 30 total)
-- -----------------------------------------------
INSERT INTO Parking_Slot (facility_id, floor_number, slot_number, slot_type, is_occupied, hourly_rate) VALUES
-- City Center Parking (facility 1)
(1, 1, 'A-01', 'Regular',      FALSE, 30.00),
(1, 1, 'A-02', 'Regular',      TRUE,  30.00),
(1, 2, 'B-01', 'Compact',      FALSE, 20.00),
(1, 2, 'B-02', 'Handicapped',  FALSE, 15.00),
(1, 3, 'C-01', 'Large',        TRUE,  50.00),
(1, 4, 'D-01', 'EV',           FALSE, 40.00),
-- Airport Parking Hub (facility 2)
(2, 1, 'A-01', 'Regular',      TRUE,  40.00),
(2, 1, 'A-02', 'Regular',      FALSE, 40.00),
(2, 2, 'B-01', 'Large',        TRUE,  60.00),
(2, 2, 'B-02', 'EV',           FALSE, 55.00),
(2, 3, 'C-01', 'Compact',      FALSE, 25.00),
(2, 3, 'C-02', 'Handicapped',  FALSE, 20.00),
-- Tech Park Garage (facility 3)
(3, 1, 'A-01', 'Regular',      TRUE,  35.00),
(3, 1, 'A-02', 'Compact',      FALSE, 25.00),
(3, 2, 'B-01', 'Regular',      TRUE,  35.00),
(3, 3, 'C-01', 'EV',           FALSE, 45.00),
(3, 4, 'D-01', 'Large',        FALSE, 55.00),
(3, 5, 'E-01', 'Handicapped',  FALSE, 20.00),
-- Railway Station Lot (facility 4)
(4, 1, 'A-01', 'Regular',      TRUE,  20.00),
(4, 1, 'A-02', 'Regular',      FALSE, 20.00),
(4, 1, 'A-03', 'Compact',      TRUE,  15.00),
(4, 2, 'B-01', 'Large',        FALSE, 35.00),
(4, 2, 'B-02', 'Handicapped',  FALSE, 10.00),
(4, 2, 'B-03', 'EV',           FALSE, 30.00),
-- Mall Parking Complex (facility 5)
(5, 1, 'A-01', 'Regular',      TRUE,  25.00),
(5, 1, 'A-02', 'Compact',      FALSE, 18.00),
(5, 2, 'B-01', 'Regular',      TRUE,  25.00),
(5, 2, 'B-02', 'EV',           FALSE, 40.00),
(5, 3, 'C-01', 'Large',        FALSE, 45.00),
(5, 3, 'C-02', 'Handicapped',  FALSE, 12.00);

-- -----------------------------------------------
-- Users
-- -----------------------------------------------
INSERT INTO User (first_name, last_name, email, phone, license_no, membership) VALUES
('Rahul',    'Sharma',     'rahul.sharma@email.com',    '9876543210', 'DL-01-2020-1234', 'Premium'),
('Priya',    'Reddy',      'priya.reddy@email.com',     '9876543211', 'TS-09-2021-5678', 'VIP'),
('Amit',     'Patel',      'amit.patel@email.com',      '9876543212', 'GJ-01-2019-9101', 'Basic'),
('Sneha',    'Gupta',      'sneha.gupta@email.com',     '9876543213', 'MH-12-2022-1121', 'Premium'),
('Vikram',   'Singh',      'vikram.singh@email.com',    '9876543214', 'DL-05-2018-3141', 'Basic'),
('Ananya',   'Nair',       'ananya.nair@email.com',     '9876543215', 'KA-01-2023-5161', 'VIP'),
('Rohan',    'Joshi',      'rohan.joshi@email.com',     '9876543216', 'TS-07-2020-7181', 'Basic'),
('Deepika',  'Menon',      'deepika.menon@email.com',   '9876543217', 'KL-07-2021-9202', 'Premium'),
('Arjun',    'Verma',      'arjun.verma@email.com',     '9876543218', 'UP-32-2022-1222', 'Basic'),
('Kavya',    'Iyer',       'kavya.iyer@email.com',      '9876543219', 'TN-01-2019-3242', 'VIP');

-- -----------------------------------------------
-- Vehicles
-- -----------------------------------------------
INSERT INTO Vehicle (user_id, license_plate, vehicle_type, brand, model, color) VALUES
(1,  'TS-09-AB-1234', 'Sedan',       'Hyundai',  'Verna',      'White'),
(1,  'TS-09-CD-5678', 'SUV',         'Tata',     'Harrier',    'Black'),
(2,  'TS-09-EF-9101', 'Sedan',       'Honda',    'City',       'Silver'),
(3,  'GJ-01-GH-1121', 'Compact',     'Maruti',   'Swift',      'Red'),
(4,  'MH-12-IJ-3141', 'SUV',         'Mahindra', 'XUV700',     'Blue'),
(5,  'DL-05-KL-5161', 'Sedan',       'Toyota',   'Camry',      'Grey'),
(6,  'KA-01-MN-7181', 'Two-Wheeler', 'Honda',    'Activa',     'Black'),
(7,  'TS-07-OP-9202', 'Compact',     'Hyundai',  'i20',        'Red'),
(8,  'KL-07-QR-1222', 'SUV',         'Kia',      'Seltos',     'White'),
(9,  'UP-32-ST-3242', 'Truck',       'Tata',     'Ace',        'Green'),
(10, 'TN-01-UV-5262', 'Sedan',       'Skoda',    'Slavia',     'Grey'),
(10, 'TN-01-WX-7282', 'Two-Wheeler', 'Royal Enfield', 'Classic 350', 'Black');

-- -----------------------------------------------
-- Reservations
-- -----------------------------------------------
INSERT INTO Reservation (user_id, slot_id, vehicle_id, reserved_from, reserved_until, status) VALUES
(1,  2,  1,  '2026-06-10 09:00:00', '2026-06-10 17:00:00', 'Completed'),
(2,  7,  3,  '2026-06-10 10:00:00', '2026-06-10 14:00:00', 'Completed'),
(3,  21, 4,  '2026-06-10 08:00:00', '2026-06-10 12:00:00', 'Completed'),
(4,  5,  5,  '2026-06-10 11:00:00', '2026-06-10 18:00:00', 'Completed'),
(5,  13, 6,  '2026-06-11 09:00:00', '2026-06-11 18:00:00', 'Active'),
(6,  25, 7,  '2026-06-11 10:00:00', '2026-06-11 13:00:00', 'Active'),
(7,  15, 8,  '2026-06-11 07:00:00', '2026-06-11 19:00:00', 'Active'),
(8,  27, 9,  '2026-06-11 12:00:00', '2026-06-11 16:00:00', 'Active'),
(9,  19, 10, '2026-06-12 08:00:00', '2026-06-12 20:00:00', 'Active'),
(10, 9,  11, '2026-06-10 06:00:00', '2026-06-10 22:00:00', 'Completed'),
(1,  6,  2,  '2026-06-11 14:00:00', '2026-06-11 20:00:00', 'Active'),
(2,  10, 3,  '2026-06-12 09:00:00', '2026-06-12 15:00:00', 'Active'),
(10, 16, 12, '2026-06-11 08:00:00', '2026-06-11 17:00:00', 'Cancelled');

-- -----------------------------------------------
-- Parking Records
-- -----------------------------------------------
INSERT INTO Parking_Record (vehicle_id, slot_id, entry_time, exit_time) VALUES
(1,  2,  '2026-06-10 09:05:00', '2026-06-10 16:50:00'),
(3,  7,  '2026-06-10 10:10:00', '2026-06-10 13:55:00'),
(4,  21, '2026-06-10 08:02:00', '2026-06-10 11:58:00'),
(5,  5,  '2026-06-10 11:15:00', '2026-06-10 17:45:00'),
(11, 9,  '2026-06-10 06:10:00', '2026-06-10 21:50:00'),
(6,  13, '2026-06-11 09:10:00', NULL),
(7,  25, '2026-06-11 10:05:00', NULL),
(8,  15, '2026-06-11 07:15:00', NULL),
(9,  27, '2026-06-11 12:10:00', NULL),
(10, 19, '2026-06-11 08:00:00', NULL),
(2,  6,  '2026-06-11 14:05:00', NULL),
-- Historical records for revenue analysis
(1,  1,  '2026-05-15 08:00:00', '2026-05-15 12:00:00'),
(3,  8,  '2026-05-16 09:00:00', '2026-05-16 15:00:00'),
(5,  14, '2026-05-20 10:00:00', '2026-05-20 18:00:00'),
(6,  13, '2026-05-22 07:00:00', '2026-05-22 19:00:00');

-- -----------------------------------------------
-- Payments (for completed records)
-- -----------------------------------------------
INSERT INTO Payment (record_id, user_id, amount, payment_method, payment_status) VALUES
(1,  1,  233.50, 'Credit Card', 'Completed'),
(2,  2,  153.33, 'UPI',         'Completed'),
(3,  3,   79.33, 'Cash',        'Completed'),
(4,  4,  327.50, 'Debit Card',  'Completed'),
(5,  10, 943.33, 'Wallet',      'Completed'),
(12, 1,  120.00, 'UPI',         'Completed'),
(13, 2,  240.00, 'Credit Card', 'Completed'),
(14, 5,  280.00, 'Cash',        'Completed'),
(15, 6,  420.00, 'UPI',         'Completed');

-- -----------------------------------------------
-- Staff
-- -----------------------------------------------
INSERT INTO Staff (facility_id, first_name, last_name, role, phone, salary, hire_date) VALUES
(1, 'Suresh',   'Kumar',    'Manager',     '8001001001', 45000.00, '2023-01-15'),
(1, 'Ravi',     'Teja',     'Attendant',   '8001001002', 18000.00, '2024-03-10'),
(1, 'Lakshmi',  'Devi',     'Security',    '8001001003', 20000.00, '2023-06-20'),
(2, 'Mohan',    'Rao',      'Manager',     '8001001004', 50000.00, '2022-11-01'),
(2, 'Sita',     'Kumari',   'Attendant',   '8001001005', 18000.00, '2024-01-15'),
(3, 'Anil',     'Reddy',    'Manager',     '8001001006', 55000.00, '2022-05-01'),
(3, 'Bhanu',    'Prasad',   'Security',    '8001001007', 22000.00, '2023-08-10'),
(3, 'Divya',    'Sri',      'Maintenance', '8001001008', 16000.00, '2024-06-01'),
(4, 'Ganesh',   'Babu',     'Manager',     '8001001009', 40000.00, '2023-03-01'),
(4, 'Harish',   'Chandra',  'Attendant',   '8001001010', 17000.00, '2024-09-15'),
(5, 'Indira',   'Priya',    'Manager',     '8001001011', 48000.00, '2022-08-20'),
(5, 'Janaki',   'Ram',      'Security',    '8001001012', 21000.00, '2023-12-01');
