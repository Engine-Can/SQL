--Covid 19 Data Exploration 

--Skills used: Joins, CTE's, Windows Functions, Aggregate Functions, Converting Data Types



Select *
From `august-monument-354616.covid_data.covid_deaths`
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From `august-monument-354616.covid_data.covid_deaths`
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From `august-monument-354616.covid_data.covid_deaths`
Where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From `august-monument-354616.covid_data.covid_deaths`
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From `august-monument-354616.covid_data.covid_deaths`
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From `august-monument-354616.covid_data.covid_deaths`
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From `august-monument-354616.covid_data.covid_deaths`
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From `august-monument-354616.covid_data.covid_deaths`
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations AS int))OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From `august-monument-354616.covid_data.covid_deaths` dea
Join `august-monument-354616.covid_data.covid_vac` vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac --(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From`august-monument-354616.covid_data.covid_deaths` dea
Join `august-monument-354616.covid_data.covid_vac` vac
On dea.location = vac.location
            and dea.date = vac.date
where dea.continent is not null 
--order by 2,3    
)
Select *, (RollingPeopleVaccinated/Population)*100 as percent_cov
From PopvsVac



