select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2;

#Looking at Total cases vs Total Deaths

select location, date, total_cases, total_deaths, round((total_deaths /total_cases)*100,2) as DeathPercentage
from coviddeaths

order by 1,2;

#Looking at Total cases vs Population

select location, date, total_cases, population, round(( total_cases/population)*100,2) as CasesPercentage
from coviddeaths
order by 1,2;

#Looking at countries with highest infection rate compared to population


select location,population, max(total_cases) as  'highest infection Count',  round(max( total_cases/population)*100,2) as 'Percentage Population infected'
from coviddeaths
group by location, population
order by 4 desc;

#Showing countries  with highest death count per population

select location,population, max(total_deaths) as  'highest deaths Count',  round(max( total_deaths/population)*100,2) as 'Percentage Population infected'
from coviddeaths
group by location, population
order by 4 desc;


#view
create view infoContinent as (select distinct(continent), sum(population), sum(total_cases), sum(total_vaccinations), sum(total_deaths), 
round((sum(total_vaccinations)/sum(population))*100,2) as 'Percentage vaccination', round((sum(total_deaths)/sum(population))*100,2) as 'Percentage deaths',
round((sum(total_deaths) /sum(total_cases))*100,2) as TotalDeathPercentage
from coviddeaths
where continent !=''
group by 1
order by 2 desc);

#Global numbers
select date, sum(new_cases), sum(new_deaths)
from coviddeaths
group by 1
order by 1 ;

SELECT 
    cd.continent, 
    cd.location, 
    cd.date, 
    cd.population, 
    cv.new_vaccinations, 
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date) AS total_vaccinations
FROM 
    covidvaccinations cv
JOIN 
    coviddeaths cd ON cv.location = cd.location AND cv.date = cd.date
WHERE 
    cd.continent IS NOT NULL;


#######################


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM((vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
/* (RollingPeopleVaccinated/population)*100*/
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM((vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
/*--, (RollingPeopleVaccinated/population)*100*/
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac
