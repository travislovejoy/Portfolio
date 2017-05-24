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

Create TABLE WinProb AS
Select p.gsis_id, drive_id, pos_team, p.home, p.home_score, p.away, p.away_score, quarter, time, g.home_score>g.away_score AS home_win
From TimePlaycalling p, game g
Where p.gsis_id =g.gsis_id;

\COPY (SELECT * FROM WinProb) TO '/home/travis/NFL/Analysis/Run_Pass_Ratio/Data/TimePlaycalling.csv' DELIMITER ',' CSV HEADER;
