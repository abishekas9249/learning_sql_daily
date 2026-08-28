# Day 03 — GROUP BY and HAVING

## Objective

Learn how to group rows and perform aggregate calculations
for each group.

---

## Topics Covered

- GROUP BY
- HAVING
- COUNT()
- SUM()
- AVG()
- MAX()
- MIN()
- WHERE + GROUP BY
- GROUP BY + HAVING
- WHERE vs HAVING
- SQL logical processing order

---

# 1. GROUP BY

GROUP BY is used to combine rows having the same value
into groups.

Example:

SELECT department, COUNT(*)
FROM employees
GROUP BY department;

This gives the number of employees in each department.

Example result:

| department | employee_count |
|------------|----------------|
| IT         | 3              |
| HR         | 2              |
| Finance    | 3              |

---

# 2. GROUP BY with Aggregate Functions

Aggregate functions operate on each group.

## COUNT()

Find the number of employees in each department:

SELECT department, COUNT(*)
FROM employees
GROUP BY department;

---

## SUM()

Find total salary for each department:

SELECT department, SUM(salary)
FROM employees
GROUP BY department;

---

## AVG()

Find average salary for each department:

SELECT department, AVG(salary)
FROM employees
GROUP BY department;

---

## MAX()

Find highest salary in each department:

SELECT department, MAX(salary)
FROM employees
GROUP BY department;

---

## MIN()

Find lowest salary in each department:

SELECT department, MIN(salary)
FROM employees
GROUP BY department;

---

# 3. HAVING

HAVING is used to filter groups after GROUP BY.

Example:

Find departments having more than 1 employee:

SELECT department, COUNT(*)
FROM employees
GROUP BY department
HAVING COUNT(*) > 1;

HAVING is commonly used with aggregate functions.

---

# 4. WHERE vs HAVING

This is an important interview question.

## WHERE

WHERE filters individual rows before grouping.

Example:

SELECT *
FROM employees
WHERE salary > 50000;

It removes employees whose salary is not greater than 50000.

---

## HAVING

HAVING filters groups after GROUP BY.

Example:

SELECT department, COUNT(*)
FROM employees
GROUP BY department
HAVING COUNT(*) > 2;

Here COUNT(*) is calculated for each department first,
and then departments having more than 2 employees are retained.

---

# Key Interview Statement

WHERE filters rows.

HAVING filters groups.

Remember:

WHERE → individual rows
HAVING → groups

---

# 5. WHERE + GROUP BY + HAVING

Example:

Find departments having more than 1 employee whose salary
is greater than 50000.

SELECT
    department,
    COUNT(*) AS employee_count
FROM employees
WHERE salary > 50000
GROUP BY department
HAVING COUNT(*) > 1;

Processing concept:

employees
    ↓
WHERE salary > 50000
    ↓
GROUP BY department
    ↓
COUNT employees
    ↓
HAVING COUNT(*) > 1
    ↓
final result

---

# 6. SQL Logical Processing Order

Conceptually, SQL processes the query approximately in this order:

FROM
    ↓
WHERE
    ↓
GROUP BY
    ↓
HAVING
    ↓
SELECT
    ↓
ORDER BY

This is useful for understanding why WHERE and HAVING
behave differently.

---

# 7. Important Interview Mistake

Question:

Find the department with the highest average salary.

Incorrect approach:

SELECT department
FROM employees
WHERE MAX(AVG(salary))
GROUP BY department;

Why is this wrong?

MAX(AVG(salary)) tries to perform two levels of aggregation
at the same query level.

First, we need to calculate the average salary for each
department.

Then we need to identify the department with the highest
average.

A simple PostgreSQL solution:

SELECT
    department,
    AVG(salary) AS average_salary
FROM employees
GROUP BY department
ORDER BY AVG(salary) DESC
LIMIT 1;

---

# 8. Interview Thinking Pattern

When the question says:

"for each department"

Think:

GROUP BY department

When the question says:

"departments having..."

Think:

GROUP BY department
HAVING ...

Examples:

Departments having more than 5 employees:

HAVING COUNT(*) > 5

Departments having average salary greater than 60000:

HAVING AVG(salary) > 60000

Departments having total salary greater than 500000:

HAVING SUM(salary) > 500000

---

# Mistakes Made Today

## Interview Challenge

Initially attempted:

SELECT department
FROM employees
WHERE MAX(AVG(salary))
GROUP BY department;

Problem:

MAX() and AVG() cannot be directly nested at the same
aggregation level in this way.

Correct thinking:

1. Calculate AVG(salary) for each department.
2. Compare/order those department averages.
3. Select the department with the highest average.

---

# Day 03 Result

Q1 → Correct
Q2 → Correct
Q3 → Correct
Q4 → Correct
Q5 → Correct
Q6 → Correct
Q7 → Correct
Q8 → Correct
Q9 → Correct
Q10 → Correct
Interview Challenge → Initially incorrect, then understood.

Score: 9/10

---

# Interview Takeaways

1. GROUP BY creates groups based on column values.
2. Aggregate functions operate on each group.
3. WHERE filters rows before grouping.
4. HAVING filters groups after grouping.
5. WHERE is generally used for row-level conditions.
6. HAVING is commonly used with aggregate conditions.
7. GROUP BY is essential for department-wise reporting.
8. Multiple query levels may be required when comparing
   aggregate results.

---

# Next Topic

Day 04 — SQL JOINs

Topics:

- INNER JOIN
- LEFT JOIN
- RIGHT JOIN
- FULL OUTER JOIN
- Joining multiple tables
- Primary key / foreign key relationship
- Real-world backend examples
- Common JOIN interview questions