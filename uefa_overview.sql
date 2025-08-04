--Creating the goals tables
create table goals(
goal_id varchar(255) Primary Key,
match_id varchar(255),
pid varchar(255),
duration INTEGER,
assist varchar(255),
goal_desc varchar(255)
);

--select query to check the table data
select * from goals;

--counting how many rows are there
select count(*) from goals;

--creating a table for matches 
create table matches(
match_id varchar(255) Primary key,
season varchar(255),
date varchar(255),
home_team varchar(255),
away_team varchar(255),
stadium varchar(255),
home_team_score INTEGER,
away_team_score INTEGER,
penalty_shoot_out INTEGER,
attendance INTEGER
);

--query to retrive data from the database for matches
select * from matches;

--create table players
create table players(
player_id varchar(255) Primary Key,
first_name varchar(255),
last_name varchar(255),
nationality varchar(255),
DOB Date,
team varchar(255),
jersey_number FLOAT,
position Varchar(255),
height FLOAT,
weight FLOAT,
foot varchar(255)
);

select * from players;

--create table for teams
create table teams(
team_name varchar(255) Primary Key,
country varchar(255),
home_stadium varchar(255)
);
select * from teams;

--create table for stadium
create table stadium(
name varchar(255),
city varchar(255),
country varchar(255),
capacity INTEGER
);

select * from stadium;

--Goal Analysis (From the Goals table)
--1.	Which player scored the most goals in a each season?
with player_goal_count as(
select p.first_name ||' '||p.last_name as Player_Name,m.season, count(g.goal_id) as total_goals,
row_number() over (partition by m.season order by count(g.goal_id) desc) as rank
from goals g
join players p on g.pid=p.player_id
join matches m on g.match_id = m.match_id
group by p.first_name, p.last_name, m.season
)
select player_name, season, total_goals from player_goal_count
where rank=1
order by season;

--2.How many goals did each player score in a given season?
select p.first_name || ' ' || p.last_name as player_name,m.season,count(g.goal_id) as total_goals
from goals g join players p
on g.pid = p.player_id
join matches m on g.match_id = m.match_id
--where m.season = '2016-2017'
group by p.first_name, p.last_name, m.season
order by total_goals desc;

--3.What is the total number of goals scored in ‘mt403’ match?
select count(goal_id) as total_goals from goals
where match_id = 'mt403';

--4.Which player assisted the most goals in a each season?
select p.first_name ||' '|| p.last_name as player_name, m.season, count(g.assist) as total_assists
from goals g
join players p on g.pid = p.player_id
join matches m on g.match_id = g.match_id
group by p.first_name, p.last_name, m.season
order by m.season, total_assists desc;

--5.Which players have scored goals in more than 10 matches?
select p.first_name ||' '|| p.last_name as player_name, count(Distinct g.match_id) as matches_scored
from goals g
join players p on g.pid = p.player_id
join matches m on g.match_id = m.match_id
group by p.first_name, p.last_name
having count(distinct g.match_id) >10
order by matches_scored desc;

--6.What is the average number of goals scored per match in a given season?
select m.season, round(sum(m.home_team_score + m.away_team_score)::Numeric / count(m.match_id),2) as avg_goals_per_match
from matches m 
group by m.season
order by m.season;

--7.Which player has the most goals in a single match?
with player_goals as(
select g.pid as player_id, g.match_id,count(g.goal_id) as goals_in_match
from goals g 
group by g.pid, g.match_id
),
ranked_players as (
select p.player_id, p.first_name || ' '||p.last_name as player_name, pm.match_id,pm.goals_in_match,
row_number() over(order by pm.goals_in_match desc) as rank
from player_goals pm 
join players p 
on pm.player_id = p.player_id
)
select player_name, match_id, goals_in_match
from ranked_players
where rank = 1;

--8.Which team scored the most goals in the all seasons?
with team_goals as(
select m.home_team as team, sum(m.home_team_score) as total_home_goals
from matches m
group by m.home_team
union all
select m.away_team as team, sum(m.away_team_score)as total_away_goals
from matches m
group by m.away_team
)
select team, sum(total_home_goals) as total_goals
from team_goals
group by team
order by total_goals desc limit 1;

--9.Which stadium hosted the most goals scored in a single season?
with stadium_goals as(
select m.stadium,m.season, sum(m.home_team_score + m.away_team_score) as Total_Goals
from matches m
group by m.stadium, m.season
),
ranked_stadiums as (
select stadium, season, total_goals,
row_number() over(partition by season order by total_goals desc) as rank
from stadium_goals
)
select stadium, season, total_goals
from ranked_stadiums
where rank=1;

