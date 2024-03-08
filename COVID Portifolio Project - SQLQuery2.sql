SELECT *
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
ORDER BY 1,2


--looking at total cases vs total deaths
-- shows likehood of dying if you contract covid in your country

SELECT Location, date, total_cases,total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
Where location like '%brazil%'
ORDER BY 1,2


--looking at total cases vs population

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%brazil%'
ORDER BY 1,2



--looking at countries with highest infection rate compared to population


SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%brazil%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


-- showing countries with the hightest death count per population


SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%brazil%'
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc



--lets break things down by continent
--showing the continents with the hightest death count per population


SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%brazil%'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc




-- GLOBAL NUMBERS



SELECT SUM(new_cases) as NC, SUM(new_deaths) as ND, SUM(new_deaths) as ND, SUM(cast(total_deaths as int)/cast(total_cases as int))*100 as DeathPercentage  --total_cases,total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%brazil%'
WHERE continent is not null
--Group by date
ORDER BY 1,2




--looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3



--USE CTE


WITH PopvsVac (Continent, Location, Dae, Population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated




--Creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3



SELECT *
FROM PercentPopulationVaccinated