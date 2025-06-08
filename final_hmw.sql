CREATE SCHEMA pandemic;
use pandemic;

CREATE TABLE disease_data_raw (
    entity VARCHAR(100),
    code VARCHAR(10),
    year YEAR,
    number_yaws INT NULL,
    polio_cases INT NULL,
    cases_guinea_worm INT NULL,
    number_rabies INT NULL,
    number_malaria INT NULL,
    number_hiv INT NULL,
    number_tuberculosis INT NULL,
    number_smallpox INT NULL,
    number_cholera_cases INT NULL
);

DROP TABLE disease_data_raw;

CREATE TABLE entities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity VARCHAR(100) NOT NULL,
    code VARCHAR(10)
);

CREATE TABLE disease_statistics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_id INT,
    year YEAR NOT NULL,
    number_yaws INT NULL,
    polio_cases INT NULL,
    cases_guinea_worm INT NULL,
    number_rabies INT NULL,
    number_malaria INT NULL,
    number_hiv INT NULL,
    number_tuberculosis INT NULL,
    number_smallpox INT NULL,
    number_cholera_cases INT NULL,
    FOREIGN KEY (entity_id) REFERENCES entities(id)
);

INSERT INTO entities (entity, code)
SELECT DISTINCT entity, code
FROM infectious_cases;
select * from entities;

INSERT INTO disease_statistics (
    entity_id, year,
    number_yaws, polio_cases, cases_guinea_worm, number_rabies,
    number_malaria, number_hiv, number_tuberculosis, number_smallpox, number_cholera_cases
)
SELECT
    e.id,
    d.year,
    NULLIF(d.number_yaws, ''),
    NULLIF(d.polio_cases, ''),
    NULLIF(d.cases_guinea_worm, ''),
    NULLIF(d.number_rabies, ''),
    NULLIF(d.number_malaria, ''),
    NULLIF(d.number_hiv, ''),
    NULLIF(d.number_tuberculosis, ''),
    NULLIF(d.number_smallpox, ''),
    NULLIF(d.number_cholera_cases, '')
FROM infectious_cases d
JOIN entities e
  ON d.entity = e.entity
 AND (d.code = e.code OR (d.code IS NULL AND e.code IS NULL));

DROP TABLE disease_data_raw;

SELECT COUNT(*) FROM infectious_cases;
SELECT * from entities;
select * from disease_statistics;

ALTER TABLE disease_statistics
ADD year_january DATE;
UPDATE disease_statistics
SET year_january = STR_TO_DATE(CONCAT(year, '-01-01'), '%Y-%m-%d');
SELECT year_january, NOW(), TIMESTAMPDIFF(YEAR, year_january, NOW())
FROM disease_statistics;

DELIMITER $$

CREATE FUNCTION date_difference(year_jan INT, date_now DATE)
RETURNS INT
DETERMINISTIC
BEGIN
DECLARE year_start_date DATE;
DECLARE result INT;
SET year_start_date = STR_TO_DATE(CONCAT(year_jan, '-01-01'), '%Y-%m-%d');
SET result = TIMESTAMPDIFF(YEAR, year_start_date, date_now);

RETURN result;
END $$

DELIMITER ;
DROP FUNCTION date_difference;
SELECT date_difference(ds.year, NOW()) as date_diff
from disease_statistics as ds;

SELECT entity, entity_id, AVG(number_rabies), MIN(number_rabies), MAX(number_rabies)
FROM disease_statistics ds
JOIN entities e ON ds.entity_id = e.id
GROUP BY entity_id
ORDER BY AVG(number_rabies) DESC
LIMIT 10;

select * from infectious_cases;


