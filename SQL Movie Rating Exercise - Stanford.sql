
Movie ( mID, title, year, director ) 
English: There is a movie with ID number mID, a title, a release year, and a director. 

Reviewer ( rID, name ) 
English: The reviewer with ID number rID has a certain name. 

Rating ( rID, mID, stars, ratingDate ) 
English: The reviewer rID gave the movie mID a number of stars rating (1-5) on a certain ratingDate. 

1. Find the titles of all movies directed by Steven Spielberg. 

select title from movie 
where director='Steven Spielberg'

2. Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order. 

select distinct m.year
from Movie m join Rating r 
on m.mID=r.mID 
where stars>=4
order by m.year asc

3. Find the titles of all movies that have no ratings. 

select m.title
from Movie m left outer join Rating r 
on m.mID=r.mID 
where r.mID is null

4. Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date. 

select distinct r.name
from Reviewer r join Rating X
on r.rID=X.rID
where X.RatingDate is NULL

5. Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. 
Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars. 

select v.name as Reviewer_Name,m.title,r.stars,r.ratingDate
from Movie m join Rating r
on m.mID=r.mID
join Reviewer v 
on v.rID=r.rID
order by v.name,m.title,r.stars

6. For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, 
return the reviewer's name and the title of the movie. 

select distinct b.name,e.title
from Rating a , Reviewer b , Rating c, Reviewer d ,Movie e
where a.rID=b.rID and c.rID=d.rID and a.mID=c.mID and a.rID=c.rID
and c.RatingDate>a.RatingDate and c.stars>a.stars
and a.mID=e.mID

7. For each movie that has at least one rating, find the highest number of stars that movie received. 
Return the movie title and number of stars. Sort by movie title. 

select a.title,a.highest_rating from
(
select m.title as title,max(stars) as highest_rating, count(r.rID) as reviews
from Movie m join Rating r
on m.mID=r.mID
group by m.title
having count(r.rID) >= 1 ) a
order by a.title

8. For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. 
   Sort by rating spread from highest to lowest, then by movie title. 
   
select m.title, max(r.stars) - min(r.stars) as spread
from Movie m join Rating r
on m.mID=r.mID
group by m.title
order by max(r.stars) - min(r.stars) desc,m.title 

9. Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980.
(Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after.
Don't just calculate the overall average rating before and after 1980.) 

    select t2.p2-t1.p1 from
    (select avg(average) as p1  from 
    (select g.mid,g.average, year from
    (select mid, avg(stars) as average from rating
    group by mid) g, movie
    where g.mid=movie.mid) j 
    where year >= 1980) t1,

    (select avg(average) as p2  from 
    (select g.mid,g.average, year from
    (select mid, avg(stars) as average from rating
    group by mid) g, movie
    where g.mid=movie.mid) j 
    where year < 1980) t2;
	
Advanced Exercises

1.  Find the names of all reviewers who rated Gone with the Wind. 

select distinct name from Reviewer,Movie,Rating
where (Reviewer.rID=Rating.rID and Rating.mID=Movie.mID) 
AND (Movie.title='Gone with the Wind')

2. For any rating where the reviewer is the same as the director of the movie, 
return the reviewer name, movie title, and number of stars. 

select distinct v.name,m.title,r.stars
from Movie m join Rating r
on m.mID=r.mID
join Reviewer v on 
v.rID=r.rID 
where m.director=v.name

3. Return all reviewer names and movie names together in a single list, alphabetized. 
(Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".) 

select distinct name as Names from Reviewer
union
select distinct title as Names from movie
order by Names

4. Find the titles of all movies not reviewed by Chris Jackson. 


select distinct mo.title from Movie mo where mo.mID
NOT IN 
(select distinct m.mID from Movie m,Reviewer v,Rating r 
where m.mID=r.mID and v.rID=r.rID and v.name='Chris Jackson')

5. For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. 
Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order. 

select distinct C.name,D.name 
from Rating A, Rating B, Reviewer C, Reviewer D
where (A.mID=B.mID and A.rID<>B.rID) 
AND (A.rID=C.rID) 
AND (D.rID=B.rID) 
AND C.name<D.name

6. For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars. 

select v.name,m.title,r.stars
from Movie m join Rating r
on m.mID=r.mID
join Reviewer v
on v.rID=r.rID
where r.stars=
(select distinct min(stars) from Rating)

7. List movie titles and average ratings, from highest-rated to lowest-rated. 
If two or more movies have the same average rating, list them in alphabetical order. 

select m.title,avg(r.stars)
from Movie m join Rating r
on m.mID=r.mID
group by m.title
order by avg(r.stars) desc,m.title

8. Find the names of all reviewers who have contributed three or more ratings. 
(As an extra challenge, try writing the query without HAVING or without COUNT.) 

select distinct name from
(select v.name,count(*)
from Rating r join Reviewer v
on r.rID=v.rID
group by v.name
having count(*)>=3)

9. Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them,
along with the director name. Sort by director name, then movie title.
(As an extra challenge, try writing the query both with and without COUNT.) 

select title,director
from movie
where director in
(select director from
(select director,count(distinct mID)
from Movie 
group by director
having count(distinct mID)>1))
order by director,title

10. Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. 
(Hint: This query is more difficult to write in SQLite than other systems; you might think of it as finding the highest average rating 
and then choosing the movie(s) with that average rating.) 

Select m.title,avg(r.stars)
from Movie m join Rating r
on m.mID=r.mID
group by m.title
having avg(r.stars)=
(select max(a.Stars) as HighestRating 
from
(select mID, avg(stars) as Stars
from Rating
group by mID) a)

11. Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. 
(Hint: This query may be more difficult to write in SQLite than other systems; you might think of it as finding the lowest average rating 
and then choosing the movie(s) with that average rating.) 

Select m.title,avg(r.stars)
from Movie m join Rating r
on m.mID=r.mID
group by m.title
having avg(r.stars)=
(select min(a.Stars) as LowestRating 
from
(select mID, avg(stars) as Stars
from Rating
group by mID) a)

12. For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, 
and the value of that rating. Ignore movies whose director is NULL. 

select director,title,max(stars) as Rating
from Movie,Rating
where Movie.mID=Rating.mID AND (director is NOT NULL)
group by director