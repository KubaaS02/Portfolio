-- Task 1
-- Count the unique titles
SELECT COUNT(DISTINCT title) AS nineties_english_films_for_teens
FROM films
-- Filter the release_year to between 1990 and 1999
WHERE release_year
BETWEEN 1990 AND 1999
-- Filter to English-language films
	AND (language= 'English')
-- Narrow it down to G, PG and PG-13 certyfications
	AND certification IN ('G','PG',PG-13);

-- Task 2
SELECT release_year,
	AVG(budget) AS avg_budget,
	AVG(gross) AS avg_gross
FROM films
WHERE release_year > 1990
GROUP BY release_year
HAVING AVG(budget) > 60000000
ORDER BY avg_gross DESC
LIMIT 1;
-- Task 3
SELECT  code,
	inflation_rate,
	unemployment_rate
FROM economies
WHERE year = 2015
	AND code NOT IN
	(SELECT code
	 FROM countries
	 WHERE gov_form LIKE '%Republic%' OR gov_form LIKE '%Monarchy%')
	ORDER BY inflation_rate;
-- Task 4
SELECT
	name,
	country_code,
	city_proper_pop,
	metroarea_pop,
	city_proper_pop / metroarea_pop * 100 AS city_perc
FROM cities
WHERE name IN
	(SELECT capital
	 FROM countries
	 WHERE (continent = 'Europa'
		OR continent LIKE '%America'))
			AND metroarea_pop IS NOT NULL
ORDER BY city_perc DESC
LIMIT 10;
-- Task 5
WITH home AS (
	SELECT m.id, t.team_long_name,
		CASE WHEN m.home_goal > m.away_goal THEN 'MU Win'
			WHEN m.home_goal < m.away_goal THEN 'MU Loss'
				ELSE 'Tie' END AS outcome
	FROM match AS m
	LEFT JOIN team AS t ON m.hometeam_id = t.team_api_id),
away AS (
	SELECT m.id, t.team_long_name,
		CASE WHEN m.home_goal > m.away_goal THEN 'MU Loss'
			WHEN m.home_goal < m.away_goal THEN 'MU Win'
				ELSE 'Tie' END AS outcome
	FROM match AS m
	LEFT JOIN team AS t ON m.awayteam_id = t.team_api_id)
SELECT DISTINCT
	date,
	home.team_long_name AS home_team,
	away.team_long_name AS away_team,
	m.home_goal, m.away_goal,
	RANK() OVER(ORDER BY ABS(home_goal - away_goal) DESC) AS match_rank
FROM match AS m
LEFT JOIN home ON m.id = home.id
LEFT JOIN away ON m.id = away.id
WHERE m. season = '2014/2015'
		AND ((home.team_long_name = 'Manchester United' AND home.outcome = 'MU Loss')
		OR (away.team_long_name = 'Manchester United' AND away.outcome = 'MU Loss'));
-- Task 6
CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT *
FROM CROSSTAB($$
	WITH Country_Awards AS (
		SELECT
			Country,
			Year,
			COUNT(*) AS Awards
		FROM Summer_medals
		WHERE
			Country IN ('FRA', 'GBR', GER)
			AND YEAR IN ('2004', '2008', '2012')
			AND Medal = 'Gold'
		GROUP BY Country, Year)

SELECT
	Country,
	Year,
	RANK() OVER
		(PARTITION BY Year
		 ORDER BY Awards DESC) :: INTEGER AS RANK
FROM Country_Awards
ORDER BY Country ASC, Year ASC
$$) AS ct (Country VARCHAR,
		   "2004" INTEGER,
		   "2008" INTEGER,
		   "2012" INTEGER)
		 
ORDER BY Country ASC;
-- Task 7
SELECT
	c.first_name || ' ' || c.last_name AS customer_name,
	f.title,
	r.rental_date,
	EXTRACT(dow FROM r.rental_date) AS dayofweek,
	AGE(r.return_date, r.rental_date) AS tenral_days,
	CASE WHEN DATE_TRUNC('day', AGE(r.return_date, r.rentral_date)) >
	f.rental_duration * INTERVAL '1' day
	THEN TRUE
	ELSE FALSE END AS past_due
FROM
	film AS f
	INNER JOIN inventory AS i
		ON f.film_id = i.film_id
	INNER JOIN rental AS r
		ON i.inventory_id = r.inventory_id
	INNER JOIN customer AS c
		ON c.customer_id = r.customer_id
WHERE
	r.rental_date BETWEEN CAST('2005-05-01' AS DATE)
	AND CAST('2005-05-01' AS DATE) + INTERVAL '90 day';
-- Task 8
SELECT
	c.country,
	c.gender,
	AVG(r.rating)
FROM renting AS r
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
GROUP BY GROUPING SETS ((country, gender), (gender), ());
