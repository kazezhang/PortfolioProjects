Select *
From [Portfolio project]..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From [Portfolio project]..CovidVacinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio project]..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows how likely you are to contract covid in your country

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From [Portfolio project]..CovidDeaths
where location like'%states%'
order by 1,2

--Looking at the total cases vs the populations
-- Shows what percentage of population got covid
Select Location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentPopulationInfected
From [Portfolio project]..CovidDeaths
where location like'%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio project]..CovidDeaths
--where location like'%states%'
Group by Location, population
order by PercentPopulationInfected desc


--Showing country with the highest death count per population
Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio project]..CovidDeaths
--where location like'%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Break things down by continent
Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio project]..CovidDeaths
--where location like'%states%'
Where continent is null
Group by Location
order by TotalDeathCount desc

-- Showing contintents withe the highest death count per population
Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio project]..CovidDeaths
--where location like'%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio project]..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) 
	as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From [Portfolio project]..CovidDeaths dea
Join [Portfolio project]..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Use CTE

With PopvsVAc (Continent, Location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) 
	as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From [Portfolio project]..CovidDeaths dea
Join [Portfolio project]..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVAc



--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio project]..CovidDeaths dea
Join [Portfolio project]..CovidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to Store data for later visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio project]..CovidDeaths dea
Join [Portfolio project]..CovidVacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



