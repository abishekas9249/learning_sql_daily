# Day 04 — SQL JOINs

## Objective

Learn how to combine data from multiple tables.

JOINs are extremely important for backend development because
real applications usually store related information in
different tables.

Examples:

- Employee → Department
- Customer → Orders
- Order → Products
- User → Payments
- Student → Courses

---

# Tables Used Throughout Day 04

## employees

| id | name   | department_id | salary |
|----|--------|---------------|--------|
| 1  | Arun   | 10            | 60000  |
| 2  | Bala   | 20            | 45000  |
| 3  | Charan | 10            | 75000  |
| 4  | Divya  | 30            | 80000  |
| 5  | Esha   | 20            | 50000  |
| 6  | Farhan | NULL          | 65000  |

## departments

| id | department_name |
|----|-----------------|
| 10 | IT              |
| 20 | HR              |
| 30 | Finance         |
| 40 | Marketing       |

Relationship:

employees.department_id → departments.id

---

# 1. INNER JOIN

## Real-world requirement

Display the employee name and their department name.

## Query

SELECT
    e.name AS employee_name,
    d.department_name
FROM employees e
INNER JOIN departments d
    ON e.department_id = d.id;

## Expected Result

| employee_name | department_name |
|---------------|-----------------|
| Arun          | IT              |
| Bala          | HR              |
| Charan        | IT              |
| Divya         | Finance         |
| Esha          | HR              |

Farhan is not included because his department_id is NULL.

## Explanation

INNER JOIN returns only rows that have a matching record
in both tables.

Think:

employees
    ↓
find matching department
    ↓
return matching records only

## Interview Takeaway

INNER JOIN = matching records from both tables.

---

# 2. JOIN Using ON

## Requirement

Match employees with their departments.

## Query

SELECT
    e.name,
    d.department_name
FROM employees e
INNER JOIN departments d
    ON e.department_id = d.id;

## Important Part

ON e.department_id = d.id

This tells SQL how the two tables are related.

## Interview Takeaway

ON defines the relationship/matching condition between
the tables.

---

# 3. LEFT JOIN

## Real-world requirement

Display ALL employees, including employees who don't
have a department.

## Query

SELECT
    e.name AS employee_name,
    d.department_name
FROM employees e
LEFT JOIN departments d
    ON e.department_id = d.id;

## Expected Result

| employee_name | department_name |
|---------------|-----------------|
| Arun          | IT              |
| Bala          | HR              |
| Charan        | IT              |
| Divya         | Finance         |
| Esha          | HR              |
| Farhan        | NULL             |

## Explanation

The employees table is on the LEFT.

LEFT JOIN keeps every row from employees.

If there is no matching department, department columns
become NULL.

## Interview Takeaway

LEFT JOIN = keep ALL records from the left table.

---

# 4. RIGHT JOIN

RIGHT JOIN keeps all records from the right table.

Example:

SELECT
    d.department_name,
    e.name AS employee_name
FROM employees e
RIGHT JOIN departments d
    ON e.department_id = d.id;

This keeps all departments.

Marketing appears even though it has no employees.

## Expected Concept

| department_name | employee_name |
|-----------------|---------------|
| IT              | Arun          |
| IT              | Charan        |
| HR              | Bala          |
| HR              | Esha          |
| Finance         | Divya         |
| Marketing       | NULL          |

## Interview Takeaway

RIGHT JOIN = keep ALL records from the right table.

In practice, RIGHT JOIN can often be rewritten as a
LEFT JOIN by changing the table order.

---

# 5. FULL OUTER JOIN

FULL OUTER JOIN keeps all records from both tables.

Concept:

LEFT-only records
+
Matching records
+
RIGHT-only records

Example:

SELECT
    e.name,
    d.department_name
FROM employees e
FULL OUTER JOIN departments d
    ON e.department_id = d.id;

This would include:

- Employees with departments
- Employees without departments
- Departments without employees

## Interview Takeaway

FULL OUTER JOIN = everything from both sides.

Note:
Database support differs. PostgreSQL supports FULL OUTER JOIN.

