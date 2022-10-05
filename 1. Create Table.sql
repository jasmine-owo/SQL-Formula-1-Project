-- 1.1. Preparation and processing of data / Normalise Tables / Change Datatypes
#CREATE DATABASE formula_1;

Use formula_1;

-- -------------------------------------------------------------------------------- --
-- 									Table sprint_results

-- Import table sprint_results: Contains most of all data from the datasets
SELECT * FROM sprint_results;

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
    time TEXT,
    milliseconds INT,
    fastestLap INT,
    fastestLapTime TEXT,
	status_id INT NOT NULL
);

INSERT INTO normalised_sprint_results SELECT * FROM sprint_results;

SELECT * FROM normalised_sprint_results;

-- we can use milliseconds to replace the time needed for the race of each drivers. so we drop the time column.
ALTER TABLE normalised_sprint_results
DROP COLUMN time;

-- Change the datatype of Fastest Lap Time to Time
ALTER TABLE normalised_sprint_results
MODIFY fastestLapTime time;

-- Change fastestLapTime and FastestLap into fastest_lap_time and fastest_lap for convenience
ALTER TABLE normalised_sprint_results
RENAME COLUMN fastestLapTime TO fastest_lap_time,
RENAME COLUMN fastestLap TO fastest_lap;

SELECT * FROM normalised_sprint_results;


-- -------------------------------------------------------------------------------- --
-- 									Table Constructors
SELECT * FROM constructors;

CREATE TABLE normalised_constructors (
	constructor_id INT NOT NULL,
	constructor_name VARCHAR(50),
	nationality VARCHAR(50)
);

INSERT INTO normalised_constructors 
SELECT
	constructorId, 
	constructorRef, 
	nationality
FROM constructors;

-- change the column to not null
ALTER TABLE normalised_constructors
MODIFY COLUMN constructor_name VARCHAR(50) NOT NULL,
MODIFY COLUMN nationality VARCHAR(50) NOT NULL;

SELECT * FROM normalised_constructors;



-- -------------------------------------------------------------------------------- --
-- 									Table Races
SELECT * FROM races;

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
SELECT 
	raceId, 
	year, 
	round, 
	circuitId, 
	name, 
	date, 
	time,
	fp1_date, 
	fp1_time, 
	fp2_date, 
	fp2_time, 
	fp3_date, 
	fp3_time, 
	sprint_date, 
	sprint_time
FROM races;

SELECT * FROM normalised_races;



-- -------------------------------------------------------------------------------- --
-- 								Table Qualifying
SELECT * FROM qualifying;

CREATE TABLE normalised_qualifying (
	qualifyed_id INT NOT NULL,
	race_id INT NOT NULL,
	driver_id INT NOT NULL,
	constructor_id INT NOT NULL,
	position INT NOT NULL,
	q1 TIME,
	q2 TIME,
	q3 TIME
);

INSERT INTO normalised_qualifying
SELECT 
	qualifyId, 
	raceId, 
	driverId, 
	constructorId, 
	position, 
	q1, 
	q2, 
	q2
FROM qualifying;

# We do not have to drop the null q2, q3 now 
#because the null values represent the losers that cannot continue the races

SELECT * FROM normalised_qualifying;



-- -------------------------------------------------------------------------------- --
-- 								Table Results
SELECT * FROM results;

CREATE TABLE normalised_results (
	result_id INT NOT NULL,
	race_id INT NOT NULL,
	driver_id INT NOT NULL,
	constructor_id INT NOT NULL,
	grid_formation INT NOT NULL,
	position INT, 
	lap INT, 
	lap_time TEXT,
	fastest_lap INT, 
	status_id INT
);

INSERT INTO normalised_results
SELECT 
	resultId, 
	raceId,
	driverId, 
	constructorId, 
	grid,
    position,
	laps, 
	time, 
	fastestLap, 
	statusId
FROM results;

-- Drop the lap_time. we will use the lap_time in pit_stops table for convenience
ALTER TABLE normalised_results
DROP COLUMN lap_time;

SELECT * FROM normalised_results;



-- -------------------------------------------------------------------------------- --
-- 							Table pit_stops --
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
SELECT raceId, 
	driverId, 
	stop, 
	lap, 
	time, 
	duration
FROM pit_stops;

SELECT * FROM normalised_pit_stops;

ALTER TABLE normalised_pit_stops
MODIFY COLUMN lap_time TIME;

SELECT * FROM normalised_pit_stops;



-- -------------------------------------------------------------------------------- --
-- 							Table Status --
SELECT * FROM status;

CREATE TABLE normalised_status (
	status_id INT NOT NULL,
	status TEXT NOT NULL
);

INSERT INTO normalised_status
SELECT 
	statusId, 
	status
FROM status;

ALTER TABLE normalised_status
MODIFY COLUMN status VARCHAR(50) NOT NULL;

SELECT * FROM normalised_status;



-- -------------------------------------------------------------------------------- --
-- 							Table circuits

SELECT * FROM circuits;

CREATE TABLE normalised_circuits (
	circuit_id INT NOT NULL,
	circuit_ref TEXT NOT NULL,
	circuit_name TEXT NOT NULL,
	circuit_location TEXT NOT NULL,
	circuit_country TEXT NOT NULL
);

INSERT INTO normalised_circuits
SELECT 
	circuitid, 
	circuitRef, 
	name, 
	location, 
	country
FROM circuits;

SELECT * FROM normalised_circuits;

ALTER TABLE normalised_circuits
MODIFY COLUMN circuit_ref VARCHAR(50) NOT NULL,
MODIFY COLUMN circuit_name VARCHAR(50) NOT NULL,
MODIFY COLUMN circuit_location VARCHAR(50) NOT NULL,
MODIFY COLUMN circuit_country VARCHAR (50) NOT NULL;

SELECT * FROM normalised_circuits;




-- -------------------------------------------------------------------------------- --
-- 								Table Drivers -- 
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
SELECT 
	driverid, 
	driverRef, 
	number, 
	code, 
	surname, 
	dob, 
	nationality
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


-- -------------------------------------------------------------------------------- --
-- 1.2. Preparation and processing of data / Primary Key, Foreing Key 

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

-- normalised_qualifying
ALTER TABLE normalised_qualifying
ADD PRIMARY KEY (qualifyed_id);

ALTER TABLE normalised_qualifying
ADD FOREIGN KEY (constructor_id) REFERENCES normalised_constructors (constructor_id);

ALTER TABLE normalised_qualifying
ADD FOREIGN KEY (driver_id) REFERENCES normalised_drivers(driver_id);

-- normalised_results
ALTER TABLE normalised_results
ADD PRIMARY KEY (result_id);

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

ALTER TABLE normalised_sprint_results
ADD FOREIGN KEY (constructor_id) REFERENCES normalised_constructors(constructor_id);

ALTER TABLE normalised_sprint_results
ADD FOREIGN KEY (status_id) REFERENCES normalised_status(status_id);

--
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
--

-- 2. Defining the problem we are trying to solve


