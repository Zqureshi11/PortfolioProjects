
select * from CovidDeaths
order by 3,4;

--Select * from CovidVaccination
--order by 3,4;

select location, date, total_cases,new_cases, total_deaths, population
from CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths
select location, date, total_cases,new_cases, total_deaths, (total_deaths/total_cases)*100 as 'Death Percentage'
from CovidDeaths
where location like '%state%'
order by 1,2

-- Total Cases vs Population
-- Shows what Percentage of population got Covid
select location, date, population,  total_cases, (total_cases/population)*100 as ' Percentage population Infected'
from CovidDeaths
where location like '%Pakista%'
order by 1,2


-- Highest Total Cases 
-- By COuntry
select location 'Location', population 'Population',  max(total_cases) as 'Highest Infected Cases', max(total_cases/population)*100 as ' Percent population infected'
from CovidDeaths
group by location , population
order by 4 desc


-- Highest People Died  Countries by country with percentage population
-- By COuntry
select location 'Location', population 'Population',  max(total_deaths) as 'Highest Death', max(total_deaths/population)*100 as ' Percent population infected'
from CovidDeaths
group by location , population
order by 3 desc


-- Highest People Died  by country
-- By COuntry
select location 'Country', max(cast(total_deaths as int)) as 'Total Death'
from CovidDeaths
where continent is not null
group by location
order by 2 desc

-- Highest People Died  by Continent
-- By Continent
select continent 'Continent', max(cast(total_deaths as int)) as 'Total Death'
from CovidDeaths
where continent is not null
group by continent
order by 2 desc


-- looking at Total Population vs vaccination
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int, cv.new_vaccinations)) Over (Partition by cd.Location order by cd.location, cd.Date) as 'RollingPeopleVaccinated'
from 
CovidDeaths cd 
join CovidVaccination cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2,3



-- Finding out how many people are vaccinated in that country 
-- USE CTE (A Common Table Expression, also called as CTE in short form, is a temporary named result set that you can reference within a SELECT, INSERT, UPDATE, or DELETE statement. The CTE can also be used in a View.)

With PopVsVaccin (continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int, cv.new_vaccinations)) Over (Partition by cd.Location order by cd.location, cd.Date) as 'RollingPeopleVaccinated'
from 
CovidDeaths cd 
join CovidVaccination cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 as '% People Vaccinated'
from 
PopVsVaccin
-- Taking example country Albania, the above query indicates, 12% of the total population of Albania is vaccinated

-- Creating Temp table can do the above job too
Drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
( Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentagePopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int, cv.new_vaccinations)) Over (Partition by cd.Location order by cd.location, cd.Date) as 'RollingPeopleVaccinated'
from 
CovidDeaths cd 
join CovidVaccination cv
on cd.location = cv.location
and cd.date = cv.date
--where cd.continent is not null

select *, (RollingPeopleVaccinated/Population)*100 as '% People Vaccinated'
from 
#PercentagePopulationVaccinated


-- Creating view to store data for later visualization
Create view PercentagePopulationVaccinated as 
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int, cv.new_vaccinations)) Over (Partition by cd.Location order by cd.location, cd.Date) as 'RollingPeopleVaccinated'
from 
CovidDeaths cd 
join CovidVaccination cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3
