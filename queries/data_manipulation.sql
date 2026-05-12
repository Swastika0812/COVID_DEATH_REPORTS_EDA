-- select data that we are  going to be using

SELECT location, date, total_cases, new_cases, total_deaths,population
FROM COVID_DEATHS
ORDER BY 1,2;

-- find total_deaths percentage  of total_cases 

SELECT 
    location, date, total_cases, total_deaths,
    ROUND(((total_deaths / total_cases) * 100)::NUMERIC, 2) AS death_percentage
FROM covid_deaths
WHERE location LIKE '%States%'
ORDER BY 1,2;

-- shows what percentage of population got covid

SELECT 
    location, date, total_cases, population,
    ROUND(((total_cases / population) * 100)::NUMERIC, 1) AS covid_percentage
FROM covid_deaths
WHERE location LIKE '%States%' AND ((total_cases / population) * 100) >=1
ORDER BY 1,2;


-- looking at countries with highest infection rate compare to population

SELECT location, population , MAX(total_cases) AS highest_infection_count,
     ROUND (((MAX(total_cases/population))*100)::NUMERIC,0) AS infection_rate
FROM covid_deaths
WHERE population IS NOT NULL AND total_cases IS NOT NULL
GROUP BY location,population
ORDER BY infection_rate DESC;


-- showing countries with highest death count per population

SELECT location, population , MAX(total_deaths) AS highest_death
FROM covid_deaths
WHERE continent IS NOT NULL 
   AND total_deaths IS NOT NULL
GROUP BY location,population
ORDER BY highest_death DESC;






-- global numbers

SELECT  SUM(new_cases) AS global_cases, 
      SUM(new_deaths) AS global_deaths,
      ROUND((((SUM(new_deaths)/SUM(new_cases)))*100)::NUMERIC, 2) AS global_death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL 
ORDER BY 1,2  
;

-- after joining with vaccination table

SELECT * FROM covid_deaths cd
JOIN covid_vaccination_data cv
ON cd.location = cv.location AND cd.date = cv.date;



-- looking at the countries with vaccination rate above 50% compared to population

SELECT cd.location, cd.population,cv.new_vaccinations,
 ROUND(((cv.new_vaccinations/cd.population)*100)::NUMERIC,1) AS vaccination_rate
 FROM covid_deaths cd
 JOIN covid_vaccination_data cv
 ON cd.location = cv.location AND cd.date = cv.date
 WHERE ROUND(((cv.new_vaccinations/cd.population)*100)::NUMERIC,1) >0.5;
 

 -- looking for the countries with increasing vaccination rate countries wise compared to population


WITH vaccination_ctn(date,location,population,new_vaccinations,cumulative_vaccinations)
AS(
 SELECT cd.date,cd.location, cd.population,cv.new_vaccinations,
 SUM(cv.new_vaccinations::INTEGER) OVER (PARTITION BY cd.location ORDER BY cd.date) AS cumulative_vaccinations
 FROM covid_deaths cd
 JOIN covid_vaccination_data cv
 ON cd.location = cv.location AND cd.date = cv.date
 WHERE cd.continent IS NOT NULL AND cv.new_vaccinations IS NOT NULL)
 SELECT * , 
 ROUND(((cumulative_vaccinations/population)*100 ):: NUMERIC,2) AS vaccination_rate
 FROM vaccination_ctn
 ;



-- creating a temporary table to find the top 10 countries with highest vaccination rate

CREATE TABLE vaccinations_temp (
    location VARCHAR(255),
    date DATE,
    population NUMERIC,
    new_vaccinations NUMERIC,
    cumulative_vaccinations NUMERIC
);

INSERT INTO vaccinations_temp
(
    location,
    date,
    population,
    new_vaccinations,
    cumulative_vaccinations
)

SELECT
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,

    SUM(cv.new_vaccinations::INTEGER)
    OVER (
        PARTITION BY cd.location
        ORDER BY cd.date
    ) AS cumulative_vaccinations

FROM covid_deaths cd

JOIN covid_vaccination_data cv
ON cd.location = cv.location
AND cd.date = cv.date

WHERE cd.continent IS NOT NULL
AND cv.new_vaccinations IS NOT NULL;

SELECT location,
ROUND(
    MAX((cumulative_vaccinations::NUMERIC / population) * 100),2) AS vaccination_rate
FROM vaccinations_temp
GROUP BY location
ORDER BY vaccination_rate DESC
LIMIT 10
;


-- creating a view to store data for later visualization

CREATE VIEW vaccinations_view AS (
  SELECT
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,

    SUM(cv.new_vaccinations::INTEGER)
    OVER (
        PARTITION BY cd.location
        ORDER BY cd.date
    ) AS cumulative_vaccinations

FROM covid_deaths cd

JOIN covid_vaccination_data cv
ON cd.location = cv.location
AND cd.date = cv.date

WHERE cd.continent IS NOT NULL
AND cv.new_vaccinations IS NOT NULL
)

SELECT * FROM vaccinations_view;
