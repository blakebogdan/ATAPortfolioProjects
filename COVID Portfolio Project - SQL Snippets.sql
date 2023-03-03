Select *
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent is not null
ORDER BY 3,4

Select *
FROM PortfolioProject.dbo.CovidVaccinations
WHERE Continent is not null
ORDER BY 3,4

--Select the data that will be used during the project
Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent is not null
ORDER BY 1,2

--Shows the likelihood of dying if you contracted COVID on a specific day in the US
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS MortalityRate
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
AND Continent is not null
ORDER BY 1,2

--Looking at the total cases vs the population
Select location, date, population, total_cases, (total_cases/population)*100 AS PercentageofPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
AND Continent is not null
ORDER BY 1,2

--What countries have the highest infection rates?
Select location, population, MAX(total_cases) as HighestCaseCount, MAX((total_cases/population))*100 AS PercentageofPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent is not null
GROUP BY Location, Population
ORDER BY PercentageofPopulationInfected DESC

--Which countries had the most deaths?
Select location,  MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent is not null
GROUP BY Location, Population
ORDER BY TotalDeathCount DESC

--What countries have the highest death count per capita
Select location, population, MAX(CAST(total_deaths as int)) as HighestDeathCount, MAX((total_deaths/population))*100 AS PercentageofPopulationDead
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent is not null
GROUP BY Location
ORDER BY PercentageofPopulationDead DESC

--Which continents had the most deaths?
Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--What are the new cases and death counts for the entire world per day?
Select date, SUM(new_cases) AS NewCases, SUM(CAST(new_deaths AS int)) AS NewDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS MortalityRate--, total_deaths, (total_deaths/total_cases)*100 AS MortalityRate
FROM PortfolioProject.dbo.CovidDeaths
WHERE Continent is not null
GROUP BY date
ORDER BY 1,2

--What are the vaccination rates globally?
--USING A CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingCountofVaccinatedPersons)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCountOfVaccinatedPersons--, (RollingCountofVaccinatedPersons/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
)
Select *, (RollingCountofVaccinatedPersons/Population)*100
FROM PopvsVac

--USING A TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingCountofVaccinatedPersons numeric
)

INSERT INTO  #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCountOfVaccinatedPersons--, (RollingCountofVaccinatedPersons/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingCountofVaccinatedPersons/Population)*100
--FROM #PercentPopulationVaccinated


--Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCountOfVaccinatedPersons--, (RollingCountofVaccinatedPersons/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null

CREATE VIEW PercentagePopulationInfected AS
Select location, date, population, total_cases, (total_cases/population)*100 AS PercentageofPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
AND Continent is not null

CREATE VIEW DailyMortalityRate AS
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS MortalityRate
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
AND Continent is not null
