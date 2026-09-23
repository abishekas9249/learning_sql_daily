-- ============================================================
-- DAILY SQL LEARNING
-- DAY 07: SQL WINDOW FUNCTIONS
-- ============================================================
--
-- Topics:
-- 1. OVER()
-- 2. PARTITION BY
-- 3. ORDER BY inside OVER()
-- 4. ROW_NUMBER()
-- 5. RANK()
-- 6. DENSE_RANK()
-- 7. LAG()
-- 8. Top-N per department
-- 9. Nth-highest salary per department
--
-- ============================================================


-- ============================================================
-- EMPLOYEE TABLE USED FOR DAY 07
-- ============================================================
--
-- id | name   | department | salary
-- ---|--------|------------|-------
-- 1  | Arun   | IT         | 60000
-- 2  | Bala   | HR         | 45000
-- 3  | Charan | IT         | 75000
-- 4  | Divya  | Finance    | 80000
-- 5  | Esha   | HR         | 50000
-- 6  | Farhan | IT         | 65000
-- 7  | Gokul  | Finance    | 70000
-- 8  | Hari   | Finance    | 90000
--
-- ============================================================


-- ============================================================
-- Q1. Total salary of all employees
-- ============================================================

SELECT
    name,
    salary,
    SUM(salary) OVER() AS total_salary
FROM employees;


-- ============================================================
-- Q2. Total salary of each department
-- ============================================================

SELECT
    name,
    department,
    salary,
    SUM(salary) OVER(
        PARTITION BY department
    ) AS department_total_salary
FROM employees;


-- ============================================================
-- Q3. Average salary of each department
-- ============================================================

SELECT
    name,
    department,
    salary,
    AVG(salary) OVER(
        PARTITION BY department
    ) AS department_average_salary
FROM employees;


-- ============================================================
-- Q4. Assign row number to all employees based on salary
--     from highest to lowest
-- ============================================================

SELECT
    name,
    salary,
    ROW_NUMBER() OVER(
        ORDER BY salary DESC
    ) AS row_num
FROM employees;


-- ============================================================
-- Q5. Assign row number within each department
-- ============================================================

SELECT
    name,
    department,
    salary,
    ROW_NUMBER() OVER(
        PARTITION BY department
        ORDER BY salary DESC
    ) AS row_num
FROM employees;


-- ============================================================
-- Q6. Rank employees by salary
-- ============================================================

SELECT
    name,
    department,
    salary,
    RANK() OVER(
        ORDER BY salary DESC
    ) AS salary_rank
FROM employees;


-- ============================================================
-- Q7. Dense rank employees by salary
-- ============================================================

SELECT
    name,
    department,
    salary,
    DENSE_RANK() OVER(
        ORDER BY salary DESC
    ) AS dense_salary_rank
FROM employees;


-- ============================================================
-- Q8. TOP 2 EMPLOYEES PER DEPARTMENT
-- ============================================================
--
-- Pattern:
-- 1. Rank employees within each department
-- 2. Use a CTE
-- 3. Filter rank <= 2
--
-- ============================================================

WITH ranked_employees AS (
    SELECT
        name,
        department,
        salary,
        ROW_NUMBER() OVER(
            PARTITION BY department
            ORDER BY salary DESC
        ) AS row_num
    FROM employees
)
SELECT
    name,
    department,
    salary
FROM ranked_employees
WHERE row_num <= 2;


-- ============================================================
-- Q9. SECOND-HIGHEST SALARY PER DEPARTMENT
-- ============================================================
--
-- DENSE_RANK is used because we want the second DISTINCT
-- highest salary.
--
-- ============================================================

WITH ranked_employees AS (
    SELECT
        name,
        department,
        salary,
        DENSE_RANK() OVER(
            PARTITION BY department
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees
)
SELECT
    name,
    department,
    salary
FROM ranked_employees
WHERE salary_rank = 2;


-- ============================================================
-- Q10. COMPARE EMPLOYEE SALARY WITH PREVIOUS EMPLOYEE
-- ============================================================
--
-- LAG() returns the value from the previous row.
--
-- ============================================================

WITH employee_salary AS (
    SELECT
        name,
        department,
        salary,
        LAG(salary) OVER(
            PARTITION BY department
            ORDER BY salary
        ) AS previous_salary
    FROM employees
)
SELECT
    name,
    department,
    salary,
    previous_salary
FROM employee_salary
WHERE salary > previous_salary;


-- ============================================================
-- ADDITIONAL INTERVIEW EXAMPLES
-- ============================================================


-- ============================================================
-- Example 1: Top 3 employees in each department
-- ============================================================

WITH ranked_employees AS (
    SELECT
        name,
        department,
        salary,
        ROW_NUMBER() OVER(
            PARTITION BY department
            ORDER BY salary DESC
        ) AS row_num
    FROM employees
)
SELECT
    name,
    department,
    salary
FROM ranked_employees
WHERE row_num <= 3;


-- ============================================================
-- Example 2: Department salary ranking
-- ============================================================

SELECT
    name,
    department,
    salary,
    RANK() OVER(
        PARTITION BY department
        ORDER BY salary DESC
    ) AS department_salary_rank
FROM employees;


-- ============================================================
-- Example 3: Previous employee salary
-- ============================================================

SELECT
    name,
    department,
    salary,
    LAG(salary) OVER(
        PARTITION BY department
        ORDER BY salary
    ) AS previous_salary
FROM employees;


-- ============================================================
-- Example 4: Next employee salary
-- ============================================================

SELECT
    name,
    department,
    salary,
    LEAD(salary) OVER(
        PARTITION BY department
        ORDER BY salary
    ) AS next_salary
FROM employees;


-- ============================================================
-- Example 5: Running salary total
-- ============================================================

SELECT
    name,
    department,
    salary,
    SUM(salary) OVER(
        ORDER BY salary
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM employees;


-- ============================================================
-- END OF DAY 07
-- ============================================================