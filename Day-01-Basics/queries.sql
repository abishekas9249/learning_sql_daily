-- Day 01: SQL Fundamentals
-- Topics: SELECT, WHERE, AND, OR, ORDER BY, DISTINCT

-- Q1. Fetch name and salary of every employee
SELECT name, salary
FROM employees;

-- Q2. Fetch employees whose salary is greater than 50000
SELECT name
FROM employees
WHERE salary > 50000;

-- Q3. Fetch employees belonging to IT
SELECT name
FROM employees
WHERE department = 'IT';

-- Q4. Fetch IT employees whose salary is greater than 60000
SELECT name
FROM employees
WHERE department = 'IT'
  AND salary > 60000;

-- Q5. Fetch employees belonging to IT or HR
SELECT name
FROM employees
WHERE department = 'IT'
   OR department = 'HR';

-- Q6. Fetch employees ordered by salary from highest to lowest
SELECT name, salary
FROM employees
ORDER BY salary DESC;

-- Q7. Fetch unique departments
SELECT DISTINCT department
FROM employees;

-- Q8. Fetch IT employees with salary greater than 60000,
-- ordered by salary from highest to lowest
SELECT name, salary
FROM employees
WHERE department = 'IT'
  AND salary > 60000
ORDER BY salary DESC;

-- Interview Challenge
-- Fetch employees whose salary is greater than 60000,
-- ordered by salary from highest to lowest
SELECT name
FROM employees
WHERE salary > 60000
ORDER BY salary DESC;