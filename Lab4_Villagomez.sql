CREATE TABLE Location (
location_id DECIMAL(12) NOT NULL PRIMARY KEY,
location_name VARCHAR(64) NOT NULL
);

CREATE TABLE dig_site (
dig_site_id DECIMAL(12) NOT NULL PRIMARY KEY,
location_id DECIMAL(12) NOT NULL,
dig_name VARCHAR(32) NOT NULL,
dig_cost DECIMAL(8,2) NULL,

CONSTRAINT location_id_fk
FOREIGN KEY (location_id)
REFERENCES Location(location_id)
);


CREATE TABLE Paleontologist (
paleontologist_id DECIMAL(12) NOT NULL PRIMARY KEY,
first_name VARCHAR(32) NOT NULL,
last_name VARCHAR(32) NOT NULL
);

ROLLBACK;

CREATE TABLE Dinosaur_discovery (
dinosaur_discovery_id DECIMAL(12) NOT NULL PRIMARY KEY,
dig_site_id DECIMAL(12) NOT NULL,
paleontologist_id DECIMAL(12) NOT NULL,
common_name VARCHAR(64) NOT NULL,
fossil_weight DECIMAL(6) NOT NULL,

CONSTRAINT dig_site_id_fk
FOREIGN KEY (dig_site_id)
REFERENCES dig_site(dig_site_id),

CONSTRAINT paleontologist_id_fk
FOREIGN KEY (paleontologist_id)
REFERENCES Paleontologist(paleontologist_id)
);

SELECT *
FROM Location;

SELECT *
FROM dig_site;

SELECT *
FROM Paleontologist;

SELECT *
FROM Dinosaur_discovery;


INSERT INTO Location (location_id, location_name) VALUES
(1, ' Stonesfield '),
(2, ' Stonesfield '),
(3, ' Stonesfield '),
(4, ' Stonesfield '),
(5, ' Stonesfield '),
(6, ' Stonesfield '),
(7, ' Stonesfield '),
(8, ' Stonesfield '),
(9, ' Stonesfield '),
(10, ' Stonesfield '),
(11, ' Stonesfield '),
(12, ' Stonesfield ');


INSERT INTO Location (location_id, location_name) VALUES
(1, 'Stonesfield'),
(2, 'Stonesfield'),
(3, 'Stonesfield'),
(4, 'Stonesfield'),
(5, 'Utah'),
(6, 'Utah'),
(7, 'Utah'),
(8, 'Arizona'),
(9, 'Stonesfield'),
(10, 'Stonesfield'),
(11, 'Stonesfield'),
(12, 'California');


UPDATE Location
SET location_name = 'Utah'
WHERE location_id = 5
RETURNING *;

SELECT *
FROM Location
ORDER BY location_id;


INSERT INTO Paleontologist (paleontologist_id, first_name, last_name) VALUES
(122, 'William', ' Buckland'),
(123, 'William', ' Buckland'),
(124, 'William', ' Buckland'),
(125, 'William', ' Buckland'),
(126, 'John', 'Ostrom'),
(127, 'John', 'Ostrom'),
(128, 'John', 'Ostrom'),
(129, 'John', 'Ostrom'),
(130, 'Henry', 'Osborn'),
(131, 'Henry', 'Osborn'),
(132, 'Henry', 'Osborn'),
(133, 'Henry', 'Osborn');



INSERT INTO dig_site (dig_site_id, location_id, dig_name, dig_cost) VALUES
(12, 1, 'Great British Dig', 8000),
(13, 2, 'Great British Dig', 8000),
(14, 3, 'Great British Dig', 8000),
(15, 4, 'Great British Dig', 8000),
(16, 5, 'Parowan Dinosaur Tracks', 10000),
(17, 6, 'Parowan Dinosaur Tracks', 10000),
(18, 7, 'Parowan Dinosaur Tracks', 10000),
(19, 8, 'Dynamic Desert Dig', 3500),
(20, 9, 'Mission Jurassic Dig', Null),
(21, 10, 'Mission Great British Dig', Null),
(22, 11, 'Ancient Site Dig', 5500),
(23, 12, 'Coal Point Dig', 9500);

