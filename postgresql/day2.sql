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

