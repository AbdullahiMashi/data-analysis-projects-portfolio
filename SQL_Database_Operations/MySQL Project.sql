use world;
CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(255),
    author VARCHAR(255),  
    price DECIMAL(10, 2)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255),
    address VARCHAR(255)
);


CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    book_id INT,
    quantity INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_date DATE,
    amount DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

INSERT INTO books (book_id, title, author, price) VALUES (1, 'Book 1', 'Author 1', 10.99), (2, 'Book 2', 'Author 2', 12.99), (3, 'Book 3', 'Author 3', 9.99), (4, 'Book 4', 'Author 4', 15.99), (5, 'Book 5', 'Author 5', 8.99);

INSERT INTO customers (customer_id, name, email, address) VALUES (1, 'Customer 1', 'customer1@example.com', 'Address 1'), (2, 'Customer 2', 'customer2@example.com', 'Address 2'), (3, 'Customer 3', 'customer3@example.com', 'Address 3'), (4, 'Customer 4', 'customer4@example.com', 'Address 4'), (5, 'Customer 5', 'customer5@example.com', 'Address 5');

INSERT INTO orders (order_id, customer_id, book_id, quantity, order_date) VALUES (1, 1, 1, 2, '2023-06-01'), (2, 2, 3, 1, '2023-06-02'), (3, 3, 2, 3, '2023-06-03'), (4, 4, 4, 2, '2023-06-04'), (5, 5, 5, 1, '2023-06-05');

INSERT INTO payments (payment_id, order_id, payment_date, amount) VALUES (1, 1, '2023-06-02', 21.98), (2, 2, '2023-06-03', 9.99), (3, 3, '2023-06-04', 38.97), (4, 4, '2023-06-05', 31.98), (5, 5, '2023-06-06', 8.99);

SELECT DATABASE();

-- Retrieve the details of all the customers
SELECT * FROM customers;

-- Retrieve the title and authors of all books
SELECT title, author FROM books;

-- Retrieve the total number of books sold     
SELECT SUM(quantity) AS TotalBooksSold FROM orders;

-- Show the names of all the customers who have placed orders
SELECT DISTINCT c.name FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;

 -- What is the total revenue generated from book sales? 
SELECT SUM(amount) AS TotalRevenue FROM payments;

 -- Which customer made the highest payment?
SELECT
    c.name,
    p.amount AS HighestPayment
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
ORDER BY HighestPayment DESC
LIMIT 1;

-- Which book has the highest price? 
SELECT title, price
FROM books
ORDER BY price DESC
LIMIT 1;

-- How many books were sold to each customer?    
SELECT
    c.name,
    SUM(o.quantity) AS TotalBooksPurchased
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.name
ORDER BY TotalBooksPurchased DESC;

-- Which customer has made the most orders?
SELECT
    c.name,
    COUNT(o.order_id) AS TotalOrders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.name
ORDER BY TotalOrders DESC
LIMIT 1;

-- Show the names of customers who have not placed any orders.
SELECT c.name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- Create an audit table to log trigger actions
CREATE TABLE book_audit_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT,
    action_type VARCHAR(50),
    action_detail VARCHAR(255),
    action_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Triggers
-- 1: AFTER INSERT (Logs a new book addition)
DELIMITER //
CREATE TRIGGER after_book_insert
AFTER INSERT ON books
FOR EACH ROW
BEGIN
    INSERT INTO book_audit_log (book_id, action_type, action_detail)
    VALUES (NEW.book_id, 'INSERT', CONCAT('New book added: ', NEW.title));
END //
DELIMITER ;

-- 2: BEFORE UPDATE (Logs a price change before it happens)
DELIMITER //
CREATE TRIGGER before_book_update
BEFORE UPDATE ON books
FOR EACH ROW
BEGIN
    IF OLD.price <> NEW.price THEN
        INSERT INTO book_audit_log (book_id, action_type, action_detail)
        VALUES (OLD.book_id, 'UPDATE', CONCAT('Price changed from ', OLD.price, ' to ', NEW.price));
    END IF;
END //
DELIMITER ;

-- 3: AFTER DELETE (Logs the deletion of a book)
DELIMITER //
CREATE TRIGGER after_book_delete
AFTER DELETE ON books
FOR EACH ROW
BEGIN
    INSERT INTO book_audit_log (book_id, action_type, action_detail)
    VALUES (OLD.book_id, 'DELETE', CONCAT('Book deleted: ', OLD.title));
END //
DELIMITER ;

-- (Stored Procedures) Procedure to calculate the total price of a customer's single order
DELIMITER //
CREATE PROCEDURE CalculateOrderTotal (IN orderID INT, OUT totalAmount DECIMAL(10, 2))
BEGIN
    SELECT SUM(b.price * o.quantity) INTO totalAmount
    FROM orders o
    JOIN books b ON o.book_id = b.book_id
    WHERE o.order_id = orderID;
END //
DELIMITER ;

-- Create new user
CREATE USER 'data_analyst'@'localhost' IDENTIFIED BY 'Project1234';

-- Grant Privileges to the New User
GRANT SELECT, INSERT, ALTER ON bookstore.* TO 'data_analyst'@'localhost';

FLUSH PRIVILEGES;



-- Backup the 'world' database
-- mysqldump -u root -p world > world_backup.sql;

-- Restore the 'world' database
-- mysql -u root -p world < world_backup.sql;

