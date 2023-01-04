-- Checking my tables 
select * from practiseProject..CovidDeaths 
order by location,date ; 

select * from practiseProject..CovidVaccinations 
order by location,date ;

--selecting the data that I am  going to use 
select location , date, total_cases ,new_cases, total_deaths ,population
from practiseProject..CovidDeaths
order by location , date ; 

-- looking for the percentage of deaths in my Tunisia 
SELECT location , date, total_cases , total_deaths , ROUND((total_deaths/total_cases)*100,2) as deathPercentage
FROM practiseProject..CovidDeaths
WHERE location = 'Tunisia'; 

--showing the percentage of infection

select location , date, population , total_cases, round((total_cases/population)*100, 2) as infectionPercentage
from practiseProject..CovidDeaths
--where location = 'Tunisia'
order by location ,date;  

--looking for the country with highest infection rate according to population 
select location, population , max(total_cases),  max (round((total_cases/population)*100, 2)) as maxInfectedCountry
from practiseProject..CovidDeaths
group by location,population
order by maxInfectedCountry desc ;


--showing countries with the highest death count per population 
select location , max(cast(total_deaths as int)) totalDeathCount 
from practiseProject..CovidDeaths 
where continent is not null 
group by location  
order by totalDeathCount desc;

--chechking the total deathCount percontinent 
select continent , max(cast(total_deaths as int)) totalDeathCount 
from practiseProject..CovidDeaths 
where continent is not null 
group by continent  
order by totalDeathCount desc;

--checking statistics worlwilde 
select date , sum(new_cases) totalCases, sum(cast (new_deaths as int) )as totalDeaths,
 sum(cast (new_deaths as int) ) / sum(new_cases)*100 as deathPercentage 
from practiseProject..CovidDeaths 
where continent is not null 
group by date 
order by date 
;


--looking at the total population against vaccination 
with vaccinationPercentage  (continent , location , date, population, new_vaccination,totalVaccinations)
as (
select dea.continent, dea.location ,dea.date, dea.population ,vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int) ) over(partition by dea.location order by dea.location , dea.date)
as totalVaccinations
from practiseProject..CovidDeaths as dea
inner join practiseProject..CovidVaccinations vac 
on  dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3; 
)
select * , (totalVaccinations/population)*100 as vacPercentage
from 
vaccinationPercentage ; 


--creating table popluationvsVaccination 
--in case you need to change something in table drop and create again 
drop table if exists percentageOfvaccinatedPeople

create table percentageOfvaccinatedPeople(
continent nvarchar(255), 
location nvarchar(255), 
date datetime , 
population numeric, 
new_vaccinations numeric, 
total_vaccinaiton numeric
);

insert into percentageOfvaccinatedPeople 
select dea.continent, dea.location ,dea.date, dea.population ,vac.new_vaccinations,
sum(cast (vac.new_vaccinations as int) ) over(partition by dea.location order by dea.location , dea.date)
as totalVaccinations
from practiseProject..CovidDeaths as dea
inner join practiseProject..CovidVaccinations vac 
on  dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3; 
;

select *, (total_vaccinaiton/population)*100
from percentageOfvaccinatedPeople