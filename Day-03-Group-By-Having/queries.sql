-- Day 03: GROUP BY and HAVING
-- Topics: GROUP BY, HAVING, COUNT, SUM, AVG, MAX, MIN

-- ============================================================
-- Q1. Find the number of employees in each department
-- ============================================================

SELECT
    department,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department;


-- ============================================================
-- Q2. Find the total salary for each department
-- ============================================================

SELECT
    department,
    SUM(salary) AS total_salary
FROM employees
GROUP BY department;


-- ============================================================
-- Q3. Find the average salary for each department
-- ============================================================

SELECT
    department,
    AVG(salary) AS average_salary
FROM employees
GROUP BY department;


-- ============================================================
-- Q4. Find the highest salary in each department
-- ============================================================

SELECT
    department,
    MAX(salary) AS maximum_salary
FROM employees
GROUP BY department;


-- ============================================================
-- Q5. Find the lowest salary in each department
-- ============================================================

SELECT
    department,
    MIN(salary) AS minimum_salary
FROM employees
GROUP BY department;


-- ============================================================
-- Q6. Find departments having more than 1 employee
-- ============================================================

SELECT
    department,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) > 1;


-- ============================================================
-- Q7. Find departments where the average salary is
-- greater than 60000
-- ============================================================

SELECT
    department,
    AVG(salary) AS average_salary
FROM employees
GROUP BY department
HAVING AVG(salary) > 60000;


-- ============================================================
-- Q8. Find departments where the total salary is
-- greater than 100000
-- ============================================================

SELECT
    department,
    SUM(salary) AS total_salary
FROM employees
GROUP BY department
HAVING SUM(salary) > 100000;


-- ============================================================
-- Q9. Find departments having more than 1 employee
-- whose salary is greater than 50000
-- ============================================================

SELECT
    department,
    COUNT(*) AS employee_count
FROM employees
WHERE salary > 50000
GROUP BY department
HAVING COUNT(*) > 1;


-- ============================================================
-- Q10. Find department-wise employee count considering
-- only employees whose salary is greater than 50000.
-- Display only departments having at least 2 such employees.
-- ============================================================

SELECT
    department,
    COUNT(*) AS employee_count
FROM employees
WHERE salary > 50000
GROUP BY department
HAVING COUNT(*) >= 2;


-- ============================================================
-- Day 03 Interview Challenge
-- Find the department with the highest average salary.
-- ============================================================

SELECT
    department,
    AVG(salary) AS average_salary
FROM employees
GROUP BY department
ORDER BY AVG(salary) DESC
LIMIT 1;