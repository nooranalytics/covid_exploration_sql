-- Data Exploration -- 

-- Select the data that we're going to be working with
Select location, date, total_cases, new_cases, total_deaths, population 
From coviddeaths
Where continent is not null
Order by 1,2;

-- Looking at total cases vs total deaths 
Select continent, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS death_percentage
From coviddeaths
Where continent is not null
Order by 1,2;

-- Looking at total cases vs total deaths  - drillind down to countries
-- Shows the likelihood of dying in the respective country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS death_percentage
From coviddeaths
WHERE location LIKE '%Germany%' and continent is not null
Order by 1,2;


-- Looking at total cases vs population
-- Shows the percentage of the population has covid
Select location, date, total_cases, population, (total_deaths/population)*100 AS contracted_covid
From coviddeaths
WHERE location LIKE '%Germany%' and continent is not null
Order by 1,2;

-- Looking at countries with highest infection rate compared to population 
Select  location, population, MAX(total_cases) as highest_infection_count,MAX( (total_cases/population))*100 AS per_pop_infected
From coviddeaths
Where continent is not null
Group by location, population
Order by per_pop_infected DESC; 

-- Breaking things down by continent 
Select continent, MAX(total_deaths) as total_death_count
From coviddeaths
Where continent is not null
Group by continent
Order by total_death_count DESC;

-- Showing countries with the highest death count per population 
Select location, MAX(total_deaths) as total_death_count
From coviddeaths
Where continent is not null
Group by location
Order by total_death_count DESC;


-- Showing countries with the highest death count per population 
-- These numbers are correct, could be due to how the data was organised 
Select location, MAX(total_deaths) as total_death_count
From coviddeaths
Where continent is  null
Group by location
Order by total_death_count DESC;


-- Global numbers 
Select  SUM(new_cases) as total_new_cases, SUM(new_deaths) as total_new_deaths,( SUM(new_deaths)/SUM(new_cases)) *100 as gloabl_percentage
From coviddeaths
Where continent is not null
Order by 1,2;


-- Global numbers drilled down by date
Select date, SUM(new_cases) as total_new_cases, SUM(new_deaths) as total_new_deaths,( SUM(new_deaths)/SUM(new_cases)) *100 as gloabl_percentage
From coviddeaths
Where continent is not null
Group by date
Order by 1,2;


-- joining with the vaccinations table 
Select * 
From coviddeaths as cd
Inner Join covidvaccinations as cv
on cd.location = cv.location
and cd.date = cv.date;

				   
-- Looking at total population vs vaccination 
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
From coviddeaths as cd                                        
Inner Join covidvaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
Where cd.continent is not null
Order by cv.new_vaccinations DESC;


-- Looking at new vaccinations per day, rolling average 
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) Over(partition by location Order by cd.location,date) as rolling_total_vaccinations 
From coviddeaths as cd                                        
Inner Join covidvaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
Where cd.continent is not null
Order by 2,3;

-- Looking at total populations vs vaccinatins using CTE
With popvsvac as (
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) Over(partition by location Order by cd.location,date) as rolling_total_vaccinations
From coviddeaths as cd                                        
Inner Join covidvaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
Where cd.continent is not null
Order by 2,3)
Select *, (rolling_total_vaccinations/population) * 100 as percent_vaccinated
From popvsvac;




-- Looking at total populations vs vaccinatins using TEMP TABLE
-- TEMP TABLE 
-- First, we create a temporary table with the necessary columns
CREATE TEMPORARY TABLE temp_popvsvac (
    continent VARCHAR(50),
    location VARCHAR(50),
    date DATE,
    population FLOAT,
    new_vaccinations FLOAT,
    rolling_total_vaccinations FLOAT
);

-- Then, we populate the temporary table with data
INSERT INTO temp_popvsvac (continent, location, date, population, new_vaccinations, rolling_total_vaccinations)
SELECT 
    cd.continent, 
    cd.location, 
    cd.date, 
    cd.population, 
    cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER(PARTITION BY location ORDER BY cd.location, date) as rolling_total_vaccinations
FROM 
    coviddeaths as cd                                        
INNER JOIN 
    covidvaccinations as cv
ON 
    cd.location = cv.location
    AND cd.date = cv.date
WHERE 
    cd.continent is not null;

-- Finally, we query the temporary table
SELECT 
    *, 
    (rolling_total_vaccinations/population) * 100 as percent_vaccinated
FROM 
    temp_popvsvac;

DROP TABLE if exists temp_popvsvac;



-- Create view to store data for later visualizations 
Create View PercentPeopleVaccindated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) Over(partition by location Order by cd.location,date) as rolling_total_vaccinations 
From coviddeaths as cd                                        
Inner Join covidvaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
Where cd.continent is not null;

-- Query view 
Select * 
From PercentPeopleVaccindated

