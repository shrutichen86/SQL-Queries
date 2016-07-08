Flights(flno, from, to, distance,departs, arrives, price)
Aircraft(aid, aname, cruisingrange)
Certified(eid, aid)
Employees(eid, ename, salary)

--1. Find the names of aircraft such that all pilots certified to operate them earn more than 80,000

select distinct x.aname from
(select a.aname,MIN(case when e.salary<80000 then 0 else 1 end) as Sal
from Certified c join Employees e
on c.eid=e.eid
join Aircraft a
on a.aid=c.aid
group by a.aname
having MIN(case when e.salary<80000 then 0 else 1 end)=1 ) x

--2. For each pilot who is certified for more than three aircraft, find the eid and the maximum cruisingrange of the aircraft that he (or she) is certified for.

select x.eid,x.max_range from
(select e.eid,count(distinct a.aid),max(a.cruisingrange) as max_range
from Certified e join Aircraft a
on c.aid=a.aid
group by e.eid
having count(distinct a.aid)>3 ) x

--3. Find the names of pilots whose salary is less than the price of the cheapest route from Los Angeles to Honolulu

select ename from Employees where salary<
(select min(price) from Flights where from='Los Angeles' and to='Honolulu')

--4. For all aircraft with cruisingrange over 1,000 miles, find the name of the aircraft and the average salary of all pilots certified for this aircraft

select a.aname,avg(e.salary) as avg_pilot_salary
from Certified c join Aircraft a 
on c.aid=a.aid
join Employees e 
on e.eid=c.eid
where a.cruisingrange>1000
group by a.aname

--5. Find the names of pilots certified for some Boeing aircraft

select distinct e.ename
from Certified c join Aircraft a 
on c.aid=a.aid
join Employees e 
on e.eid=c.eid
where lower(a.aname) like '%boeing%'

--6. Find the aids of all aircraft that can be used on routes from Los Angeles to Chicago

SELECT A.aid
FROM Aircraft A
WHERE A.cruisingrange > 
( SELECT MIN (F.distance) FROM Flights F WHERE F.from = 'Los Angeles' AND F.to = 'Chicago') 

--7. Identify the routes that can be piloted by every pilot who makes more than $100,000

select x.from,x.to from
(select distinct f.from,f.to,count(distinct c.eid) as pilot_certification
from Flights f join Aircraft a
on f.flno=a.aid
join Certified c
on c.aid=a.aid
join Employees e
on e.eid=c.eid
where c.Salary>1000000 and f.distance>a.cruisingrange
group by f.from,f.to
having count(distinct c.eid)=(select count(distinct eid) from Employees where salary>1000000)x

--8. Print the enames of pilots who can operate planes with cruisingrange greater than 3,000 miles, but are not certified on any Boeing aircraft
select distinct e.ename
from Aircraft a join Certified c
on a.aid=c.aid
join Employees e 
on c.eid=e.eid
where a.cruisingrange>3000
and c.aid not IN
(select distinct aid from Aircarft where aname like 'Boeing%' )

--9. A customer wants to travel from Madison to New York with no more than two changes of flight. List the choice of departure times from Madison
-- if the customer wants to arrive in New York by 6 p.m

SELECT F.departs
FROM Flights F
WHERE F.flno IN ( 
( SELECT F0.flno
 FROM Flights F0
 WHERE F0.from = 'Madison' AND F0.to = 'New York'
 AND F0.arrives < '18:00' )
 UNION
 ( SELECT F0.flno
 FROM Flights F0, Flights F1
 WHERE F0.from = 'Madison' AND F0.to <> 'New York'
 AND F0.to = F1.from AND F1.to = 'New York'
 AND F1.departs > F0.arrives
 AND F1.arrives < '18:00' )
 UNION
 ( SELECT F0.flno
 FROM Flights F0, Flights F1, Flights F2
 WHERE F0.from = 'Madison'
 AND F0.to = F1.from
 AND F1.to = F2.from
 AND F2.to = 'New York'
 AND F0.to <> 'New York'
 AND F1.to <> 'New York'
 AND F1.departs > F0.arrives
 AND F2.departs > F1.arrives
 AND F2.arrives < '18:00' )) 

--10. Compute the difference between the average salary of a pilot and the average salary of all employees (including pilots)

SELECT Temp1.avgsal - Temp2.avgsal
FROM (SELECT AVG (E.salary) AS avgsal
FROM Employees E
WHERE E.eid IN (SELECT DISTINCT C.eid
FROM Certified C )) AS Temp1,
(SELECT AVG (E1.salary) AS avgsal
FROM Employees E1 ) AS Temp2

--11. Print the name and salary of every nonpilot whose salary is more than the average salary for pilots

select e.name,e.salary 
from Employees e left join Certified c 
on e.eid=c.eid
where c.eid is null and e.salary >
(SELECT AVG (E.salary) AS avgsal
FROM Employees E
WHERE E.eid IN (SELECT DISTINCT C.eid FROM Certified C ))

--12. Print the names of employees who are certified only on aircrafts with cruising range longer than 1000 miles

select x.ename from
(select e.ename,min(case when a.cruisingrange>1000 then 1 else 0 end ) as range
from Certified c join Aircraft a 
on c.aid=a.aid
join Employees e
on e.eid=c.eid
group by e.ename
having min(case when a.cruisingrange>1000 then 1 else 0 end )=1) x

--13. Print the names of employees who are certified only on aircrafts with cruising range longer than 1000 miles, but on at least two such aircrafts

select distinct x.ename from
(select e.ename,min(case when a.cruisingrange>1000 then 1 else 0 end ) as range,count(*) as no_aircrafts
from Certified c join Aircraft a 
on c.aid=a.aid
join Employees e
on e.eid=c.eid
group by e.ename
) x
where x.range=1 and x.no_aircrafts>=2

--14. Print the names of employees who are certified only on aircrafts with cruising range longer than 1000 miles and who are certified on some Boeing aircraft. 

select distinct x.ename from
(select e.ename,min(case when a.cruisingrange>1000 then 1 else 0 end ) as range,max(case when a.aname like 'Boeing%' then 1 else 0 end) as flight_name
from Certified c join Aircraft a 
on c.aid=a.aid
join Employees e
on e.eid=c.eid
group by e.ename
) x
where x.range=1 and x.flight_name=1