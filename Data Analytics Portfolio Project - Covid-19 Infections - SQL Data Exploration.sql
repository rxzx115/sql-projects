-- to find daily death rate in the US

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases) * 100, 2) AS death_rate
FROM molten-thought-441320-u6.Example.coviddeaths
WHERE location = 'United States'




-- to find daily infection rate in the US

SELECT location, date, total_cases, population, ROUND((total_cases/population) * 100, 2) AS infection_rate
FROM molten-thought-441320-u6.Example.coviddeaths
WHERE location = 'United States'




-- to find daily infection rate and death rate in US in one query
SELECT location, date, total_cases, total_deaths, population, ROUND((total_cases/population) * 100, 2) AS infection_rate, ROUND((total_deaths/total_cases) * 100, 2) AS death_rate
FROM molten-thought-441320-u6.Example.coviddeaths
WHERE location = 'United States'




-- to find the location, date, total cases, total deaths, population on the date WHERE each country had the max deaths by using CTEs and the rank function. Uses a cte in the code.
WITH RankedDeaths AS (
    SELECT
        location,
        date,
        total_cases,
        total_deaths,
        population,
        RANK() OVER (PARTITION BY location ORDER BY total_deaths DESC, date ASC) AS rank_deaths
    FROM molten-thought-441320-u6.Example.coviddeaths
    WHERE continent IS NOT NULL
)
SELECT location, date, total_cases, total_deaths, population
FROM RankedDeaths
WHERE rank_deaths = 1
ORDER BY location ASC




-- to find the day with the highest infection rate by country and related details
WITH RankedInfections AS (
    SELECT
        location,
        date,
        total_cases,
        total_deaths,
        population,
        RANK() OVER (PARTITION BY location ORDER BY total_cases/population DESC, date ASC) AS rank_infections
    FROM molten-thought-441320-u6.Example.coviddeaths
    WHERE continent IS NOT NULL
)
SELECT location, date, total_cases, total_deaths, population, ROUND(total_cases/population * 100, 2) AS infection_rate
FROM RankedInfections
WHERE rank_infections = 1
ORDER BY infection_rate DESC




-- to find the day with the highest death rate by country and related details
WITH RankedDeaths AS (
    SELECT
        location,
        date,
        total_cases,
        total_deaths,
        population,
        RANK() OVER (PARTITION BY location ORDER BY total_deaths/total_cases DESC, date ASC) AS rank_deaths
    FROM molten-thought-441320-u6.Example.coviddeaths
    WHERE continent IS NOT NULL
)
SELECT location, date, total_cases, total_deaths, population, ROUND(total_deaths/total_cases * 100, 2) AS death_rate
FROM RankedDeaths
WHERE rank_deaths = 1
ORDER BY death_rate DESC




-- to find the highest number of infections and infection rates by country
SELECT location, population, MAX(total_cases) AS max_infections, ROUND(MAX(total_cases) / population * 100, 2) AS infection_rate
FROM molten-thought-441320-u6.Example.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infection_rate DESC




-- to find countries with highest death count per population
SELECT location, population, MAX(total_deaths) AS max_deaths, ROUND(MAX(total_deaths) / population * 100, 2) AS death_rate
FROM molten-thought-441320-u6.Example.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY max_deaths DESC




-- to find the highest deaths by continent
SELECT continent, MAX(total_deaths) AS max_deaths
FROM molten-thought-441320-u6.Example.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY max_deaths DESC




-- to find the max deaths by continent and the related data points by using CTEs
WITH RankedDeaths AS (
    SELECT
        continent,
        date,
        total_cases,
        total_deaths,
        population,
        RANK() OVER (PARTITION BY continent ORDER BY total_deaths DESC, date ASC) AS rank_deaths
    FROM molten-thought-441320-u6.Example.coviddeaths
    WHERE continent IS NOT NULL
)
SELECT continent, date, total_cases, total_deaths, population
FROM RankedDeaths
WHERE rank_deaths = 1
ORDER BY continent ASC




-- to find the max deaths by location and the related data points by using CTEs
WITH RankedDeaths AS (
    SELECT
        location,
        date,
        total_cases,
        total_deaths,
        population,
        RANK() OVER (PARTITION BY location ORDER BY total_deaths DESC, date ASC) AS rank_deaths
    FROM molten-thought-441320-u6.Example.coviddeaths
    WHERE continent IS NOT NULL
)
SELECT location, date, total_cases, total_deaths, population
FROM RankedDeaths
WHERE rank_deaths = 1
ORDER BY location ASC




