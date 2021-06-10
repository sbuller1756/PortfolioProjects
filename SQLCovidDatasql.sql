select * from PortfolioProject.dbo.CovidDeaths order by 3,4

select * from PortfolioProject.dbo.CovidVaccinations order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject.dbo.CovidDeaths
order by 1,2

Alter table PortfolioProject.dbo.CovidDeaths
alter column total_deaths numeric(18,0);

Alter table PortfolioProject.dbo.CovidDeaths
alter column total_cases numeric(18,0);

Alter table PortfolioProject.dbo.CovidDeaths
alter column new_cases numeric(18,0);

Alter table PortfolioProject.dbo.CovidDeaths
alter column date date;

Alter table PortfolioProject.dbo.CovidVaccinations
alter column date date;

Alter table PortfolioProject.dbo.CovidDeaths
alter column population numeric(18,0);

--Total Cases vs Total Deaths in the United States
select Location, date, total_cases, total_deaths, (total_deaths/isnull(nullif(total_cases,0),1))*100 as DeathPercentage 
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2

--Total Cases vs Population in the United States
select Location, date, total_cases, population, (total_cases/isnull(nullif(population,0),1))*100 as InfectionPercentage 
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2

--Countries with highest infection rate 
select Location, max(total_cases) as MaxInfectionCount, population, max((total_cases/isnull(nullif(population,0),1)))*100 as InfectionPercentage 
from PortfolioProject.dbo.CovidDeaths
group by location, population
order by InfectionPercentage DESC


--Continents with highest death count per population
select location, max(total_deaths) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent =''
group by location
order by TotalDeathCount DESC


--Countries with highest death count per population
select Location, max(total_deaths) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent <>''
group by location
order by TotalDeathCount DESC


--Global numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/isnull(nullif(sum(new_cases),0),1)*100 as DeathPercentage 
from PortfolioProject.dbo.CovidDeaths
where continent <>''
group by date
order by 1,2

--Total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent <>''
order by 2,3

--CTE
With PopvsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent <>''
--order by 2,3
)

select *, (rollingpeoplevaccinated/isnull(nullif(population,0),1))*100 from PopvsVac

--temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations int,
rollingpeoplevaccinated int
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
 , sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent <>''

select *, (rollingpeoplevaccinated/isnull(nullif(population,0),1))*100 as rollingpercentvaccinated from #percentpopulationvaccinated

--view to store data for visualizations

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent <>''

select * from percentpopulationvaccinated
