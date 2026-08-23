-- ============================================================
-- LAB - 2 : Demonstration of the Relational Model
-- Campus Canteen Management System (CCMS)
-- ============================================================
CREATE DATABASE
      CREATE DATABASE campusdb;
USE campusdb;

-- --------------------------------------------------------------
-- 1. Create tables with constraints (PK, FK, UNIQUE, NOT NULL,
--    CHECK, DEFAULT)
-- --------------------------------------------------------------
CREATE TABLE STUDENT (
    Student_ID INT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Department VARCHAR(50) NOT NULL,
    Phone_Number VARCHAR(15) NOT NULL
);

CREATE TABLE VENDOR (
    Vendor_ID INT PRIMARY KEY,
    Vendor_Name VARCHAR(50) NOT NULL,
    Contact_No VARCHAR(15) UNIQUE NOT NULL,
    Opening_Time TIME NOT NULL,
    Closing_Time TIME NOT NULL,
    Location VARCHAR(100) NOT NULL
);

CREATE TABLE MENU_ITEM (
    Item_ID INT PRIMARY KEY,
    Item_Name VARCHAR(50) NOT NULL,
    Price DECIMAL(8,2) NOT NULL,
    Prep_Time INT DEFAULT 10,
    Availability_Status VARCHAR(20) DEFAULT 'Available',
    CHECK (Price > 0),
    CHECK (Prep_Time >= 0)
);

