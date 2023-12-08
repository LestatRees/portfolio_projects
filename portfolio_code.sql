/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


select
	*
from
	covid_deaths
where continent is not null
order by
    3
  , 4


--select data we are going to be analyzing

select
	location
  , date
  , total_cases
  , new_cases
  , total_deaths
  , population
from
	covid_deaths
where continent is not null
order by
    1,2

--looking at total cases vs total deaths
--shows the percantage chance of dying if you contract covid in a specific country

select
	location
  , date
  , total_cases
  , total_deaths
  , (total_deaths/total_cases) * 100 as death_percentage
from
	covid_deaths
where
	location
		like '%state%'
order by
    1
  , 2

--looking at total cases vs population
--shows percantage of population infected with covid

select
    location
  , date
  , population
  , total_cases
  , (total_cases/population) * 100 as covid_percantage
from
	covid_deaths
where
	location
		like '%state%'
order by
    1
  , 2

--countries with the highest infection rates compared to population

select
    location
  , continent
  , population
  , max(total_cases) as highest_infection_count
  , max((total_cases/population)) * 100 as percent_of_population_infected
from
	covid_deaths
--where
--	location
--		like '%state%'
group by
    location
  , population
  , continent
order by
	percent_of_population_infected desc

--showing countries with the highest death count per population

select
    location
  , continent
  , max(cast(total_deaths as int)) as total_death_count
from
	covid_deaths
--where
--	location
--		like '%state%'
	where continent is not null
group by
    location
  , continent
order by
	total_death_count desc

--break things down by continent

--showing the continents with the highest death count

select
    continent
  , max(cast(total_deaths as int)) as total_death_count
from
	covid_deaths
--where
--	location
--		like '%state%'
	where continent is not null
group by
	continent
order by
	total_death_count desc


--global numbers

select
    date
  , sum(new_cases) as total_cases
  , sum(cast(new_deaths as int)) as total_deaths
  , sum(cast(new_deaths as int))/sum(new_cases) * 100 as death_percantage
from
	covid_deaths
--where
--	location
--		like '%state%'
where continent is not null
group by 
	date
order by
    1
  , 2

--total of reported data 

select
    sum(new_cases) as total_cases
  , sum(cast(new_deaths as int)) as total_deaths
  , sum(cast(new_deaths as int))/sum(new_cases) * 100 as death_percantage
from
	covid_deaths
--where
--	location
--		like '%state%'
where continent is not null
--group by 
--	date
order by
    1
  , 2


--looking at total population vs vaccinations

select
    dea.continent
  , dea.location
  , dea.date
  , dea.population
  , vac.new_vaccinations 
  , sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinations
--, (rolling_vaccinations/population) * 100
from
	covid_deaths dea
		join
			covid_vaccinations vac
			on dea.location = vac.location
			and dea.date = vac.date
where dea.continent is not null
order by
    2
  , 3
		

 
 --using a CTE

with pop_vs_vac
	( continent
   	, location
	, date
	, population
	, new_vaccinations
	, rolling_vaccinations
	) as
(
select
    dea.continent
  , dea.location
  , dea.date
  , dea.population
  , vac.new_vaccinations 
  , sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinations
--, (rolling_vaccinations/population) * 100
from
	covid_deaths dea
		join
			covid_vaccinations vac
			on dea.location = vac.location
			and dea.date = vac.date
where dea.continent is not null
--order by
--    2
--  , 3
)
;
select
  *
  , (rolling_vaccinations/population) * 100 as percent_vacinated
from
	pop_vs_vac

--using a temp table

drop table if exists #percent_population_vac
create table #percent_population_vac
	( continent nvarchar(255)
  	, location nvarchar(255)
	, date datetime
	, population numeric
	, new_vaccinations numeric
	, rolling_vaccinations numeric
	)

insert into #percent_population_vac
select
    dea.continent
  , dea.location
  , dea.date
  , dea.population
  , vac.new_vaccinations 
  , sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinations
--, (rolling_vaccinations/population) * 100
from
	covid_deaths dea
		join
			covid_vaccinations vac
			on dea.location = vac.location
			and dea.date = vac.date
--where dea.continent is not null
--order by
--    2
--  , 3


select
  *
  , (rolling_vaccinations/population) * 100 as percent_vacinated
from
	#percent_population_vac



--creating multiple views to store data for later vizes

create view percent_population_vac as
select
    dea.continent
  , dea.location
  , dea.date
  , dea.population
  , vac.new_vaccinations 
  , sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccinations
--, (rolling_vaccinations/population) * 100
from
	covid_deaths dea
		join
			covid_vaccinations vac
			on dea.location = vac.location
			and dea.date = vac.date
where dea.continent is not null
;
select
	*
from
	percent_population_vac
;

--second one

create view percent_population_infected as

select
    location
  , continent
  , population
  , max(total_cases) as highest_infection_count
  , max((total_cases/population)) * 100 as percent_of_population_infected
from
	covid_deaths
where 
	continent is not null
group by
    location
  , population
  , continent

select
	*
from
	percent_population_infected
