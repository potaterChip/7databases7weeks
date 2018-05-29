-- Below are most of the queries ran before I got to the "homework"

INSERT INTO countries VALUES ('we', 'Westeros');
INSERT INTO cities VALUES ('Winterfell', '666666', 'we');
INSERT INTO venues(name, street_address, type, postal_code, country_code) VALUES ('Torture Chamber', '12 steps to the left', 'private', '666666', 'we');

INSERT INTO events(title, starts, ends, venue_id) VALUES('Wedding', '2018-02-26 21:00:00', '2018-02-26 23:00:00', 2);
INSERT INTO events(title, starts, ends, venue_id) VALUES('Dinner with Mom', '2018-02-26 18:00:00', '2018-02-26 20:30:00', 3);
INSERT INTO events(title, starts, ends) VALUES('Valentines''s Day', '2018-02-14 00:00:00', '2018-02-14 23:59:00');

-- Running the "add_event" SP, notice the postal_code is different from the book because I still have that old postal code
SELECT add_event('House Party', '2018-05-03 23:00', '2018-05-04 02:00', 'Run''s House', '87200', 'us');

CREATE TABLE logs(
event_id integer,
old_title varchar(255),
old_starts timestamp,
old_ends timestamp,
logged_at timestamp DEFAULT current_timestamp
);

CREATE OR REPLACE FUNCTION log_event() RETURNS trigger AS $$
DECLARE
BEGIN
INSERT INTO logs(event_id, old_title, old_starts, old_ends)
VALUES (OLD.event_id, OLD.title, OLD.starts, OLD.ends);
RAISE NOTICE 'Someone just changed event #%', OLD.event_id;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_events AFTER UPDATE ON events FOR EACH ROW EXECUTE PROCEDURE log_event();


-- ** HOMEWORK **
-- 1. Create a rule that captures DELETEs on venues and instead sets the active flag (created in the Day 1 homework) to FALSE
CREATE RULE delete_venues AS ON DELETE TO venues DO INSTEAD
UPDATE venues
SET active = false
WHERE venue_id = OLD.venue_id;

-- *** To get #2 to work, I had to run the statement below to enable the crosstab function. May have missed this
--     somewhere in the text, but I don't think so
-- ***
CREATE EXTENSION tablefunc;

-- 2. A temporary table was not the best way to implement our event calendar pivot table. The generate_series(a, b) function returns a set of records, from a to b. Replace the month_count table SELECT with this.
SELECT * FROM crosstab(
'SELECT extract(year from starts) as year,
extract(month from starts) as month, count(*)
FROM events
GROUP BY year, month
ORDER BY year, month',
'select month from generate_series(1,12) as s(month)'
) AS (
year int,
jan int, feb int, mar int, apr int, may int, jun int, jul int, aug int, sep int, oct int, nov int, dec int
) ORDER BY YEAR;

-- 3. Build a pivot table that displays every day in a single month, where each week of the month is a row and each day name forms a column across the top (seven days, starting with Sunday and ending with Saturday) like a standard month calendar. Each day should contain a count of the number of events for that date or should remain blank if no event occurs.

-- ** This one might be more complicated than what it needs to be, and possibly because I'm just missing some postgresql functions,
--    but this is what I came up with. Use the generate_series function again to build a temporary list of days for
--    the month. I hard coded in february because that has the most events as far as my data goes. Left join it on
--    events so you still get a list of days without events. Use the extract function for week to use as the row id. The value from extracting
--    the week is the week number of the year, and the documentation says even this can be iffy when it comes to the first week of
--    the year or the last week of the year (i.e. 2019/1/1 could potentially return that as week 55 or whatever of 2018).
--    It also results in an ugly id column. I suppose I could go further in selecting from the pivot table to clean up
--    the results, but for now I get a result that looks like this:
--     week | sunday | monday | tuesday | wednesday | thursday | friday | saturday
    -- ------+--------+--------+---------+-----------+----------+--------+----------
    --     5 |        |        |         |           |          |        |
    --     6 |        |        |         |           |          |        |
    --     7 |        |        |         |         1 |        2 |        |
    --     8 |        |        |         |           |          |        |
    --     9 |        |      2 |         |           |          |        |
    -- (5 rows)

SELECT * FROM crosstab(
'SELECT extract(week from day_of_month) as week, extract(dow from day_of_month) AS day_of_week, NULLIF(count(events.starts), 0)
FROM generate_series(''2018-02-01'', ''2018-02-28'', ''1 day''::interval) AS s(day_of_month)
LEFT JOIN events ON s.day_of_month = events.starts::date
GROUP BY week, day_of_week, events.starts::date
ORDER BY week, day_of_week',
'select day_of_week from generate_series(0,6) as s(day_of_week)'
) AS (
  week int,
  Sunday int, Monday int, Tuesday int, Wednesday int, Thursday int, Friday int, Saturday int
) ORDER BY week;