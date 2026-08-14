CREATE DATABASE IF NOT EXISTS returns_project;
USE returns_project;

DROP TABLE IF EXISTS orders_returns;

CREATE TABLE orders_returns (
    Order_ID                VARCHAR(20),
    Customer_ID              VARCHAR(20),
    Order_Date                DATE,
    Ship_Date                 DATE,
    Estimated_Delivery_Date   DATE,
    Actual_Delivery_Date      DATE,
    Ship_Mode                 VARCHAR(30),
    Region                    VARCHAR(20),
    City                      VARCHAR(50),
    Category                  VARCHAR(30),
    Sub_Category               VARCHAR(30),
    Sales                     DECIMAL(10,2),
    Quantity                  INT,
    Discount                  DECIMAL(4,2),
    Profit                    DECIMAL(10,2),
    Shipping_Cost              DECIMAL(10,2),
    Return_Reason              VARCHAR(50),
    Return_Date                DATE,
    Refund_Amount               DECIMAL(10,2),
    Return_Status              VARCHAR(3),
    Return_Processing_Time      INT,
    Delivery_Delay_Days         INT,
    Was_Late                  TINYINT(1),
    PRIMARY KEY (Order_ID),
    INDEX idx_category (Category),
    INDEX idx_customer (Customer_ID),
    INDEX idx_return_status (Return_Status)
);