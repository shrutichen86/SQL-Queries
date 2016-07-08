--Student(snum, sname, major, level, age)
--Class(name, meets at, room, fid)
--Enrolled(snum, cname)
--Faculty(fid, fname, deptid)

--1. Find the names of all Juniors (Level = JR) who are enrolled in a class taught by I. Teach.

select distinct s.sname
from Student s join Enrolled e
on s.snum=e.snum
join Class c 
on e.cname=c.name
join Faculty f 
on c.fid=e.fid
where f.fname='I.Teach' and s.level='JR'

--2. Find the age of the oldest student who is either a History major or is enrolled in a course taught by I. Teach

select max(s.age)  as Max_Age
from Student s join Enrolled e
on s.snum=e.snum
join Class c 
on e.cname=c.name
join Faculty f 
on c.fid=e.fid
where f.fname='I.Teach' or s.major='History'

--3. Find the names of all classes that either meet in room R128 or have five or more students enrolled.

select distinct c.name as Class_name
from Class c 
where c.room='R128'
UNION
select a.name as Class_name from
(select c.name,count(distinct c.snum) as students_enrolled
join Enrolled e join Class c
on c.name=e.cname
group by c.name
having count(distinct c.snum)>=5)a

--4. Find the names of all students who are enrolled in two classes that meet at the same time

select distinct x.sname from 
(select s.sname,a.meetsat,count(distinct b.cname)
from Class a join  Enrolled b
on a.cname=b.name
join Student s
on s.snum=b.snum
group by a.sname,a.meetsat
having count(distinct b.cname)>=2 ) x

--5. Find the names of faculty members who teach in every room in which some class is taught

select distinct x.fname as faculty from
(select f.fname,count(distinct c.room) as rooms
Faculty f join Class c
on f.fid=c.fid
group by f.fname
having count(distinct c.room)=(select count(distinct room) from class)) x

--6. Find the names of faculty members for whom the combined enrollment of the courses that they teach is less than five

select distinct x.fname as Faculty
(select f.fname,count(distinct e.snum)
from Faculty f join Class c
on f.fid=c.fid
join Enrolled e 
on e.cname=c.cname
group by f.fname
having count(distinct e.snum)<5 ) x

--7. Print the Level and the average age of students for that Level, for each Level

select Level,AVG(age)
from Student
group by Level

--8. Print the Level and the average age of students for that Level, for all Levels except JR

select Level,AVG(age)
from Student
where Level<>'JR'
group by Level

--9. Find the names of students who are enrolled in the maximum number of classes

select distinct y.sname from
(select x.sname,max(x.classes) from
(select s.sname,count(distinct e.cname) as classes
from Class c join Enrolled e
on c.name=e.cname
join Student s 
on s.snum=e.snum
group by s.name) x )y

--10. Find the names of students who are not enrolled in any class

select distinct s.sname
from Student s 
where s.snum NOT IN
(select distinct e.snum from Enrolled e)

--11. For each age value that appears in Students, find the level value that appears most often. For example, if there are more FR level students aged 18 than SR, 
--JR, or SO students aged 18, you should print the pair (18, FR)

select x.age,x.level from
(select age,level,row_number() over (partition by age order by count(*) desc) as Ranking
from Student )x
where x.Ranking =1