INSERT INTO Dinosaur_discovery (dinosaur_discovery_id, dig_site_id, paleontologist_id, common_name, fossil_weight) VALUES
(567, 12, 122, 'Megalosaurus', 3000),
(568, 13, 123, 'Apatosaurus', 4000),
(569, 14, 124, 'Triceratops', 4500),
(570, 15, 125, 'Stegosaurus', 3500),
(571, 16, 126, 'Parasaurolophus', 6000),
(572, 17, 127, 'Tyrannosaurus Rex', 5000),
(573, 18, 128, 'Velociraptor', 7000),
(574, 19, 129, 'Tyrannosaurus Rex', 6000),
(575, 20, 130, 'Spinosaurus', 8000),
(576, 21, 131, 'Diplodocus', 9000),
(577, 22, 132, 'Tyrannosaurus Rex', 7500),
(578, 23, 133, 'Mauisaurus', 8500);


SELECT common_name,fossil_weight,COUNT(*) AS "Dinosaur"
FROM Dinosaur_discovery
WHERE fossil_weight>=4200
GROUP BY Dinosaur_discovery.common_name, Dinosaur_discovery.fossil_weight;


SELECT COUNT(*) as "At least 4200 lbs"
FROM Dinosaur_discovery
WHERE fossil_weight>=4200;

SELECT Dig_site.dig_name AS "Dig Site Name",
TO_CHAR((dig_cost), 'L99999D99') AS "Cost",
COUNT(Dinosaur_discovery.common_name) AS "Num of Dino Discoveries"
FROM Dig_site
JOIN Dinosaur_discovery ON Dig_site.Dig_site_id = Dinosaur_discovery.Dig_site_id
GROUP BY  Dig_site.dig_name, Dig_site.dig_cost
ORDER BY "Num of Dino Discoveries" DESC;

SELECT TO_CHAR(MIN(DISTINCT dig_cost), 'L99999D99') AS least_expensive,
TO_CHAR(MAX(DISTINCT dig_cost), 'L99999D99') AS most_expensive
FROM Dig_site;


SELECT dig_name, MIN(dig_cost), MAX(dig_cost)
FROM Dig_site
GROUP BY dig_name;


SELECT Dig_site.dig_name, SUM(Dinosaur_discovery.fossil_weight) as total_weight_per_site
FROM Dinosaur_discovery
JOIN Dig_site ON Dinosaur_discovery.Dig_site_id = Dig_site.Dig_site_id
GROUP BY Dig_site.dig_name
HAVING SUM(fossil_weight) >= 15000;


SELECT Location.location_name, COUNT(Dinosaur_discovery.common_name)
FROM Dinosaur_discovery
JOIN Dig_site ON Dinosaur_discovery.Dig_site_id = Dig_site.Dig_site_id
JOIN Location ON Dig_site.location_id = Location.location_id
GROUP BY Location.location_name
HAVING COUNT(Dinosaur_discovery.common_name)>=6;


SELECT Paleontologist.first_name, Paleontologist.last_name, Location.location_name,
COUNT(CASE WHEN Location.location_name = 'Stonesfield' THEN location_name END) as "# of Stonesfield Digs",
COUNT(Dinosaur_discovery.Dinosaur_discovery_id) as number_of_digs
FROM Paleontologist
JOIN Dinosaur_discovery ON Paleontologist.paleontologist_id = Dinosaur_discovery.paleontologist_id
JOIN Dig_site ON Dinosaur_discovery.Dig_site_id = Dig_site.Dig_site_id
JOIN Location ON Dig_site.location_id = Location.location_id
GROUP BY Paleontologist.first_name, Paleontologist.last_name, Location.location_name
ORDER BY number_of_digs desc;

SELECT Dig_site.dig_name AS "Dig Site Name",
TO_CHAR((dig_cost), 'L99999D99') AS "Cost",
COUNT(Dinosaur_discovery.common_name) AS "Num of Dino Discoveries"
FROM Dig_site
JOIN Dinosaur_discovery ON Dig_site.Dig_site_id = Dinosaur_discovery.Dig_site_id
GROUP BY  Dig_site.dig_name, Dig_site.dig_cost
ORDER BY "Num of Dino Discoveries" DESC;