-- Match Analysis
-- 10.What was the highest-scoring match in a particular season?
select match_id, m.season, m.home_team,m.away_team,m.home_team_score, m.away_team_score,(m.home_team_score + m.away_team_score) as Total_Goals
from matches m 
where m.season='2020-2021'	--here i have taken the particular year as '2020-2021'
order by total_goals desc limit 1;

--11.How many matches ended in a draw in a given season?
select count(*) as draw_matches
from matches m
where m.season='2020-2021' and m.home_team_score = m.away_team_score;

--12.Which team had the highest average score (home and away) in the season 2021-2022?
with avg_score as(
select m.season,m.home_team as team, avg(m.home_team_score) as avg_home_score,
0 as avg_away_score
from matches m
where m.season='2021-2022'
group by m.season, m.home_team
union all
select m.season, m.away_team as team,0 as avg_home_score,
avg(m.away_team_score) as avg_away_score
from matches m
where m.season='2021-2022'
group by m.season, m.away_team
)
select team, round(avg(avg_home_score + avg_home_score),2) as avg_total_score
from avg_score
group by team
order by avg_total_score desc limit 1;

--13.How many penalty shootouts occurred in a each season?
select m.season, count(*) as penalty_shootouts
from matches m
where m.penalty_shoot_out = '1'
group by m.season
order by m.season;

--14.What is the average attendance for home teams in the 2021-2022 season?
select m.home_team, Round(avg(m.attendance),2) as avg_attendance
from matches m
where m.season='2021-2022'
group by m.home_team
order by avg_attendance desc;

--15.Which stadium hosted the most matches in a each season?
with stadium_match_count as(
select m.season,m.stadium, count(*) as match_count,
row_number() over(partition by m.season order by count(*)desc)as rank
from matches m
group by m.season,m.stadium
)
select season, stadium, match_count
from stadium_match_count
where rank=1
order by season;

--16.What is the distribution of matches played in different countries in a season?
select s.country, count(m.match_id) as matches_played
from matches m
join stadium s 
on m.stadium = s.name
where m.season='2021-2022'		--here season is'2021-2022'
group by s.country
order by matches_played desc;

--17.What was the most common result in matches (home win, away win, draw)?
select result_type, count(*) as result_count
from (select 
	case
		when m.home_team_score > m.away_team_score then 'Home Team Won'
		when m.away_team_score > m.home_team_score then 'Away Team Won'
		Else 'Draw'
	End as result_type
	from matches m
) results
group by result_type
order by result_count desc limit 1;

--Player Analysis 
--18.Which players have the highest total goals scored (including assists)?
select g.pid as player_id, p.first_name ||' '|| p.last_name as player_name, count(g.goal_id) as total_goals
from goals g
join players p on g.pid = p.player_id
group by g.pid, p.first_name, p.last_name
order by total_goals desc limit 1;

--19.What is the average height and weight of players per position?
select position, round(avg(height)::numeric,2) as avg_height,round(avg(weight)::numeric,2) as avg_weight
from players
group by position
order by position;

--20.Which player has the most goals scored with their left foot?
select g.pid as player_id, p.first_name ||' '||p.last_name as player_name,count(g.goal_id) as left_foot_goals
from goals g join players p
on g.pid = p.player_id
where p.foot = 'L'
group by g.pid, p.first_name, p.last_name
order by left_foot_goals desc limit 1;

--21.What is the average age of players per team?
select team, round(avg(extract(year from age(dob))),2) as avg_age
from players
group by team
order by avg_age desc;

--22.How many players are listed as playing for a each team in a season?
select p.team, count(p.player_id) as player_count
from players p
join goals g on p.player_id = g.pid
join matches m on g.match_id = g.match_id
where m.season = '2020-2021' 	--taken season as 2020-2021
group by p.team
order by player_count desc;

--23.Which player has played in the most matches in the each season?
with player_match_count as(
select g.pid as player_id, count(distinct g.match_id)as match_count, m.season 
from goals g
join matches m on g.match_id = m.match_id
group by g.pid, m.season
)
select player_id, match_count, season
from player_match_count
where(season, match_count) 
in(select season, max(match_count)
from player_match_count
group by season
)order by season;

--24.What is the most common position for players across all teams?
select position, count(*) as position_count
from players
group by position
order by position_count desc limit 1;

--25.Which players have never scored a goal?
select p.player_id, p.first_name ||' '||p.last_name as player_name
from players p
left join goals g on p.player_id = g.pid
where g.goal_id is null;

