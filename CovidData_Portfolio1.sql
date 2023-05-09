-- EXPLORE CovidDeaths DATASETS

SELECT * 
From "PortfolioProject".."CovidDeaths"
WHERE continent is not null
order by 3,4

	-- Select data that I use
SELECT location, date, total_cases, new_cases,total_deaths,population
From "PortfolioProject".."CovidDeaths"
WHERE continent is not null
ORDER BY 1,2

	-- Total Cases vs Total Deaths (Shows likelihood of dying if you contract covid in countires) 
SELECT location, date, total_cases, total_deaths, round((Total_deaths/total_cases)*100,3) as DeathPercentage
From "PortfolioProject".."CovidDeaths"
WHERE location like '%states'
and continent is not null
ORDER BY 1,2

	-- Total case vs Population (Show what percentage of population got Covid) 
SELECT location, date, population, total_cases, round((Total_cases/population)*100,3) as DeathPercentage
From "PortfolioProject".."CovidDeaths"
WHERE continent is not null
ORDER BY 1,2

	-- Counties with highest infection rate compared to population 
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/population)*100) as PercentPopulationInfected
From "PortfolioProject".."CovidDeaths"
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

	-- Break down the Total Death Count by location (including null value)   
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
From "PortfolioProject".."CovidDeaths"
-- WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- BREAK DOWN THINGS DOWN BY CONTINENT

	-- Showing continents with the highest death count per population 
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From "PortfolioProject".."CovidDeaths"
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

	-- Countries with Highest Death Count per Population 
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
From "PortfolioProject".."CovidDeaths"
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From "PortfolioProject".."CovidDeaths"
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From "PortfolioProject".."CovidDeaths"
WHERE continent is not null
ORDER BY 1,2


--EXPLORE CovidVaccinaion DATASETS

SELECT * 
FROM PortfolioProject..CovidVaccination

-- Looking at Total Population vs Vaccinations (Using Join) 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	 ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- The number of accumulative vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	   sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
-- 	   (RollingPeopleVaccinated/dea.population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	 ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USE CTE
WITH PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	   sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	 ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 
from PopvsVac


-- TEMP TABLE 
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_Vaccinations numeric,
  RollingPeopleVaccinated numeric
  )

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	   sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	 ON dea.location=vac.location and dea.date=vac.date
-- WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	   sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	 ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null


SELECT *
FROM PercentPopulationVaccinated