SELECT TO_CHAR(MIN(DISTINCT dig_cost), 'L99999D99') AS least_expensive,
TO_CHAR(MAX(DISTINCT dig_cost), 'L99999D99') AS most_expensive
FROM Dig_site;


SELECT *
FROM Dinosaur_discovery;


CREATE TABLE Person (
person_id DECIMAL(12) NOT NULL PRIMARY KEY,
first_name VARCHAR(32) NOT NULL,
last_name VARCHAR(32) NOT NULL,
username VARCHAR(20) NOT NULL
);

CREATE TABLE Post (
post_id DECIMAL(12) NOT NULL PRIMARY KEY,
person_id DECIMAL(12) NOT NULL,
content VARCHAR(255) NOT NULL,
created_on DATE NOT NULL,
summary VARCHAR(13) NOT NULL,

CONSTRAINT person_id_fk
FOREIGN KEY (person_id)
REFERENCES Person(person_id)
);

CREATE TABLE Likes (
likes_id DECIMAL(12) NOT NULL PRIMARY KEY,
person_id DECIMAL(12) NOT NULL,
post_id DECIMAL(12) NOT NULL,
liked_on DATE,

CONSTRAINT person_id_fk
FOREIGN KEY (person_id)
REFERENCES Person(person_id),

CONSTRAINT post_id_fk
FOREIGN KEY (post_id)
REFERENCES Post(post_id)
);

SELECT *
FROM Person;

SELECT *
FROM Post;

SELECT *
FROM Likes;

ROLLBACK;


CREATE SEQUENCE person_seq START WITH 1;
CREATE SEQUENCE post_seq START WITH 1;
CREATE SEQUENCE likes_seq START WITH 1;

--Derek Peterson, 1 post, 1 like

INSERT INTO Person (person_id, first_name, last_name, username)
VALUES(nextval('person_seq'), 'Derek', 'Peterson', 'petersonworld');

INSERT INTO Post (post_id, person_id, content, created_on, summary)
VALUES(nextval('post_seq'), currval('person_seq'), 'Video Posts', CAST('12-JAN-2020' AS DATE), 'outside...');

INSERT INTO Likes (likes_id, person_id, post_id, liked_on)
VALUES(nextval('likes_seq'),  (SELECT person_id FROM Person WHERE first_name ='Derek'), currval('post_seq'), CAST('15-JAN-2020' AS DATE));

--Justin Garcia, 2 posts, 2 likes

INSERT INTO Person (person_id, first_name, last_name, username)
VALUES(nextval('person_seq'),'Justin', 'Garcia', 'justing34');

INSERT INTO Post (post_id, person_id, content, created_on, summary)
VALUES(nextval('post_seq'), currval('person_seq'), 'Picture Posts', CAST('29-APR-2014' AS DATE), 'swim...');

INSERT INTO Likes (likes_id, person_id, post_id, liked_on)
VALUES(nextval('likes_seq'),  (SELECT person_id FROM Person WHERE first_name ='Justin'), currval('post_seq'), CAST('17-AUG-2014' AS DATE));

INSERT INTO Post (post_id, person_id, content, created_on, summary)
VALUES(nextval('post_seq'), currval('person_seq'), 'Video Posts', CAST('24-JAN-2020' AS DATE), 'snow...');

INSERT INTO Likes (likes_id, person_id, post_id, liked_on)
VALUES(nextval('likes_seq'),  (SELECT person_id FROM Person WHERE first_name ='Justin'), currval('post_seq'), CAST('20-FEB-2020' AS DATE));

-- Patty Nora, 2 posts, 1 likes
INSERT INTO Person (person_id, first_name, last_name, username)
VALUES(nextval('person_seq'),'Patty', 'Nora', 'pattyy');

INSERT INTO Post (post_id, person_id, content, created_on, summary)
VALUES(nextval('post_seq'), currval('person_seq'), 'Picture Posts', CAST('06-APR-2020' AS DATE), 'Nights...');

INSERT INTO Likes (likes_id, person_id, post_id, liked_on)
VALUES(nextval('likes_seq'), (SELECT person_id FROM Person WHERE first_name ='Patty'), currval('post_seq'), CAST('13-JUL-2020' AS DATE));

