-- Prompt --
-- GoodThought NGO has been a catalyst for positive change, focusing its efforts on education, healthcare, and sustainable development to make a significant difference in communities worldwide. With this mission, GoodThought has orchestrated an array of assignments aimed at uplifting underprivileged populations and fostering long-term growth.

-- This project offers a hands-on opportunity to explore how data-driven insights can direct and enhance these humanitarian efforts. In this project, you'll engage with the GoodThought PostgreSQL database, which encapsulates detailed records of assignments, funding, impacts, and donor activities from 2010 to 2023. This comprehensive dataset includes:
--     - Assignments: Details about each project, including its name, duration (start and end dates), budget, geographical region, and the impact score.
--     - Donations: Records of financial contributions, linked to specific donors and assignments, highlighting how financial support is allocated and utilized.
--     - Donors: Information on individuals and organizations that fund GoodThought’s projects, including donor types.

-- Write two SQL queries to answer the following questions:
--     List the top five assignments based on total value of donations, categorized by donor type. The output should include four columns: 1) assignment_name, 2) region, 3) rounded_total_donation_amount rounded to two decimal places, and 4) donor_type, sorted by rounded_total_donation_amount in descending order. Save the result as highest_donation_assignments.

--     Identify the assignment with the highest impact score in each region, ensuring that each listed assignment has received at least one donation. The output should include four columns: 1) assignment_name, 2) region, 3) impact_score, and 4) num_total_donations, sorted by region in ascending order. Include only the highest-scoring assignment per region, avoiding duplicates within the same region. Save the result as top_regional_impact_assignments.

-----------------------------------------------------------------------------------------------------------------------------

-- highest_donation_assignments
SELECT assignment_name, region, ROUND(SUM(amount),2) AS rounded_total_donation_amount, donor_type
FROM assignments
LEFT JOIN donations
USING(assignment_id)
LEFT JOIN donors
USING(donor_id)
WHERE donor_type IS NOT null
GROUP BY donor_type, assignment_name, region
ORDER BY rounded_total_donation_amount DESC
LIMIT 5;
-----------------------------------------------------------------------------------------------------------------------------

-- top_regional_impact_assignments
WITH CTE AS (
SELECT 
	DISTINCT assignment_name,
	region,
	impact_score,
	ROW_NUMBER() OVER (PARTITION BY region ORDER BY impact_score DESC) AS rowrank,
	COUNT(amount) AS num_total_donations
FROM assignments
LEFT JOIN donations
ON assignments.assignment_id = donations.assignment_id
LEFT JOIN donors
ON donations.donor_id = donors.donor_id
GROUP BY assignment_name, region, impact_score
HAVING (COUNT(amount) > 0)
ORDER BY region, rowrank
)
SELECT 
	assignment_name,
	region,
	impact_score,
	num_total_donations
FROM CTE
WHERE rowrank = 1;
