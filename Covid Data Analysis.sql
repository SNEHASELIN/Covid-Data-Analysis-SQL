
select * from PortfolioProject ..coviddeath 
where continent is not null
order by 3,4

select * from PortfolioProject ..covid_vac order by 3,4



select Location,date,total_cases,new_cases,total_deaths, population
from PortfolioProject ..coviddeath order by 1,2

--Total Cases vs Total Deaths in UK

select Location,date,total_cases,total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from PortfolioProject ..coviddeath 
where Location like'%United Kingdom%'
order by 1,2

--Total Cases vs Population

select Location,date,population,total_cases, (total_cases/population)*100 as InfectionPercentage
from PortfolioProject ..coviddeath 
--where Location like'%United Kingdom%'
order by 1,2

--Countries with Highest Rate of Infection relative to Population
select Location,population,max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as InfectionPercentage
from PortfolioProject ..coviddeath 
--where Location like'%United Kingdom%'
GROUP BY Location,population
order by InfectionPercentage DESC

--Countries with Highest Death Rate relative to Population
select Location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject ..coviddeath 
--where Location like'%United Kingdom%'
where continent is not null
GROUP BY Location
order by TotalDeathCount DESC

--Death in each Continent

select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject ..coviddeath 
--where Location like'%United Kingdom%'
where continent is not  null
group by continent
order by TotalDeathCount DESC


==--Global Scenario

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 as DeathPercentage
from PortfolioProject ..coviddeath 
--where Location like'%United Kingdom%'
where continent is not null
--group by date
order by 1,2

--Total Population vs Vaccinations
with popvac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(bigint,v.new_vaccinations)) over  (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeath d
join
PortfolioProject..covid_vac v
on d.location=v.location
and d.date=v.date
where d.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100 
from popvac



--Temp Table
drop table if exists PercentPopulationVaccinated 
create table PercentPopulationVaccinated(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into PercentPopulationVaccinated
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(bigint,v.new_vaccinations)) over  (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeath d
join
PortfolioProject..covid_vac v
on d.location=v.location
and d.date=v.date
--where d.continent is not null

select *,(RollingPeopleVaccinated/population)*100 from PercentPopulationVaccinated

--Creating View


Use PortfolioProject
Go
create view P as
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(bigint,v.new_vaccinations)) over  (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from PortfolioProject..coviddeath d
join
PortfolioProject..covid_vac v
on d.location=v.location
and d.date=v.date
where d.continent is not null


select * from P