CREATE TABLE ORDER_TABLE (
    Order_ID INT PRIMARY KEY,
    Student_ID INT NOT NULL,
    Vendor_ID INT NOT NULL,
    Order_Time DATETIME NOT NULL,
    Pickup_Time DATETIME,
    Predicted_Ready_Time DATETIME,
    Order_Status VARCHAR(20) DEFAULT 'Pending',
    Total_Amount DECIMAL(10,2) NOT NULL,
    CHECK (Total_Amount >= 0),
    CONSTRAINT FK_ORDER_STUDENT FOREIGN KEY (Student_ID)
        REFERENCES STUDENT(Student_ID) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT FK_ORDER_VENDOR FOREIGN KEY (Vendor_ID)
        REFERENCES VENDOR(Vendor_ID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE ORDER_ITEM (
    Order_Item_ID INT PRIMARY KEY,
    Order_ID INT NOT NULL,
    Item_ID INT NOT NULL,
    Quantity INT NOT NULL,
    Unit_Price DECIMAL(8,2) NOT NULL,
    Subtotal DECIMAL(10,2) NOT NULL,
    CHECK (Quantity > 0),
    CHECK (Unit_Price > 0),
    CHECK (Subtotal >= 0),
    FOREIGN KEY (Order_ID) REFERENCES ORDER_TABLE(Order_ID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Item_ID) REFERENCES MENU_ITEM(Item_ID)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PICKUP_TOKEN (
    Token_ID INT PRIMARY KEY,
    Order_ID INT UNIQUE NOT NULL,
    QR_Code VARCHAR(100) UNIQUE NOT NULL,
    Generated_Time DATETIME NOT NULL,
    Scheduled_Pickup_Time DATETIME,
    Collection_Time DATETIME,
    Token_Status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (Order_ID) REFERENCES ORDER_TABLE(Order_ID)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- Verify structure
DESC STUDENT;
DESC VENDOR;
DESC MENU_ITEM;
DESC ORDER_TABLE;
DESC ORDER_ITEM;
DESC PICKUP_TOKEN;

SHOW TABLES;

-- --------------------------------------------------------------
-- 2. Demonstrate enforcement of constraints
-- --------------------------------------------------------------

-- Valid inserts
INSERT INTO STUDENT VALUES(101,'RAHUL','rahul@gmail.com','CSE','9876543210');
INSERT INTO VENDOR VALUES (1,'Campus Cafe','9871112222','08:00:00','20:00:00','Block A');
INSERT INTO MENU_ITEM VALUES(1,'Burger',80,15,'Available');

SELECT * FROM STUDENT;
SELECT * FROM VENDOR;
SELECT * FROM MENU_ITEM;

-- Unique constraint violation
INSERT INTO STUDENT VALUES(102,'AMAN','rahul@gmail.com','IT','9999999999');
-- ERROR 1062 (23000): Duplicate entry 'rahul@gmail.com' for key 'student.Email'

-- Primary key constraint violation
INSERT INTO STUDENT VALUES(101,'AMAN','rahul@gmail.com','IT','9999999999');
-- ERROR 1062 (23000): Duplicate entry '101' for key 'student.PRIMARY'

-- NOT NULL constraint violation
INSERT INTO STUDENT (Student_ID,Name,Department,Phone_Number)
VALUES (103,'Riya','CSE','9999999999');
-- ERROR 1364 (HY000): Field 'Email' doesn't have a default value

-- Check constraint violation
INSERT INTO MENU_ITEM VALUES(2,'Pizza',-100,20,'Available');
-- ERROR 3819 (HY000): Check constraint 'menu_item_chk_1' is violated.

-- Foreign key constraint violation
INSERT INTO ORDER_TABLE VALUES(1,999,1,'2025-05-01 10:00','2025-05-01 10:30','2025-05-01 10:20','Pending',200);
-- ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails

-- --------------------------------------------------------------
-- 3. ALTER TABLE demonstrations
-- --------------------------------------------------------------

-- Add new column
ALTER TABLE STUDENT ADD COLUMN Year INTEGER DEFAULT 1;
DESC STUDENT;

-- Rename column
ALTER TABLE STUDENT RENAME COLUMN Year TO Academic_Year;

-- Rename table
ALTER TABLE MENU_ITEM RENAME TO FOOD_ITEM;

-- --------------------------------------------------------------
-- 4. List constraints on each table
-- --------------------------------------------------------------

SHOW CREATE TABLE STUDENT;

-- --------------------------------------------------------------
-- 5. Dropping a constraint (UNIQUE on Email)
-- --------------------------------------------------------------

SHOW INDEX FROM STUDENT;

ALTER TABLE STUDENT DROP INDEX Email;

DESCRIBE STUDENT;

-- After dropping, duplicate email insert now succeeds
-- (uniqueness restriction removed)

-- --------------------------------------------------------------
-- 6. Data integrity via ON UPDATE / ON DELETE CASCADE
-- --------------------------------------------------------------

INSERT INTO STUDENT(Student_ID, Name, Email, Department, Phone_Number)
VALUES(201,'Priya','priya@gmail.com','CSE','9876543211');

-- Attempting duplicate vendor PK (expected to fail)
INSERT INTO VENDOR VALUES(1,'Campus Cafe','9871112222','08:00:00','20:00:00','Block A');
-- ERROR 1062 (23000): Duplicate entry '1' for key 'vendor.PRIMARY'

INSERT INTO ORDER_TABLE (Order_ID, Student_ID, Vendor_ID, Order_Time,
    Pickup_Time, Predicted_Ready_Time, Order_Status, Total_Amount)
VALUES(10,201,1,NOW(),NULL,NULL,'Pending',300);

SELECT * FROM ORDER_TABLE;

-- ON UPDATE CASCADE demonstration
UPDATE STUDENT SET Student_ID = 301 WHERE Student_ID = 201;
SELECT * FROM ORDER_TABLE;   -- Student_ID auto-updated to 301

-- ON DELETE CASCADE demonstration
DELETE FROM STUDENT WHERE Student_ID = 301;
SELECT * FROM ORDER_TABLE;   -- related order row auto-deleted

-- --------------------------------------------------------------
-- 7. TRUNCATE and DROP commands
-- --------------------------------------------------------------

SELECT * FROM ORDER_ITEM;

TRUNCATE TABLE PICKUP_TOKEN;
SELECT * FROM PICKUP_TOKEN;   -- Empty set, structure preserved

SHOW TABLES;
DROP TABLE PICKUP_TOKEN;
SHOW TABLES;   -- PICKUP_TOKEN permanently removed

-- ============================================================
-- Conclusion: Implemented PK, FK, UNIQUE, NOT NULL, CHECK, DEFAULT
-- constraints; demonstrated ALTER TABLE, cascading referential
-- integrity, and TRUNCATE vs DROP behaviour.
-- - REHITA.N, 2648543, 1 MSAIM
-- ============================================================
