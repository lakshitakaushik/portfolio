select *
from portfolioproject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from portfolioproject..CovidVaccinations
--order by 3,4

select location, date,total_cases,new_cases,total_deaths,population
from portfolioproject..CovidDeaths
where continent is not null
order by 1,2

--total deaths vs total cases
select location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from portfolioproject..CovidDeaths
where location like 'india'
and continent is not null
order by 1,2


--total cases vs populaton
select location, date,total_cases,population,(total_cases/population)*100 as casepercentage
from portfolioproject..CovidDeaths
where location like 'india'
and continent is not null
order by 1,2


--country with highest infecton rate 
select location, population, MAX(total_cases) as highestinfectioncount,MAX(total_cases/population)*100 as percentageaffected
from portfolioproject..CovidDeaths
where continent is not null
group by location, population
order by 5 desc

--country with highest deathcount per population
  select location,MAX (cast(total_deaths as int)) as highestdeathcount, population, MAX(total_deaths/population)*100 as percentagedeaths
from portfolioproject..CovidDeaths
where continent is not null
group by location,population
order by 2 desc

--continent with highest deaths
select location,MAX (cast(total_deaths as int)) as highestdeathcount
from portfolioproject..CovidDeaths
where continent is null
group by location
order by 2 desc

--global numbers

select date,sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercent
from portfolioproject..CovidDeaths
where continent is not null
group by date
order by 1,2
--remove date to see total world no

--joining tables
select *
from portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date

--apply order and certain cols only
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- vaccination per location 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
from portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
order by 2,3

--vaccination percentage
--use cte
with popvsvac (continent,location,date,population,new_vaccinations, rollingpeoplevaccinated)
as
(

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by 
dea.location,dea.date) as rollingpeoplevaccinated
from portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/Population)*100
from popvsvac


--temp table
drop table if exists #percentpopuvaccinated
create table #percentpopuvaccinated
(continent nvarchar(255),
location nvarchar(255),
data datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
Insert into #percentpopuvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by 
dea.location,dea.date) as rollingpeoplevaccinated
from portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
--order by 2,3
select *, (rollingpeoplevaccinated/Population)*100
from #percentpopuvaccinated


--create view for visualisation
create view percentpopuvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by 
dea.location,dea.date) as rollingpeoplevaccinated
from portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null