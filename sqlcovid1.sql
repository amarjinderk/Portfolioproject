Select *
from [portfolio database]..coviddeaths
order by 3,4

--Select *
--from [portfolio database]..covidvaccine
--order by 3,4
--to show all the data for vaccine db
--total cases vs/ total deaths
Select location,date,total_cases,new_cases,total_deaths,population
from [portfolio database]..coviddeaths
order by 1,2
  
--shows likelihood of dying in canada
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from [portfolio database]..coviddeaths
where location like '%canada%'
order by 1,2

--total cases vs population
--percentage of population get covid
Select location,date,population,total_cases,(total_deaths/total_cases)*100 as percentageofpopulationinfected
from [portfolio database]..coviddeaths
--where location like '%canada%'
order by 1,2
--countries with higher infection rate compare to population
Select location,population,max(total_cases) as highestinfectioncount,max((total_deaths/total_cases))*100 as percentageofpopulationinfected
from [portfolio database]..coviddeaths
--where location like '%canada%'
group by location,population
order by percentageofpopulationinfected desc
--desc (descending order)

--countries with highest deathcount per population
Select location, max(cast(total_deaths as int))as totaldeathcount
from [portfolio database]..coviddeaths
where continent is not null
group by location
order by totaldeathcount desc
--highest deathcount per population for continent  
Select continent, max(cast(total_deaths as int))as totaldeathcount
from [portfolio database]..coviddeaths
where continent is not null
group by continent
order by totaldeathcount desc


--global number 

Select sum(new_cases) as totalnewcases, sum(cast (new_deaths as int)) as totalnewdeaths,
sum(cast (new_deaths as int))/sum(new_cases)*100 as totaldeathpercentage
--(total_deaths/total_cases)*100 as percentageofpopulationinfected
from [portfolio database]..coviddeaths
--where location like '%canada%'
where continent is not null 
--group by date
order by 1,2

--joining covid vaccine and covid death
Select * 
from [portfolio database]..coviddeaths dea
join [portfolio database]..covidvaccine vac
on dea.location=  vac.location
and dea.date=vac.date

--CTE
with popvsvac(Continent,location, date, population,new_vaccinations ,rollingpeoplevaccinated)
as
(--total population vs vaccination take by people
select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
,Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from [portfolio database]..coviddeaths dea
join [portfolio database]..covidvaccine vac
on dea.location=  vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (rollingpeoplevaccinated/Population)*100 as percentageofpeoplevaccinated
From PopvsVac

--temp table 
-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table
if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
,Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from [portfolio database]..coviddeaths dea
join [portfolio database]..covidvaccine vac
on dea.location=  vac.location
and dea.date= vac.date
--where dea.continent is not null
--order by 2,3
Select *, (rollingpeoplevaccinated/Population)*100
From #PercentPopulationVaccinated


Select * 
from #PercentPopulationVaccinated

DROP table #PercentPopulationVaccinated;






-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [portfolio database]..coviddeaths dea
join [portfolio database]..covidvaccine vac
on dea.location=  vac.location
and dea.date= vac.date
where dea.continent is not null