-- ============================================================
-- LAB - 5 : ACID PROPERTIES OF TRANSACTION
-- Campus Canteen Management System (CCMS)
--
-- This script is self-contained: it (re)builds the USER/VENDOR/
-- FOOD_ITEM/ORDER_TABLE/ORDER_ITEM schema used from Lab 3 onward
-- (see the note in Lab 3's script) and adds Order_ID 31, which the
-- manual's Isolation demo reads/updates but never shows being
-- created. Run this in campusdb. Requires InnoDB (MariaDB/MySQL
-- default) for transactions to actually work.
-- ============================================================

USE campusdb;

-- --------------------------------------------------------------
-- Section 0: schema + sample data (same as Lab 3, safe to re-run)
-- --------------------------------------------------------------
DROP TABLE IF EXISTS ORDER_ITEM;
DROP TABLE IF EXISTS ORDER_TABLE;
DROP TABLE IF EXISTS FOOD_ITEM;
DROP TABLE IF EXISTS VENDOR;
DROP TABLE IF EXISTS USER;

CREATE TABLE USER (
    User_ID INT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone_Number VARCHAR(15) NOT NULL,
    User_Type VARCHAR(20) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE VENDOR (
    Vendor_ID INT PRIMARY KEY,
    Vendor_Name VARCHAR(50) NOT NULL,
    Contact_No VARCHAR(15) UNIQUE NOT NULL,
    Opening_Time TIME NOT NULL,
    Closing_Time TIME NOT NULL,
    Location VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE FOOD_ITEM (
    Item_ID INT PRIMARY KEY,
    Item_Name VARCHAR(50) NOT NULL,
    Price DECIMAL(8,2) NOT NULL,
    Prep_Time INT DEFAULT 10,
    Availability_Status VARCHAR(20) DEFAULT 'Available'
) ENGINE=InnoDB;

CREATE TABLE ORDER_TABLE (
    Order_ID INT PRIMARY KEY,
    User_ID INT NOT NULL,
    Vendor_ID INT NOT NULL,
    Order_Time DATETIME NOT NULL,
    Pickup_Time DATETIME,
    Predicted_Ready_Time DATETIME,
    Order_Status VARCHAR(20) DEFAULT 'Pending',
    Total_Amount DECIMAL(10,2) NOT NULL,
    QR_Code VARCHAR(20),
    FOREIGN KEY (User_ID) REFERENCES USER(User_ID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Vendor_ID) REFERENCES VENDOR(Vendor_ID)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE ORDER_ITEM (
    Order_Item_ID INT PRIMARY KEY,
    Order_ID INT NOT NULL,
    Item_ID INT NOT NULL,
    Quantity INT NOT NULL,
    Unit_Price DECIMAL(8,2) NOT NULL,
    Subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (Order_ID) REFERENCES ORDER_TABLE(Order_ID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Item_ID) REFERENCES FOOD_ITEM(Item_ID)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO USER VALUES
    (101,'RAHUL','rahul@gmail.com','9876543210','Student'),
    (102,'Priya','priya@gmail.com','9876543211','Faculty');

INSERT INTO VENDOR VALUES
    (1,'Campus Cafe','9871112222','08:00:00','20:00:00','Block A'),
    (2,'Food Court','9873334444','09:00:00','21:00:00','Block B');

INSERT INTO FOOD_ITEM VALUES
    (1,'Burger',80.00,15,'Available'),
    (2,'Pizza',150.00,15,'Available'),
    (3,'Coffee',40.00,5,'Available'),
    (4,'Sandwich',80.00,8,'Available');

INSERT INTO ORDER_TABLE VALUES
    (1,101,1,'2025-07-01 10:00:00',NULL,'2025-07-01 10:15:00','Pending',120.00,'QR001'),
    (2,102,2,'2025-07-01 11:00:00',NULL,'2025-07-01 11:20:00','Ready',190.00,'QR002'),
    (3,101,2,'2025-07-01 12:00:00','2025-07-01 12:30:00','2025-07-01 12:25:00','Collected',230.00,'QR003'),
    -- Order 31 is created here specifically for the Isolation demo below,
    -- since the manual updates/reads Order_ID 31 without ever showing it
    -- being inserted.
    (31,101,1,'2025-07-08 17:00:00',NULL,'2025-07-08 17:15:00','Pending',100.00,'QR031');

INSERT INTO ORDER_ITEM VALUES
    (1,1,1,1,80.00,80.00),
    (2,1,3,1,40.00,40.00),
    (3,2,2,1,150.00,150.00),
    (4,2,3,1,40.00,40.00),
    (5,3,2,1,150.00,150.00),
    (6,3,4,1,80.00,80.00);

SELECT * FROM USER;
SELECT * FROM VENDOR;
SELECT * FROM FOOD_ITEM;
SELECT * FROM ORDER_TABLE;
SELECT * FROM ORDER_ITEM;

-- ============================================================
-- 1. ATOMICITY
-- A transaction is all-or-nothing: either all operations
-- succeed and are COMMITted, or none are applied (ROLLBACK).
-- ============================================================

-- STEP 1: Start transaction and insert a new order
START TRANSACTION;

INSERT INTO ORDER_TABLE
    (Order_ID, User_ID, Vendor_ID, Order_Time, Pickup_Time,
     Predicted_Ready_Time, Order_Status, Total_Amount, QR_Code)
VALUES
    (40, 101, 1, NOW(), NULL, NULL, 'Pending', 160, 'QR040');

SELECT * FROM ORDER_TABLE WHERE Order_ID = 40;

-- STEP 2: Insert a new ordered item and COMMIT
INSERT INTO ORDER_ITEM
    (Order_Item_ID, Order_ID, Item_ID, Quantity, Unit_Price, Subtotal)
VALUES
    (9, 40, 1, 2, 80, 160);

COMMIT;

SELECT * FROM ORDER_TABLE WHERE Order_ID = 40;
SELECT * FROM ORDER_ITEM WHERE Order_ID = 40;

-- --------------------------------------------------------------
-- Demonstrate failure handling using ROLLBACK
-- --------------------------------------------------------------

-- STEP 1: Start transaction and create a new order
START TRANSACTION;

INSERT INTO ORDER_TABLE
VALUES (41, 101, 1, NOW(), NULL, NULL, 'Pending', 100, 'QR041');

-- STEP 2: Enter an invalid ordered item (Item_ID 999 does not exist
-- in FOOD_ITEM, so the foreign key constraint fails)
INSERT INTO ORDER_ITEM
VALUES (10, 41, 999, 1, 100, 100);
-- Expected: ERROR 1452 (23000): Cannot add or update a child row:
-- a foreign key constraint fails (order_item -> food_item)

ROLLBACK;

SELECT * FROM ORDER_TABLE WHERE Order_ID = 41;
-- Empty set -> ROLLBACK undid the order-40-like insert above too,
-- confirming atomicity: nothing from this transaction was kept.

-- ============================================================
-- 2. CONSISTENCY
-- Every transaction must leave the database in a valid state
-- by enforcing PK, FK, and domain (CHECK) constraints.
-- ============================================================

-- Demonstration 1: Primary Key constraint
INSERT INTO USER VALUES (101,'Test','test@gmail.com','9999999999','Student');
-- Expected: ERROR 1062 (23000): Duplicate entry '101' for key 'PRIMARY'

-- Demonstration 2: Foreign Key constraint
INSERT INTO ORDER_TABLE
VALUES (42, 999, 1, NOW(), NULL, NULL, 'Pending', 100, 'QR042');
-- Expected: ERROR 1452 (23000): Cannot add or update a child row:
-- a foreign key constraint fails (order_table -> user)

-- ============================================================
-- 3. ISOLATION
-- Concurrent transactions run independently; changes made by
-- one transaction are not visible to others until committed.
--
-- To actually see this, open TWO separate terminal/mysql sessions
-- (both `USE campusdb;`) and run the "Window 1" and "Window 2"
-- blocks below in the order shown, interleaving them as marked.
-- ============================================================

-- ---- Session / Window 1 ----
START TRANSACTION;

UPDATE ORDER_TABLE
SET Order_Status = 'Ready'
WHERE Order_ID = 31;

SELECT Order_ID, Order_Status
FROM ORDER_TABLE
WHERE Order_ID = 31;
-- shows 'Ready' inside this session (uncommitted change)

-- ---- Session / Window 2 (run this concurrently, in another session) ----
-- SELECT Order_ID, Order_Status
-- FROM ORDER_TABLE
-- WHERE Order_ID = 31;
-- still shows 'Pending' here -> Window 1's uncommitted change is isolated

-- ---- Back in Window 1 ----
COMMIT;

-- ---- Window 2, after Window 1 commits ----
SELECT Order_ID, Order_Status
FROM ORDER_TABLE
WHERE Order_ID = 31;
-- now shows 'Ready' -> change is visible only after COMMIT

-- ============================================================
-- 4. DURABILITY
-- Once a transaction is committed, changes persist even after
-- closing and reopening the database session.
-- ============================================================

-- STEP 1: Start transaction and insert item
START TRANSACTION;

INSERT INTO FOOD_ITEM
    (Item_ID, Item_Name, Price, Prep_Time, Availability_Status)
VALUES
    (6, 'French Fries', 90, 10, 'Available');

-- STEP 2: COMMIT
COMMIT;

-- STEP 3: Verify inserted item
SELECT * FROM FOOD_ITEM WHERE Item_ID = 6;

-- STEP 4: Exit the MySQL session (run manually: EXIT;)
-- STEP 5: Reopen MySQL and re-run the query below in a fresh session
--         to confirm the row is still there.
-- USE campusdb;
-- SELECT * FROM FOOD_ITEM WHERE Item_ID = 6;
-- Data persists -> durability confirmed
