-- ============================================================
-- LAB - 4 : NORMALIZATION
-- Campus Canteen Management System (CCMS)
--
-- NOTE: the manual creates a `normalization_lab` database but then
-- switches back to `campusdb` to actually create the tables. Doing
-- that literally will collide with the USER/VENDOR/FOOD_ITEM/
-- ORDER_TABLE/ORDER_ITEM tables already created in campusdb by
-- Lab 3 ("table already exists" errors). This script fixes that by
-- actually using `normalization_lab` throughout, so the exercise
-- runs standalone without touching campusdb. Tested end-to-end.
-- ============================================================

-- --------------------------------------------------------------
-- Create and use a dedicated database for this exercise
-- --------------------------------------------------------------
DROP DATABASE IF EXISTS normalization_lab;
CREATE DATABASE normalization_lab;
USE normalization_lab;

-- --------------------------------------------------------------
-- Create the UNNORMALIZED table
-- --------------------------------------------------------------

CREATE TABLE ORDER_DETAILS_UN (
    Order_ID INT,
    User_ID INT,
    User_Name VARCHAR(100),
    User_Type VARCHAR(20),
    Vendor_ID INT,
    Vendor_Name VARCHAR(100),
    Item_ID INT,
    Item_Name VARCHAR(100),
    Quantity INT,
    Unit_Price DECIMAL(10,2),
    Total_Amount DECIMAL(10,2)
);

-- Insert sample data
INSERT INTO ORDER_DETAILS_UN VALUES
    (1,101,'Rahul','Student',1,'Campus Cafe',1,'Burger',2,80,160),
    (1,101,'Rahul','Student',1,'Campus Cafe',3,'Coffee',1,40,160),
    (2,102,'Priya','Faculty',2,'Food Court',2,'Pizza',1,150,150),
    (3,101,'Rahul','Student',2,'Food Court',4,'Sandwich',2,60,120);

-- Display the unnormalized table
SELECT * FROM ORDER_DETAILS_UN;

-- --------------------------------------------------------------
-- Create the NORMALIZED tables
-- --------------------------------------------------------------

CREATE TABLE USER (
    User_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    User_Type VARCHAR(20)
);

CREATE TABLE VENDOR (
    Vendor_ID INT PRIMARY KEY,
    Vendor_Name VARCHAR(100)
);

CREATE TABLE FOOD_ITEM (
    Item_ID INT PRIMARY KEY,
    Item_Name VARCHAR(100),
    Unit_Price DECIMAL(10,2)
);

CREATE TABLE ORDER_TABLE (
    Order_ID INT PRIMARY KEY,
    User_ID INT,
    Vendor_ID INT,
    Total_Amount DECIMAL(10,2),
    FOREIGN KEY (User_ID) REFERENCES USER(User_ID),
    FOREIGN KEY (Vendor_ID) REFERENCES VENDOR(Vendor_ID)
);

CREATE TABLE ORDER_ITEM (
    Order_ID INT,
    Item_ID INT,
    Quantity INT,
    PRIMARY KEY (Order_ID, Item_ID),
    FOREIGN KEY (Order_ID) REFERENCES ORDER_TABLE(Order_ID),
    FOREIGN KEY (Item_ID) REFERENCES FOOD_ITEM(Item_ID)
);

SHOW TABLES;

-- --------------------------------------------------------------
-- Insert normalized sample data
-- (parent tables first, so foreign keys resolve)
-- --------------------------------------------------------------

INSERT INTO USER VALUES (101,'Rahul','Student');
INSERT INTO USER VALUES (102,'Priya','Faculty');

INSERT INTO VENDOR VALUES (1,'Campus Cafe');
INSERT INTO VENDOR VALUES (2,'Food Court');

INSERT INTO FOOD_ITEM VALUES (1,'Burger',80.00);
INSERT INTO FOOD_ITEM VALUES (2,'Pizza',150.00);
INSERT INTO FOOD_ITEM VALUES (3,'Coffee',40.00);
INSERT INTO FOOD_ITEM VALUES (4,'Sandwich',60.00);

INSERT INTO ORDER_TABLE VALUES (1,101,1,160.00);
INSERT INTO ORDER_TABLE VALUES (2,102,2,150.00);
INSERT INTO ORDER_TABLE VALUES (3,101,2,120.00);

INSERT INTO ORDER_ITEM VALUES (1,1,2);
INSERT INTO ORDER_ITEM VALUES (1,3,1);
INSERT INTO ORDER_ITEM VALUES (2,2,1);
INSERT INTO ORDER_ITEM VALUES (3,4,2);

-- Display tables with inserted values
SELECT * FROM USER;
SELECT * FROM VENDOR;
SELECT * FROM FOOD_ITEM;
SELECT * FROM ORDER_TABLE;
SELECT * FROM ORDER_ITEM;

-- --------------------------------------------------------------
-- JOIN query across all normalized tables
-- --------------------------------------------------------------

SELECT
    U.Name,
    U.User_Type,
    V.Vendor_Name,
    F.Item_Name,
    OI.Quantity,
    F.Unit_Price,
    (OI.Quantity * F.Unit_Price) AS Subtotal,
    O.Total_Amount
FROM USER U
JOIN ORDER_TABLE O ON U.User_ID = O.User_ID
JOIN VENDOR V ON O.Vendor_ID = V.Vendor_ID
JOIN ORDER_ITEM OI ON O.Order_ID = OI.Order_ID
JOIN FOOD_ITEM F ON OI.Item_ID = F.Item_ID;

-- ============================================================
-- NOTES / THEORY (kept for documentation)
-- ============================================================

-- Primary Key of ORDER_DETAILS_UN:
--   (Order_ID, Item_ID)  -- composite, since one order has many items

-- Candidate Key:
--   (Order_ID, Item_ID)

-- Functional Dependencies:
--   Order_ID -> User_ID, Vendor_ID, Total_Amount
--   User_ID  -> User_Name, User_Type
--   Vendor_ID -> Vendor_Name
--   Item_ID  -> Item_Name, Unit_Price
--   (Order_ID, Item_ID) -> Quantity

-- Anomalies in ORDER_DETAILS_UN:
--   Update anomaly : vendor name change must be repeated in every row
--   Insert anomaly : cannot add a vendor/item without an order
--   Delete anomaly : deleting last order for a vendor loses vendor info

-- Normal Forms achieved:
--   1NF: all attributes atomic, no repeating groups
--   2NF: partial dependencies removed by splitting into
--        USER, VENDOR, FOOD_ITEM, ORDER_TABLE, ORDER_ITEM
--   3NF: transitive dependencies removed; every non-key attribute
--        depends only on its own table's primary key

-- Before vs After Normalization
-- One large table          -> Multiple related tables
-- High redundancy          -> Low redundancy
-- Update anomaly exists     -> Removed
-- Insert anomaly exists     -> Removed
-- Delete anomaly exists     -> Removed
-- Poor consistency         -> Better consistency
