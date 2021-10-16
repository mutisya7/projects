--select  *
--from covidproject..covid19deaths
--order by 3,4

--select * 
--from covidproject..covidvaccination
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from covidproject..covid19deaths
order by 3,4

-- loooking at total cases vs total deaths
--possible death if you contract coid 19
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from covidproject..covid19deaths
where location like '%kenya%'
order by 1,2


--looking at total cases vs population
--population of people with covid
select location,date,population,total_cases,(total_cases/population)*100 as population_affected
from covidproject..covid19deaths
where location like '&kenya&'
order by 1,2

--countries with highest infection rate compared with countries
select location,population, MAX(total_cases) as highestinfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from covidproject..covid19deaths
group by location,population
order by PercentPopulationInfected desc


--showing countries with the highest death count per population
select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from covidproject..covid19deaths
where continent is not null
group by location
order by TotalDeathCount desc


--continents
select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from covidproject..covid19deaths
where continent is not null
group by continent
order by TotalDeathCount desc

--continents null
select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from covidproject..covid19deaths
where continent is null
group by continent
order by TotalDeathCount desc

--global numbers
select date,SUM(new_cases),SUM(cast(new_deaths as int)) --,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from covidproject..covid19deaths
where continent is not null
group by date
order by 1,2

--death percentage across the globe
select SUM(new_cases) as total_cases,
SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from covidproject..covid19deaths
where continent is not null
group by date
order by 1,2

--vaccinations joint with deaths
select *
from covidproject..covid19deaths dea
join covidproject..covidvaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
     
--looking at population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingVaccinated
from covidproject..covid19deaths dea
join covidproject..covidvaccination vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE
With PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from covidproject..covid19deaths dea
join covidproject..covidvaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3
)
Select *,(RollingPeopleVaccinated/population) * 100
From PopvsVac

--Using temp table

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from covidproject..covid19deaths dea
join covidproject..covidvaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *,(RollingPeopleVaccinated/population) * 100
From #PercentPopulationVaccinated

Create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from covidproject..covid19deaths dea
join covidproject..covidvaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3
--table 1
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From covidproject..covid19deaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--table2
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From covidproject..covid19deaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc
--table 3

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covidproject..covid19deaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc
--table 4
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covidproject..covid19deaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc