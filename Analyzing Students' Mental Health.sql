-- Prompt -- 
-- Does going to university in a different country affect your mental health? A Japanese international university surveyed its students in 2018 and published a study the following year that was approved by several ethical and regulatory boards.

-- The study found that international students have a higher risk of mental health difficulties than the general population, and that social connectedness (belonging to a social group) and acculturative stress (stress associated with joining a new culture) are predictive of depression.

-- Explore the students data using PostgreSQL to find out if you would come to a similar conclusion for international students and see if the length of stay is a contributing factor.

-------------------------------------------------------------------------------------------------------------------------------

-- Explore and analyze the students data to see how the length of stay (stay) impacts the average mental health diagnostic scores of the international students present in the study.

SELECT 
	stay, 
	COUNT(inter_dom) AS count_int, 
	ROUND(AVG(todep), 2) AS average_phq, 
	ROUND(AVG(tosc), 2) AS average_scs, 
	ROUND(AVG(toas), 2) AS average_as
FROM students
WHERE inter_dom = 'Inter'
GROUP BY stay
ORDER BY stay DESC;
