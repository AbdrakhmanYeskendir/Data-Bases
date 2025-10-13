-- Part 1: CHECK Constraints
-- Task 1.1
DROP TABLE IF EXISTS employees CASCADE;
CREATE TABLE employees (
employee_id integer,
first_name text,
last_name text,
age integer CHECK (age BETWEEN 18 AND 65),
salary numeric CHECK (salary > 0)
);

-- valid inserts
INSERT INTO employees VALUES (1, 'Alice', 'Ivanova', 25, 1500);
INSERT INTO employees VALUES (2, 'Bob', 'Petrov', 64, 3200);

-- invalid insert attempts (commented out)
-- Violates age CHECK: age < 18
-- INSERT INTO employees VALUES (3, 'Young', 'Kid', 16, 1000);
-- Violates age CHECK: age > 65
-- INSERT INTO employees VALUES (4, 'Old', 'Person', 70, 2000);
-- Violates salary CHECK: salary <= 0
-- INSERT INTO employees VALUES (5, 'Zero', 'Salary', 30, 0);

-- Task 1.2
DROP TABLE IF EXISTS products_catalog CASCADE;
CREATE TABLE products_catalog (
product_id integer,
product_name text,
regular_price numeric,
discount_price numeric,
CONSTRAINT valid_discount CHECK (
regular_price > 0
AND discount_price > 0
AND discount_price < regular_price
)
);

-- valid inserts
INSERT INTO products_catalog VALUES (1, 'Widget A', 100.00, 80.00);
INSERT INTO products_catalog VALUES (2, 'Widget B', 50.00, 25.00);

-- invalid insert attempts (commented out)
-- Violates valid_discount: regular_price <= 0
-- INSERT INTO products_catalog VALUES (3, 'Bad', 0, 0);
-- Violates valid_discount: discount_price <= 0
-- INSERT INTO products_catalog VALUES (4, 'Bad2', 20.00, 0);
-- Violates valid_discount: discount_price >= regular_price
-- INSERT INTO products_catalog VALUES (5, 'NoDisc', 30.00, 35.00);

-- Task 1.3
DROP TABLE IF EXISTS bookings CASCADE;
CREATE TABLE bookings (
booking_id integer,
check_in_date date,
check_out_date date,
num_guests integer CHECK (num_guests BETWEEN 1 AND 10),
CHECK (check_out_date > check_in_date)
);

-- valid inserts
INSERT INTO bookings VALUES (1, '2025-10-20', '2025-10-24', 2);
INSERT INTO bookings VALUES (2, '2025-11-01', '2025-11-02', 1);

-- invalid insert attempts (commented out)
-- Violates num_guests CHECK: num_guests < 1
-- INSERT INTO bookings VALUES (3, '2025-12-01', '2025-12-05', 0);
-- Violates num_guests CHECK: num_guests > 10
-- INSERT INTO bookings VALUES (4, '2025-12-10', '2025-12-15', 12);
-- Violates date CHECK: check_out_date <= check_in_date
-- INSERT INTO bookings VALUES (5, '2025-12-20', '2025-12-20', 2);

-- =========================
-- Part 2: NOT NULL Constraints
-- Task 2.1
DROP TABLE IF EXISTS customers CASCADE;
CREATE TABLE customers (
customer_id integer NOT NULL,
email text NOT NULL,
phone text,
registration_date date NOT NULL
);

