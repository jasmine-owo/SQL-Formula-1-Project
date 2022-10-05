-- 3. DML/ DATA MANIPULATION LANGUAGE / AGGREGATE FUNCTIONS / ANALYZING THE DATA

USE formula_1;

-- General Info about F1

-- 2. Find the country that hosted the F1 races

SELECT circuit_country 
FROM normalised_circuits;

-- 3. Find the circuit that hosted the F1 races and which countries join the races
SELECT circuit_ref, circuit_country 
FROM normalised_circuits;

-- About the racer
-- 4. Find the avg/max/min time difference between the 1st, 2nd and 3rd runners.

-- fastest and slowest driver (amongst the first three positions) across all years
SELECT * FROM normalised_sprint_results;

-- fastest 
SELECT driver_id, position, MIN(milliseconds) AS difference
FROM normalised_sprint_results 
WHERE position BETWEEN 1 and 3
GROUP BY driver_id, position
ORDER BY MIN(milliseconds) ASC;

-- slowest
SELECT driver_id, position, MAX(milliseconds) AS difference
FROM normalised_sprint_results 
WHERE position BETWEEN 1 and 3
GROUP BY driver_id, position
ORDER BY MAX(milliseconds) DESC;

-- 5. Find the constructor that has won the most races in F1

SELECT c.constructor_id, c.constructor_name 
FROM normalised_constructors AS c
INNER JOIN 
	(SELECT constructor_id, 
    COUNT(constructor_id) 
    FROM normalised_results 
    WHERE position = 1
     GROUP BY constructor_id 
     ORDER BY COUNT(constructor_id) DESC
     LIMIT 1) AS v
ON c.constructor_id = v.constructor_id;

-- 6. Find the driver that has won the races in F1 and the respecting constructor
SELECT d.driver_surname, c.constructor_name, r.race_year
FROM normalised_sprint_results AS sr
LEFT JOIN normalised_drivers AS d on sr.driver_id = d.driver_id
LEFT JOIN normalised_constructors AS c on sr.constructor_id = c.constructor_id 
LEFT JOIN normalised_races AS r on sr.race_id = r.race_id
WHERE sr.position =1
ORDER BY r.race_year;

-- 7. Find the fastest pit_stop in the dataset 
SELECT d.driver_surname, ps.duration, r.race_id, r.race_date, r.round, r.race_name
FROM normalised_pit_stops ps
LEFT JOIN normalised_drivers d ON ps.driver_id = d.driver_id
LEFT JOIN normalised_races r ON ps.race_id = r.race_id
WHERE ps.duration = (SELECT MIN(duration) FROM normalised_pit_stops);

#Let's look at the corresponding race details
SELECT * FROM normalised_races WHERE race_id = 858;

-- Investigate the relationships ---------------------------------------------

-- 8. Compare the nationality of the 1st racers and the hosting country
SELECT d.nationality, r.race_name, r.race_id
FROM normalised_sprint_results AS sr
LEFT JOIN normalised_drivers AS d on sr.driver_id = d.driver_id
LEFT JOIN normalised_races AS r on sr.race_id = r.race_id
WHERE sr.position =1
ORDER BY d.driver_surname;

-- 9. Find the F1 top fastest lap, its correlated circuit and its constructor

SELECT 
	ns.fastest_lap_time,
    ns.milliseconds,
    c.circuit_name,
    co.constructor_name,
    ns.driver_id
FROM normalised_sprint_results AS ns
INNER JOIN normalised_circuits AS c
	ON ns.driver_id = c.circuit_id
LEFT JOIN normalised_constructors AS co
	USING (constructor_id)
WHERE fastest_lap_time IS NOT NULL
	AND milliseconds IS NOT NULL
ORDER BY ns.fastest_lap_time
LIMIT 1;

-- 10. Find the avg/sum/count of the pole position (q1, q2, q3) and the winners 
SELECT sec_to_time(AVG(TIME_TO_SEC(q1))) AS average_q1, sec_to_time(STD(TIME_TO_SEC(q1))) AS std_q1,
sec_to_time(AVG(TIME_TO_SEC(q2))) AS average_q2, sec_to_time(STD(TIME_TO_SEC(q2))) AS std_q2,
sec_to_time(AVG(TIME_TO_SEC(q3))) AS average_q3, sec_to_time(STD(TIME_TO_SEC(q3))) AS std_q3
FROM normalised_qualifying;

-- Then, find the average and the std of the winners' pole positions
SELECT sec_to_time(AVG(TIME_TO_SEC(q1))) AS average_q1, sec_to_time(STD(TIME_TO_SEC(q1))) AS std_q1,
sec_to_time(AVG(TIME_TO_SEC(q2))) AS average_q2, sec_to_time(STD(TIME_TO_SEC(q2))) AS std_q2,
sec_to_time(AVG(TIME_TO_SEC(q3))) AS average_q3, sec_to_time(STD(TIME_TO_SEC(q3))) AS std_q3
FROM normalised_qualifying
WHERE position = 1;

-- 11. Correlation between duration of pit stops and time to win race/reach the end line

SELECT
	position,
    laps AS no_laps,
    fastest_lap_time,
    milliseconds AS result_milliseconds,
	driver_id,
    constructor_id,
    race_id
FROM normalised_sprint_results
WHERE position BETWEEN 1 AND 3
ORDER BY position ASC;

-- 12. Find the avg pit stop duration by each constructor in each year 

SELECT 
	ROUND(AVG(duration), 2) AS avg_pit_stop_duration,
    c.constructor_name,
    races.race_year
FROM normalised_pit_stops AS ps
INNER JOIN normalised_constructors AS c
	ON ps.driver_id = c.constructor_id
LEFT JOIN normalised_races AS races
	ON ps.race_id = races.race_id
GROUP BY  c.constructor_name, races.race_year
ORDER BY c.constructor_name ASC;

-- 13. Find the avg pit stop by circuit

SELECT 
	ROUND(AVG(ps.duration),2) AS avg_pit_stop,
    c.circuit_id AS circuit_id,
    c.circuit_name,
    c.circuit_location,
    c.circuit_country,
    races.race_name
FROM normalised_pit_stops AS ps
INNER JOIN normalised_circuits AS c
	ON ps.driver_id = c.circuit_id
LEFT JOIN normalised_races AS races
	ON ps.driver_id = races.race_id
GROUP BY c.circuit_id, races.circuit_id, c.circuit_name, c.circuit_location, c.circuit_country, races.race_name
ORDER BY c.circuit_country ASC;

-- 14. The curse of number 13* 
	-- >Does number 13 lost the most races?
    -- >Does number 13 have more accidents/disqualify than other racers?
SELECT * FROM normalised_sprint_results;    

SELECT *
FROM normalised_sprint_results
WHERE car_number = 13; -- Nobody use car number 13 in this dataset

-- The curse of number 13
-- Does number 13 lost the most races?
SELECT car_number
FROM normalised_sprint_results
WHERE position = 20;

-- Does number 13 have more accidents/disqualify than other racers?
SELECT sr.car_number, sr.constructor_id, sr.driver_id, s.status
FROM normalised_sprint_results sr
RIGHT JOIN normalised_status s ON sr.status_id = s.status_id
WHERE s.status_id = 2 
OR s.status_id = 3 
OR s.status_id = 4
OR s.status_id = 73
OR s.status_id = 82

