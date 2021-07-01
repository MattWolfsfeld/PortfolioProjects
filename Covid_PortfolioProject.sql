Select *
From dbo.CovidDeaths
where continent is not null
order by 3,4

--Select *
--From dbo.CovidVaccinations
--order by 3,4

--Select the Data that we are going to be using.
Select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths


Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population

Select location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
from dbo.CovidDeaths
--Where location like '%states%'
order by 1,2

--Looking at Countries with the highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as InfectionPercentage
from dbo.CovidDeaths
--Where location like '%states%'
Group by location, population
order by InfectionPercentage desc

--Showing Countries with the highest death count per population

Select location,Max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
--Where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc

--Let's break things down by continent


--Showing the continents with highest death count

Select continent,Max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

Select  date, sum(new_cases)as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths
--Where location like '%states%'
where continent is not null
group by date
order by 1,2

select *
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3


-- Using CTE
with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--Using Temp Table

Drop table if exists #PercentPopulationVaccination
create table #PercentPopulationVaccination
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

insert into #PercentPopulationVaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccination

--Creating view to store data for later visualizations

Create View PercentPopulationVaccination as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccination