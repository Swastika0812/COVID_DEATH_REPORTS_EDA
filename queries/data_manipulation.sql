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