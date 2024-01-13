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