---

# 6. JOIN + WHERE

## Requirement

Find employees whose salary is greater than 60000,
along with their department.

## Query

SELECT
    e.name AS employee_name,
    e.salary,
    d.department_name
FROM employees e
INNER JOIN departments d
    ON e.department_id = d.id
WHERE e.salary > 60000;

## Expected Result

| employee_name | salary | department_name |
|---------------|--------|-----------------|
| Arun          | 60000  | IT              |
| Charan        | 75000  | IT              |
| Divya         | 80000  | Finance         |
| Farhan        | 65000  | NULL             |

Note:
If using INNER JOIN, Farhan is excluded because he has
no matching department.

If the requirement is to include Farhan, use LEFT JOIN.

## Interview Takeaway

JOIN combines related data.

WHERE filters rows.

---

# 7. JOIN + GROUP BY + COUNT

## Requirement

Find the number of employees in each department.

## Query

SELECT
    d.department_name,
    COUNT(e.id) AS employee_count
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.id
GROUP BY d.department_name;

## Expected Result

| department_name | employee_count |
|-----------------|----------------|
| IT              | 2              |
| HR              | 2              |
| Finance         | 1              |
| Marketing       | 0              |

## Why LEFT JOIN?

We need Marketing even though it has zero employees.

Therefore:

departments
    ↓
LEFT JOIN
    ↓
employees

## Important

Use:

COUNT(e.id)

rather than:

COUNT(*)

when using an outer join and you want zero for
departments with no matching employees.

---

# 8. COUNT(*) vs COUNT(column)

This is an important interview topic.

Suppose:

departments:

| id | department_name |
|----|-----------------|
| 40 | Marketing       |

There is no employee for Marketing.

With LEFT JOIN:

SELECT *
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.id;

Marketing produces a row where employee columns are NULL.

COUNT(*) counts the resulting row.

COUNT(e.id) counts only non-NULL employee IDs.

Therefore:

COUNT(*)
→ may return 1 for Marketing

COUNT(e.id)
→ returns 0 for Marketing

## Interview Takeaway

For counting matching child records after an OUTER JOIN,
COUNT(child_table.id) is usually the safer choice.

---

# 9. JOIN + GROUP BY + AVG

## Requirement

Find the average salary for each department.

## Query

SELECT
    d.department_name,
    AVG(e.salary) AS average_salary
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.id
GROUP BY d.department_name;

## Expected Result

| department_name | average_salary |
|-----------------|----------------|
| IT              | 67500          |
| HR              | 47500          |
| Finance         | 80000          |
| Marketing       | NULL            |

Marketing has no employees, so there is no salary to average.

## Interview Takeaway

AVG() ignores NULL values.

---

# 10. JOIN + GROUP BY + HAVING

## Requirement

Find departments having more than 1 employee.

## Query

SELECT
    d.department_name,
    COUNT(e.id) AS employee_count
FROM departments d
INNER JOIN employees e
    ON e.department_id = d.id
GROUP BY d.department_name
HAVING COUNT(e.id) > 1;

## Expected Result

| department_name | employee_count |
|-----------------|----------------|
| IT              | 2              |
| HR              | 2              |

## Explanation

JOIN
    ↓
Match employees with departments

GROUP BY
    ↓
Create one group per department

COUNT
    ↓
Count employees in each group

HAVING
    ↓
Keep only groups with count > 1

---

# 11. LEFT JOIN + GROUP BY + HAVING

If we wanted to include departments with zero employees
before applying a condition, we could use LEFT JOIN.

Example:

SELECT
    d.department_name,
    COUNT(e.id) AS employee_count
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.id
GROUP BY d.department_name
HAVING COUNT(e.id) >= 0;

This includes every department.

---

# 12. Department Report

## Real-world requirement

Display:

- Department name
- Employee count
- Average salary

Include departments having zero employees.

## Query

SELECT
    d.department_name,
    COUNT(e.id) AS employee_count,
    AVG(e.salary) AS average_salary
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.id
GROUP BY d.department_name;

