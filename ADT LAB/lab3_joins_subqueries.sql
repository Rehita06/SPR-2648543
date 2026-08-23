-- ============================================================
-- LAB - 3 : JOINS AND SUBQUERIES
-- Campus Canteen Management System (CCMS)
--
-- NOTE ON SCHEMA: from this lab onward the manual switches from the
-- STUDENT/Student_ID naming used in Lab 2 to a USER/User_ID naming
-- (and adds a QR_Code column to ORDER_TABLE). That migration step was
-- never shown in the manual, so this script recreates the tables it
-- needs from scratch with sample data that reproduces the exact
-- row counts/values shown in the manual's screenshots. Tested
-- end-to-end on MariaDB 10.11 / MySQL-compatible syntax.
-- ============================================================

USE campusdb;

-- --------------------------------------------------------------
-- Self-contained schema + sample data (safe to re-run)
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
);

CREATE TABLE VENDOR (
    Vendor_ID INT PRIMARY KEY,
    Vendor_Name VARCHAR(50) NOT NULL,
    Contact_No VARCHAR(15) UNIQUE NOT NULL,
    Opening_Time TIME NOT NULL,
    Closing_Time TIME NOT NULL,
    Location VARCHAR(100) NOT NULL
);

CREATE TABLE FOOD_ITEM (
    Item_ID INT PRIMARY KEY,
    Item_Name VARCHAR(50) NOT NULL,
    Price DECIMAL(8,2) NOT NULL,
    Prep_Time INT DEFAULT 10,
    Availability_Status VARCHAR(20) DEFAULT 'Available'
);

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
);

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
);

INSERT INTO USER VALUES
    (101,'RAHUL','rahul@gmail.com','9876543210','Student'),
    (102,'Priya','priya@gmail.com','9876543211','Faculty'),
    (103,'Anil','anil@gmail.com','9876543212','Staff'),
    (104,'Sneha','sneha@gmail.com','9876543213','Guest');

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
    (3,101,2,'2025-07-01 12:00:00','2025-07-01 12:30:00','2025-07-01 12:25:00','Collected',230.00,'QR003');

INSERT INTO ORDER_ITEM VALUES
    (1,1,1,1,80.00,80.00),   -- Order 1: Burger
    (2,1,3,1,40.00,40.00),   -- Order 1: Coffee
    (3,2,2,1,150.00,150.00), -- Order 2: Pizza
    (4,2,3,1,40.00,40.00),   -- Order 2: Coffee
    (5,3,2,1,150.00,150.00), -- Order 3: Pizza
    (6,3,4,1,80.00,80.00);   -- Order 3: Sandwich

-- --------------------------------------------------------------
-- PART A : JOINS
-- --------------------------------------------------------------

-- INNER JOIN
SELECT
    U.Name,
    V.Vendor_Name,
    O.Order_ID,
    O.Order_Status,
    O.Total_Amount
FROM USER U
INNER JOIN ORDER_TABLE O
    ON U.User_ID = O.User_ID
INNER JOIN VENDOR V
    ON O.Vendor_ID = V.Vendor_ID;

-- LEFT JOIN
SELECT
    U.User_ID,
    U.Name,
    O.Order_ID,
    O.Order_Status
FROM USER U
LEFT JOIN ORDER_TABLE O
    ON U.User_ID = O.User_ID;

-- RIGHT JOIN
SELECT
    U.Name,
    O.Order_ID,
    O.Total_Amount
FROM USER U
RIGHT JOIN ORDER_TABLE O
    ON U.User_ID = O.User_ID;

-- FULL OUTER JOIN (emulated via UNION of LEFT + RIGHT JOIN,
-- since MySQL/MariaDB have no native FULL OUTER JOIN)
SELECT
    U.User_ID,
    U.Name,
    O.Order_ID
FROM USER U
LEFT JOIN ORDER_TABLE O
    ON U.User_ID = O.User_ID

UNION

SELECT
    U.User_ID,
    U.Name,
    O.Order_ID
FROM USER U
RIGHT JOIN ORDER_TABLE O
    ON U.User_ID = O.User_ID;

-- --------------------------------------------------------------
-- PART B : SUBQUERIES
-- --------------------------------------------------------------

-- Subquery 1: Users who have placed at least one order
SELECT *
FROM USER
WHERE User_ID IN (
    SELECT User_ID
    FROM ORDER_TABLE
);

-- Subquery 2: Users who have NOT placed any order
SELECT *
FROM USER
WHERE User_ID NOT IN (
    SELECT User_ID
    FROM ORDER_TABLE
);

-- Subquery 3: Food items priced above the average price of all menu items
SELECT * FROM FOOD_ITEM
WHERE Price > (SELECT AVG(Price) FROM FOOD_ITEM);

-- Subquery 4: Order with the highest total bill amount
SELECT *
FROM ORDER_TABLE
WHERE Total_Amount = (
    SELECT MAX(Total_Amount)
    FROM ORDER_TABLE
);

-- Subquery 4 (contd.): Vendors who have received at least one order
SELECT *
FROM VENDOR
WHERE Vendor_ID IN (
    SELECT Vendor_ID
    FROM ORDER_TABLE
);

-- --------------------------------------------------------------
-- PART C : CORRELATED QUERIES
-- --------------------------------------------------------------

-- Correlated Query 1: Orders whose total amount is greater than
-- the average order amount of the SAME user
SELECT *
FROM ORDER_TABLE O1
WHERE Total_Amount > (
    SELECT AVG(Total_Amount)
    FROM ORDER_TABLE O2
    WHERE O1.User_ID = O2.User_ID
);

-- Correlated Query 2: Users whose total spending is greater than
-- the average order amount across ALL orders
SELECT DISTINCT U.Name, O.User_ID
FROM USER U
JOIN ORDER_TABLE O
    ON U.User_ID = O.User_ID
WHERE
    (SELECT SUM(Total_Amount)
     FROM ORDER_TABLE O2
     WHERE O.User_ID = O2.User_ID)
    >
    (SELECT AVG(Total_Amount)
     FROM ORDER_TABLE);

-- --------------------------------------------------------------
-- Complete order details: user, vendor, menu items, quantity,
-- subtotal, and total order amount
-- --------------------------------------------------------------

SELECT
    U.User_ID,
    U.Name,
    U.User_Type,
    V.Vendor_Name,
    O.Order_ID,
    O.Order_Status,
    F.Item_Name,
    OI.Quantity,
    OI.Unit_Price,
    OI.Subtotal,
    O.Total_Amount
FROM USER U
JOIN ORDER_TABLE O
    ON U.User_ID = O.User_ID
JOIN VENDOR V
    ON O.Vendor_ID = V.Vendor_ID
JOIN ORDER_ITEM OI
    ON O.Order_ID = OI.Order_ID
JOIN FOOD_ITEM F
    ON OI.Item_ID = F.Item_ID;

-- ============================================================
-- JOIN Type reference
-- INNER JOIN      : matching records in both tables only
-- LEFT JOIN       : all left records + matches from right (NULLs otherwise)
-- RIGHT JOIN      : all right records + matches from left (NULLs otherwise)
-- FULL OUTER JOIN : all records from both, emulated via UNION of
--                   LEFT JOIN and RIGHT JOIN in MySQL/MariaDB
-- ============================================================
