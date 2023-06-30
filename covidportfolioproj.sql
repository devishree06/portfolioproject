SELECT *
FROM portfolioproject..coviddeath$
WHERE continent is not null
ORDER BY 3,4

--Total cases VS Total deaths (globally) 

SELECT location, date,  total_cases, total_deaths,(CAST( total_deaths AS float)/CAST(total_cases AS int))*100 AS deathpercentage
FROM portfolioproject..coviddeath$
WHERE continent is not null
ORDER BY 1,2

--Total cases VS Total deaths (in India)

SELECT location, date, total_cases, total_deaths,(CAST( total_deaths AS float)/CAST(total_cases AS int))*100 AS deathpercentage
FROM portfolioproject..coviddeath$
WHERE location like '%indi%'
ORDER BY 1,2

--Total cases VS Population (globally) 

SELECT location, date, population, total_cases,(CAST( total_cases AS float)/CAST(population AS decimal(12,0)))*100 AS infectionpercentage
FROM portfolioproject..coviddeath$
WHERE continent is not null
ORDER BY 1,2

--Total cases VS Population (in India)

SELECT location, date, population, total_cases,(CAST( total_cases AS float)/CAST(population AS decimal(12,0)))*100 AS infectionpercentage
FROM portfolioproject..coviddeath$
WHERE location like '%indi%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT location, population,MAX(total_cases) AS highestinfectioncount ,MAX(CAST( total_cases AS float)/CAST(population AS decimal(12,0)))*100 AS highestinfectionpercentage
FROM portfolioproject..coviddeath$
WHERE continent is not null
GROUP BY  location, population
ORDER BY highestinfectionpercentage desc

--countries with highest death count per population 

SELECT location,MAX(cast(total_deaths as int)) as Totaldeathcount
FROM portfolioproject..coviddeath$
WHERE continent is not null
GROUP BY  location
ORDER BY Totaldeathcount desc

--Breaking things down by continent

SELECT continent,MAX(cast(total_deaths as int)) as Totaldeathcount
FROM portfolioproject..coviddeath$
WHERE continent is not null
GROUP BY continent
ORDER BY Totaldeathcount desc

--GLOBAL NUMBERS

SELECT  SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 as globaldeathpercent
FROM portfolioproject..coviddeath$
where continent is not null
ORDER BY 1,2


--Total population VS vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
FROM portfolioproject..coviddeath$ dea
join portfolioproject..covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
ORDER BY 2,3




--CTE
with popvsvac ( continent, location, date, population, new_vaccinations,rollingpeoplevaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
FROM portfolioproject..coviddeath$ dea
join portfolioproject..covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (rollingpeoplevaccinated/population)*100
FROM popvsvac


--create temp table

DROP table if exists #percentagepeoplevaccinated
Create table #percentagepeoplevaccinated
(
continent nvarchar(100),
location nvarchar(100),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric,
)

Insert into #percentagepeoplevaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
FROM portfolioproject..coviddeath$ dea
join portfolioproject..covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--ORDER BY 2,3
SELECT *, (rollingpeoplevaccinated/population)*100 as percentofpeoplevaccinated
FROM #percentagepeoplevaccinated


--creating view to store data for visualiation later

Create view  percentagepeoplevaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
FROM portfolioproject..coviddeath$ dea
join portfolioproject..covidvaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

SELECT *
FROM  percentagepeoplevaccinated


