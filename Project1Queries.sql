
--Select * From PortfolioProject..CovidDeaths
--Order by 3,4

--Select * From PortfolioProject..CovidVacs
--Order by 3,4

-- Select our data


Select Location, date, total_cases,new_cases,total_deaths, population 
from PortfolioProject..CovidDeaths
Order by 1,2

-- Looking at total cases vs total deaths
-- Chance of dying if you had Covid

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases*100) as DeathPercentage 
from PortfolioProject..CovidDeaths
Where Location like '%korea%'
Order by 1,2

-- Looking at total cases vs Population
-- Chance of getting Covid

Select Location, date, Population, total_cases, (total_cases/Population*100) as CovidPercentage 
from PortfolioProject..CovidDeaths
Where Location like '%states'
Order by 1,2

-- Looking at the Max Infection Rate of each country

Select Location, Population, max(total_cases) as MaxCases, max((total_cases/Population*100)) as MaxInfection
From PortfolioProject..CovidDeaths
Group By Location, Population
Order by MaxInfection Desc

-- Looking at the Max Death Rate of each country

Select Location, Population, max(total_cases) as MaxCases, max(total_deaths) as MaxDeath, (max(total_deaths)/max(total_cases)*100) as MaxDeathRate
From PortfolioProject..CovidDeaths
Where continent is not null
and Location NOT LIKE 'North Korea'
Group By Location, Population
Order by MaxDeathRate Desc

-- Looking at the countries with highest death count per population

Select Location, Population, max(cast(total_deaths as int)) as MaxDeath
From PortfolioProject..CovidDeaths
Where continent is not null
--and Location NOT LIKE 'North Korea'
Group By Location, Population
Order by MaxDeath Desc

-- Looking at the continents with highest death count per population

Select Continent, max(cast(total_deaths as int)) as MaxDeath
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
Order by MaxDeath Desc

-- Looking at the continents with highest death count per population where the data does the grouping for us

Select location, max(cast(total_deaths as int)) as MaxDeath
From PortfolioProject..CovidDeaths
Where continent is null
and location not like '%income%'
and location not like '%international%'
Group By location
Order by MaxDeath Desc

-- Looking at global numbers for new cases and new deaths

Select date, sum(new_cases) as GlobalNewCases, sum(cast(new_deaths as int)) as GlobalNewDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as GlobalDeathtoCasePercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group By date
Order by date

-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingVacCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacs vac
	On dea.date = vac.date
	and dea.location = vac.location
Where dea.continent is not null
Order by 2,3

--Side Note
--cast(x.a as int) is the same as convert(int,x.a)

-- Using CTE to do more with the query above

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations,RollingVacCount)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,Sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingVacCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacs vac
	On dea.date = vac.date
	and dea.location = vac.location
Where dea.continent is not null
--Order by 2,3
)

Select *, RollingVacCount/Population*100 as VaxPercentage
From PopvsVac
order by 2,3

-- Using Temp Table

Drop Table if exists #PercentPopVaxxed
Create Table #PercentPopVaxxed
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingVacCount numeric
)

Insert into #PercentPopVaxxed
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,Sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingVacCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacs vac
	On dea.date = vac.date
	and dea.location = vac.location
Where dea.continent is not null
--Order by 2,3

Select *, RollingVacCount/Population*100 as VaxPercentage
From #PercentPopVaxxed

-- Create a View

Create View PercentPopVaxView as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,Sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingVacCount
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacs vac
	On dea.date = vac.date
	and dea.location = vac.location
Where dea.continent is not null

Select *
From PercentPopVaxView