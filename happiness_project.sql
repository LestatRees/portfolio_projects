--cities with the highest happiness project using CTEs, joins, window functions

select
	*
from
	city_happiness

;
--checking for any incorrect data

select
	max(happiness_score)
  , min(happiness_score)
  , City
from
	city_happiness
group by
	city
order by
	happiness_score desc

--cities with highest happiness compared to their traffic density


select
	city
  , Traffic_Density
  , Happiness_Score
from 
	city_happiness
order by 
	Happiness_Score desc
;

--finding the highest average happiness per city while using window functions

select
	city
  , avg(happiness_score) over (partition by city) as avg_happiness_per_city
from
	city_happiness
order by
	avg_happiness_per_city desc
;


--what factors affect the average happiness the most

select
	city
  , Green_Space_Area
  , Traffic_Density
  , Cost_of_Living_Index
  , avg(happiness_score) over (partition by city) as avg_happiness_per_city
from
	city_happiness
order by
	avg_happiness_per_city desc
;


--what factors affect the average happiness using a CTE and a self join

with avg_happiness as 
		(
		select
			city
		  , avg(happiness_score) over (partition by city) as avg_happiness_per_city
		from
			city_happiness
		)
select
	c.city
  , c.green_space_area 
  , a.avg_happiness_per_city
from
	avg_happiness a
		left join
			city_happiness c
				on a.city = c.city
order by
	avg_happiness_per_city desc
;


-- what quarter of the year has the highest happiness score

with quarter_happiness as(

select
	*,
case
	when month in ('January', 'February', 'March') then 'Q1'
	when month in ('April', 'May', 'June') then 'Q2'
	when month in ('July', 'August', 'September') then 'Q3'
	when month in ('October', 'November', 'December') then 'Q4'
	end as quarters_of_year
from
	city_happiness
)

select
	city
  , Happiness_Score
  , quarters_of_year
from
	quarter_happiness
order by
	Happiness_Score desc