<p align="center">
  <img src="https://img.shields.io/badge/MySQL-8.x-4479A1?style=for-the-badge&logo=mysql&logoColor=white" />
  <img src="https://img.shields.io/badge/SQL-50%2B%20Queries-orange?style=for-the-badge&logo=databricks&logoColor=white" />
  <img src="https://img.shields.io/badge/Normalization-BCNF-green?style=for-the-badge" />
  <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" />
</p>

<h1 align="center">🅿️ Parking Management System</h1>
<h3 align="center">A Comprehensive Database Management Systems Project</h3>
<p align="center"><i>Efficient parking and slot allocation across multiple facilities</i></p>

---

## 📋 Table of Contents

- [About the Project](#-about-the-project)
- [Database Schema](#-database-schema)
- [ER Diagram](#-er-diagram)
- [Normalization](#-normalization)
- [SQL Coverage](#-sql-coverage)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Sample Queries](#-sample-queries)
- [Stored Procedures](#-stored-procedures)
- [Triggers](#-triggers)
- [Views](#-views)
- [Interview Preparation](#-interview-preparation)
- [Tech Stack](#-tech-stack)

---

## 🎯 About the Project

The **Parking Management System** is a full-fledged relational database project built with **MySQL** that manages:

- 🏢 **Multiple parking facilities** across a city
- 🅿️ **Slot allocation** with type-based pricing (Compact, Regular, Large, Handicapped, EV)
- 👤 **User management** with tiered memberships (Basic, Premium, VIP)
- 🚗 **Vehicle registration** linked to user accounts
- 📅 **Advance reservations** with status tracking
- ⏱️ **Real-time parking records** with auto-computed duration
- 💳 **Payment processing** across multiple methods (Cash, Card, UPI, Wallet)
- 👷 **Staff management** per facility with role-based assignments

> This project demonstrates real-world database design covering **schema design, normalization to BCNF, ER modeling, and 50+ SQL queries** spanning all SQL categories.

---

## 🗄️ Database Schema

The system consists of **8 normalized tables** with proper referential integrity:

```
┌──────────────┐     ┌──────────────────┐     ┌──────────────┐
│   Facility   │────<│  Parking_Slot    │────<│Parking_Record│
│              │     │                  │     │              │
│ facility_id  │     │ slot_id          │     │ record_id    │
│ name         │     │ facility_id (FK) │     │ vehicle_id   │
│ address      │     │ floor_number     │     │ slot_id (FK) │
│ city         │     │ slot_number      │     │ entry_time   │
│ state        │     │ slot_type        │     │ exit_time    │
│ zip_code     │     │ is_occupied      │     │ duration_hrs │
│ total_floors │     │ hourly_rate      │     └──────┬───────┘
└──────┬───────┘     └──────────────────┘            │ 1:1
       │                                      ┌──────┴───────┐
       │ 1:M                                  │   Payment    │
┌──────┴───────┐     ┌──────────────────┐     │              │
│    Staff     │     │     Vehicle      │     │ payment_id   │
│              │     │                  │     │ record_id FK │
│ staff_id     │     │ vehicle_id       │     │ user_id (FK) │
│ facility_id  │     │ user_id (FK)     │     │ amount       │
│ first_name   │     │ license_plate    │     │ method       │
│ last_name    │     │ vehicle_type     │     │ status       │
│ role         │     │ brand, model     │     └──────────────┘
│ salary       │     └────────┬─────────┘
└──────────────┘              │
                       ┌──────┴───────┐     ┌──────────────────┐
                       │     User     │────<│  Reservation     │
                       │              │     │                  │
                       │ user_id      │     │ reservation_id   │
                       │ first_name   │     │ user_id (FK)     │
                       │ last_name    │     │ slot_id (FK)     │
                       │ email        │     │ vehicle_id (FK)  │
                       │ phone        │     │ reserved_from    │
                       │ license_no   │     │ reserved_until   │
                       │ membership   │     │ status           │
                       └──────────────┘     └──────────────────┘
```

### Table Summary

| Table | Records | Purpose |
|-------|---------|---------|
| `Facility` | 5 | Parking garages / lots |
| `Parking_Slot` | 30 | Individual slots (6 per facility) |
| `User` | 10 | Registered customers |
| `Vehicle` | 12 | Vehicles owned by users |
| `Reservation` | 13 | Advance slot bookings |
| `Parking_Record` | 15 | Entry/exit logs with computed duration |
| `Payment` | 9 | Payment transactions |
| `Staff` | 12 | Facility employees |

---

## 📐 ER Diagram

### Entities & Relationships

```
  Facility ──── 1:M ──── Parking_Slot ──── 1:M ──── Parking_Record ──── 1:1 ──── Payment
     │                        │
     │ 1:M                    │ 1:M
     │                        │
   Staff                 Reservation
                              │
                         ┌────┴────┐
                     User ── 1:M ── Vehicle ── 1:M ── Parking_Record
                       │
                       │ 1:M
                       │
                    Payment
```

### Key Relationships

| Relationship | Type | Description |
|-------------|------|-------------|
| Facility → Parking_Slot | 1:M | A facility has many slots |
| Facility → Staff | 1:M | A facility employs many staff |
| User → Vehicle | 1:M | A user owns many vehicles |
| User → Reservation | 1:M | A user makes many reservations |
| Vehicle → Parking_Record | 1:M | A vehicle has many parking sessions |
| Parking_Record → Payment | 1:1 | Each session has one payment |

---

## 📏 Normalization

The schema is fully normalized to **Boyce-Codd Normal Form (BCNF)**:

| Normal Form | Requirement | Status |
|-------------|------------|--------|
| **1NF** | Atomic values, no repeating groups, primary keys | ✅ All attributes atomic; names split into first/last |
| **2NF** | No partial dependencies | ✅ All PKs are single-column (AUTO_INCREMENT) |
| **3NF** | No transitive dependencies | ✅ No non-key → non-key dependencies |
| **BCNF** | Every FD determinant is a superkey | ✅ All determinants are superkeys |

### Functional Dependencies

```
Facility:       facility_id → {name, address, city, state, zip_code, total_floors}
Parking_Slot:   slot_id → {facility_id, floor_number, slot_number, slot_type, is_occupied, hourly_rate}
User:           user_id → {first_name, last_name, email, phone, license_no, membership}
                email → user_id  (candidate key)
                license_no → user_id  (candidate key)
Vehicle:        vehicle_id → {user_id, license_plate, vehicle_type, brand, model, color}
                license_plate → vehicle_id  (candidate key)
Payment:        payment_id → {record_id, user_id, amount, payment_method, payment_status}
                record_id → payment_id  (candidate key)
```

---

## 🔍 SQL Coverage

This project includes **70+ comprehensive SQL queries** covering every major SQL category:

### Query Categories

| Category | Count | Topics |
|----------|-------|--------|
| **DDL** | 10+ | CREATE TABLE, ALTER TABLE (ADD/MODIFY/DROP/RENAME column), CREATE INDEX, CREATE VIEW |
| **DML** | 4+ | INSERT, UPDATE, DELETE |
| **DRL / SELECT** | 20+ | Basic SELECT, WHERE, ORDER BY, LIMIT, DISTINCT, BETWEEN, LIKE |
| **Joins** | 5 types | INNER, LEFT, RIGHT, CROSS, SELF |
| **Subqueries** | 4 types | Scalar, Row, Table, Correlated |
| **Aggregates** | 6+ | COUNT, SUM, AVG, MAX, MIN, GROUP_CONCAT |
| **GROUP BY / HAVING** | 8+ | Grouping with filters, conditional aggregation (IF) |
| **Set Operations** | 2 | UNION, simulated INTERSECT |
| **Views** | 3 | Occupancy dashboard, revenue summary, active sessions |
| **Stored Procedures** | 6 | Park vehicle, exit & bill, facility report, atomic demo, cursor demo, safe transfer |
| **User-Defined Functions** | 2 | Fee calculator (with discount), slot status |
| **Triggers** | 3 | Auto-occupy, auto-free, prevent unsafe delete |
| **Cursors** | 1 | Row-by-row pending charges calculation |
| **Window Functions** | 3 | RANK, DENSE_RANK, running totals |
| **TCL / ACID** | 5+ | COMMIT, ROLLBACK, SAVEPOINT, error handling, atomicity demo |
| **Locking** | 2 | FOR UPDATE (exclusive), LOCK IN SHARE MODE (shared) |
| **DCL** | 2 | GRANT, REVOKE |
| **String Functions** | 5+ | UPPER, LENGTH, SUBSTRING, LOCATE, REVERSE, CONCAT |
| **Date Functions** | 5+ | DAYNAME, MONTHNAME, DATEDIFF, TIMESTAMPDIFF, DATE_FORMAT |
| **Advanced** | 8+ | CASE, EXISTS, ANY/ALL, COALESCE, IFNULL, BETWEEN, peak hours |

---

## 📁 Project Structure

```
parkingmanagementdbms/
│
├── schema.sql                        # Database & table creation (DDL)
├── sample_data.sql                   # Sample data for all 8 tables (DML)
├── queries.sql                       # 50+ core SQL queries (joins, subqueries, views, triggers, etc.)
├── advanced_concepts.sql             # ACID demos, cursors, functions, ALTER, locking, error handling
├── er_diagram_and_normalization.sql  # ER diagram & BCNF normalization proof
├── interview_questions.tex           # LaTeX source for interview prep document
├── interview_questions.pdf           # Compiled PDF — 45+ interview Q&A
└── README.md                         # This file
```

---

## 🚀 Getting Started

### Prerequisites

- **MySQL 8.x** installed ([Download](https://dev.mysql.com/downloads/))
- **MySQL Workbench** (recommended) or any MySQL client

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/marurisaikiran/parkingmanagementdbms.git
   cd parkingmanagementdbms
   ```

2. **Create the database and tables**
   ```bash
   mysql -u root -p < schema.sql
   ```

3. **Load sample data**
   ```bash
   mysql -u root -p < sample_data.sql
   ```

4. **Run queries**
   ```bash
   mysql -u root -p < queries.sql
   ```

   Or open each file in **MySQL Workbench** and execute sequentially.

### Using MySQL Workbench

1. Open MySQL Workbench → Connect to your local instance
2. `File → Open SQL Script` → Select `schema.sql` → Execute (⚡)
3. Repeat for `sample_data.sql`, `queries.sql`, and `advanced_concepts.sql`

---

## 💡 Sample Queries

### Currently Parked Vehicles
```sql
SELECT v.license_plate, v.brand, v.model,
       f.name AS facility, ps.slot_number, pr.entry_time
FROM Parking_Record pr
JOIN Vehicle v ON pr.vehicle_id = v.vehicle_id
JOIN Parking_Slot ps ON pr.slot_id = ps.slot_id
JOIN Facility f ON ps.facility_id = f.facility_id
WHERE pr.exit_time IS NULL;
```

### Facility Occupancy Dashboard
```sql
SELECT f.name AS facility,
       COUNT(s.slot_id) AS total_slots,
       SUM(s.is_occupied) AS occupied,
       ROUND(SUM(s.is_occupied) * 100.0 / COUNT(*), 1) AS occupancy_pct
FROM Facility f
JOIN Parking_Slot s ON f.facility_id = s.facility_id
GROUP BY f.facility_id, f.name;
```

### Revenue by Payment Method
```sql
SELECT payment_method,
       COUNT(*) AS transactions,
       SUM(amount) AS total_revenue,
       ROUND(AVG(amount), 2) AS avg_amount
FROM Payment
WHERE payment_status = 'Completed'
GROUP BY payment_method
ORDER BY total_revenue DESC;
```

### Membership Discount Simulation (CASE)
```sql
SELECT CONCAT(u.first_name, ' ', u.last_name) AS customer,
       u.membership, p.amount AS original,
       CASE u.membership
           WHEN 'VIP'     THEN ROUND(p.amount * 0.80, 2)
           WHEN 'Premium' THEN ROUND(p.amount * 0.90, 2)
           ELSE p.amount
       END AS discounted_amount
FROM Payment p
JOIN User u ON p.user_id = u.user_id;
```

---

## 🧪 ACID Properties — Demonstrated

Each ACID property is demonstrated with runnable SQL in `advanced_concepts.sql`:

| Property | How It's Demonstrated |
|----------|----------------------|
| **Atomicity** | `sp_atomic_demo()` — multi-step slot transfer; if any step fails, entire transaction rolls back |
| **Consistency** | FK violations (non-existent user), UNIQUE violations (duplicate email) — DB rejects invalid state |
| **Isolation** | `SELECT ... FOR UPDATE` — locks a slot row so concurrent booking attempts must wait |
| **Durability** | After `COMMIT`, InnoDB's write-ahead log (redo log) ensures data survives crashes |

```sql
-- Atomicity: All-or-nothing slot transfer
CALL sp_atomic_demo();

-- Isolation: Lock a slot to prevent double-booking
START TRANSACTION;
SELECT * FROM Parking_Slot WHERE slot_id = 14 FOR UPDATE;  -- exclusive lock
UPDATE Parking_Slot SET is_occupied = TRUE WHERE slot_id = 14;
COMMIT;
```

---

## ⚙️ Stored Procedures & Functions

### Stored Procedures

| Procedure | Parameters | Description |
|-----------|-----------|-------------|
| `sp_park_vehicle` | `(vehicle_id, slot_id)` | Parks a vehicle — checks availability, inserts record, marks slot occupied |
| `sp_exit_vehicle` | `(record_id, payment_method)` | Exits vehicle — sets exit time, calculates bill, inserts payment, frees slot |
| `sp_facility_report` | `(facility_id)` | Returns comprehensive facility stats — slots, staff, revenue |
| `sp_atomic_demo` | `()` | Demonstrates ACID atomicity with error handling and rollback |
| `sp_pending_charges_cursor` | `()` | Uses a **CURSOR** to iterate active sessions and compute pending charges |
| `sp_safe_transfer_slot` | `(record_id, new_slot_id)` | Transfers vehicle between slots with full error handling |

### User-Defined Functions

| Function | Returns | Description |
|----------|---------|-------------|
| `fn_calculate_fee` | `DECIMAL(8,2)` | Calculates parking fee with membership-based discount (VIP 20%, Premium 10%) |
| `fn_slot_status` | `VARCHAR(50)` | Returns human-readable slot status (e.g., "Regular - AVAILABLE") |

```sql
-- Park a vehicle
CALL sp_park_vehicle(4, 3);

-- Exit and generate bill
CALL sp_exit_vehicle(6, 'UPI');

-- Cursor demo: pending charges for all active sessions
CALL sp_pending_charges_cursor();

-- Calculate fee with VIP discount
SELECT fn_calculate_fee('2026-06-10 09:00:00', '2026-06-10 17:00:00', 30.00, 'VIP');
-- Result: 192.00 (8hrs × ₹30 = ₹240, 20% VIP discount)
```

---

## 🔔 Triggers

| Trigger | Event | Action |
|---------|-------|--------|
| `trg_after_park` | AFTER INSERT on Parking_Record | Auto-marks slot as occupied |
| `trg_after_exit` | AFTER UPDATE on Parking_Record | Auto-frees slot when exit_time is set |
| `trg_before_user_delete` | BEFORE DELETE on User | Prevents deletion if user has active parking |

---

## 👁️ Views

| View | Purpose |
|------|---------|
| `vw_facility_occupancy` | Dashboard: total, occupied, available slots with occupancy % |
| `vw_revenue_summary` | Revenue breakdown per facility |
| `vw_active_sessions` | Live view of parked vehicles with estimated bill |

```sql
-- Check facility occupancy
SELECT * FROM vw_facility_occupancy;

-- Live parking with estimated costs
SELECT * FROM vw_active_sessions;
```

---

## 📝 Interview Preparation

The [`interview_questions.pdf`](interview_questions.pdf) contains **45 compulsory DBMS interview questions** with detailed answers covering:

| Topic | Questions |
|-------|-----------|
| Project Overview | Q1–Q3 |
| ER Diagrams | Q4–Q6 |
| Normalization (1NF → BCNF) | Q7–Q10 |
| SQL Theory (DDL/DML/DRL/TCL/DCL) | Q11–Q14 |
| Keys & Indexing | Q15–Q16 |
| All JOIN Types | Q17–Q18 |
| Subqueries & Nested Queries | Q19–Q20 |
| Aggregate Functions & GROUP BY | Q21–Q22 |
| Views | Q23 |
| Stored Procedures | Q24–Q25 |
| Triggers | Q26 |
| ACID & Transactions | Q27–Q28 |
| Window Functions | Q29 |
| Advanced Theory | Q30–Q35 |
| Practical Query Writing | Q36–Q40 |
| Miscellaneous & Scaling | Q41–Q45 |

---

## 🛠️ Tech Stack

<p>
  <img src="https://img.shields.io/badge/MySQL-4479A1?style=flat-square&logo=mysql&logoColor=white" />
  <img src="https://img.shields.io/badge/MySQL%20Workbench-4479A1?style=flat-square&logo=mysql&logoColor=white" />
  <img src="https://img.shields.io/badge/LaTeX-008080?style=flat-square&logo=latex&logoColor=white" />
  <img src="https://img.shields.io/badge/SQL-FF6600?style=flat-square&logo=databricks&logoColor=white" />
</p>

---

<p align="center">
  <b>⭐ Star this repo if you found it helpful!</b>
</p>
