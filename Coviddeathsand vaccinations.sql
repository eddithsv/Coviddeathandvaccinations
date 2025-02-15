-- Covid 19 Data Exploration 

-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, 
-- Creating Views, Converting Data Types


Use portfolio_project;
SELECT *
FROM CovidDeaths;

SELECT * FROM CovidDeaths 
ORDER BY 3,4 
LIMIT 5;

SELECT location, date, new_cases, total_cases, total_deaths, population 
FROM CovidDeaths 
ORDER BY location, date; 
-- LIMIT 5;

 -- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY location, date;

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage 
FROM CovidDeaths 
WHERE location LIKE '%India' AND continent IS NOT NULL
ORDER BY location, date ;

-- Highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS Highestinfectioncount, MAX((total_cases/population)*100) AS populationinfected_Percentage
FROM CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY populationinfected_Percentage desc;

-- Showing countries with highest death count per population
SELECT location, MAX(total_deaths) AS total_death
FROM CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_deathS desc;

-- BY CONTINENT
SELECT continent, MAX(total_deaths) AS total_death
FROM CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_deathS desc;

-- Showing continents with highest death count
SELECT location, MAX(total_deaths) AS total_death
FROM CovidDeaths 
WHERE continent IS NULL
GROUP BY location
ORDER BY total_deaths desc;

-- Global numbers
SELECT continent, MAX(total_deaths) AS total_death
FROM CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_deathS desc;

SELECT SUM(new_cases) AS newcases, SUM(new_deaths) AS newdeath, (SUM(new_deaths)/SUM(new_cases))*100 AS DEATH_PERCENTAGE
FROM coviddeaths 
WHERE continent IS NOT NULL
ORDER BY 1 desc;

-- Covidvaccinations
SELECT *
FROM covidvaccinations

-- Join Covid deaths and Covid Vaccinations
SELECT *
FROM coviddeaths d1
JOIN covidvaccinations d2
ON d1.location=d2.location
AND d1.date=d2.date
LIMIT 5;

SELECT d1.continent, d1.location, d1.date, population, new_vaccinations
FROM coviddeaths d1
JOIN covidvaccinations d2
ON d1.location=d2.location
AND d1.date=d2.date
WHERE d1.continent IS NOT NULL
ORDER BY 1,2,3
LIMIT 5;

SELECT d1.continent, d1.location, d1.date, population, new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY d1.location ORDER BY d1.location, d1.date) AS rolling_vaccinated
FROM coviddeaths d1
JOIN covidvaccinations d2
ON d1.location=d2.location
AND d1.date=d2.date
WHERE D1.continent IS NOT NULL
ORDER BY 1,2,3;


--  Using CTE to perform Calculation on Partition By in previous query

With PopVsVacc( Continent, Location, Date, Population, New_vaccinations, Rollingpeople_vaccinated) AS
(
SELECT d1.continent, d1.location, d1.date, population, new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY d1.location ORDER BY d1.location, d1.date) AS rolling_vaccinated
FROM coviddeaths d1
JOIN covidvaccinations d2
ON d1.location=d2.location
AND d1.date=d2.date
WHERE D1.continent IS NOT NULL
-- ORDER BY 1,2,3
)
SELECT *, (Rollingpeople_vaccinated/Population)*100 AS Percentage_vaccinated
FROM PopVsVacc

-- TEMP TABLE

DROP TABLE IF EXISTS #PeopleVaccinated
CREATE TABLE #PeopleVaccinated
(CONTINENT nvarchar(255),
LOCATION nvarchar(255),
DATE datetime,
POPULATION numeric,
New_vaccination numeric,
Rollingpeople_vaccinated numeric);
INSERT INTO #PeopleVaccinated
SELECT d1.continent, d1.location, d1.date, population, new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY d1.location ORDER BY d1.location, d1.date) AS rolling_vaccinated
FROM coviddeaths d1
JOIN covidvaccinations d2
ON d1.location=d2.location
AND d1.date=d2.date
-- WHERE D1.continent IS NOT NULL
-- ORDER BY 1,2,3

SELECT *
FROM #PeopleVaccinated;

DROP TEMPORARY TABLE IF EXISTS PeopleVaccinated;
CREATE TEMPORARY TABLE PeopleVaccinated (
    CONTINENT VARCHAR(255),
    LOCATION VARCHAR(255),
    DATE TEXT,
    POPULATION NUMERIC,
    New_vaccination NUMERIC,
    Rollingpeople_vaccinated NUMERIC
);

INSERT INTO PeopleVaccinated
SELECT 
    d1.continent, 
    d1.location, 
    d1.date, 
    d1.population, 
    d2.new_vaccinations, 
    SUM(d2.new_vaccinations) OVER (PARTITION BY d1.location ORDER BY d1.date) AS Rollingpeople_vaccinated
FROM coviddeaths d1
JOIN covidvaccinations d2
ON d1.location = d2.location
AND d1.date = d2.date;

SELECT *
FROM PeopleVaccinated;

