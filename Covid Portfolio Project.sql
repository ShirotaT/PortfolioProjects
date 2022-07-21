select *
From PortfolioProject..CovidDeaths
where continent is not null
Order By location asc

--select *
--From PortfolioProject..CovidVaccinations
--Order By location asc

select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where location = 'indonesia'
order by date asc

--Looking at Total Cases vs Total Deaths

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location = 'indonesia'
order by date asc

--Looking at Total Cases vs Population

select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
where location = 'indonesia'
order by date asc

--Looking at Indonesia Highest Infection Rate compared to Population

select location, Max(total_cases) as HighestInfection, population, MAX((total_cases/population))*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
Group by location, population
order by InfectedPercentage desc

--Showing Country with Highest Death Count per Population

select location, Max(cast(total_deaths as int)) as TotalDeath
From PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by TotalDeath desc

--Showing Continents with highest death count

select location, Max(cast(total_deaths as int)) as TotalDeath
From PortfolioProject..CovidDeaths
where continent is null
Group by location
order by TotalDeath desc


--Global numbers
select date, SUM(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location = 'indonesia'
where continent is not null
Group by date
order by 1,2

select SUM(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location = 'indonesia'
where continent is not null
--Group by date
order by 1,2

--Looking total population vs vaccinated

select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea. date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--Use CTE

with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) 
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea. date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)

select* , (rollingpeoplevaccinated/Population)*100 
from PopvsVac

--Temp Table

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccintaion numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea. date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

select* , (rollingpeoplevaccinated/Population)*100 
from #PercentPopulationVaccinated

--creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea. date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select *
from PercentPopulationVaccinated