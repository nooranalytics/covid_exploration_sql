-- Tableau Queries--
USE Portfolio;

-- 1
-- Global numbers 
Select  SUM(new_cases) as total_new_cases, SUM(new_deaths) as total_new_deaths,( SUM(new_deaths)/SUM(new_cases)) *100 as gloabl_percentage
From coviddeaths
Where continent is not null
Order by 1,2;

-- 2 
-- Showing countries with the highest death count per population 
-- These numbers are correct, could be due to how the data was organised 
Select location, MAX(total_deaths) as total_death_count
From coviddeaths
Where continent is  null
Group by location
Order by total_death_count DESC;

-- 3
-- Looking at countries with highest infection rate compared to population 
Select  location, population, MAX(total_cases) as highest_infection_count,MAX( (total_cases/population))*100 AS per_pop_infected
From coviddeaths
Where continent is not null
Group by location, population
Order by per_pop_infected DESC; 

-- 4
-- Looking at countries with highest infection rate compared to population 
Select  continent, date, population, MAX(total_cases) as highest_infection_count,MAX( (total_cases/population))*100 AS per_pop_infected
From coviddeaths
Where continent is not null
Group by continent, population, date
Order by per_pop_infected DESC; 



-- 5
-- Looking at new vaccinations per day, rolling average 
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) Over(partition by location Order by cd.location,date) as rolling_total_vaccinations 
From coviddeaths as cd                                        
Inner Join covidvaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
Where cd.continent is not null
Order by 2,3;


-- 6 
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