-- to find the max deaths by using continent instead of country
SELECT location, MAX(total_deaths) AS max_deaths
FROM molten-thought-441320-u6.Example.coviddeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY max_deaths DESC




-- to find the number of deaths daily and globally
SELECT date, SUM(new_cases) AS total_new_cases, SUM(new_deaths) AS total_new_deaths, ROUND(SUM(new_deaths) / SUM(new_cases) * 100, 2) AS death_rate
FROM molten-thought-441320-u6.Example.coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2




-- to find the total number of cases and deaths globally
SELECT SUM(new_cases) AS total_new_cases, SUM(new_deaths) AS total_new_deaths, ROUND(SUM(new_deaths) / SUM(new_cases) * 100, 2) AS death_rate
FROM molten-thought-441320-u6.Example.coviddeaths
WHERE continent IS NOT NULL




--to find vaccinations and populations by location and date
SELECT d.location, d.date, d.population, v.new_vaccinations
FROM molten-thought-441320-u6.Example.coviddeaths d
INNER JOIN molten-thought-441320-u6.Example.covidvaccines v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL




-- to create a running count of new vaccinations by location and day without a cte 
SELECT *, ROUND(running_vaccinations / population * 100, 2) AS running_vaccinations_percent
FROM
(SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS running_vaccinations
FROM molten-thought-441320-u6.Example.coviddeaths d
INNER JOIN molten-thought-441320-u6.Example.covidvaccines v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL)




-- This uses a cte 

WITH PopvsVac AS (
    SELECT d.continent, 
    d.location, 
    d.date, 
    d.population, 
    v.new_vaccinations, 
    SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS running_vaccinations
    FROM molten-thought-441320-u6.Example.coviddeaths d
    INNER JOIN molten-thought-441320-u6.Example.covidvaccines v
    ON d.location = v.location AND d.date = v.date
    WHERE d.continent IS NOT NULL
    )
SELECT *, 
ROUND(running_vaccinations/population * 100,2) AS running_vaccinations_rate
FROM PopvsVac




-- to create a table
CREATE TABLE molten-thought-441320-u6.Example.runningvaccines AS
WITH PopvsVac AS (
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS running_vaccinations
FROM molten-thought-441320-u6.Example.coviddeaths d
INNER JOIN molten-thought-441320-u6.Example.covidvaccines v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
)
SELECT *, ROUND(running_vaccinations/population * 100,2) AS running_vaccinations_percent
FROM PopvsVac




-- drop a table
DROP TABLE molten-thought-441320-u6.Example.runningvaccines




--create a view for data visualization
--to create a view
CREATE VIEW molten-thought-441320-u6.Example.runningvaccinationsview AS
WITH PopvsVac AS (
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS running_vaccinations
FROM molten-thought-441320-u6.Example.coviddeaths d
INNER JOIN molten-thought-441320-u6.Example.covidvaccines v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
)
SELECT *, ROUND(running_vaccinations/population * 100,2) AS running_vaccinations_percent
FROM PopvsVac




--to SELECT the view
SELECT *
FROM molten-thought-441320-u6.Example.runningvaccinationsview




-- to drop the view
DROP VIEW `molten-thought-441320-u6.Example.runningvaccinationsview`




--to find total new cases, total new deaths, and average death rate globally
SELECT SUM(new_cases) AS total_new_cases, SUM(new_deaths) AS total_new_deaths, ROUND(SUM(new_deaths) / SUM(new_cases) * 100, 2) AS avg_death_rate
FROM molten-thought-441320-u6.Example.coviddeaths
WHERE continent IS NOT NULL




--to find total deaths by continent
SELECT continent, SUM(new_deaths) AS total_deaths
FROM molten-thought-441320-u6.Example.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent




-- to find the highest infection rate for each country
SELECT location, population, MAX(total_cases) AS max_infection_count, ROUND(MAX(total_cases) / population *100, 2) AS max_infection_rate
FROM molten-thought-441320-u6.Example.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY max_infection_rate DESC




-- to find daily infection rates by country by using new cases data
WITH PopvsInf AS (
SELECT d.continent, d.location, d.date, d.population, d.new_cases, SUM(d.new_cases) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS running_cases
FROM molten-thought-441320-u6.Example.coviddeaths d
WHERE d.continent IS NOT NULL
)
SELECT *, ROUND(running_cases/population * 100,2) AS running_cases_percent
FROM PopvsInf




-- to find daily infection rates by country by using total cases data
SELECT location, population, date, MAX(total_cases) AS max_infections, ROUND(MAX(total_cases / population) * 100, 2) AS max_infection_rate
FROM molten-thought-441320-u6.Example.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
