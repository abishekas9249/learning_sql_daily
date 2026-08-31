-- ============================================================
-- Day 05: SQL SUBQUERIES
-- ============================================================
-- Topics:
-- 1. Scalar subquery
-- 2. Aggregate subquery
-- 3. IN with subquery
-- 4. Second-highest salary
-- 5. Correlated subquery
-- 6. EXISTS
-- 7. Subquery with department-level calculations
-- ============================================================


-- ============================================================
-- TABLE USED
-- ============================================================

-- employees
--
-- | id | name   | department | salary |
-- |----|--------|------------|--------|
-- | 1  | Arun   | IT         | 60000  |
-- | 2  | Bala   | HR         | 45000  |
-- | 3  | Charan | IT         | 75000  |
-- | 4  | Divya  | Finance    | 80000  |
-- | 5  | Esha   | HR         | 50000  |
-- | 6  | Farhan | IT         | 65000  |
-- | 7  | Gokul  | Finance    | 70000  |
-- | 8  | Hari   | Finance    | 90000  |


-- ============================================================
-- Q1. Find employees whose salary is greater than the
-- average salary of all employees.
-- ============================================================

SELECT
    name,
    salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);


-- ============================================================
-- Q2. Find employees whose salary is less than the
-- average salary of all employees.
-- ============================================================

SELECT
    name,
    salary
FROM employees
WHERE salary < (
    SELECT AVG(salary)
    FROM employees
);


-- ============================================================
-- Q3. Find employee(s) who have the highest salary.
-- ============================================================

SELECT
    name,
    salary
FROM employees
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
);


-- ============================================================
-- Q4. Find employee(s) who have the lowest salary.
-- ============================================================

SELECT
    name,
    salary
FROM employees
WHERE salary = (
    SELECT MIN(salary)
    FROM employees
);


-- ============================================================
-- Q5. Find employees whose salary is greater than the
-- average salary of the IT department.
-- ============================================================

SELECT
    name,
    salary,
    department
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
    WHERE department = 'IT'
);


-- ============================================================
-- Q6. Find employees who belong to departments where the
-- average salary is greater than 60000.
-- ============================================================

SELECT
    name,
    department,
    salary
FROM employees
WHERE department IN (
    SELECT department
    FROM employees
    GROUP BY department
    HAVING AVG(salary) > 60000
);


-- ============================================================
-- Q7. Find employee(s) with the second-highest DISTINCT salary.
-- ============================================================

SELECT
    name,
    salary
FROM employees
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
    WHERE salary < (
        SELECT MAX(salary)
        FROM employees
    )
);


-- ============================================================
-- Q8. Find employees whose salary is equal to the maximum
-- salary in their own department.
-- ============================================================

SELECT
    e.name,
    e.salary,
    e.department
FROM employees e
WHERE e.salary = (
    SELECT MAX(e2.salary)
    FROM employees e2
    WHERE e2.department = e.department
);


-- ============================================================
-- Q9. Find departments that have at least one employee
-- earning more than 75000.
-- ============================================================

SELECT DISTINCT
    d.department
FROM employees d
WHERE EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department = d.department
      AND e.salary > 75000
);


-- ============================================================
-- Q10. INTERVIEW CHALLENGE
--
-- Find employees who earn more than the average salary
-- of their own department.
-- ============================================================

SELECT
    e.name,
    e.salary,
    e.department
FROM employees e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department = e.department
);