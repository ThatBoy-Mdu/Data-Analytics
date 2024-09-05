-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?
SELECT gender, count(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY gender;
-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race, count(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY race
ORDER BY count(*) DESC;
-- 3. What is the age distribution of employees in the company?
SELECT 
	min(age) AS youngest,
    max(age) AS oldest
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00';
SELECT
	CASE
		WHEN age>= 18 AND age <=25 THEN '18-25'
        WHEN age>= 26 AND age <=35 THEN '26-35'
        WHEN age>= 36 AND age <=60 THEN '36-60'
        ELSE '61+'
	END AS age_group,
    count(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY age_group
ORDER BY age_group;

-- 4. How many employees work at headquarters versus remote locations?
SELECT location, count(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?
SELECT
	round(avg(datediff(termdate,hire_date))/365,0) AS ave_length_of_emp
FROM hr
WHERE termdate <= curdate() AND termdate <> '0000-00-00' AND age >= 18;
-- 6. How does the gender distribution vary across departments and job titles?
SELECT department, gender, COUNT(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY department,gender
ORDER BY department;

-- 7. What is the distribution of job titles across the company?
SELECT jobtitle, count(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- 8. Which department has the highest turnover rate?
SELECT department,
total_count,
terminated_count,
terminated_count/total_count AS termination_rate
FROM (
	SELECT department,
    count(*) AS total_count,
    SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
FROM hr
WHERE age >= 18 
GROUP BY department
) AS subquery
ORDER BY termination_rate DESC;

-- 9. What is the distribution of employees across locations by city and state?
SELECT location_state, count(*) AS count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location_state
ORDER BY count DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates?
SELECT
	year,
	hires,
	terminations,
	hires - terminations AS net_change,
	round((hires-terminations)/hires * 100,2) AS net_change_percentage
FROM(
	SELECT
		YEAR(hire_date) AS year,
        count(*) AS hires,
        SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminations
        FROM hr
        WHERE age >= 18
        GROUP BY YEAR(hire_date)
        ) AS subquery
ORDER BY year ASC;
-- 11. What is the tenure distribution for each department?
SELECT department, round(avg(datediff(termdate, hire_date)/365),0) AS avg_tenure
FROM hr
WHERE termdate <= curdate() AND termdate <> '0000-00-00' AND age >= 18
GROUP BY department;