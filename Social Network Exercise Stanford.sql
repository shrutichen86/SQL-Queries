--Students at your hometown high school have decided to organize their social network using databases. 
--So far, they have collected information about sixteen students in four grades, 9-12. Here's the schema: 

--Highschooler ( ID, name, grade ) 
--English: There is a high school student with unique ID and a given first name in a certain grade. 

--Friend ( ID1, ID2 ) 
--English: The student with ID1 is friends with the student with ID2. Friendship is mutual, so if (123, 456) is in the Friend table, so is (456, 123). 

--Likes ( ID1, ID2 ) 
--English: The student with ID1 likes the student with ID2. Liking someone is not necessarily mutual, so if (123, 456) is in the Likes table,
-- there is no guarantee that (456, 123) is also present. 

--1.Find the names of all students who are friends with someone named Gabriel

select distinct name from Highschooler 
where ID in 
(select ID2 
from Friend 
where ID1 in
(select ID 
from Highschooler
where name='Gabriel')
UNION
select ID1 
from Friend
where ID2 in
(select ID 
from Highschooler
where name='Gabriel'))

--2. For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, 
--and the name and grade of the student they like. 

select distinct b.name,b.grade,c.name,c.grade 
from Likes a join Highschooler b
on a.ID1=b.ID
join Highschooler c
on a.ID2=c.ID
where b.grade-c.grade>=2

--3. For every pair of students who both like each other, return the name and grade of both students. 
--Include each pair only once, with the two names in alphabetical order. 

select distinct h1.name, h1.grade, h2.name, h2.grade 
from Likes l1, Likes l2, Highschooler h1, Highschooler h2
where l1.ID1=l2.ID2 and l2.ID1=l1.ID2 and l1.ID1=h1.ID and l1.ID2=h2.ID and h1.name<h2.name

--4.Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. 
--Sort by grade, then by name within each grade. 

select distinct name,grade
from Highschooler 
where ID not in
( select distinct ID1 from Likes)
and ID not in
(select distinct ID2 from Likes)
order by grade,name

--5. For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), 
--return A and B's names and grades. 

select distinct a.name,a.grade,b.name,b.grade 
from highschooler a,highschooler b,likes c
where b.id not IN
(select distinct id1 from likes)
AND a.id=c.id1 and b.id=c.id2

--6.Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade. 

select name, grade from Highschooler
where ID not in (
  select ID1 
  from Highschooler H1, Friend, Highschooler H2
  where H1.ID = Friend.ID1 and Friend.ID2 = H2.ID and H1.grade <> H2.grade)
order by grade, name;

--7. For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!). 
--For all such trios, return the name and grade of A, B, and C. 

Select h1.name,h1.grade,h2.name,h2.grade,h3.name,h3.grade
From Highschooler h1,Highschooler h2,Highschooler h3,Likes L   
Where h1.ID = L.ID1 AND h2.ID = L.ID2 
and 
L.ID1 not in (Select ID1 FROM Friend where (ID1=h1.ID and ID2=h2.ID) OR (ID1=h2.ID and ID2=h1.ID) )
AND h3.ID in 
(
Select F1.ID2 from Friend F1,Friend F2
 where 
((F1.ID1=h1.ID AND F1.ID2 = h3.ID) 
  OR (F1.ID1=h3.ID AND F1.ID2 = h1.ID )) 
AND 
((F2.ID1=h2.ID AND F2.ID2 = h3.ID ) 
  OR (F2.ID1=h3.ID AND F2.ID2 = h2.ID))
) 

--8. Find the difference between the number of students in the school and the number of different first names. 

select count(distinct ID) - count(distinct name) from Highschooler

--Extra Questions - Advanced

--1.For every situation where student A likes student B, but student B likes a different student C, return the names and grades of A, B, and C. 

select a.name,a.grade,b.name,b.grade,c.name,c.grade
from Highschooler a, Highschooler b,Highschooler c,Likes d,Likes e
where (a.ID=d.ID1 and b.ID=d.ID2) and (b.ID<>d.ID1 and a.ID<>d.ID2) 
and (b.ID=e.ID1 and c.ID=e.ID2) and (a.name<>b.name) 
and (b.name<>c.name) and (c.anme<>a.name)

--2. Find those students for whom all of their friends are in different grades from themselves. Return the students' names and grades. 

select distinct name, grade from Highschooler
where ID not in (
  select ID1 
  from Highschooler H1, Friend, Highschooler H2
  where H1.ID = Friend.ID1 and Friend.ID2 = H2.ID and H1.grade = H2.grade)

--3. What is the average number of friends per student? (Your result should be just one number.) 

select avg(cnt) from(
select id1,count(id2) as cnt from friend 
group by id1)

--4. Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. 
--Do not count Cassandra, even though technically she is a friend of a friend

select count(id2) from friend where id1 in 
(
  select id2 from friend where id1 in (select id from highschooler where name='Cassandra')
)
and id1 not in (select id from highschooler where name='Cassandra')

--5. Find the name and grade of the student(s) with the greatest number of friends. 


select h.name, h.grade from highschooler h, friend f where
h.id = f.id1 group by f.id1 having count(f.id2) = (
select max(r.c) from
(select count(id2) as c from friend group by id1) as r)




