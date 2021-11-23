Select *
From PortfolioProject..Deaths
order by 3, 4

--Select *
--From PortfolioProject..Vaccinations
--order by 3, 4

--Selecting data that we are going to be using 

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..Deaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (Cast (total_deaths AS Float) / Cast (total_cases AS Float))*100 as death_rate
From PortfolioProject..Deaths
order by 1, 2

-- Looking at Total Cases vs Population
-- Showing what Percentage of population got covid

SELECT location, date, total_cases, population, (Cast (total_cases AS Float) / Cast (population AS Float))*100 as cases_rate
From PortfolioProject..Deaths
where location like '%states%'
order by 1, 2

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(Cast (total_cases AS Float) / Cast (population AS Float))*100 as InfectionRate
From PortfolioProject..Deaths
Group by location, population
order by InfectionRate desc

-- Showing countries with the highest death count per population 
SELECT location, MAX(CAST(total_deaths as float)) as TotalDeathCount
From PortfolioProject..Deaths
where continent is null
Group by location
order by TotalDeathCount desc

-- Showing continents with the highest death count per population 
SELECT continent, MAX(CAST(total_deaths as float)) as TotalDeathCount
From PortfolioProject..Deaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers
SELECT date, SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths,
SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage
From PortfolioProject..Deaths
where continent is not null
Group by date
order by 1, 2

-- Looking at Total Population vs Vaccinations

-- USING CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..Deaths dea
Join PortfolioProject..Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- TEMP TABLE

Create Table #PopulationVaccinatedPercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PopulationVaccinatedPercentage
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..Deaths dea
Join PortfolioProject..Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Select *, (RollingPeopleVaccinated/population)*100
From #PopulationVaccinatedPercentage


-- Creating view to store data for later visualizations	

Create View PopulationVaccinatedPercentage as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccination/population)*100
From PortfolioProject..Deaths dea
Join PortfolioProject..Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3


