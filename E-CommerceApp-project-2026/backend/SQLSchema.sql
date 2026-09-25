
CREATE DATABASE TechTraders_tgdb;
GO

Use TechTraders_tgdb;
GO

-----------------------------  CATEGORY  -------------------------------------------

CREATE TABLE category(
    category_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    name VARCHAR(80) NOT NULL
);


INSERT INTO category (Name)
VALUES
    ('smart devices'),
    ('photography'),
    ('appliances'),
    ('automotive'),
    ('cables and adapters'),
    ('other')

;

SELECT * FROM category;

-----------------------------  PRODUCT  -------------------------------------------

CREATE TABLE product(
    product_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    name VARCHAR(80) NOT NULL,
    description VARCHAR(500) NOT NULL,
    price FLOAT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    category_id INT NOT NULL,
    CONSTRAINT FK_products_categories
        FOREIGN KEY (category_id)
        REFERENCES category(category_id)
);

INSERT INTO product (Name, description ,price, image_url, category_id)
VALUES
    ('Iphone 13 pro', 'Where innovation meets expectation', 16000, 'https://images.frandroid.com/wp-content/uploads/2021/09/apple-iphone-13-pro-frandroid-2021.png', 1);

SELECT * FROM product;



-----------------------------  Product_Cart  -------------------------------------------

CREATE TABLE product_cart (
    product_id INT NOT NULL,
    cart_id INT NOT NULL,
    quantity INT NOT NULL

    PRIMARY KEY (product_id, cart_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE,
    FOREIGN KEY (cart_id) REFERENCES cart(cart_id) ON DELETE CASCADE
);
SELECT * FROM product_cart

INSERT INTO product_cart(product_id, cart_id, quantity)
VALUES
    (1, 1, 1);


-----------------------------  Cart  -------------------------------------------

CREATE TABLE cart (
    cart_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    user_id INT NOT NULL,
    CONSTRAINT FK_cart_users
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
);

INSERT INTO cart(user_id)
VALUES
    (1);

select * FROM cart;


-----------------------------  Cart related  -------------------------------------------
select * FROM cart;
SELECT * FROM product_cart
SELECT * FROM product;

-----------------------------  Product_Order  -------------------------------------------

CREATE TABLE product_order (
    product_id INT NOT NULL,
    order_id INT NOT NULL,
    order_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,

    PRIMARY KEY (product_id, order_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);
SELECT * FROM product_order

-----------------------------  Order  -------------------------------------------

CREATE TABLE orders (
    order_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    user_id INT NOT NULL,
    address_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT GETDATE(),
    order_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Pending',

    CONSTRAINT FK_orders_users
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    CONSTRAINT FK_orders_address
        FOREIGN KEY (address_id)
        REFERENCES address(address_id)
);


ALTER TABLE orders
ADD address_id INT NOT NULL;

ALTER TABLE orders
ADD CONSTRAINT FK_orders_address
    FOREIGN KEY (address_id)
    REFERENCES address(address_id);


Select * from orders
Select * from product_order


-----------------------------  USERS  -------------------------------------------

CREATE TABLE users (
    user_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    email VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(80) NOT NULL,
);

SELECT * FROM users
SELECT * FROM product_cart
select * FROM cart

-----------------------------  CUSTOMERS  -------------------------------------------

CREATE TABLE customers (
    user_id INT NOT NULL PRIMARY KEY,
    phone_number VARCHAR(20) NOT NULL,
    --address VARCHAR(255) NOT NULL,

    CONSTRAINT FK_customers_users
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);
SELECT
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    c.phone_number
FROM users u
INNER JOIN customers c
    ON u.user_id = c.user_id;

-----------------------------  EMPLOYEE  -------------------------------------------

CREATE TABLE employee (
    user_id INT NOT NULL PRIMARY KEY,
    department VARCHAR(80) NOT NULL,

    CONSTRAINT FK_employees_users
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);
SELECT
    u.user_id,
    u.name,
    u.email,
    e.department
FROM users u
INNER JOIN employee e
    ON u.user_id = e.user_id;


ALTER TABLE customers
DROP COLUMN address;

    drop table employee
    drop table customers
    drop table users
    drop table cart
    drop table orders
    drop table product_cart
    drop table product_order


    -----------------------------  Address  -------------------------------------------

    CREATE TABLE address (
    address_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    user_id INT NOT NULL,
    address_line_1 VARCHAR(50) NOT NULL,
    address_line_2 VARCHAR(50) NOT NULL,
    city VARCHAR(80) NOT NULL,
    province VARCHAR(80) NOT NULL,
    postal_code VARCHAR(10) NOT NULL,

    CONSTRAINT FK_address_customers
        FOREIGN KEY (user_id)
        REFERENCES customers(user_id)
        ON DELETE CASCADE
);

SELECT * FROM Address


-----------------------------  audit  -------------------------------------------


CREATE TABLE audit_log (
    audit_id INT IDENTITY(1,1) PRIMARY KEY,

    user_id INT NULL,

    method VARCHAR(10) NOT NULL,
    endpoint VARCHAR(255) NOT NULL,

    status_code INT NOT NULL,
    response_time_ms INT NOT NULL,

    ip_address VARCHAR(45) NULL,

    created_at DATETIME2 NOT NULL DEFAULT GETDATE()
);

SELECT * FROM audit_log
TRUNCATE TABLE audit_log
