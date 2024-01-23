-- Total Cases vs Total Deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'Poland'
ORDER BY 1,2

-- Total Cases vs Population, percentage of population got Covid
SELECT Location, date, population, total_cases, (total_cases/population) * 100 AS %PopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'Poland'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'Poland'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

-- Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'Poland'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Continents with Highest Death Count per Population
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'Poland'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global numbers
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int)) / SUM(new_cases)* 100 AS death_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'Poland'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Total Population vs Vaccinations

With PopvsVacc (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/ population)*100
FROM PopvsVacc