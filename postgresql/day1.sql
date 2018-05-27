-- 1. Select all the tables we created (and only those) from pg_class and examine the table to get a sense of what kinds of metadata Postgres stores about tables.
SELECT * FROM pg_class WHERE relnamespace = 2200;
-- with the above I had to fish around for the relnamespace value first. Not quite sure if that's what the author was looking for.
-- Also can get some table info from this query:
SELECT * FROM pg_tables WHERE schemaname = 'public';

-- 2. Write a query that finds the country name of the Fight Club event.
SELECT c.country_name FROM events e JOIN venues v ON v.venue_id = e.venue_id JOIN countries c ON c.country_code = v.country_code WHERE e.title = 'Fight Club';

-- 3. Alter the venues table such that it contains a Boolean column called active with a default value of TRUE.
ALTER TABLE venues ADD active boolean DEFAULT true;
