select *
from PortfolioProject..CovidDeaths
order by 3, 4


select MAX(total_cases), SUM(CAST(new_cases AS BIGINT)), location
from PortfolioProject..CovidDeaths
where location = 'India'
GROUP BY location


--select *
--from PortfolioProject..CovidVaccinations
--order by 3, 4

SELECT location, date, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_deaths, total_cases, population, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1, 2

--Looking at total cases vs population
--Shows what percentage of people got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location = 'United States'
ORDER BY 1, 2

--Looking at countries with highest infection rate compared to population

SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location = 'United States'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Showing countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) AS TotaltDeathCount
FROM PortfolioProject..CovidDeaths
where Continent is not null
--Need to add continent in above clause as there are some locations which are not countries but continents and have continent as null
GROUP BY location
ORDER BY TotaltDeathCount DESC

-- LET'S BREAK THIS DOWN BY CONTINENTS
--Showing continents with the highest death count per population


SELECT continent, MAX(cast(total_deaths as int)) AS TotaLDeathCount
FROM PortfolioProject..CovidDeaths
where Continent is not null
--Need to add continent in above clause as there are some locations which are not countries but continents and have continent as null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT  SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent IS NOT NULL 
order by 1, 2
--GROUP BY date, location
--ORDER BY  DeathPercentage DESC, date

--Looking at total population vs vaccinations


SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, CAST(dea.date AS DATETIME)) 
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100- Cannot use a newly created column for calculations, so we use CTE ot Temp table
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



--Use CTE

WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, CAST(dea.date AS DATETIME)) 
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac
ORDER BY 2, 3

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPeopleVaccinated
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, CAST(dea.date AS DATETIME)) 
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPeopleVaccinated
ORDER BY 2, 3



--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, CAST(dea.date AS DATETIME)) 
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