--Team Analysis 

--26.Which team has the largest home stadium in terms of capacity?
select t.team_name, s.name as stadium_name, s.capacity
from teams t join stadium s on t.home_stadium = s.name
order by s.capacity desc limit 1;

--27.Which teams from a each country participated in the UEFA competition in a season?
select m.season, t.team_name, t.country
from teams t
join matches m on t.team_name = m.home_team OR t.team_name = m.away_team
where m.season = '2020-2021'
group by m.season, t.team_name, t.country
order by t.country, t.team_name;

--28.Which team scored the most goals across home and away matches in a given season?
select team, sum(home_goals + away_goals) as total_goals
from(
select home_team as team, home_team_score as home_goals, away_team_score as away_goals
from matches 
where season = '2020-2021'
union all
select away_team as team, away_team_score as home_goals, home_team_score as away_goals
from matches 
where season = '2020-2021'
)as goals
group by team
order by total_goals desc limit 1;

--29.How many teams have home stadiums in a each city or country?
SELECT city, COUNT(DISTINCT team_name) AS team_count
FROM teams t
JOIN stadium s ON t.home_stadium = s.name
GROUP BY city
ORDER BY team_count DESC;

--30.Which teams had the most home wins in the 2021-2022 season?
select home_team, count(*) as home_wins
from matches 
where season = '2021-2022' and home_team_score > away_team_score
group by home_team
order by home_wins desc limit 1;

--Stadium Analysis 

--31.Which stadium has the highest capacity?
select name as stadium_name, capacity from stadium
order by capacity desc limit 1;

--32.	How many stadiums are located in a ‘Russia’ country or ‘London’ city?
select count(*) as stadium_count from stadium
where country ='Russia' or city='London';

--33.Which stadium hosted the most matches during a season?
select stadium, count(*) as match_count
from matches 
where season='2021-2022'
group by stadium
order by match_count desc limit 1;

--34.What is the average stadium capacity for teams participating in a each season?
select m.season, round(avg(s.capacity),2) as avg_capacity
from matches m join teams t 
on m.home_team = t.team_name or m.away_team = t.team_name
join stadium s on t.home_stadium = s.name
group by m.season
order by m.season;

--35.How many teams play in stadiums with a capacity of more than 50,000?
select count(distinct team_name) as team_count
from teams t 
join stadium s on t.home_stadium = s.name
where s.capacity > 50000;

--36.Which stadium had the highest attendance on average during a season?
select s.name as stadium_name, round(avg(m.attendance),2) as avg_attendance
from matches m join stadium s on m.stadium = s.name
where m.season ='2020-2021'		--season is '2020-2021'
group by s.name
order by avg_attendance desc limit 1;

--37.What is the distribution of stadium capacities by country?
select s.country, round(avg(s.capacity),2) as avg_stadium_capacity
from stadium s
group by s.country
order by avg_stadium_capacity desc;

--Cross-Table Analysis 

--38.Which players scored the most goals in matches held at a specific stadium?
select g.pid as player_id, count(g.goal_id) as total_goals
from goals g join matches m 
on g.match_id = m.match_id 
where stadium = 'Old Trafford'
group by g.pid
order by total_goals desc limit 1;
-- we can have the list of stadium from this command select name from stadium

--39.Which team won the most home matches in the season 2021-2022 (based on match scores)?
select home_team, count(*) as home_wins
from matches 
where season = '2021-2022' and  home_team_score > away_team_score
group by home_team
order by home_wins desc limit 1;

--40.Which players played for a team that scored the most goals in the 2021-2022 season?
with team_goals as (
select home_team as team, sum(home_team_score) + sum(away_team_score) as total_goals
from matches 
where season = '2021-2022'
group by home_team
order by total_goals desc limit 1
)
select p.first_name, p.last_name, p.team
from players p
join team_goals tg on p.team = tg.team;

--41.How many goals were scored by home teams in matches where the attendance was above 50,000?
select sum(home_team_score)as total_score
from matches 
where attendance > 50000;

--42.Which players played in matches where the score difference (home team score - away team score) was the highest?
with max_score_diff as (
select match_id, home_team_score - away_team_score as score_diff
from matches 
order by score_diff desc limit 1
)
select g.pid as player_id, count(g.goal_id) as total_goals
from goals g
join max_score_diff msd on g.match_id = msd.match_id
group by g.pid
order by total_goals desc;

--43.How many goals did players score in matches that ended in penalty shootouts?
select g.pid as player_id, count(g.goal_id) as total_goals
from goals g
join matches m on g.match_id = m.match_id 
where m.penalty_shoot_out = 1
group by g.pid;

