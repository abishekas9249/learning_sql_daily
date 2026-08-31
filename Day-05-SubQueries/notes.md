# Day 05 — SQL Subqueries

## Objective

Learn how to use one SQL query inside another SQL query.

A subquery is a query written inside another query.

Subqueries are useful when the result of one query is needed
by another query.

---

# Table Used

## employees

| id | name   | department | salary |
|----|--------|------------|--------|
| 1  | Arun   | IT         | 60000  |
| 2  | Bala   | HR         | 45000  |
| 3  | Charan | IT         | 75000  |
| 4  | Divya  | Finance    | 80000  |
| 5  | Esha   | HR         | 50000  |
| 6  | Farhan | IT         | 65000  |
| 7  | Gokul  | Finance    | 70000  |
| 8  | Hari   | Finance    | 90000  |

---

# 1. What is a Subquery?

A subquery is a query inside another SQL query.

Example:

SELECT name, salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);

The inner query:

SELECT AVG(salary)
FROM employees

runs first conceptually and produces one value.

The outer query then uses that value.

---

# 2. Scalar Subquery

A scalar subquery returns a single value.

Example:

SELECT AVG(salary)
FROM employees;

Result:

| avg |
|-----:|
| 66875 |

The outer query can compare salary with this value.

---

# Q1. Employees earning above average

## Requirement

Find employees whose salary is greater than the
average salary of all employees.

## Solution

SELECT
    name,
    salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);

## Expected Result

| name   | salary |
|--------|-------:|
| Charan | 75000  |
| Divya  | 80000  |
| Farhan | 65000  |
| Gokul  | 70000  |
| Hari   | 90000  |

## Thinking

First:

SELECT AVG(salary)
FROM employees;

Then compare every employee salary against that value.

## Interview Pattern

salary > (SELECT AVG(salary) ...)

---

# Q2. Employees earning below average

## Requirement

Find employees whose salary is less than the
overall average salary.

## Solution

SELECT
    name,
    salary
FROM employees
WHERE salary < (
    SELECT AVG(salary)
    FROM employees
);

## Expected Result

| name | salary |
|------|-------:|
| Arun | 60000  |
| Bala | 45000  |
| Esha  | 50000 |

## Interview Pattern

salary < (SELECT AVG(salary) ...)

---

# Q3. Highest salary

## Requirement

Find employee(s) having the highest salary.

## Solution

SELECT
    name,
    salary
FROM employees
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
);

## Inner Query

SELECT MAX(salary)
FROM employees;

Result:

90000

## Expected Result

| name | salary |
|------|-------:|
| Hari | 90000  |

## Important

Using:

WHERE salary = (SELECT MAX(salary) ...)

can return multiple employees if several employees
have the same highest salary.

---

# Q4. Lowest salary

## Requirement

Find employee(s) having the lowest salary.

## Solution

SELECT
    name,
    salary
FROM employees
WHERE salary = (
    SELECT MIN(salary)
    FROM employees
);

## Expected Result

| name | salary |
|------|-------:|
| Bala | 45000  |

---

# Q5. Greater than IT department average

## Requirement

Find employees whose salary is greater than the
average salary of the IT department.

## Step 1 — Find IT average

SELECT AVG(salary)
FROM employees
WHERE department = 'IT';

IT employees:

| name   | salary |
|--------|-------:|
| Arun   | 60000  |
| Charan | 75000  |
| Farhan | 65000  |

IT average:

66666.67

## Step 2 — Compare employees against that value

## Solution

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

## Expected Result

| name   | salary | department |
|--------|-------:|------------|
| Charan | 75000  | IT         |
| Divya  | 80000  | Finance    |
| Hari   | 90000  | Finance    |

Note:

The condition says salary is greater than the IT average,
so employees from other departments can also be returned.

---

# Q6. IN with a Subquery

## Requirement

Find employees who belong to departments where the
average salary is greater than 60000.

## Step 1 — Find qualifying departments

SELECT
    department
FROM employees
GROUP BY department
HAVING AVG(salary) > 60000;

Expected:

| department |
|------------|
| IT         |
| Finance    |

## Step 2 — Find employees in those departments

Use IN.

## Solution

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

## Explanation

The subquery returns multiple values:

IT
Finance

Therefore we use:

IN (...)

## Interview Pattern

column IN (
    SELECT column
    ...
)

---

# 3. IN vs = with Subqueries

If the subquery returns one value:

salary = (
    SELECT AVG(salary)
    ...
)

can be used.

If the subquery returns multiple values:

department IN (
    SELECT department
    ...
)

should be used.

## Remember

= → one value

IN → multiple possible values

---

# Q7. Second-highest distinct salary

## Requirement

Find the employee(s) with the second-highest salary.

Salary order:

| salary |
|-------:|
| 90000  |
| 80000  |
| 75000  |
| 70000  |
| 65000  |
| 60000  |
| 50000  |
| 45000  |

Highest:

90000

Second-highest:

80000

## Solution

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

## How it works

Inner-most query:

SELECT MAX(salary)
FROM employees;

Returns:

90000

Next query:

SELECT MAX(salary)
FROM employees
WHERE salary < 90000;

Returns:

80000

Outer query finds employee(s) with salary = 80000.

## Expected Result

| name  | salary |
|-------|-------:|
| Divya | 80000  |

## Interview Takeaway

Second-highest salary is a very common SQL interview question.

Later we will solve it using:

- DENSE_RANK()
- ROW_NUMBER()
- CTE
- LIMIT/OFFSET

---

# Q8. Maximum salary in each department

## Requirement

Find employees whose salary is equal to the maximum
salary in their own department.

## Example

### IT

| name   | salary |
|--------|-------:|
| Arun   | 60000  |
| Charan | 75000  |
| Farhan | 65000  |

