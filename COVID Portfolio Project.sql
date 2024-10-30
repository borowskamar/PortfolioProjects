-- Select Data that we are going to be using

Select Continent, Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
Order by 2, 3;

-- Looking at Total Cases vs Total Deaths in Poland

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where location in ('Poland');

-- Looking at total cases vs population in Polands. Shows what percentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
From PortfolioProject.dbo.CovidDeaths
where location in ('Poland');


-- Looking at countries with highest infection rate compared to population

Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as InfectionRate
From PortfolioProject.dbo.CovidDeaths
Group by location, population
Order by InfectionRate DESC;

-- Showing countries with highest death count per population

Select Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Group by location
Order by TotalDeathCount DESC;

-- issue: in some of the rows the name of the continent is added to the location column and the continent column is set to null. Let's get rid of such rows

Select Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount DESC;


-- let's break things down by continent
Select continent, MAX(total_deaths) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount DESC;

-- it seems that the correct way would be to actually select location column where continent is set to NULL to get information about a specific continent (because of the structure of the data)
Select Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount DESC;


-- Global numbers 

Select date, SUM(new_cases) as total_new_cases_OnThatDay, SUM(new_deaths) as total_new_deaths_OnThatDay, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where continent is not null
group by date
order by 1,2;



-- Looking at the second table

Select *
From PortfolioProject.dbo.CovidVaccinations;


-- Let's join these two tables

Select *
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Order by 3,4;


-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, population, new_vaccinations
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
Order by 2,3;


-- Do a rolling count of new vaccinations

Select dea.continent, dea.location, dea.date, population, new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
Order by 2,3;




-- We want to know how many people in a specific country are vaccinated. We will create a CTE to be 
-- able to use the RollingPeopleVaccinated column in a separate query

With PopvsVac (Continent, Location, Date, Population, new_vacccinations, RollingPeopleVaccinated) as

(
Select dea.continent, dea.location, dea.date, population, new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3 
)

Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac
Order by 2,3


-- We can do the exact same thing by creating a temporary table 

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, population, new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3 


Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated



-- Creating  view to store data for later visualizations

DROP VIEW PercentPopulationVaccinatedView2


Use ProjectPortfolio
GO
Create View PercentPopulationVaccinatedView as
Select dea.continent, dea.location, dea.date, population, new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3
