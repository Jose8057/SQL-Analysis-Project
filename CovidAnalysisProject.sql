--check weather table is successfully loaded
Select *
From Portfolioproject ..CovidDeaths$
Where continent is not null
order by 3,4

--Select *
--from Portfolioproject..CovidVacines$
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolioproject ..CovidDeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows DeathPercentage of your country

Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From Portfolioproject ..CovidDeaths$
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
Select location, date,population ,total_cases, (total_cases/population)*100 as PercentofInfection
From Portfolioproject ..CovidDeaths$
Where location like '%states%'
order by 1,2

--looking highest case vs Population

Select location,population ,MAX(total_cases) as HighestinfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfection
From Portfolioproject ..CovidDeaths$
Where location like '%states%'
Group by location, population
order by PercentPopulationInfection desc

--Showing Countries with Highest Death Count per Population

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioproject ..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc


---Let's Break things down by continent
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioproject ..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--showing contintents with the highest death count
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioproject ..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers

Select date, SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage   --(total_deaths/total_cases)*100 as DeathPercentage
From Portfolioproject ..CovidDeaths$
where continent is not null
--Where location like '%states%'
Group by date
order by 1,2

--Looking at Total Population vs Vaccinations
With PopvsVac(continent, location, date, population, new_vaccinations, Uptoday) 
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as Uptoday
from Portfolioproject..CovidDeaths$ dea
Join Portfolioproject..CovidVacines$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
--use CTE
Select *, (Uptoday/population)*100
From PopvsVac

--TEMP Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Uptoday numeric
)
Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as Uptoday
from Portfolioproject..CovidDeaths$ dea
Join Portfolioproject..CovidVacines$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null

Select *, (Uptoday/population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as Uptoday
from Portfolioproject..CovidDeaths$ dea
Join Portfolioproject..CovidVacines$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated