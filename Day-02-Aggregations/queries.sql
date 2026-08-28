-- Day 02: Aggregate Functions
-- Topics: COUNT, SUM, AVG, MIN, MAX

-- Q1. Total number of employees
SELECT COUNT(*)
FROM employees;

-- Q2. Total salary
SELECT SUM(salary)
FROM employees;

-- Q3. Average salary
SELECT AVG(salary)
FROM employees;

-- Q4. Highest salary
SELECT MAX(salary)
FROM employees;

-- Q5. Lowest salary
SELECT MIN(salary)
FROM employees;

-- Q6. Number of IT employees
SELECT COUNT(*)
FROM employees
WHERE department = 'IT';

-- Q7. Total salary of IT employees
SELECT SUM(salary)
FROM employees
WHERE department = 'IT';

-- Q8. Average salary of HR employees
SELECT AVG(salary)
FROM employees
WHERE department = 'HR';

-- Q9. Highest salary among IT employees
SELECT MAX(salary)
FROM employees
WHERE department = 'IT';

-- Q10. Total and average salary of employees
-- whose salary is greater than 50000
SELECT
    SUM(salary) AS total_salary,
    AVG(salary) AS avg_salary
FROM employees
WHERE salary > 50000;

-- Interview Challenge
-- Find total salary and average salary of employees
-- whose salary is greater than the overall average salary
SELECT
    SUM(salary) AS total_salary,
    AVG(salary) AS avg_salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);