-- valid inserts
INSERT INTO customers VALUES (1, 'alice@example.com
', '77001234567', '2025-01-10');
INSERT INTO customers VALUES (2, 'bob@example.com
', NULL, '2025-05-05');

-- invalid insert attempts (commented out)
-- Violates NOT NULL: customer_id IS NULL
-- INSERT INTO customers VALUES (NULL, 'x@example.com
', '77000000000', '2025-01-01');
-- Violates NOT NULL: email IS NULL
-- INSERT INTO customers VALUES (3, NULL, '77001112233', '2025-02-02');
-- Violates NOT NULL: registration_date IS NULL
-- INSERT INTO customers VALUES (4, 'c@example.com
', '77009998877', NULL);

-- Task 2.2
DROP TABLE IF EXISTS inventory CASCADE;
CREATE TABLE inventory (
item_id integer NOT NULL,
item_name text NOT NULL,
quantity integer NOT NULL CHECK (quantity >= 0),
unit_price numeric NOT NULL CHECK (unit_price > 0),
last_updated timestamp NOT NULL
);

-- valid inserts
INSERT INTO inventory VALUES (1, 'Screwdriver', 50, 5.99, now());
INSERT INTO inventory VALUES (2, 'Hammer', 20, 12.50, now());
INSERT INTO inventory VALUES (3, 'Nails Pack', 1000, 0.10, now());

-- invalid insert attempts (commented out)
-- Violates NOT NULL: item_name IS NULL
-- INSERT INTO inventory VALUES (4, NULL, 10, 1.00, now());
-- Violates CHECK: quantity < 0
-- INSERT INTO inventory VALUES (5, 'BadQty', -5, 2.00, now());
-- Violates CHECK: unit_price <= 0
-- INSERT INTO inventory VALUES (6, 'Free', 10, 0, now());

-- Task 2.3
-- (Nullable column examples already shown: phone in customers can be NULL)
-- valid insert with nullable phone
INSERT INTO customers VALUES (3, 'charlie@example.com
', NULL, '2025-06-01');

-- =========================
-- Part 3: UNIQUE Constraints
-- Task 3.1
DROP TABLE IF EXISTS users CASCADE;
CREATE TABLE users (
user_id integer,
username text UNIQUE,
email text UNIQUE,
created_at timestamp
);

-- valid inserts
INSERT INTO users VALUES (1, 'alice', 'alice@example.com
', now());
INSERT INTO users VALUES (2, 'bob', 'bob@example.com
', now());

-- invalid insert attempts (commented out)
-- Violates UNIQUE on username
-- INSERT INTO users VALUES (3, 'alice', 'alice2@example.com
', now());
-- Violates UNIQUE on email
-- INSERT INTO users VALUES (4, 'charlie', 'alice@example.com
', now());

-- Task 3.2
DROP TABLE IF EXISTS course_enrollments CASCADE;
CREATE TABLE course_enrollments (
enrollment_id integer,
student_id integer,
course_code text,
semester text,
CONSTRAINT unique_student_course_semester UNIQUE (student_id, course_code, semester)
);

-- valid inserts
INSERT INTO course_enrollments VALUES (1, 1001, 'CS101', 'Fall2025');
INSERT INTO course_enrollments VALUES (2, 1002, 'CS101', 'Fall2025');

-- invalid insert attempts (commented out)
-- Violates unique_student_course_semester (duplicate triple)
-- INSERT INTO course_enrollments VALUES (3, 1001, 'CS101', 'Fall2025');

-- Task 3.3 (Modify users to add named UNIQUE constraints)
DROP TABLE IF EXISTS users_modified CASCADE;
CREATE TABLE users_modified (
user_id integer,
username text,
email text,
created_at timestamp,
CONSTRAINT unique_username UNIQUE (username),
CONSTRAINT unique_email UNIQUE (email)
);

-- valid inserts
INSERT INTO users_modified VALUES (1, 'dmitry', 'dmitry@example.com
', now());
INSERT INTO users_modified VALUES (2, 'elena', 'elena@example.com
', now());

-- invalid insert attempts (commented out)
-- Violates unique_username
-- INSERT INTO users_modified VALUES (3, 'dmitry', 'dmitry2@example.com
', now());
-- Violates unique_email
-- INSERT INTO users_modified VALUES (4, 'olga', 'dmitry@example.com
', now());

-- =========================
-- Part 4: PRIMARY KEY Constraints
-- Task 4.1
DROP TABLE IF EXISTS departments CASCADE;
CREATE TABLE departments (
dept_id integer PRIMARY KEY,
dept_name text NOT NULL,
location text
);

-- valid inserts
INSERT INTO departments VALUES (1, 'HR', 'Almaty');
INSERT INTO departments VALUES (2, 'IT', 'Nur-Sultan');
INSERT INTO departments VALUES (3, 'Sales', 'Shymkent');

-- invalid insert attempts (commented out)
-- Violates PRIMARY KEY: duplicate dept_id
-- INSERT INTO departments VALUES (2, 'Support', 'Almaty');
-- Violates PRIMARY KEY: dept_id NULL
-- INSERT INTO departments VALUES (NULL, 'Temp', 'Nowhere');

-- Task 4.2
DROP TABLE IF EXISTS student_courses CASCADE;
CREATE TABLE student_courses (
student_id integer,
course_id integer,
enrollment_date date,
grade text,
PRIMARY KEY (student_id, course_id)
);

-- valid inserts
INSERT INTO student_courses VALUES (1001, 501, '2025-09-01', 'A');
INSERT INTO student_courses VALUES (1002, 501, '2025-09-01', 'B');

-- invalid insert attempts (commented out)
-- Violates PRIMARY KEY (duplicate pair student_id, course_id)
-- INSERT INTO student_courses VALUES (1001, 501, '2025-09-02', 'A+');

-- Task 4.3
-- (Comparison exercise: explanation requested in lab — omitted here per user's minimal comments requirement)

-- =========================
-- Part 5: FOREIGN KEY Constraints
-- Task 5.1
DROP TABLE IF EXISTS employees_dept CASCADE;
CREATE TABLE employees_dept (
emp_id integer PRIMARY KEY,
emp_name text NOT NULL,
dept_id integer REFERENCES departments(dept_id),
hire_date date
);

-- valid insert: existing dept_id
INSERT INTO employees_dept VALUES (1, 'Safi', 2, '2025-03-10');
INSERT INTO employees_dept VALUES (2, 'Maya', 1, '2025-04-15');

-- invalid insert attempts (commented out)
-- Violates FK: dept_id 999 does not exist in departments
-- INSERT INTO employees_dept VALUES (3, 'NoDept', 999, '2025-05-01');

-- Task 5.2 Library schema
DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS authors CASCADE;
DROP TABLE IF EXISTS publishers CASCADE;

CREATE TABLE authors (
author_id integer PRIMARY KEY,
author_name text NOT NULL,
country text
);

CREATE TABLE publishers (
publisher_id integer PRIMARY KEY,
publisher_name text NOT NULL,
city text
);

CREATE TABLE books (
book_id integer PRIMARY KEY,
title text NOT NULL,
author_id integer REFERENCES authors(author_id),
publisher_id integer REFERENCES publishers(publisher_id),
publication_year integer,
isbn text UNIQUE
);

-- sample data inserts
INSERT INTO authors VALUES (1, 'A. Pushkin', 'Russia');
INSERT INTO authors VALUES (2, 'J. Austen', 'UK');
INSERT INTO authors VALUES (3, 'F. Dostoevsky', 'Russia');

INSERT INTO publishers VALUES (1, 'Penguin', 'London');
INSERT INTO publishers VALUES (2, 'O'Reilly', 'Sebastopol');
INSERT INTO publishers VALUES (3, 'KazakhPub', 'Almaty');

INSERT INTO books VALUES (1, 'Eugene Onegin', 1, 1, 1833, '978-1-23456-000-1');
INSERT INTO books VALUES (2, 'Pride and Prejudice', 2, 1, 1813, '978-1-23456-000-2');
INSERT INTO books VALUES (3, 'Crime and Punishment', 3, 3, 1866, '978-1-23456-000-3');

-- Task 5.3 ON DELETE options
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products_fk CASCADE;
DROP TABLE IF EXISTS categories CASCADE;

CREATE TABLE categories (
category_id integer PRIMARY KEY,
category_name text NOT NULL
);

CREATE TABLE products_fk (
product_id integer PRIMARY KEY,
product_name text NOT NULL,
category_id integer REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE orders (
order_id integer PRIMARY KEY,
order_date date NOT NULL
);

CREATE TABLE order_items (
item_id integer PRIMARY KEY,
order_id integer REFERENCES orders(order_id) ON DELETE CASCADE,
product_id integer REFERENCES products_fk(product_id),
quantity integer CHECK (quantity > 0)
);

-- sample inserts
INSERT INTO categories VALUES (1, 'Electronics');
INSERT INTO categories VALUES (2, 'Books');

INSERT INTO products_fk VALUES (10, 'Headphones', 1);
INSERT INTO products_fk VALUES (11, 'Novel', 2);

INSERT INTO orders VALUES (100, '2025-09-10');
INSERT INTO order_items VALUES (1000, 100, 10, 2);
INSERT INTO order_items VALUES (1001, 100, 11, 1);

-- Test cases (commented):
-- 1) Try to delete a category that has products (should fail due to RESTRICT)
-- DELETE FROM categories WHERE category_id = 1; -- expected: error, RESTRICT prevents delete
-- 2) Delete an order and observe order_items deleted automatically (CASCADE)
-- DELETE FROM orders WHERE order_id = 100; -- expected: order_items with order_id=100 removed

-- =========================
-- Part 6: Practical Application (E-commerce)
-- Task 6.1
DROP TABLE IF EXISTS order_details CASCADE;
DROP TABLE IF EXISTS orders_ecom CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers_ecom CASCADE;

CREATE TABLE customers_ecom (
customer_id integer PRIMARY KEY,
name text NOT NULL,
email text NOT NULL UNIQUE,
phone text,
registration_date date NOT NULL
);

CREATE TABLE products (
product_id integer PRIMARY KEY,
name text NOT NULL,
description text,
price numeric NOT NULL CHECK (price >= 0),
stock_quantity integer NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE orders_ecom (
order_id integer PRIMARY KEY,
customer_id integer REFERENCES customers_ecom(customer_id) ON DELETE SET NULL,
order_date date NOT NULL,
total_amount numeric NOT NULL CHECK (total_amount >= 0),
status text NOT NULL CHECK (status IN ('pending','processing','shipped','delivered','cancelled'))
);

CREATE TABLE order_details (
order_detail_id integer PRIMARY KEY,
order_id integer REFERENCES orders_ecom(order_id) ON DELETE CASCADE,
product_id integer REFERENCES products(product_id),
quantity integer NOT NULL CHECK (quantity > 0),
unit_price numeric NOT NULL CHECK (unit_price >= 0)
);

-- sample data: customers (at least 5)
INSERT INTO customers_ecom VALUES (1, 'Customer A', 'a@shop.com
', '77001112233', '2025-01-01');
INSERT INTO customers_ecom VALUES (2, 'Customer B', 'b@shop.com
', '77002223344', '2025-02-02');
INSERT INTO customers_ecom VALUES (3, 'Customer C', 'c@shop.com
', NULL, '2025-03-03');
INSERT INTO customers_ecom VALUES (4, 'Customer D', 'd@shop.com
', '77003334455', '2025-04-04');
INSERT INTO customers_ecom VALUES (5, 'Customer E', 'e@shop.com
', '77004445566', '2025-05-05');

-- sample data: products (at least 5)
INSERT INTO products VALUES (101, 'Laptop', 'Gaming laptop', 1200.00, 10);
INSERT INTO products VALUES (102, 'Mouse', 'Wireless mouse', 25.50, 200);
INSERT INTO products VALUES (103, 'Keyboard', 'Mechanical', 75.00, 150);
INSERT INTO products VALUES (104, 'Monitor', '27 inch', 300.00, 20);
INSERT INTO products VALUES (105, 'USB Cable', '1m cable', 2.50, 500);

-- sample data: orders (at least 5)
INSERT INTO orders_ecom VALUES (1001, 1, '2025-09-01', 1275.50, 'pending');
INSERT INTO orders_ecom VALUES (1002, 2, '2025-09-02', 300.00, 'processing');
INSERT INTO orders_ecom VALUES (1003, 3, '2025-09-03', 25.50, 'shipped');
INSERT INTO orders_ecom VALUES (1004, 4, '2025-09-04', 1200.00, 'delivered');
INSERT INTO orders_ecom VALUES (1005, 5, '2025-09-05', 77.50, 'cancelled');

-- sample data: order_details (at least 5)
INSERT INTO order_details VALUES (5001, 1001, 101, 1, 1200.00);
INSERT INTO order_details VALUES (5002, 1001, 102, 1, 25.50);
INSERT INTO order_details VALUES (5003, 1002, 104, 1, 300.00);
INSERT INTO order_details VALUES (5004, 1003, 102, 1, 25.50);
INSERT INTO order_details VALUES (5005, 1004, 101, 1, 1200.00);

-- Test queries demonstrating constraints (examples; failed attempts commented out)

-- UNIQUE constraint on customer email: duplicate email attempt
-- INSERT INTO customers_ecom VALUES (6, 'Dup', 'a@shop.com
', '77009990000', '2025-06-06'); -- expected: violation unique

-- CHECK price non-negative: negative price attempt
-- INSERT INTO products VALUES (106, 'BadPrice', 'x', -5.00, 10); -- expected: violation CHECK price >= 0

-- CHECK stock_quantity non-negative
-- INSERT INTO products VALUES (107, 'BadStock', 'x', 10.00, -1); -- expected: violation CHECK stock_quantity >= 0

-- CHECK order status allowed values
-- INSERT INTO orders_ecom VALUES (1006, 1, '2025-09-06', 10.00, 'unknown'); -- expected: violation CHECK status IN (...)

-- CHECK quantity in order_details positive
-- INSERT INTO order_details VALUES (5006, 1001, 102, 0, 25.50); -- expected: violation CHECK quantity > 0

-- FOREIGN KEY behavior: deleting customer referenced by orders_ecom (ON DELETE SET NULL)
-- DELETE FROM customers_ecom WHERE customer_id = 1; -- expected: orders_ecom.customer_id for orders of customer 1 set to NULL

-- FOREIGN KEY behavior: deleting an order cascades to order_details
-- DELETE FROM orders_ecom WHERE order_id = 1002; -- expected: corresponding order_details rows removed