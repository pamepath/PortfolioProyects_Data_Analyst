select *
 from PortfolioProject..CovidDeaths
 Where continent is not null
 order by 3,4

	--select *
	--from PortfolioProject..CovidVaccinations
	--order by 3,4

-- Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1, 2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where Location like '%honduras%'
order by 1, 2

-- Looking at Total cases vs Population
--Shows what % of population got covid
Select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentageOfPopulationInfected
From PortfolioProject..CovidDeaths
--where Location like '%honduras%'
order by 1, 2

--Looking at Countries whit highest infection rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentageOfPopulationInfected
From PortfolioProject..CovidDeaths
--where Location like '%honduras%'
Group by Location, Population
order by PercentageOfPopulationInfected desc

--Let's break things down by location
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
--where Location like '%honduras%'
Where continent is null
Group by Location
order by TotalDeathCount desc

--Let's break things down by continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
--where Location like '%honduras%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Showing Countries whit highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
--where Location like '%honduras%'
Where continent is null
Group by Location
order by TotalDeathCount desc


--Showing Continents whit highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
--where Location like '%honduras%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where Location like '%honduras%'
where continent is not null
--Group by date
order by 1, 2

-- Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where Location like '%honduras%'
where continent is not null
Group by date
order by 1, 2




--Looking at total population vs vaccinations

--Use CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as  RollingPeopleVaccinated

From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 1, 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as  RollingPeopleVaccinated

From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order by 1, 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Create a view to store data for later visualizations
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as  RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 1, 2, 3


Select * 
From PercentPopulationVaccinated
