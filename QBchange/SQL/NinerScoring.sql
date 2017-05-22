

CREATE VIEW NinerOffense AS
SELECT week, season_year, team_id, PF, PA, PYDS, PTD, RYDS, RTDS, PATT, RATT, SACKS, PYDS+RYDS AS TotalYards
FROM offense O
WHERE O.season_year=2012
AND O.team_id= 'SF';

\COPY (SELECT * FROM NinerOffense) TO '/home/travis/NFL/Analysis/QBchange/Data/Offense.csv' DELIMITER ',' CSV HEADER;

DROP VIEW NinerOffense;

CREATE VIEW NinerScoring AS
SELECT O.week, O.season_year, O.team_id, PTD+ RTDS AS Touchdowns, FGM, PINT+FUM AS Turnovers
FROM offense O, Special S
WHERE O.season_year=2012
AND O.team_id= 'SF'
AND O.season_year= S.season_year
AND O.week= S.week
AND O.team_id= S.team_id;

\COPY (SELECT * FROM NinerScoring) TO '/home/travis/NFL/Analysis/QBchange/Data/Scoring.csv' DELIMITER ',' CSV HEADER;

DROP VIEW NinerScoring;


