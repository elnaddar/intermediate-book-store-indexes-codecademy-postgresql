-- Before you make any changes to a database and it’s tables, you should know what you are working with. Examine the indexes that already exist on the three tables customers, books and orders. There are indexes of note — books_author_idx and books_title_idx. We will get to their use soon, but for fun can you guess what we will be using them for? It also appears that an index is missing, can you figure out what it is?
SELECT *
FROM pg_indexes
WHERE tablename IN ('books', 'customers', 'orders');

-- # Partial Index
-- Your marketing team reaches out to you to request regular information on sales figures, but they are only interested in sales of greater than 18 units sold in an order to see if there would be a benefit in targeted marketing. They will need the customer_ids, and quantity ordered.

-- Perform an EXPLAIN ANALYZE when doing the SELECT function to get the information WHERE quantity > 18. Take note of how long this select statement took without an index.
EXPLAIN ANALYZE SELECT customer_id, quantity
FROM orders
WHERE quantity > 18;

-- Because we know they are only ever interested in orders where specifically more than 18 books were ordered we can build an index to improve the search time for this specific query.
CREATE INDEX orders_customer_id_quantity_gt_18_idx
ON orders(customer_id, quantity)
WHERE quantity > 18;

-- Don’t forget to always verify that your index is doing what you are trying to accomplish. Write your EXPLAIN ANALYZE query again, this time after your new index to compare the before and after of the impact of this query. Can you explain the change? As more orders are placed, would this difference become greater or less noticeable?
EXPLAIN ANALYZE SELECT customer_id, quantity
FROM orders
WHERE quantity > 18;

-- # Primary Key
-- At the start of the project, you were asked if you could find what index was missing. You may have noticed that the customers table is missing a primary key, and therefore its accompanying index. Let’s create that primary key now.
-- To check the effectiveness of this index, write a query that uses a WHERE clause targeting the primary key field. Run this query before and after creating the index. You can add EXPLAIN ANALYZE to these queries to see how long they take with and without the index. Make sure that these two queries are identical — you want to make sure you’re using the same measuring stick before and after the index is created.


-- Seq Scan on customers  (cost=0.00..2626.00 rows=1 width=76) (actual time=19.157..20.129 rows=1 loops=1)
-- Planning Time: 0.087 ms
-- Execution Time: 20.149 ms
EXPLAIN ANALYZE SELECT *
FROM customers
WHERE "customer_id" = 5000;

ALTER TABLE customers
ADD PRIMARY KEY(customer_id);

-- Index Scan using customers_pkey on customers  (cost=0.29..8.31 rows=1 width=76) (actual time=0.043..0.046 rows=1 loops=1)
-- Planning Time: 0.270 ms
-- Execution Time: 0.096 ms
EXPLAIN ANALYZE SELECT *
FROM customers
WHERE "customer_id" = 5000;

-- You might have noticed that when you got the top 10 records from the customers table that they weren’t in numerical order by customer_id. This was intentionally done to simulate a system that has experienced updates, deletes, inserts from a live system. Use your new primary key to fix this so the system is ordered in the database physically by customer_id.
-- To verify this worked, you can query the first 10 rows of the customers table again to see the table organized by the primary key.
SELECT * FROM customers LIMIT 10;

CLUSTER customers USING customers_pkey;

SELECT * FROM customers LIMIT 10;


-- # No secondary lookup
-- Regular searches are done on the combination of customer_id and book_id on the orders table. You have determined (through testing) that this would be a good candidate to build a multicolumn index on. Let’s build this index!
CREATE INDEX orders_customer_id_book_id_idx
ON orders(customer_id, book_id);

-- You notice that your queries using the index you just built are also regularly asking for the quantity ordered as well.Drop your previous index and recreate it to improve it for this new information.
-- Don’t forget you can test your query before and after creation to see its impact.

EXPLAIN ANALYZE
SELECT "customer_id", "book_id", quantity
FROM orders
WHERE quantity > 18;

DROP INDEX orders_customer_id_book_id_idx;
CREATE INDEX orders_customer_id_book_id_quantity_idx
ON orders(customer_id, book_id, quantity);

EXPLAIN ANALYZE
SELECT "customer_id", "book_id", quantity
FROM orders
WHERE quantity > 18;