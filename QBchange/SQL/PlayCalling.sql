Create View PlayCalling AS
Select d.gsis_id, g.week, g.season_year,pos_team AS team_id, SUM(passing_att +passing_sk) AS Pass, SUM(rushing_att) as Rush
From drive d, agg_play p, game g
WHERE d.drive_id= p.drive_id
AND d.gsis_id= p.gsis_id
AND d.gsis_id= g.gsis_id
AND season_type='Regular'
Group By d.gsis_id, g.week, g.season_year, pos_team;

Create View TimeOfPossesion AS
Select d.gsis_id, g.week, g.season_year,pos_team AS team_id, SUM(cast(replace(replace(cast(pos_time as text), '(', ''), ')', '') as float))/60 as pos_time
From drive d, game g
WHERE d.gsis_id= g.gsis_id
AND season_type='Regular'
Group By d.gsis_id, g.week, g.season_year, pos_team;

CREATE VIEW NinerPlayCalling AS
SELECT p.gsis_id, p.week, p.season_year, p. team_id, Pass, Rush, pos_time
FROM PlayCalling as p, TimeOfPossesion as t,
		(Select gsis_id, week, season_year, ('SF'= g.home_team) AS home, g.home_team, g.away_team, home_score, away_score
		FROM Game as g
		Where 'SF' IN (g.home_team, g.away_team)
		AND g.season_type= 'Regular'
		AND g.season_year=2012
		Order By week) AS g
WHERE p.gsis_id= t.gsis_id
AND p.week= t.week
AND p.season_year= t.season_year
AND p.team_id= t.team_id
AND g.gsis_id=p.gsis_id;


\COPY (SELECT * FROM NinerPlayCalling) TO '/home/travis/NFL/Analysis/QBchange/Data/PlayCalling.csv' DELIMITER ',' CSV HEADER;
