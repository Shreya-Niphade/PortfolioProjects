Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contarct covid in your country
Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Total cases vs Population
--Shows what percentage of population got covid
Select location, date, population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population
Select location, population,MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location='india'
Group by location, population
order by PercentPopulationInfected desc

--Showing countries with the highest Death Count per population
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location='india'
where continent is not null
Group by location
order by TotalDeathCount desc

--Showing the continents with the highest deathcounts
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location='india'
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select   SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--GROUP BY date
order by 1,2

--Looking at total population vs vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopsvsVac (Continent, Location, Date, Population,New_Vaccnations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopsvsVac

--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location=vac.location and dea.date=vac.date
--where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualization

Create  View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select * from PercentPopulationVaccinated