INSERT INTO Post (post_id, person_id, content, created_on, summary)
VALUES(nextval('post_seq'), currval('person_seq'), 'Stories', CAST('24-JAN-2020' AS DATE), 'School...');



--Ashley Hansley, 2 posts, 1 likes
INSERT INTO Person (person_id, first_name, last_name, username)
VALUES(nextval('person_seq'),'Ashley', 'Hansley', 'ashleycookie');

INSERT INTO Post (post_id, person_id, content, created_on, summary)
VALUES(nextval('post_seq'), currval('person_seq'), 'Reels', CAST('14-APR-2022' AS DATE), 'Fun Day...');

INSERT INTO Likes (likes_id, person_id, post_id, liked_on)
VALUES(nextval('likes_seq'),  (SELECT person_id FROM Person WHERE first_name ='Ashley'), currval('post_seq'), CAST('15-JUN-2022' AS DATE));

INSERT INTO Post (post_id, person_id, content, created_on, summary)
VALUES(nextval('post_seq'), currval('person_seq'), 'Live Videos', CAST('14-APR-2022' AS DATE), 'Love...');


--Addison Bardot, 1 posts, 1 likes
INSERT INTO Person (person_id, first_name, last_name, username)
VALUES(nextval('person_seq'),'Addison', 'Bardot', 'ad_cat90');

INSERT INTO Post (post_id, person_id, content, created_on, summary)
VALUES(nextval('post_seq'), currval('person_seq'), 'Stories', CAST('26-FEB-2019' AS DATE), 'Picnic...');

INSERT INTO Likes (likes_id, person_id, post_id, liked_on)
VALUES(nextval('likes_seq'), (SELECT person_id FROM Person WHERE first_name ='Addison'), currval('post_seq'), CAST('23-MAY-2019' AS DATE));


--Get all persons details.
SELECT Person.person_id, Person.first_name, Person.last_name, Person.username, content, created_on, summary, Likes.likes_id, Likes.liked_on, Post.post_id
FROM Person
JOIN Post ON Post.person_id = Post.person_id
JOIN Likes ON Post.post_id = Likes.post_id
ORDER BY likes_id, person_id, first_name, last_name, created_on;

--old--
SELECT Person.person_id, Person.first_name, Person.last_name, Person.username, content, created_on, summary, Likes.likes_id, Likes.liked_on, Post.post_id
FROM Post
JOIN Likes ON Post.post_id = Likes.post_id
JOIN Person ON Person.person_id = Post.person_id
ORDER BY likes_id, person_id, first_name, last_name, created_on;

ROLLBACK;

DELETE FROM Person;
DELETE FROM Post;
DELETE FROM Likes;

--end of old--

CREATE OR REPLACE PROCEDURE add_michelle_stella()
AS
$proc$
BEGIN
INSERT INTO Person (person_id, first_name, last_name, username)
VALUES (nextval('person_seq'), 'Michelle', 'Stella', 'm_stella');
END;
$proc$ LANGUAGE plpgsql;

CALL add_michelle_stella();

SELECT *
FROM Person;

--Post (post_id, person_id, content, created_on, summary)

CREATE OR REPLACE PROCEDURE add_post (
--p_post_id IN DECIMAL, --Do not include sequences here.
p_person_id IN DECIMAL,
p_content IN VARCHAR,
p_created_on IN DATE)

LANGUAGE plpgsql
AS
$$
DECLARE
--derive the summary from the content, storing the derivation temporarily in a variable
v_summary_deriv VARCHAR(13);
BEGIN
--Calculate the item_code value and put it into the variable.
--Recall that the summary field stores the first 10 characters of the content followed by “…”.
v_summary_deriv := SUBSTRING(p_content FROM 1 FOR 10) || '...';

--Insert a row with the combined values of the parameters and the variable.
INSERT INTO Post (post_id, person_id, content, created_on, summary)
VALUES(nextval('post_seq'), p_person_id, p_content, p_created_on, v_summary_deriv);
END;
$$;

