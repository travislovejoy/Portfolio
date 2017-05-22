
Create VIEW AlexSmith AS
SELECT full_name, week, season_year, (CASE WHEN home THEN away_team ELSE home_team END) AS opponent,  SUM(passing_cmp) AS Comp, SUM(passing_att) AS Pass_att, SUM(passing_yds) AS Pass_yards, SUM(passing_tds) as Pass_tds, SUM(passing_int) AS Int, SUM(passing_sk) AS Sacked, SUM(rushing_att) AS Rush_att, SUM(rushing_yds) as Rush_yards, SUM(rushing_tds) as Rush_tds, 
(CASE WHEN home THEN (CASE WHEN home_score> away_score THEN 1 ELSE 0 END) ELSE (CASE WHEN away_score> home_score THEN 1 ELSE 0 END) END) AS WIN
FROM player AS p, play_player AS pp, 
		(Select gsis_id, week, season_year, ('SF'= g.home_team) AS home, g.home_team, g.away_team, home_score, away_score
		FROM Game as g
		Where 'SF' IN (g.home_team, g.away_team)
		AND g.season_type= 'Regular'
		AND g.season_year=2012
		AND week<9
		Order By week) AS Games
WHERE full_name= 'Alex Smith'
AND pp.team = 'SF'
AND p.player_id= pp.player_id
AND pp.gsis_id IN (Games.gsis_id)
GROUP BY full_name, week, season_year, opponent, win
ORDER BY week;

\COPY (Select * from AlexSmith) TO '/home/travis/NFL/Analysis/QBchange/Data/AlexSmith.csv' DELIMITER ',' CSV HEADER;
Drop View AlexSmith

