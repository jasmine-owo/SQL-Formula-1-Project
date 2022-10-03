							-- TEAM WHITE: FORMULA 1 WORLD CHAMPIONSHIP DATASETS --
		-- SOURCE: DATASET FROM KAGGLE: https://www.kaggle.com/datasets/rohanrao/formula-1-world-championship-1950-2020 -- 
-- SUMMARY --
-- 1. DDL / DATA DEFINITION LANGUAGE
-- 1.1. PREPARATION AND PROCESSING OF DATA / NORMALISE TABLES / CHANGE DATATYPES
-- 1.2. PREPARATION AND PROCESSING OF DATA / PRIMARY KEY, FOREING KEY 
-- 2. DEFINING THE PROBLEM WE ARE TRYING TO SOLVE
-- 3. DML/ DATA MANIPULATION LANGUAGE / ANALYZING THE DATA
-- 4. SHARE THE INSIGHTS FROM THE DATA (DASHBOARDS, GRAPHS)

--
-- 1. DDL / DATA DEFINITION LANGUAGE
-- 1.1. PREPARATION AND PROCESSIN OF DATA / NORMALISE TABLES / CHANGE DATATYPES
CREATE DATABASE formula_1;

Use formula_1;

-- Import table sprint_results: Contains most of all data from the datasets
SELECT *
FROM sprint_results;

-- Create a new normalised_table
CREATE TABLE normalised_sprint_results (
result_id INT NOT NULL,
race_id INT NOT NULL,
driver_id INT NOT NULL,
constructor_id INT NOT NULL,
car_number INT NOT NULL,
grid_formation INT NOT NULL,
position INT NOT NULL,
points INT NOT NULL, 
laps INT NOT NULL,
status_id INT,
time TIME
);

SELECT * FROM sprint_results;

-- Drop column 'time'
SET SQL_SAFE_UPDATES = 0;

ALTER TABLE normalised_sprint_results
DROP COLUMN time;

-- Let's see if it works :)
SELECT * FROM normalised_sprint_results;

-- Now, let's add again the column lap_time 
ALTER TABLE normalised_sprint_results
ADD fastest_lap_time TIME;

--  Formación lap:
-- The lap before the start of the race when the cars are driven round from the grid to form up 
-- on the grid again for the start of the race. Sometimes referred to as the warm-up lap or parade lap.

-- Insert into normalised_sprint_results data from sprint_results 
INSERT INTO normalised_sprint_results
SELECT resultId, 
raceId, 
driverId, 
constructorId, 
number, 
grid, 
position, 
points, 
laps, 
statusId, 
fastestLapTime
FROM sprint_results;

-- Let's see our new table
SELECT * FROM normalised_sprint_results;

-- Now, let's add the info of the other tables

-- Table Constructors

SELECT * FROM constructors;

CREATE TABLE normalised_constructors (
constructor_id INT NOT NULL,
constructor_name VARCHAR(50),
nationality VARCHAR(50)
);

INSERT INTO normalised_constructors
SELECT constructorId, constructorRef, nationality
FROM constructors;

ALTER TABLE normalised_constructors
MODIFY COLUMN constructor_name VARCHAR(50) NOT NULL;

SELECT * FROM normalised_constructors;

-- Table Races

SELECT *
FROM races;

CREATE TABLE normalised_races (
race_id INT NOT NULL,
race_year DATE,
round INT NOT NULL,
circuit_id INT NOT NULL,
race_name VARCHAR(50) NOT NULL
);

SELECT * FROM normalised_races;

-- The column race_year is 'DATE', 	it needs to be 'YEAR' type
ALTER TABLE normalised_races
DROP COLUMN race_year;

-- Add race_year but in 'YEAR' format
ALTER TABLE normalised_races
ADD race_year YEAR;

INSERT INTO normalised_races
SELECT raceId, round, circuitId, name, year
FROM races;

-- Let's drop normalised_races and make it again 
DROP TABLE normalised_races;

CREATE TABLE normalised_races (
race_id INT NOT NULL,
race_year YEAR,
round INT NOT NULL,
circuit_id INT NOT NULL,
race_name VARCHAR(50) NOT NULL,
race_date DATE,
race_time TIME,
fp1_date DATE,
fp1_time TIME, 
fp2_date DATE, 
fp2_time TIME, 
fp3_date DATE,
fp3_time TIME, 
sprint_date DATE,
sprint_time TIME
);

INSERT INTO normalised_races
SELECT raceId, year, round, circuitId, name, date, time,
fp1_date, fp1_time, fp2_date, fp2_time, fp3_date, 
fp3_time, sprint_date, sprint_time
FROM races;

