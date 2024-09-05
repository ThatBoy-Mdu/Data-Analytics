# Data-Analytics Project
### Using analysis skills to explore, manipulate and visualize data

To begin, we create a database on mySQL and give the file any name.
``` mySQL
CREATE DATABASE busi;
```

Then inform mySQL of where to access this specific dataset. once the data is imported we can view a sample of the data.
```mysql
USE busi;

SELECT * FROM hr;
```

And when the importing of the data is complete, we can begin with the data cleaning process.
So, firstly we have to rename the id column, since it is written in odd characters. In this step, I changed column ID and converted the datatype from text to VARCHAR(20) this is character variable, and set it to 20 characters in that space or column.
```mysql
ALTER TABLE hr
CHANGE COLUMN ï»¿id Employee_ID VARCHAR(20)NULL;
DESCRIBE hr;
```
![1](https://github.com/user-attachments/assets/f6b46057-f97e-4046-9aaf-fe9730697e3b)

Then checked the datatypes of all the other columns. Next, I worked with the birthdate column. This column has some inconsistant data inputs, and therefore cannot be used to get accurate information.
```mysql
SELECT birthdate FROM hr;

SET sql_safe_updates = 0;

UPDATE hr
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'),'%Y-%m-%d')
	WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'),'%Y-%m-%d')
	ELSE NULL 
END;

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;
```
NB: I set the SET sql_safe_updates = 0; function because the data encypted and was not to be changed.
Then moved to change the birthdate from a text datatype to a date datatype. then used a WHEN function to set the condition to the parameters that I required to convert to a date datatype. And proceeded to alter the table and modify the column. 

![pic 2](https://github.com/user-attachments/assets/2a9b1627-c017-4f0b-b884-a1a2b5eee960)

Next, modified the column data for hire_date using the same technique used to convert the birthdate column.
```mysql
UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'),'%Y-%m-%d')
	WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'),'%Y-%m-%d')
	ELSE NULL 
END;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;
```
![pic 3](https://github.com/user-attachments/assets/eaf4fd58-fff6-493d-b2c3-69e1f85ee83b)

then same for termdate, but termdate dataset had (inconsistant) date and times in the same column thus, we had to remove the time and set the null or empty rows with 0000-00-00 in the year-month-day format as reqired by the question.
```mysql
UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

ALTER TABLE hr
MODIFY COLUMN termdate DATE;
```
then after a new 'age' column which didn't exist was created in order to be able to answer the questions to follow,
```mysql
ALTER TABLE hr ADD COLUMN age INT;
```
and lastly, the age was calculated. Upon realization it was discovered that there was ages which were negative values and others less than 18 which is incorrect. to view the ages, we took a look at minimum and maximum values and used a SELECT statement to filter the ages to only over 18 years.
```mysql
UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT 
	min(age) AS youngest,
    max(age) AS oldest
FROM hr;
```
![pic 4](https://github.com/user-attachments/assets/7ecc29ac-0daf-491c-9db7-3d6cf957c248)

![pic 5](https://github.com/user-attachments/assets/c25f9e67-27d8-4169-80d9-d34525c861a6)

#### Exercise Questions:
```mysql
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
```
THE RESULTS OF THESE QUESTIONS ARE VISUALIZED IN EXCEL AND SAVED IN CSV FILE FOR DATA VISUALIZATION.
Please go ahead and view those 🙂 (The xlsx and docx files)


