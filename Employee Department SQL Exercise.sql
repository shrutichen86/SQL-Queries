--Emp(eid, ename, age, salary)
--Works(eid, did, pct_time)
--Dept(did, dname, budget, managerid)

--1. Print the names and ages of each employee who works in both the Hardware department and the Software department

SELECT distinct E.ename, E.age
FROM Emp E, Works W1, Works W2, Dept D1, Dept D2
WHERE E.eid = W1.eid AND W1.did = D1.did AND D1.dname = 'Hardware' 
AND E.eid = W2.eid AND W2.did = D2.did AND D2.dname = 'Software'

--2. For each department with more than 20 full-time-equivalent employees (i.e.,where the part-time and full-time employees add up to at least that many fulltime
--employees), print the did together with the number of employees that work in that department

SELECT W.did, COUNT (W.eid)
FROM Works W
GROUP BY W.did
HAVING 2000 < 
( SELECT SUM (W1.pct time)
 FROM Works W1
 WHERE W1.did = W.did )

--3. Print the name of each employee whose salary exceeds the budget of all of the departments that he or she works in

select distinct x.ename from
(select e.ename,e.salary as sal,max(d.budget) as budget
from Emp e join Works w 
on e.eid=w.eid
join Dept d
on d.did=w.did
group by e.ename,e.salary) x
where x.sal>x.budget

--4. Find the managerids of managers who manage only departments with budgets greater than $1 million

select managerid from
(select managerid,min(budget)
from Dept
group by managerid
having min(budget)>1000000) x

--5. Find the enames of managers who manage the departments with the largest budgets

select distinct ename from Dept d join Emp e on e.eid = d.managerid 
where d.budget=(select max(budget) from Dept)

--6. If a manager manages more than one department, he or she controls the sum of all the budgets for those departments. Find the managerids of managers
--who control more than $5 million

select x.managerid from
(select managerid,sum(budget) as total
from Dept
group by managerid
having sum(budget)>5000000 ) x


--7. Find the managerids of managers who control the largest amounts

select x.managerid from
(select managerid,sum(budget) as total,rank() over (order by sum(budget) desc) as ranking
from Dept
group by managerid )
where x.ranking=1

--8. Find the enames of managers who manage only departments with budgets larger than $1 million, but at least one department with budget less than $5 million 

SELECT DISTINCT Em.ename
FROM Emp Em, Dept D
WHERE Em.eid In (Select D.managerid 
                 FROM Dept D
                 WHERE D.budget > 1000000             
                 GROUP BY D.managerid
                 HAVING MIN(D.budget) < 5000000
             )