SELECT * FROM normalised_races;

-- Table Qualifying

SELECT * FROM qualifying;

CREATE TABLE normalised_qualifying (
qualifyed_id INT NOT NULL,
race_id INT NOT NULL,
driver_id INT NOT NULL,
constructor_id INT NOT NULL,
position INT NOT NULL,
q1 INT,
q2 INT,
q3 INT
);

ALTER TABLE normalised_qualifying
DROP COLUMN q1,
DROP COLUMN q2,
DROP COLUMN q3;

ALTER TABLE normalised_qualifying
ADD q1 TEXT,
ADD q2 TEXT,
ADD q3 TEXT;

SELECT * FROM normalised_qualifying;

INSERT INTO normalised_qualifying
SELECT qualifyId, raceId, driverId, 
constructorId, position, q1, q2, q2
FROM qualifying;

ALTER TABLE normalised_qualifying
MODIFY COLUMN q1 TIME,
MODIFY COLUMN q2 TIME,
MODIFY COLUMN q3 TIME;

SELECT * FROM normalised_qualifying;

-- Table Results

SELECT * FROM results;

CREATE TABLE normalised_results (
result_id INT NOT NULL,
race_id INT NOT NULL,
driver_id INT NOT NULL,
constructor_id INT NOT NULL,
grid_formation INT NOT NULL,
position INT NOT NULL, 
laps INT NOT NULL, 
laps_time TEXT,
fastest_lap INT, 
statust_id INT
);

ALTER TABLE normalised_results
DROP COLUMN position;

ALTER TABLE normalised_results
ADD COLUMN position INT;

INSERT INTO normalised_results
SELECT resultId, raceId, driverId, constructorId, grid, 
laps, time, fastestLap, statusId, position
FROM results;

SELECT * FROM normalised_results;

-- Change plural to singular. In columns it is preferred to use singular names
ALTER TABLE normalised_results
RENAME COLUMN laps TO lap,
RENAME COLUMN laps_time TO lap_time;

SELECT * FROM normalised_results;

-- Table pit_stops --

SELECT * FROM pit_stops;

CREATE TABLE normalised_pit_stops (
race_id INT NOT NULL, 
driver_id INT NOT NULL,
stop INT,
lap INT, 
lap_time TEXT, -- We are talking about the time difference between two runners +1.0000000000009999
duration DOUBLE
);

INSERT INTO normalised_pit_stops
SELECT raceId, driverId, stop, lap, time, duration
FROM pit_stops;

SELECT * FROM normalised_pit_stops;

ALTER TABLE normalised_pit_stops
MODIFY COLUMN lap_time TIME;

SELECT * FROM normalised_pit_stops;

-- Table Status --

SELECT * FROM status;

CREATE TABLE normalised_status (
status_id INT NOT NULL,
status TEXT NOT NULL
);

INSERT INTO normalised_status
SELECT statusId, status
FROM status;

SELECT * FROM normalised_status;

ALTER TABLE normalised_status
MODIFY COLUMN status VARCHAR(50) NOT NULL;

SELECT * FROM normalised_status;

-- Table circuits
SELECT * FROM circuits;

CREATE TABLE normalised_circuits (
circuit_id INT NOT NULL,
circuit_ref TEXT NOT NULL,
circuit_name TEXT NOT NULL,
circuit_location TEXT NOT NULL,
circuit_country TEXT NOT NULL
);

INSERT INTO normalised_circuits
SELECT circuitid, circuitRef, name, location, country
FROM circuits;

SELECT * FROM normalised_circuits;

ALTER TABLE normalised_circuits
MODIFY COLUMN circuit_ref VARCHAR(50) NOT NULL,
MODIFY COLUMN circuit_name VARCHAR(50) NOT NULL,
MODIFY COLUMN circuit_location VARCHAR(50) NOT NULL,
MODIFY COLUMN circuit_country VARCHAR (50) NOT NULL;

SELECT * FROM normalised_circuits;

-- Table Drivers -- 

SELECT * FROM drivers;

CREATE TABLE normalised_drivers (
driver_id INT NOT NULL,
driver_ref TEXT NOT NULL,
driver_number TEXT,
driver_code TEXT, 
driver_surname TEXT NOT NULL,
birthdate TEXT NOT NULL, 
nationality TEXT NOT NULL
);

ALTER TABLE normalised_drivers
MODIFY COLUMN birthdate TEXT NULL;

INSERT INTO normalised_drivers
SELECT driverid, driverRef, number, code, surname, dob, nationality
FROM drivers;