CALL add_post(20,'Reels', CAST('19-APR-2021' AS DATE));

SELECT *
FROM Post;


CREATE OR REPLACE PROCEDURE add_like (
p_username IN VARCHAR,
p_post_id IN DECIMAL,
p_liked_on IN DATE)

LANGUAGE plpgsql
AS $$
DECLARE

v_person_id DECIMAL(12);

BEGIN

SELECT person_id
INTO v_person_id
FROM Person
WHERE username = p_username;

INSERT INTO Likes(likes_id, person_id, post_id, liked_on)
VALUES(nextval('likes_seq'), v_person_id, p_post_id, p_liked_on);
END;
$$;

CALL add_like('ad_cat90', 34, CAST('08-DEC-2014' AS DATE));

SELECT *
FROM Likes;

INSERT INTO Post (post_id, person_id, content, created_on, summary)
VALUES(nextval('post_seq'), currval('person_seq'), 'Stories', CAST('26-FEB-2019' AS DATE), 'Picnic...');


CREATE OR REPLACE FUNCTION valid_sum ()
RETURNS TRIGGER LANGUAGE plpgsql
AS $trigfunc$
BEGIN
RAISE EXCEPTION USING MESSAGE = 'Summary Format Validation Error.',
ERRCODE = 22000;
END;
$trigfunc$;

CREATE TRIGGER valid_sum
BEFORE UPDATE OR INSERT ON Post
FOR EACH ROW WHEN(NEW.summary <> (SUBSTRING(new.content FROM 1 FOR 10) || '...'))
EXECUTE PROCEDURE valid_sum();

--incorrect summary
INSERT INTO Post VALUES(NEXTVAL('post_seq'), 24, 'Picture', CAST('26-FEB-2019' AS DATE), 'Picturew...');

--correct summary
INSERT INTO Post VALUES(NEXTVAL('post_seq'),24,'Picture', CAST('26-FEB-2019' AS DATE), 'Picture...');

SELECT *
FROM Post;


SELECT *
FROM Person;

ROLLBACK;

CREATE OR REPLACE FUNCTION block_like_func_1()
RETURNS TRIGGER LANGUAGE plpgsql
AS $$
DECLARE
v_created_on DATE;
BEGIN
SELECT Post.created_on
INTO v_created_on
FROM Post
Join Likes on Post.post_id = NEW.post_id;

IF New.liked_on < v_created_on THEN --if the created on date is greater than the liked date then run
RAISE EXCEPTION USING MESSAGE = 'A post cannot be liked before it was created.',
ERRCODE = 22000;
END IF;
RETURN NEW;
END;
$$;
CREATE TRIGGER like_validate_5_trg
BEFORE UPDATE OR INSERT ON Likes
FOR EACH ROW
EXECUTE PROCEDURE block_like_func_1();

--correct
INSERT INTO Likes
VALUES(nextval('likes_seq'), 23, 29, CAST('10-JUN-2022' AS DATE));
--incorrect
INSERT INTO Likes
VALUES(nextval('likes_seq'), 20, 31, CAST('24-JAN-2014' AS DATE));

SELECT *
FROM Likes;

SELECT *
FROM Post;



CREATE TABLE post_content_history (
post_id DECIMAL(12) NOT NULL,
old_content VARCHAR(255) NOT NULL,
new_content VARCHAR(255) NOT NULL,
change_date DATE NOT NULL,
FOREIGN KEY (post_id) REFERENCES Post(post_id));

CREATE OR REPLACE FUNCTION post_content_history()
RETURNS TRIGGER LANGUAGE plpgsql
AS $$
BEGIN
IF OLD.content <> NEW.content THEN
INSERT INTO post_content_history(post_id, old_content, new_content, change_date)
VALUES(NEW.post_id, OLD.content, NEW.content, CURRENT_DATE);
END IF;
RETURN NEW;
END;
$$;

CREATE TRIGGER content_history_trg_3
BEFORE UPDATE ON Post
FOR EACH ROW
EXECUTE PROCEDURE post_content_history();


SELECT *
FROM Post;

SELECT *
FROM post_content_history;

UPDATE Post
SET content = 'Fish Tac...'
WHERE post_id = 37;
