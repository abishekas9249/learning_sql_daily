-- ============================================================
-- DAY 06: CTEs (Common Table Expressions)
-- Database: PostgreSQL
-- Table: employees
-- ============================================================


-- Sample table
-- ------------------------------------------------------------
-- id | name   | department | salary
-- ------------------------------------------------------------
-- 1  | Arun   | IT         | 60000
-- 2  | Bala   | HR         | 45000
-- 3  | Charan | IT         | 75000
-- 4  | Divya  | Finance    | 80000
-- 5  | Esha   | HR         | 50000
-- 6  | Farhan | IT         | 65000
-- 7  | Gokul  | Finance    | 70000
-- 8  | Hari   | Finance    | 90000


-- ============================================================
-- Q1. Find the average salary of each department using a CTE
-- ============================================================

WITH average_department AS (
    SELECT
        department,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
)
SELECT
    department,
    average_salary
FROM average_department;


-- ============================================================
-- Q2. Find departments whose average salary is greater than
--     60000
-- ============================================================

WITH average_department AS (
    SELECT
        department,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
)
SELECT
    department,
    average_salary
FROM average_department
WHERE average_salary > 60000;


-- ============================================================
-- Q3. Count employees in each department using a CTE
-- ============================================================

WITH department_count AS (
    SELECT
        department,
        COUNT(*) AS employee_count
    FROM employees
    GROUP BY department
)
SELECT
    department,
    employee_count
FROM department_count;


-- ============================================================
-- Q4. Find departments having more than 2 employees
-- ============================================================

WITH department_count AS (
    SELECT
        department,
        COUNT(*) AS employee_count
    FROM employees
    GROUP BY department
)
SELECT
    department,
    employee_count
FROM department_count
WHERE employee_count > 2;


-- ============================================================
-- Q5. Find departments having at least 3 employees and
--     average salary greater than 60000
-- ============================================================

WITH department_summary AS (
    SELECT
        department,
        COUNT(*) AS employee_count,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
)
SELECT
    department,
    employee_count,
    average_salary
FROM department_summary
WHERE employee_count >= 3
  AND average_salary > 60000;


-- ============================================================
-- Q6. Find employees whose salary is greater than their
--     department's average salary
-- ============================================================

WITH filter_department AS (
    SELECT
        department,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
)
SELECT
    e.name,
    e.department,
    e.salary,
    fd.average_salary
FROM employees e
INNER JOIN filter_department fd
    ON e.department = fd.department
WHERE e.salary > fd.average_salary;


-- ============================================================
-- Q7. Find the department with the highest average salary
-- ============================================================

WITH average_department AS (
    SELECT
        department,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
)
SELECT
    department,
    average_salary
FROM average_department
ORDER BY average_salary DESC
LIMIT 1;


-- ============================================================
-- Q8. Find all employees who belong to the department having
--     the highest average salary
-- ============================================================

WITH average_department AS (
    SELECT
        department,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
),
highest_average_department AS (
    SELECT
        department,
        average_salary
    FROM average_department
    ORDER BY average_salary DESC
    LIMIT 1
)
SELECT
    e.name,
    e.department,
    e.salary
FROM employees e
INNER JOIN highest_average_department had
    ON e.department = had.department;


-- ============================================================
-- Q9. Display department average salary and employee count
--     together
-- ============================================================

WITH average_department AS (
    SELECT
        department,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
),
count_department AS (
    SELECT
        department,
        COUNT(*) AS employee_count
    FROM employees
    GROUP BY department
)
SELECT
    ad.department,
    ad.average_salary,
    cd.employee_count
FROM average_department ad
INNER JOIN count_department cd
    ON ad.department = cd.department;


-- ============================================================
-- Q10. Find the department having the highest total salary
-- ============================================================

WITH total_expenditure AS (
    SELECT
        department,
        SUM(salary) AS total_salary
    FROM employees
    GROUP BY department
)
SELECT
    department,
    total_salary
FROM total_expenditure
ORDER BY total_salary DESC
LIMIT 1;


-- ============================================================
-- INTERVIEW CHALLENGE
-- ============================================================
-- Find employees whose salary is greater than the average
-- salary of their own department.


WITH department_average AS (
    SELECT
        department,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
)
SELECT
    e.name,
    e.department,
    e.salary,
    da.average_salary
FROM employees e
INNER JOIN department_average da
    ON e.department = da.department
WHERE e.salary > da.average_salary;