SELECT * FROM normalised_drivers; 

ALTER TABLE normalised_drivers
MODIFY COLUMN driver_ref VARCHAR(50) NOT NULL,
MODIFY COLUMN driver_number INT,
MODIFY COLUMN driver_code VARCHAR(50), 
MODIFY COLUMN driver_surname VARCHAR(50) NOT NULL,
MODIFY COLUMN birthdate DATE, 
MODIFY COLUMN nationality VARCHAR(50) NOT NULL;

SELECT * FROM normalised_drivers;

-- Let's look all our new tables
SELECT * FROM normalised_circuits;
SELECT * FROM normalised_constructors;
SELECT * FROM normalised_drivers;
SELECT * FROM normalised_pit_stops;
SELECT * FROM normalised_qualifying;
SELECT * FROM normalised_races;
SELECT * FROM normalised_results;
SELECT * FROM normalised_sprint_results;
SELECT * FROM normalised_status;

-- 1.2. PRIMARY KEY, FOREING KEY 

-- normalised_drivers
ALTER TABLE normalised_drivers
ADD PRIMARY KEY (driver_id);

-- normalised_constructors
ALTER TABLE normalised_constructors
ADD PRIMARY KEY (constructor_id);

-- normalised_circuits
ALTER TABLE normalised_circuits
ADD PRIMARY KEY (circuit_id);

-- normalised_races
ALTER TABLE normalised_races
ADD PRIMARY KEY (race_id);

ALTER TABLE normalised_races
ADD FOREIGN KEY (circuit_id) REFERENCES normalised_circuits(circuit_id);

-- normalised_pit_stops
ALTER TABLE normalised_pit_stops
ADD FOREIGN KEY (driver_id) REFERENCES normalised_drivers(driver_id);

ALTER TABLE normalised_pit_stops
DROP FOREIGN KEY `normalised_pit_stops_ibfk_2`;

-- ALTER TABLE normalised_pit_stops
-- ADD FOREIGN KEY (race_id) REFERENCES normalised_races (race_id);


-- normalised_qualifying
ALTER TABLE normalised_qualifying
ADD PRIMARY KEY (qualifyed_id);

ALTER TABLE normalised_qualifying
ADD FOREIGN KEY (constructor_id) REFERENCES normalised_constructors (constructor_id);

ALTER TABLE normalised_qualifying
DROP FOREIGN KEY `normalised_qualifying_ibfk_2`;

-- ALTER TABLE normalised_qualifying
-- ADD FOREIGN KEY (race_id) REFERENCES normalised_races(race_id);

ALTER TABLE normalised_qualifying
ADD FOREIGN KEY (driver_id) REFERENCES normalised_drivers(driver_id);

-- normalised_results
ALTER TABLE normalised_results
ADD PRIMARY KEY (result_id);

-- ALTER TABLE normalised_results
-- ADD FOREIGN KEY (race_id) REFERENCES normalised_races(race_id);

ALTER TABLE normalised_results
ADD FOREIGN KEY (driver_id) REFERENCES normalised_drivers(driver_id);

ALTER TABLE normalised_results
ADD FOREIGN KEY (constructor_id) REFERENCES normalised_constructors(constructor_id);

-- normalised_status
ALTER TABLE normalised_status
ADD PRIMARY KEY (status_id);

-- normalised_sprint_results
ALTER TABLE normalised_sprint_results
ADD FOREIGN KEY (result_id) REFERENCES normalised_results (result_id);

ALTER TABLE normalised_sprint_results
ADD FOREIGN KEY (driver_id) REFERENCES normalised_drivers(driver_id);

-- ALTER TABLE normalised_sprint_results
-- ADD FOREIGN KEY (race_id) REFERENCES normalised_races(race_id);

ALTER TABLE normalised_sprint_results
ADD FOREIGN KEY (constructor_id) REFERENCES normalised_constructors(constructor_id);

ALTER TABLE normalised_sprint_results
ADD FOREIGN KEY (status_id) REFERENCES normalised_status(status_id);

USE formula_1;

SELECT * FROM normalised_circuits;
SELECT * FROM normalised_constructors;
SELECT * FROM normalised_drivers;
SELECT * FROM normalised_pit_stops;
SELECT * FROM normalised_qualifying;
SELECT * FROM normalised_races;
SELECT * FROM normalised_results;
SELECT * FROM normalised_sprint_results;
SELECT * FROM normalised_status;

-- 2. DEFINING THE PROBLEM WE ARE TRYING TO SOLVE







