
CREATE DATABASE TechTraders_tgdb;
GO

Use TechTraders_tgdb;
GO

-----------------------------  CATEGORY  -------------------------------------------

CREATE TABLE category(
    category_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    name VARCHAR(80) NOT NULL
);

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

-----------------------------  Product_Cart  -------------------------------------------

CREATE TABLE product_cart (
    product_id INT NOT NULL,
    cart_id INT NOT NULL,
    quantity INT NOT NULL

    PRIMARY KEY (product_id, cart_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE,
    FOREIGN KEY (cart_id) REFERENCES cart(cart_id) ON DELETE CASCADE
);

-----------------------------  Cart  -------------------------------------------

CREATE TABLE cart (
    cart_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    user_id INT NOT NULL,
    CONSTRAINT FK_cart_users
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
);


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

-----------------------------  USERS  -------------------------------------------

CREATE TABLE users (
    user_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    email VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(80) NOT NULL,
);

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

-----------------------------  EMPLOYEE  -------------------------------------------

CREATE TABLE employee (
    user_id INT NOT NULL PRIMARY KEY,
    department VARCHAR(80) NOT NULL,

    CONSTRAINT FK_employees_users
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);

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

-----------------------------  audit  -------------------------------------------


CREATE TABLE audit_log (
    audit_id INT IDENTITY(1,1) PRIMARY KEY,
    method VARCHAR(10) NOT NULL,
    endpoint VARCHAR(255) NOT NULL,
    status_code INT NOT NULL,
    response_time_ms INT NOT NULL,
    ip_address VARCHAR(45) NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE()
);

SELECT * FROM audit_log
TRUNCATE TABLE audit_log

-----------------------------  query  -------------------------------------------

--Product query
SELECT
    p.product_id,
    p.name AS product_name,
    c.name AS category_name,
    p.price,
    p.quantity
FROM product p
INNER JOIN category c
    ON p.category_id = c.category_id;


--category query
SELECT
    p.name,
    p.price,
    p.quantity
FROM product p
INNER JOIN category c
    ON p.category_id = c.category_id
WHERE c.name = 'phones';


--customer query
SELECT
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    c.phone_number
FROM users u
INNER JOIN customers c
    ON u.user_id = c.user_id;


--revenue by product
SELECT
    p.name,
    SUM(po.quantity * po.order_price) AS revenue
FROM product p
INNER JOIN product_order po
    ON p.product_id = po.product_id
GROUP BY p.name
ORDER BY revenue DESC;

--monthly revenue
SELECT
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    SUM(order_amount) AS total_sales
FROM orders
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY year, month;

--products with <5 items
SELECT
    name,
    quantity
FROM product
WHERE quantity <= 5
ORDER BY quantity;