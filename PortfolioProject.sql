
--select * from CovidDeaths
--where continent is not NULL
--order by 3,4

--select * from CovidVaccinations
--order by 3,4 

-----------------------------selecting the data 
--select location, date, total_cases, new_cases, total_deaths, population
--from CovidDeaths
--order By 1,2

-----------------------------Total Cases vs Total Deaths(likelihood of dying if a person is covid positive)
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not NULL
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%India%' and continent is not NULL
order by 1,2 

-----------------------------Total Cases vs Population (shows covid +ve People)
select location, date, population, total_cases, (total_cases/population)*100 as CovidCasesPercentage
from CovidDeaths
where continent is not NULL
order by 1,2

select location, date, population, total_cases, (total_cases/population)*100 as CovidCasesPercentage
from CovidDeaths
where location like '%India%' and continent is not NULL
order by 1,2

-----------------------------Countries with highest infection rate compared to population
select Location, Population, max(total_cases) as HighestInfectionRate, Max(total_cases/population)*100 as
InfectedPopluationPercentage
from CovidDeaths
where continent is not NULL
group by Location,population
order by InfectedPopluationPercentage desc 

-----------------------------Countries with highest death count per population
select Location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not NULL
Group by Location
order by TotalDeathCount desc

-----------------------------Continents with highest death Count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not NULL
group by location
order by TotalDeathCount desc

-----------------------------Global Numbers
select date, sum(New_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 
as NewDeathPetrcentage
from CovidDeaths
where continent is not null
group by date
order by 1,2 

----Total cases, deaths, deathpercentage
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100
as DeathPercentage
from CovidDeaths
where continent is not null

-----------------------------------joining the two tables
select *
from CovidDeaths as Cdea
join CovidVaccinations as Cvac
  on Cdea.Location=Cvac.Location
  and Cdea.date=Cvac.date

---------------------Total Population vs Vaccination
-------using CTE
with popVsvac(continent,location,date,population,new_vaccinations, RollingPeopleVaccinated)
as
(select Cdea.continent, Cdea.location, Cdea.date, Cdea.population, Cvac.new_vaccinations,
sum(convert(int,Cvac.new_Vaccinations))over(partition by Cdea.location order by Cdea.location, Cdea.date) as RollingPeopleVaccinated
from CovidDeaths as Cdea
join CovidVaccinations as Cvac
    on Cdea.Location=Cvac.location 
	and Cdea.date=Cvac.date
where Cdea.continent is not null
--order by 2,3
)
select continent,location,population, (max(RollingPeopleVaccinated)/population)*100
from popVsvac
where location='Albania'
group by continent,location,population

-------using tempTable
drop table if exists #TempPopVsVac
create table #TempPopVsVac
( Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #TempPopVsVac
select Cdea.continent, Cdea.location, Cdea.date, Cdea.population, Cvac.new_vaccinations,
sum(convert(int,Cvac.new_Vaccinations))over(partition by Cdea.location order by Cdea.location, Cdea.date) as RollingPeopleVaccinated
from CovidDeaths as Cdea
join CovidVaccinations as Cvac
    on Cdea.Location=Cvac.location 
	and Cdea.date=Cvac.date
where Cdea.continent is not null
--order by 2,3

select Continent,location,population, (max(RollingPeopleVaccinated)/population)*100
from #TempPopVsVac
where location='Albania'
group by Continent,location,population



--------------------------Creating view to store data for later visualizations

create view percentPeopleVaccinated as
select Cdea.continent, Cdea.location, Cdea.date, Cdea.population, Cvac.new_vaccinations,
sum(convert(int,Cvac.new_Vaccinations))over(partition by Cdea.location order by Cdea.location, Cdea.date) as RollingPeopleVaccinated
from CovidDeaths as Cdea
join CovidVaccinations as Cvac
    on Cdea.Location=Cvac.location 
	and Cdea.date=Cvac.date
where Cdea.continent is not null
--order by 2,3

select *
from percentPeopleVaccinated 