--penalty shootout is 0(false) for each row so there is no output



--44.What is the distribution of home team wins vs away team wins by country for all seasons?
select m.season, t.country,sum(case when m.home_team_score > m.away_team_score then 1 else 0 end) as home_team_wins,
sum(case when m.away_team_score > m.home_team_score then 1 else 0 end) as away_team_wins
from matches m join teams t on m.home_team = t.team_name or m.away_team = t.team_name
group by m.season, t.country
order by m.season;

--45.	Which team scored the most goals in the highest-attended matches?
with max_attendance_matches as(
select match_id
from matches
where attendance =(select max(attendance) from matches)
)
select m.home_team as team,sum(m.home_team_score) as total_goals
from matches m
join max_attendance_matches mam on m.match_id = mam.match_id
group by m.home_team
order by total_goals desc limit 1;

--46.Which players assisted the most goals in matches where their team lost(you can include 3)?
select g.assist as player_id, count(g.goal_id) as total_assists
from goals g join matches m on g.match_id = m.match_id
where ((m.home_team = g.assist and m.home_team_score < m.away_team_score)
or(m.away_team = g.assist and m.away_team_score < m.home_team_score))
group by g.assist
order by total_assists desc limit 3;

--47.What is the total number of goals scored by players who are positioned as defenders?
select sum(g.duration) as total_goals
from goals g join players p on g.pid = p.player_id
where p.position = 'Defender';

--48.Which players scored goals in matches that were held in stadiums with a capacity over 60,000?
select g.pid as player_id, count(g.goal_id) as total_goals
from goals g join matches m on g.match_id = m.match_id
join stadium s on m.stadium = s.name
where s.capacity > 60000
group by g.pid;

--49.How many goals were scored in matches played in cities with specific stadiums in a season?
select sum(m.home_team_score + m.away_team_score) as total_goals
from matches m join stadium s on m.stadium = s.name
where city = 'London'		--any city from stadium table 
and m.season='2021-2022';	--here season is '2021-2022'	

--50.Which players scored goals in matches with the highest attendance (over 100,000)?
select g.pid as player_id, count(g.goal_id) as total_goals
from goals g join matches m on g.match_id = m.match_id
where m.attendance >100000
group by g.pid
order by total_goals desc;

--no attendance over 100000

--Additional Complex Queries 
--51.What is the average number of goals scored by each team in the first 30 minutes of a match?
select m.home_team as team, round(avg(case when g.duration <=30 then 1 else 0 end),2) as avg_goals_first_30
from matches m
left join goals g on m.match_id = g.match_id
group by m.home_team
union all
select m.away_team as team, round(avg(case when g.duration <-30 then 1 else 0 end),2) as avg_goals_first_30
from matches m
left join goals g on m.match_id = g.match_id
group by m.away_team
order by avg_goals_first_30 desc;

--52.	Which stadium had the highest average score difference between home and away teams?
select m.stadium, round(avg(abs(m.home_team_score - m.away_team_score)),2) as avg_score_diff
from matches m 
group by m.stadium
order by avg_score_diff desc limit 1;

--53.	How many players scored in every match they played during a given season?
select p.player_id, count(distinct m.match_id) as total_matches, count(distinct g.match_id) as matches_scored_in
from players p
join matches m on m.season ='2020-2021' 	--here season is '2020-2021'
left join goals g on g.pid = p.player_id and g.match_id = m.match_id
group by p.player_id
having count(distinct m.match_id) = count(distinct g.match_id);

--there is no player who have scored in any match


--54.	Which teams won the most matches with a goal difference of 3 or more in the 2021-2022 season?
select team, count(match_id) as win_count
from(
select m.home_team as team, m.home_team_score - m.away_team_score as score_diff,
m.match_id
from matches m
where m.season='2021-2022' and m.home_team_score - m.away_team_score >=3
union all
select m.away_team as team, m.away_team_score - m.home_team_score as score_diff,m.match_id
from matches m
where m.season= '2021-2022' and m.away_team_score - m.home_team_score >=3
)as winning_matches
group by team
order by win_count desc limit 1;

--55.	Which player from a specific country has the highest goals per match ratio?
select p.player_id, round(count(g.goal_id) *1.0 / count(distinct m.match_id),2) as goal_per_match_ratio
from players p
join goals g on p.player_id = g.pid
join matches m on g.match_id = m.match_id
where p.nationality ='England'		--here specific country is England
group by p.player_id
order by goal_per_match_ratio desc limit 1;