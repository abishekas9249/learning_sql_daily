-- ============================================================
-- Day 04: SQL JOINs
-- Topics:
-- INNER JOIN
-- LEFT JOIN
-- RIGHT JOIN
-- JOIN + WHERE
-- JOIN + GROUP BY
-- JOIN + HAVING
-- COUNT(e.id) vs COUNT(*)
-- ============================================================


-- ============================================================
-- TABLES USED
-- ============================================================

-- employees
--
-- | id | name    | department_id | salary |
-- |----|---------|---------------|--------|
-- | 1  | Arun    | 10            | 60000  |
-- | 2  | Bala    | 20            | 45000  |
-- | 3  | Charan  | 10            | 75000  |
-- | 4  | Divya   | 30            | 80000  |
-- | 5  | Esha    | 20            | 50000  |
-- | 6  | Farhan  | NULL          | 65000  |
--
--
-- departments
--
-- | id | department_name |
-- |----|-----------------|
-- | 10 | IT              |
-- | 20 | HR              |
-- | 30 | Finance         |
-- | 40 | Marketing       |


-- ============================================================
-- Q1. Display employee name and department name
-- ============================================================

SELECT
    e.name AS employee_name,
    d.department_name
FROM employees e
INNER JOIN departments d
    ON e.department_id = d.id;


-- ============================================================
-- Q2. Display employee name, salary and department name
-- ============================================================

SELECT
    e.name AS employee_name,
    e.salary,
    d.department_name
FROM employees e
INNER JOIN departments d
    ON e.department_id = d.id;


-- ============================================================
-- Q3. Find employees who belong to the IT department
-- ============================================================

SELECT
    e.name AS employee_name,
    d.department_name
FROM employees e
INNER JOIN departments d
    ON e.department_id = d.id
WHERE d.department_name = 'IT';


-- ============================================================
-- Q4. Display ALL employees, including employees
-- who don't have a department
-- ============================================================

SELECT
    e.name AS employee_name,
    d.department_name
FROM employees e
LEFT JOIN departments d
    ON e.department_id = d.id;


-- ============================================================
-- Q5. Display ALL departments, including departments
-- that don't have any employees
-- ============================================================

SELECT
    d.department_name,
    e.name AS employee_name
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.id;


-- ============================================================
-- Q6. Find employees whose salary is greater than 60000
-- along with their department name
-- ============================================================

SELECT
    e.name AS employee_name,
    e.salary,
    d.department_name
FROM employees e
INNER JOIN departments d
    ON e.department_id = d.id
WHERE e.salary > 60000;


-- ============================================================
-- Q7. Find the number of employees in each department
-- ============================================================

SELECT
    d.department_name,
    COUNT(e.id) AS employee_count
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.id
GROUP BY d.department_name;


-- ============================================================
-- Q8. Find the average salary for each department
-- ============================================================

SELECT
    d.department_name,
    AVG(e.salary) AS average_salary
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.id
GROUP BY d.department_name;


-- ============================================================
-- Q9. Find departments having more than 1 employee
-- ============================================================

SELECT
    d.department_name,
    COUNT(e.id) AS employee_count
FROM departments d
INNER JOIN employees e
    ON e.department_id = d.id
GROUP BY d.department_name
HAVING COUNT(e.id) > 1;


-- ============================================================
-- Q10. Display each department's name, number of employees,
-- and average salary.
--
-- Include departments that currently have ZERO employees.
-- ============================================================

SELECT
    d.department_name,
    COUNT(e.id) AS employee_count,
    AVG(e.salary) AS average_salary
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.id
GROUP BY d.department_name;


-- ============================================================
-- DAY 04 INTERVIEW CHALLENGE
--
-- Find the department with the highest number of employees.
-- ============================================================

SELECT
    d.department_name,
    COUNT(e.id) AS employee_count
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.id
GROUP BY d.department_name
ORDER BY employee_count DESC
LIMIT 1;