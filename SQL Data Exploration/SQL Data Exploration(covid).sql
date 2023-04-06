/*
Data Exploration using Covid-19 Dataset
Commands used: ORDER BY, GROUP BY, AS, Aggregate Functions, CAST, JOIN, CONVERT, Partition By, CTE, Temp Table
*/

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

--Selecting the data that I am going to be using

SELECT  Location, date, total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


--Looking at the total cases vs total deaths

SELECT  Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Looking at Total Cases Vs Population
--Shows what percentage of population got Covid in USA.

SELECT  Location, date, population,total_cases,(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


--Looking at countries with Highest Infection Rate compared to Population

SELECT  Location,population,MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location,population
ORDER BY PercentPopulationInfected desc

--Showing the countries with the Highest Death Count per Population
SELECT  Location,MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL 
GROUP BY Location
ORDER BY TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
--Showing the continents with highest death counts
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL 
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Breaking Global Numbers

SELECT date, sum(new_cases)as total_cases, sum(cast(new_deaths as int ))as total_deaths,sum(cast(new_deaths as int ))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
group by date
ORDER BY 1,2

--Looking at Total Population Vs Vaccinations
SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location= vac.location
	and dea.date= vac.date

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location= vac.location
	and dea.date= vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location,dea.Date) as RollingPeopleVaccinated
,(RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location= vac.location
	and dea.date= vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE
With PopVsVac (Continent, Location, Date, Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/ population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location= vac.location
	and dea.date= vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac


--creating TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/ population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location= vac.location
	and dea.date= vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



--Creating view to store data for later Visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/ population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location= vac.location
	and dea.date= vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

select *
from PercentPopulationVaccinated