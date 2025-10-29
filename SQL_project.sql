create database Energy;
use Energy;
show tables;

select * from consum_3;
select * from country_3;
select * from emission_3;
select * from gdp_3;
select * from population_3;
select * from production_3;

# Data Analysis Questions
# General & Comparative Analysis

# What is the total emission per country for the most recent year available?
select e.country, sum(e.emission) as total_emission,year
from emission_3 as e
where e.year=(select max(year) from emission_3)
group by e.country,year
order by total_emission desc;

# What are the top 5 countries by GDP in the most recent year?
select g.country,sum(g.value) as total_gdp,year
from gdp_3 as g
where g.year=(select max(year) from gdp_3)
group by g.country,g.year
order by total_gdp desc
limit 5;


# Compare energy production and consumption by country and year. 
select c.consumption, c.country,c.year,p.production,(p.production-c.consumption) as difference
from consum_3 as c
join production_3 as p
on c.country=p.country
and c.year=p.year;
 
# Which energy types contribute most to emissions across all countries?

select `energy type`,sum(emission) as contribution
from emission_3 as e
group by `energy type`
order by contribution desc
limit 1;
 
 
 # Trend Analysis Over Time

# How have global emissions changed year over year?
select year, sum(emission) as total_emission
from emission_3 
group by year
order by total_emission desc;

# What is the trend in GDP for each country over the given years?
select year, sum(value) as GDP_Trend
from gdp_3
group by year
order by year desc;
# How has population growth affected total emissions in each country?
select p.countries,sum(p.value) as population_growth,sum(e.emission) as total_emission
from population_3 as p
join emission_3 as e
on p.countries=e.country
group by p.countries
order by total_emission desc;

# Has energy consumption increased or decreased over the years for major economies?
select c.year,c.consumption, g.value from consum_3 as c
join gdp_3 as g
on c.year=g.year
where g.value=(select max(g.value) from gdp_3)
group by g.value,c.year,c.consumption
order by c.consumption desc;
# Hence consumption increased over years for major economies


# What is the average yearly change in emissions per capita for each country?
select country,year, avg(`per capita emission`) as yearly_avg
from emission_3
group by country,year
order by year desc;
# Ratio & Per Capita Analysis

# What is the emission-to-GDP ratio for each country by year?
select e.country,e.year,sum(e.emission),g.value,round(sum(emission)/g.value,4)
from emission_3 as e
join gdp_3 as g
on e.country=g.country
and e.year=g.year
group by e.country,e.year,g.value
order by e.year;
# What is the energy consumption per capita for each country over the last decade?
alter table emission_3 rename column`per capita emission` to per_capita_emission;
select c.country,c.year,round(sum(c.consumption)/(sum(e.emission)/avg(e.per_capita_emission)),4) as total_consumption_per_capita
from consum_3 as c
join emission_3 as e
on c.country=e.country
and c.year=e.year
where c.year>=year(curdate())-10
group by c.country,c.year
order by c.country,c.year;
# How does energy production per capita vary across countries?
select p.country,p.year,sum(p.production)/pop.value as energy_production_per_capita
from production_3 as p
join population_3 as pop
on p.country=pop.countries
and p.year=pop.year
group by p.country,p.year,pop.value
order by p.country,p.year;

# Which countries have the highest energy consumption relative to GDP?
select c.country,c.year,sum(c.consumption)/sum(g.value) as highest_energy_consumption
from consum_3 as c
join gdp_3 as g
on c.country=g.country
and c.year=g.year
group by c.country,c.year,g.value;
# What is the correlation between GDP growth and energy production growth?

 # Global Comparisons

# What are the top 10 countries by population and how do their emissions compare?
select countries,sum(value) as total_population
from population_3 
group by countries
order by total_population desc
limit 10;
select p.countries,sum(p.value) as total_population,
sum(e.emission) as total_emission,
sum(e.emission)/sum(p.value)  as emission_per_capita
from population_3 as p
join emission_3 as e
on p.countries=e.country
group by p.countries
order by total_population desc
limit 10;
# Which countries have improved (reduced) their per capita emissions the most over the last decade?
select country,(max(per_capita_emission)-min(per_capita_emission)) as reduction_in_emission
from emission_3
where year between 2020 and 2024
group by country
having reduction_in_emission >0
order by reduction_in_emission desc;
#What is the global share (%) of emissions by country?
SELECT country,ROUND(SUM(emission) * 100.0 / (SELECT SUM(emission) FROM emission_3), 2) AS global_share_percent
FROM emission_3
GROUP BY country
ORDER BY global_share_percent DESC;
# This analysis shows China has large global share % as 32.35


#What is the global average GDP, emission, and population by year?
SELECT e.year,
    ROUND(AVG(e.emission), 2) AS avg_emission,
    ROUND(AVG(g.value), 2) AS avg_gdp,
    ROUND(AVG(p.value), 2) AS avg_population
FROM emission_3  as e
JOIN gdp_3 as g 
ON e.country = g.country AND e.year = g.year
JOIN population_3 as p 
ON e.country = p.countries AND e.year = p.year
GROUP BY e.year
ORDER BY e.year;
# In the year 2023 avg_emission, avg_gdp and avg_population has increased

