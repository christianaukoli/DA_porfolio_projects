-- Prompt --
-- Video games are big business: the global gaming market is projected to be worth more than $300 billion by 2027 according to Mordor Intelligence. With so much money at stake, the major game publishers are hugely incentivized to create the next big hit. But are games getting better, or has the golden age of video games already passed?

-- In this project, you'll analyze video game critic and user scores as well as sales data for the top 400 video games released since 1977. You'll search for a golden age of video games by identifying release years that users and critics liked best, and you'll explore the business side of gaming by looking at game sales data.

-----------------------------------------------------------------------------------------------------------------------------

-- Find the ten best-selling games. The output should contain all the columns in the game_sales table and be sorted by the games_sold column in descending order. 

SELECT *
FROM public.game_sales
ORDER BY games_sold DESC
LIMIT 10;

-----------------------------------------------------------------------------------------------------------------------------

-- Find the ten years with the highest average critic score, where at least four games were released (to ensure a good sample size). Return an output with the columns year, num_games released, and avg_critic_score. The avg_critic_score should be rounded to 2 decimal places. The table should be ordered by avg_critic_score in descending order. 

SELECT year, COUNT(name) AS num_games, ROUND(AVG(critic_score),2) AS avg_critic_score
FROM public.reviews 
LEFT JOIN game_sales 
USING(name)
GROUP BY year
HAVING COUNT(name) >= 4
ORDER BY avg_critic_score DESC
LIMIT 10;

-----------------------------------------------------------------------------------------------------------------------------

-- Find the years where critics and users broadly agreed that the games released were highly rated. Specifically, return the years where the average critic score was over 9 OR the average user score was over 9. The pre-computed average critic and user scores per year are stored in users_avg_year_rating and critics_avg_year_rating tables respectively. The query should return the following columns: year, num_games, avg_critic_score, avg_user_score, and diff. The diff column should be the difference between the avg_critic_score and avg_user_score. The table should be ordered by the year in ascending order.

SELECT year, u.num_games, avg_critic_score, avg_user_score, (avg_critic_score - avg_user_score) AS diff
FROM public.users_avg_year_rating AS u
LEFT JOIN public.critics_avg_year_rating AS c
USING(year)
WHERE avg_critic_score > 9
	OR avg_user_score > 9
ORDER BY year;
