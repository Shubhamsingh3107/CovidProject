use covidproject;

SELECT * FROM covidproject.coviddeath order by location,date;

select location,date,total_cases,new_cases,total_deaths,population from coviddeath order by location,date ;

--DEATH vs POPULATION
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercent from coviddeath
#where location = 'India'
order by location,date

-- TOTAL CASES vs POPULATION
select location,date,population,total_cases,(total_cases/population)*100 as infectedpercent from coviddeath
where location = 'India'
order by location,date


-- MAX TOTAL CASES vs POPULATION
select location,population,date,max(total_cases) as maxcases,max(total_cases/population)*100 as infectedpercent from coviddeath
group by location,population,date
order by infectedpercent desc


-- COUNTRY WITH HIGHEST DEATHS  (CAST & CONTINENT NOT NULL CONCEPT)
select location,max(cast(total_deaths as int)) as maxdeath from coviddeath
where continent is not null
group by location
order by maxdeath desc ;

-- CONTINENT WITH HIGHEST DEATH
select continent,sum(cast(new_deaths as int)) as maxdeath from coviddeath
where continent is not null
group by continent
order by maxdeath desc ;


--GLOBAL AFFECT
select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases)) *100 as percentdeath from coviddeath
group by date
order by date ;

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases)) *100 as percentdeath 
from coviddeath where continent is not null;

--TOTAL POPULATION VS VACCINATION (JOINING TWO TABLES)
select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations
from coviddeath as dea
join covidvaccination as vacc
on dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null
order by location,date;

--TOTAL POPULATION VS TOTAL VACCINATION and PER DAY VACCINATION
select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations,sum(cast(vacc.new_vaccinations as bigint)) over 
(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from coviddeath as dea
join covidvaccination as vacc
on dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null
order by location,date;

--TOTAL POPULATION VS TOTAL VACCINATION (in percentage)
with popvsvacc (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations,sum(cast(vacc.new_vaccinations as bigint)) over 
(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from coviddeath as dea
join covidvaccination as vacc
on dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null
--order by location,date;
)
select *,(rollingpeoplevaccinated/population)*100 as vaccperc 
from popvsvacc


--	CREATING VIEW FOR VISUALIZATION

create view populationvaccinatedperc as
select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations,sum(cast(vacc.new_vaccinations as bigint)) over 
(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from coviddeath as dea
join covidvaccination as vacc
on dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null



-- MINE

-- DEATH AND INFECTED PERCENT VS MEDIAN AGE OF COUNTRY

select dea.location,max(vacc.median_age) as median_age,
max(dea.total_cases/dea.population)*100 as infectedpercent,max(dea.total_deaths/dea.population)*100 as deathpercent
from coviddeath as dea 
join covidvaccination as vacc
on dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null 
group by dea.location
order by dea.location;


--FULLY VACCINATED PERCENTAGE VS POPULATION
select dea.location,max(dea.population) as population,max(vacc.total_boosters) as fully_vaccinated,
max(vacc.total_boosters)/max(dea.population)*100 as fully_vaccinated_percent
from coviddeath as dea
join covidvaccination as vacc
on dea.location = vacc.location
where dea.continent is not null
group by dea.location
order by fully_vaccinated_percent desc;

--GDP/per_capita Vs HDI,Beds Available,life expectancy

select dea.location,max(dea.population) as population,(max(dea.total_deaths)/max(dea.total_cases))*100 as deathpercent,
(max(dea.total_cases)/max(dea.population)*100) as infectedpercent,max(vacc.life_expectancy) as life_expectancy,
max(vacc.human_development_index) as HDI,max(vacc.gdp_per_capita) as GDP_per_capita,max(vacc.hospital_beds_per_thousand) as hospital_beds_per_thosuand
from coviddeath as dea
join covidvaccination as vacc
on dea.location = vacc.location
where dea.continent is not null
group by dea.location
--having max(total_boosters) is not null and max(dea.population) is not null
order by max(vacc.gdp_per_capita) desc;