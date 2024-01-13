-- Before you make any changes to a database and it’s tables, you should know what you are working with. Examine the indexes that already exist on the three tables customers, books and orders. There are indexes of note — books_author_idx and books_title_idx. We will get to their use soon, but for fun can you guess what we will be using them for? It also appears that an index is missing, can you figure out what it is?
SELECT *
FROM pg_indexes
WHERE tablename IN ('books', 'customers', 'orders');