select *
from FirstPortofolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--from FirstPortofolioProject..CoivdVaccinations
--order by 3,4

--Select data yang akan dipakai

Select location, date, total_cases, new_cases, total_deaths, population
from FirstPortofolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Menunjukan persentase kematian dari total kasus
Select location, date, total_cases, total_deaths, Round ((total_deaths/total_cases)*100,4) as [Presentase Kematian (%)]
from FirstPortofolioProject..CovidDeaths
Where continent is not null
order by 1,2

--menunjukan persentase kematian dari total kasus di Indonesia (with where statment)
Select location, date, total_cases, total_deaths, Round ((total_deaths/total_cases)*100,4) as [Presentase Kematian (%)]
from FirstPortofolioProject..CovidDeaths
Where location like 'Indonesia'
order by 2

-- Persentase total kasus dan populasi
Select location, date, total_cases, population, Round ((total_cases/population)*100,4) as [Persentase yang terkena covid (%)]
from FirstPortofolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Persentase total Case dan populasi di Indonesia
Select location, date, total_cases, population, Round ((total_cases/population)*100,4) as [Persentase yang terkena covid (%)]
from FirstPortofolioProject..CovidDeaths
Where location like 'Indonesia'
order by 1,2

--Infeksi terbanyak yang terjadi di negara tertentu
Select location, MAX (total_cases) as HighestInfection, population, Max(Round(((total_cases/ population)*100),4)) as [Persentase yang terkena covid (%)]
from FirstPortofolioProject..CovidDeaths
Where continent is not null
Group by location, population
order by [Persentase yang terkena covid (%)] desc

--Banyaknya manusia yang meninggal di berbagai
Select location, max (total_deaths) as TotalDeathCount
from FirstPortofolioProject..CovidDeaths
Where continent is not null  --Because some continent in the data is store in the location column and have null continent data
Group by location
order by TotalDeathCount desc

--Banyaknya manusia yang meninggal di berbagai benua
Select continent, max (total_deaths) as TotalDeathCount
from FirstPortofolioProject..CovidDeaths
Where continent is not null  --Because some continent in the data is store in the location column and have null continent data
Group by continent
order by TotalDeathCount desc

--Menampilkan benua dengan tingkat kematian tertinggi
Select top 1 continent, max (total_deaths) as TotalDeathCount
from FirstPortofolioProject..CovidDeaths
Where continent is not null  --Because some continent in the data is store in the location column and have null continent data
Group by continent

--Menampilkan banyaknyya kasus tiap hari di dunia
Select date , sum (new_cases) as JumlahKasus, Sum (new_deaths) as JumlahKematian , Round (ISNULL(SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100, 0),4) 
AS [Persentase kematian]
from FirstPortofolioProject..CovidDeaths
Where continent is not null  --Because some continent in the data is store in the location column and have null continent data
Group by date
order by 1

--Total Kasus di Dunia
Select sum (new_cases) as JumlahKasus, Sum (new_deaths) as JumlahKematian , Round (ISNULL(SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100, 0),4) 
AS [Persentase kematian]
from FirstPortofolioProject..CovidDeaths
Where continent is not null  --Because some continent in the data is store in the location column and have null continent data



--USE CTE
with PopuVsVac (continent, location, date, population, new_vaccinations, JumlahOrangVaksin)
as
(
-- total population vs total vaccination in country
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
SUM(convert (bigint, vac.new_vaccinations)) over (partition by deaths.location order by deaths.location, deaths.date Rows unbounded preceding) as JumlahOrangVaksin
from FirstPortofolioProject..CovidDeaths as deaths
join FirstPortofolioProject..CoivdVaccinations as vac
	on deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null
)

Select *, Round ((JumlahOrangVaksin/population) * 100,4)  as PersentaseJumlahOrangVaksin
from PopuVsVac 
order by  2,3


--temp Table
Drop table if exists #PersentaseVaksinPopulasi
Create Table #PersentaseVaksinPopulasi
(
continent nvarchar (300),
Location nvarchar (300),
Date datetime,
population bigint,
new_vaccinations int,
JumlahOrangVaksin bigint,
)
insert into #PersentaseVaksinPopulasi
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
SUM(convert (bigint, vac.new_vaccinations)) over (partition by deaths.location order by deaths.location, deaths.date Rows unbounded preceding) as JumlahOrangVaksin
from FirstPortofolioProject..CovidDeaths as deaths
join FirstPortofolioProject..CoivdVaccinations as vac
	on deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null

Select *, Round ((JumlahOrangVaksin / convert (float , population)) * 100,4)  as PersentaseJumlahOrangVaksin
from #PersentaseVaksinPopulasi

--Create view for later data visualization
create view PersentaseVaksinPopulasi as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
SUM(convert (bigint, vac.new_vaccinations)) over (partition by deaths.location order by deaths.location, deaths.date Rows unbounded preceding) as JumlahOrangVaksin
from FirstPortofolioProject..CovidDeaths as deaths
join FirstPortofolioProject..CoivdVaccinations as vac
	on deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null