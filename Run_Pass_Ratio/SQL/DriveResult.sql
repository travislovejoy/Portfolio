Create Table DriveResult AS
Select d.gsis_id, d.drive_id, pos_team, Sum( (rushing_tds *6) + (passing_tds*6) +(kicking_fgm*3)+ (kicking_xpmade)+ (rushing_twoptm*2) + (passing_twoptm*2) + (kickret_tds *6)) AS offensive_points, SUM((defense_int_tds * 7)+ (defense_frec_tds*7) + (defense_misc_tds *7) + (puntret_tds * 7) + (defense_safe*2)) as defensive_points
From drive d, agg_play p
WHERE d.gsis_id= p.gsis_id
AND d.drive_id=p.drive_id
Group By d.gsis_id, d.drive_id, pos_team;

Create Table Possesions AS
Select d.gsis_id, d.drive_id, pos_team, g.home, (CASE WHEN pos_team= g.home THEN d.offensive_points ELSE d.defensive_points END) AS home_score, g.away, (CASE WHEN pos_team= g.away THEN offensive_points ELSE defensive_points END) as away_score
from DriveResult d, (Select gsis_id, home_team as home, away_team as away From game WHERE season_type= 'Regular') AS g
WHERE d.gsis_id= g.gsis_id
Order BY d.gsis_id, d.drive_id;

Create TABLE PossesionsScore AS
Select p2.gsis_id, p2.drive_id, p2.pos_team, p2.home, SUM(p1.home_score) AS home_score, p2.away, SUM(p1.away_score) AS away_score
From Possesions p1, Possesions p2
WHERE p1.gsis_id=p2.gsis_id
AND p1.drive_id<p2.drive_id
Group BY p2.gsis_id, p2.drive_id, p2.pos_team, p2.home, p2.away
Order BY p2.gsis_id, p2.drive_id;

Insert Into PossesionsScore
Select gsis_id, drive_id, pos_team, home, 0, away,  0
FROM Possesions 
WHERE drive_id=1;

DROP TABLE DriveResult;
Drop TABLE Possesions;


Create TABLE TimePlaycalling AS
Select p.gsis_id, p.drive_id, p.pos_team, home, home_score, away, away_score, pass, Rush, SUBSTRING(cast(time AS text), 3,1) AS Quarter, REPLACE(SUBSTRING(cast(time AS text), 5), ')', '') AS Time
From Possesions Pos, play p, (Select gsis_id, drive_id, play_id, (passing_att+ passing_sk) AS pass, rushing_att as Rush From agg_play) AS ap
WHERE ap.gsis_id= p.gsis_id
AND Pos.gsis_id= p.gsis_id
AND p.drive_id= ap.drive_id
AND Pos.drive_id= p.drive_id
AND p.play_id= ap.play_id;


\COPY (SELECT * FROM TimePlayCalling) TO '/home/travis/NFL/Analysis/Run_Pass_Ratio/Data/TimePlaycalling.csv' DELIMITER ',' CSV HEADER;





GARBAGE



Select d.gsis_id, g.week, g.season_year,pos_team AS team_id, SUM(passing_att +passing_sk) AS Pass, SUM(rushing_att) as Rush
From drive d, agg_play p, game g
WHERE d.drive_id= p.drive_id
AND d.gsis_id= p.gsis_id
AND d.gsis_id= g.gsis_id
AND season_type='Regular'
Group By d.gsis_id, g.week, g.season_year, pos_team;





Create Table DriveResult AS
Select d.gsis_id, d.drive_id, pos_team, Sum( (rushing_tds *6) + (passing_tds*6) +(kicking_fgm*3)+ (kicking_xpmade)+ (rushing_twoptm*2) + (passing_twoptm*2) + (kickret_tds *6)) AS offensive_points, SUM((defense_int_tds * 7)+ (defense_frec_tds*7) + (defense_misc_tds *7) + (puntret_tds * 7) + (defense_safe*2)) as defensive_points
From drive d, agg_play p, (Select gsis_id, home_team as home, away_team as away From game WHERE season_type= 'Regular') AS g 
WHERE d.gsis_id= g.gsis_id
AND d.gsis_id= p.gsis_id 
AND d.drive_id=p.drive_id
Group By d.gsis_id, d.drive_id, pos_team;


Select d2.gsis_id, d2.drive_id, (CASE WHEN (Select pos_team= g.home_team From game g, DriveResult d1 WHERE g.gsis_id=d1.gsis_id AND d2.gsis_id=d1.gsis_id AND d1.drive_id=d2.drive_id) THEN d2.offensive_points ELSE d2.defensive_points END) AS home, (CASE WHEN (Select pos_team= g.away_team From game g, DriveResult d1 WHERE g.gsis_id=d1.gsis_id AND d2.gsis_id=d1.gsis_id AND d1.drive_id=d2.drive_id) THEN offensive_points ELSE defensive_points END) as away
from DriveResult d2
Order BY d2.gsis_id, d2.drive_id;




