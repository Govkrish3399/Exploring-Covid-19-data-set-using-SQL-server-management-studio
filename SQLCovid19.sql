select * from SQLProject..CovidDeaths
where location like '%states%' and continent is not null
order by 2,3

--select * from SQLProject..CovidVaccinations

--Explore total_cases vs total_deaths
-- Shows the likelihood of dying if people get covid

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From SQLProject..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2

--Total Cases vs Population

-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From SQLProject..CovidDeaths
--Where location like '%states%'
order by 1,2

-- What will be the infection rate per population, and list out countries with high infection rates

Select Location,Population, MAX(total_cases) as HighestInfectionCounts,  MAX((total_cases/population))*100 as PercentPopulationInfected
From SQLProject..CovidDeaths
where total_cases is not null
Group by location, Population
order by PercentPopulationInfected desc 


-- list countries with highest death counts

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From SQLProject..CovidDeaths
Where continent is not null and location not in('World', 'European Union', 'International')
Group by Location
order by TotalDeathCount desc

--Globally representing the number of death cases reported

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From SQLProject..CovidDeaths
where continent is not null 
order by 1,2

-- What would be the average reproduction rate per continent

Select continent, AVG(cast(reproduction_rate as float)) AS AverageReproductionRate
from SQLProject..CovidDeaths where continent is not null
group by continent
order by 1 desc

-- The date with the highest number of new cases worldwide

Select date,MAX(new_cases) as TotalNewCases 
from SQLProject..CovidDeaths where continent is not null
group by date
order by TotalNewCases desc

-- Calculate the average stringency index for each year to understand how strict COVID-19 restrictions where in Asia

select date, location, avg(stringency_index) as AverageStringency
from SQLProject..CovidVaccinations
where iso_code='BTN' and stringency_index is not null
group by date, location
order by AverageStringency

-- Showing the Total Population versus Vaccine Receieved

-- Showing the perecentage of population that has receieved atleast one Covid vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLProject..CovidDeaths dea
Join SQLProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Created a temp table to find the Percentage of population who has receieved atleast one covid vaccine

DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQLProject..CovidDeaths dea
Join SQLProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.location not in('World', 'European Union', 'International')
--order by 2,3
Select * , (RollingPeopleVaccinated/Population)*100 as PercentagePeopleRollingVaccine
From PercentPopulationVaccinated


