Maximum IT salary = 75000

### HR

| name | salary |
|------|-------:|
| Bala | 45000  |
| Esha | 50000  |

Maximum HR salary = 50000

### Finance

| name  | salary |
|-------|-------:|
| Divya | 80000  |
| Gokul | 70000  |
| Hari  | 90000  |

Maximum Finance salary = 90000

## Solution

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

## Expected Result

| name   | salary | department |
|--------|-------:|------------|
| Charan | 75000  | IT         |
| Esha   | 50000  | HR         |
| Hari   | 90000  | Finance    |

## Important Concept

This is a CORRELATED SUBQUERY.

The inner query refers to:

e.department

from the outer query.

For every employee:

1. Get their department.
2. Find the maximum salary in that department.
3. Compare the employee's salary with that maximum.

---

# 4. Correlated Subquery

A correlated subquery depends on the current row
of the outer query.

Example:

SELECT
    e.name,
    e.salary
FROM employees e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department = e.department
);

The inner query uses:

e.department

from the outer query.

Therefore the inner query is evaluated in relation to
the current employee.

---

# Q9. EXISTS

## Requirement

Find departments that have at least one employee earning
more than 75000.

## Solution

SELECT DISTINCT
    d.department
FROM employees d
WHERE EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department = d.department
      AND e.salary > 75000
);

## Expected Result

| department |
|------------|
| Finance    |

## Why?

Finance contains:

| name  | salary |
|-------|-------:|
| Divya | 80000  |
| Gokul | 70000  |
| Hari  | 90000  |

At least one employee earns more than 75000.

## What does EXISTS mean?

EXISTS asks:

"Does at least one matching row exist?"

The actual selected value inside EXISTS is not important.

Therefore:

SELECT 1

is commonly used.

---

# 5. EXISTS Mental Model

Think:

For each department:

Does an employee exist
    ↓
whose salary > 75000?
    ↓
YES → return department
NO  → don't return department

---

# Q10 — Interview Challenge

## Requirement

Find employees who earn more than the average salary
of their own department.

This is a classic correlated subquery question.

## Example: IT

| name   | salary |
|--------|-------:|
| Arun   | 60000  |
| Charan | 75000  |
| Farhan | 65000  |

IT average:

66666.67

Therefore:

Charan → 75000 > 66666.67 → YES

## Example: Finance

| name  | salary |
|-------|-------:|
| Divya | 80000  |
| Gokul | 70000  |
| Hari  | 90000  |

Finance average:

80000

Therefore:

Hari → 90000 > 80000 → YES

## Solution

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

## Expected Result

| name   | salary | department |
|--------|-------:|------------|
| Charan | 75000  | IT         |
| Hari   | 90000  | Finance    |

---

# 6. Types of Subqueries Learned

## Scalar Subquery

Returns one value.

Example:

SELECT AVG(salary)
FROM employees;

Used with:

=
>
<
>=
<=

---

## Multi-row Subquery

Returns multiple values.

Example:

SELECT department
FROM employees
GROUP BY department
HAVING AVG(salary) > 60000;

Used with:

IN

---

## Correlated Subquery

Depends on the outer query.

Example:

SELECT AVG(e2.salary)
FROM employees e2
WHERE e2.department = e.department;

---

## EXISTS Subquery

Checks whether at least one matching row exists.

Example:

WHERE EXISTS (
    SELECT 1
    ...
)

---

# 7. Important Interview Patterns

## Employees above company average

WHERE salary > (
    SELECT AVG(salary)
    FROM employees
)

---

## Employee with highest salary

WHERE salary = (
    SELECT MAX(salary)
    FROM employees
)

---

## Employee with lowest salary

WHERE salary = (
    SELECT MIN(salary)
    FROM employees
)

---

## Second-highest salary

MAX(salary)
WHERE salary < MAX(salary)

---

## Employees above their department average

WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department = e.department
)

---

## Departments meeting a calculated condition

WHERE department IN (
    SELECT department
    FROM employees
    GROUP BY department
    HAVING ...
)

---

# 8. Common Mistakes

## Mistake 1

Using = when the subquery returns multiple values.

Incorrect:

WHERE department = (
    SELECT department
    ...
)

Correct:

WHERE department IN (
    SELECT department
    ...
)

---

## Mistake 2

Returning AVG(salary) when the outer query needs
department names.

For example:

IN (
    SELECT AVG(salary)
    ...
)

is wrong if the outer column is:

department

The data types don't match.

---

## Mistake 3

Trying to write aggregate functions at the wrong level.

Incorrect concept:

MAX(AVG(salary))

Instead:

1. Calculate average per department.
2. Use another query level to find the maximum.

---

## Mistake 4

Forgetting correlation.

If the question says:

"average salary of THEIR department"

you need to connect the inner query to the
outer employee:

e2.department = e.department

---

# 9. WHERE vs Subquery

A normal WHERE condition compares against a fixed value:

WHERE salary > 60000

A subquery allows the comparison value to be calculated:

WHERE salary > (
    SELECT AVG(salary)
    FROM employees
)

This makes the query dynamic.

---

# Day 05 Interview Takeaways

1. A subquery is a query inside another query.
2. Scalar subqueries return one value.
3. Multi-row subqueries can be used with IN.
4. MAX() can be used in a subquery to find the highest value.
5. MIN() can be used to find the lowest value.
6. Second-highest salary can be solved using nested subqueries.
7. Correlated subqueries depend on the outer query.
8. EXISTS checks whether a matching row exists.
9. WHERE filters rows using a subquery result.
10. GROUP BY + HAVING can be used inside a subquery.
11. When the question says "their own department", think
    correlated subquery.
12. When the question says "departments where...", think
    GROUP BY + HAVING and possibly IN.