Select d.gsis_id, d.drive_id, pos_team, (CASE WHEN pos_team= g.home THEN d.offensive_points ELSE d.defensive_points END) AS home, (CASE WHEN pos_team= g.away THEN offensive_points ELSE defensive_points END) as away
from DriveResult d, (Select gsis_id, home_team as home, away_team as away From game WHERE season_type= 'Regular') AS g
WHERE d.gsis_id= g.gsis_id
Order BY d.gsis_id, d.drive_id;

GARBAGE AFTER THIS POINT

CREATE VIEW Home_Score AS



Select dr1.gsis_id, home_team, dr1.drive_id, SUM(dr2.offensive_points) AS PF, SUM(dr2.defensive_points) AS PA
FROM DriveResult dr1, DriveResult dr2, (Select gsis_id, home_team From game WHERE season_type='Regular') as home
Where dr1.gsis_id = home.gsis_id
AND dr1.pos_team= home.home_team
AND dr1.gsis_id= dr2.gsis_id
AND dr2.pos_team= home.home_team
AND dr2.drive_id<dr1.drive_id
Group BY dr1.gsis_id,home.home_team, dr1.drive_id
Order By dr1.gsis_id, dr1.drive_id;

Create View Away_Score AS
Select dr1.gsis_id, away_team, dr1.drive_id, SUM(dr2.offensive_points) AS PF, SUM(dr2.defensive_points) AS PA
FROM DriveResult dr1, DriveResult dr2, (Select gsis_id, away_team From game WHERE season_type='Regular') as away
Where dr1.gsis_id = away.gsis_id
AND dr1.pos_team= away.away_team
AND dr1.gsis_id= dr2.gsis_id
AND dr2.pos_team= away_team
AND dr2.drive_id<dr1.drive_id
Group BY dr1.gsis_id,away_team, dr1.drive_id
Order By dr1.gsis_id, dr1.drive_id;

create table temp AS
select d.gsis_id, d.drive_id, h.PF, h.PA
FROM (Select d.gsis_id, d.drive_id from drive d, game g WHERE  g.season_type='Regular' AND d.gsis_id=g.gsis_id) AS d left join  Home_Score h ON 
d.gsis_id= h.gsis_id
AND d.drive_id= h.drive_id
ORDER by d.gsis_id, d.drive_id;


select gsis_id, drive_id, (CASE WHEN PF is Null then (SELECT t2.PF 
						       FROM temp t2 
							WHERE t1.drive_id> t2.drive_id 
							AND t1.gsis_id= t2.gsis_id 
							AND t2.PF is not NULL ORDER BY t2.drive_id DESC Limit 1) Else PF END) AS PF
From temp t1;
SELECT TOP 1 DATE1 FROM Table1 WHERE ID2<T.ID2 
  AND Date1 IS NOT NULL ORDER BY ID2 DESC
Select d.gsis_id, d.pos_team, d.drive_id, h.PF+a.PA AS home_score, a.PF+h.PA AS away_score_score
FROM 
	(Select dr1.gsis_id, home_team, dr1.drive_id, SUM(dr2.offensive_points) AS PF, SUM(dr2.defensive_points) AS PA
	FROM DriveResult dr1, DriveResult dr2, (Select gsis_id, home_team From game WHERE season_type='Regular') as home
	Where dr1.gsis_id = home.gsis_id
	AND dr1.pos_team= home.home_team
	AND dr1.gsis_id= dr2.gsis_id
	AND dr2.pos_team= home.home_team
	AND dr2.drive_id<dr1.drive_id
	Group BY dr1.gsis_id,home.home_team, dr1.drive_id
	Order By dr1.gsis_id, dr1.drive_id) AS h,
	
	(Select dr1.gsis_id, away_team, dr1.drive_id, SUM(dr2.offensive_points) AS PF, SUM(dr2.defensive_points) AS PA
	FROM DriveResult dr1, DriveResult dr2, (Select gsis_id, away_team From game WHERE season_type='Regular') as away
	Where dr1.gsis_id = away.gsis_id
	AND dr1.pos_team= away.away_team
	AND dr1.gsis_id= dr2.gsis_id
	AND dr2.pos_team= away_team
	AND dr2.drive_id<dr1.drive_id
	Group BY dr1.gsis_id,away_team, dr1.drive_id
	Order By dr1.gsis_id, dr1.drive_id) AS a,
	
	(SELECT gsis_id, drive_id,pos_team
	FROM drive) AS d
WHERE h.gsis_id= a.gsis_id
AND d.gsis_id= a.gsis_id
AND (d.drive_id= h.drive_id AND d.drive_id> a.drive_id)
OR (d.drive_id= a.drive_id AND d.drive_id> h.drive_id);
AND d.drive_id= (SELECT max(drive_id) from h where h.drive_id<d.drive_id);




##Garbage Queries
Select pos_team from agg_play p, drive d
WHERE p.gsis_id= '2013120803'
AND p.drive_id=10
AND d.drive_id=p.drive_id
AND p.gsis_id=d.gsis_id;

 Select p.pos_team, d.pos_team,description from play p, drive d
WHERE p.gsis_id= '2013120803'
AND p.drive_id=11                                              
AND d.drive_id=p.drive_id
AND p.gsis_id=d.gsis_id;

Select drive_id 
From drive
WHERE gsis_id='2009091300'
AND pos_team= 'ATL';
