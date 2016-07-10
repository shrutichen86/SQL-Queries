create table states (statecode , population_2010 , population_2000 , population_1950 , population_1900 , landarea , name,  admitted_to_union );
create table counties(name , statecode , population_1950 , population_2010 );
create table senators(statecode , name , affiliation , took_office, born);
create table committees(id, parent_committee, name, chairman , ranking_member);


--1.List all state names and their 2-letter codes. Output columns: name, statecode . Order by the state name.

select name,statecode
from states
order by name

--2. Write a query to report the information for all counties whose names start with "Prince" .
--Output columns: name, statecode, populate_1950, populateion_2010
--Order by state code.

select c.name,c.statecode,c.population_1950,c.population_2010
from counties c 
where c.name like 'Prince%'
order by c.statecode

--3. Write a single query to list only the population in year 2010 for the state represented by Sen. Richard Lugar.
--Output column: populate_2010

select s.population_2010
from states s join senators se
on s.statecode=se.statecode
where se.name like '%Richard Lugar'

--4. Write a single query to report only the total number of the counties in 'Maryland'. The query should not hard-code the state code for Maryland.

select count(c.name) as total_counties
from counties c join states s 
on c.statecode=s.statecode
where s.name='Maryland'

--5.  Write a single query to find the name of the state that was admitted last into the union.

select name 
from states where admitted_to_union=(select max(admitted_to_union) from states)

--6.  Write a query to find the names of the counties whose names are at least 20 characters long. Keep in mind that county name is defined to be a fixed-length 
--30 character string, so you must elimiated the padded whitespaces to correctly answer the query
--Output columns: name (of the county)
--Order by: name.

select name 
from counties
where LEN(RTRIM(LTRIM(name)))>=20
order by name

--7. Write a query to find the name of the state with the minimum number of counties. If there are multiple such states, all should be reported.
--Output column: name (of the state)

select x.name from
(select s.name, rank() over (order by count(*)) as ranking
from states s join counties c
on s.statecode=c.statecode 
group by s.name) x
where x.ranking=1

--8.  Create a view called HighPopulationCounties containing the high-population counties (defined to be counties with at least 2.5M population in 2010), 
--and their state names.
--View columns: countyname, statename, population_2010

select c.name as county_name,s.name as state_name,c.population_2010
from states s join counties c
on s.statecode=c.statecode
where c.population_2010>=2500000
order by c.population_2010 desc

--9. Write a query to find if any senators represent a state that was admitted to the union after they were born. 
--Hint: Use "extract" function that operates on the dates. 
--Output columns: senator_name, year_born, state_name, year_state_admitted
--Order by senator name.

select s.name as senator_name,s.born,st.name as state_name,st.admitted_to_union
from senators s join states st
on s.statecode=st.statecode
where YEAR(st.admitted_to_union) > s.born

--10. Find all democratic (i.e., with affiliation = 'D') senators that are not chairman of any committee or sub-committee.  
--Output columns: name
--Order by name.

select distinct s.name as senator_name
from senators s left outer join committees c
on s.name=c.chairman 
where c.chairman is null and s.affiliation='D'
order by s.name

--11. Create a table (call it PopulationGrowth), that contains three columns: statename, growth_1900_to_1950, growth_1950_to_2000, where the 
--growth_1900_to_1950 is defined as: population_1950/population_1900, and the second number is defined similarly. 
--List the result of:"select * from PopulationGrowth where growth_1950_to_2000 > 5 order by statename;" 

select name , population_1950/CONVERT(FLOAT,population_1900) as growth_1900_to_1950,population_2000/CONVERT(FLOAT,population_1950) as growth_1950_to_2000
from states
where population_2000/CONVERT(FLOAT,population_1950) >5
order by name

--12. Write a query to find all the states whose growth rate was higher by a factor of 2 or more in the period 1900 to 1950, than in the period from 1950 to 2000? 
--Use PopulationGrowth table created above. For example, if a state grew by a factor of 3 between 1900 and 1950, but only
--by a factor of 1.45 between 1950 and 2000, then it would qualify for the answer.

select x.name from
(select name , population_1950/CONVERT(FLOAT,population_1900) as growth_1900_to_1950,population_2000/CONVERT(FLOAT,population_1950) as growth_1950_to_2000
from states ) x
where x.growth_1900_to_1950 / x.growth_1950_to_2000>=2

--13. Write a query to find the day when the 30th state was admitted to the union, and the name of the state.
--Output columns: name, admitted_to_union

select x.name , x.admitted_to_union from
(select name, admitted_to_union,rank() over (order by admitted_to_union) as ranking
from states ) x
where x.ranking=30

--14. Write a query to find the name of the state whose representatives are the ranking members of most committees or subcommittees?
--Here the committees and the subcommittees are counted separately.

select x.name from
(select states.name, count(*) as num, rank() over(order by count(*) desc) as ranking
from states, senators, committees
where states.statecode = senators.statecode and senators.name = committees.ranking_member
group by states.name) x
where x.ranking=1

--15. Write a query to find the state that was admitted next after 'Minnesota'. If there are multiple such states (admitted on the same day), all should be reported. 
--Make sure the date is reported correct (see question 13).
--Output: name, admitted_to_union

select x.name,x.admitted_to_union from
(select name , admitted_to_union,rank() over (order by admitted_to_union) as ranking
from states where admitted_to_union>(select admitted_to_union from states where name='Minnesota')
) x
where x.ranking=1

--16. Write a query to add a new column called ``num_subcommittees'' to the Committees table. Initially the ``num_subcommittees'' column would be listed as empty.  
--Write a query to ``update'' the table to set it appropriately. The columns should be set to 0 if the committee has no sub-committees, to -1 if the committee is 
--a sub-committee, and to the number of subcommittees otherwise

select a.id,a.parent_committee,
case
when a.parent_committee is not null then -1 else (select count(*) from committees b where b.parent_committee = a.id) END as num_subcommittees
from Committees a 

--17.  Write a query to find the largest gap (in number of days) between admission of two consecutive states. For example, the gap between Delaware and Pennsylvania 
--was 5 days, whereas the gap between Utah and the next state to be admitted, Oklahoma, was almost 11 years
--Output: state_one, state_two, gap (in days)

select y.state_one,y.state_two,y.gap 
from
(select x.state_one,x.state_two,x.gap,rank() over (order by gap desc) as new_rank
from
(select s1.name as state_one, s2.name as state_two, DATEDIFF(DAY,s1.admitted_to_union ,s2.admitted_to_union) as gap,
rank() over (partition by s1.name order by DATEDIFF(DAY,s1.admitted_to_union ,s2.admitted_to_union)) as ranking
from states s1, states s2
where s1.admitted_to_union < s2.admitted_to_union ) x
where x.ranking =1) y
where y.new_rank=1

--18. As you can see, there is a population field associated with the state, as well as the counties. We would like to make sure that they are consistent, i.e., 
--the population of a state is equal to the sum total of populations of its counties. Write a query to check if there is any violation for the 2010 population.
--Output: names of states which violate the property, the two population counts
--Order by: state name

select x.name , x.population_2010,x.county_population
from
(select s.name,s.population_2010,sum(c.population_2010) as county_population
from states s join counties c
on s.statecode=c.statecode
group by s.name,s.population_2010) x
where x.population_2010<> x.county_population
order by x.name
