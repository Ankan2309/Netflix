--Step:1 DataBase Creation.
create database netflix_project

--Step:2 Table Creation.
create table netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550));

--Step:3 Check all Datas are in accurate formate.
select * from netflix;

-- 15 Business Problems & Solutions--

--1. Count the number of Movies vs TV Shows
select count(case when type = 'Movie' then 1 end) movie,
       count(case when type = 'TV Show' then 1 end) tv_show from netflix;

--2. Find the most common rating for movies and TV shows
select type, rating, count(*) from netflix group by 1,2 order by 3 desc;

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;



--3. List all movies released in a specific year (e.g., 2020)
select type, title, release_year from netflix where release_year = 2020 and type = 'Movie' ; 

--4. Find the top 5 countries with the most content on Netflix.
select unnest(string_to_array(country,','))as new_country, count(*) as total_content 
from netflix group by 1 order by 2 desc limit 5 ;

--5. Identify the longest movie
select type, duration from netflix where type = 'Movie' order by SPLIT_PART(duration,' ',1)::int desc;

--6. Find content added in the last 5 years.
select count(*) content, release_year from netflix group by 2 order by 2 desc limit 5; 

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
with cte as (select *, unnest(string_to_array(director,',')) as person from netflix)
select type, person from cte where person ='Rajiv Chilaka'

--8. List all TV shows with more than 5 seasons
select type, duration from netflix where type = 'TV Show' and duration >= '5 Season';

--9. Count the number of content items in each genre
select count(*), unnest(string_to_array(listed_in,',')) as genre from netflix group by 2 order by 1 desc ;

--10.Find each year and the average numbers of content release in India on netflix.return top 5 year with highest avg content release!
select country, release_year, count(show_id) total_rel,
round(count(show_id)::numeric/(select count(show_id) from netflix where country= 'India')::numeric * 100) as avg_rel
from netflix where country = 'India' group by 1,2 order by 4 desc limit 5;

--11. List all movies that are documentaries
with cte as (select *,unnest(string_to_array(listed_in,',')) as genre from netflix)
select type, genre from cte where genre ='Documentaries' ;

--12. Find all content without a director
select * from netflix where director is null;

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select * from netflix where casts like '%Salman Khan%' 
and release_year > extract(year from current_date) -10;

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select count(*),unnest(string_to_array(casts,',')) actor from netflix 
where country = 'India' group by 2 order by 1 desc limit 10;

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. 
--Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.
with cte as (select *, (case when description ilike '%kill%' or description ilike '%violence%' then 'bad'
                             else 'good' end) as category from netflix)
select category, type, count(*) as content_count from cte group by 1,2 order by 2