## Expected Result

| department_name | employee_count | average_salary |
|-----------------|----------------|----------------|
| IT              | 2              | 67500          |
| HR              | 2              | 47500          |
| Finance         | 1              | 80000          |
| Marketing       | 0              | NULL            |

---

# 13. Interview Challenge

## Question

Find the department with the highest number of employees.

## Step 1

Count employees for each department.

GROUP BY department.

## Step 2

Sort departments by employee count.

ORDER BY employee_count DESC.

## Step 3

Take the first result.

LIMIT 1.

## Solution

SELECT
    d.department_name,
    COUNT(e.id) AS employee_count
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.id
GROUP BY d.department_name
ORDER BY employee_count DESC
LIMIT 1;

## Expected Result

| department_name | employee_count |
|-----------------|----------------|
| IT              | 2              |

Note:
HR also has 2 employees. LIMIT 1 returns only one department.

Later we will learn how to return ALL departments tied
for the highest count using window functions.

---

# JOIN Cheat Sheet

| JOIN | Meaning |
|------|---------|
| INNER JOIN | Matching records from both tables |
| LEFT JOIN | All left + matching right |
| RIGHT JOIN | All right + matching left |
| FULL OUTER JOIN | All records from both |

---

# JOIN Interview Thinking

When an interviewer says:

"Show all employees..."

Think:

LEFT JOIN

When they say:

"Show all departments..."

Think:

Make departments the LEFT table.

When they say:

"Only matching employees and departments..."

Think:

INNER JOIN

When they say:

"How many employees per department?"

Think:

JOIN + GROUP BY + COUNT

When they say:

"Departments having more than 2 employees..."

Think:

GROUP BY + HAVING COUNT(*) > 2

When using OUTER JOIN and counting matching records:

Prefer:

COUNT(e.id)

when you need zero for entities with no matches.

---

# Common Mistakes From Day 04

## Mistake 1 — Wrong table/column name

Initially used:

department

instead of:

departments

And:

d.name

instead of:

d.department_name

Always check the actual schema.

---

## Mistake 2 — AVG(*)

Incorrect:

AVG(*)

Correct:

AVG(e.salary)

AVG() requires a numeric expression/column.

---

## Mistake 3 — COUNT(*) with OUTER JOIN

When counting employees for every department,
including departments with zero employees:

Prefer:

COUNT(e.id)

instead of:

COUNT(*)

---

## Mistake 4 — Finding the maximum aggregate

Incorrect pattern:

HAVING MAX(employee_count)

To find the department with the highest employee count,
one simple approach is:

GROUP BY
    ↓
COUNT
    ↓
ORDER BY COUNT DESC
    ↓
LIMIT 1

Later we will learn tie-safe solutions using
window functions.

---

# SQL Processing Pattern

For today's combined queries, remember:

FROM / JOIN
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
    ↓
LIMIT

---

# Day 04 Result

Q1 → Correct
Q2 → Correct
Q3 → Correct
Q4 → Correct
Q5 → Correct
Q6 → Correct
Q7 → Needed COUNT(e.id) correction
Q8 → Needed AVG(e.salary) correction
Q9 → Correct concept, column naming correction
Q10 → Needed COUNT(e.id) correction
Interview Challenge → Incorrect initially, corrected using
GROUP BY + ORDER BY + LIMIT

Overall: 7/10

---

# Day 04 Interview Takeaways

1. INNER JOIN returns matching rows.
2. LEFT JOIN preserves all rows from the left table.
3. RIGHT JOIN preserves all rows from the right table.
4. FULL OUTER JOIN preserves rows from both tables.
5. ON defines how tables are related.
6. WHERE filters rows.
7. GROUP BY creates groups.
8. HAVING filters groups.
9. COUNT(e.id) is useful with OUTER JOIN when counting
   matching child records.
10. AVG(e.salary) calculates average salary.
11. Finding the highest grouped result can use
   ORDER BY aggregate DESC + LIMIT 1.
12. Tie-handling requires a more advanced approach.



