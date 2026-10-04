# SQL Hands-On Interview Revision

> **Goal:** Solve unfamiliar SQL problems by identifying the correct approach, not by memorizing queries.

---

# Practice Table

```sql
employees (
    id,
    name,
    department,
    salary
)
```

| id | name   | department | salary |
| -: | ------ | ---------- | -----: |
|  1 | Arun   | IT         |  60000 |
|  2 | Bala   | HR         |  45000 |
|  3 | Charan | IT         |  75000 |
|  4 | Divya  | Finance    |  80000 |
|  5 | Esha   | HR         |  50000 |
|  6 | Farhan | IT         |  65000 |
|  7 | Gokul  | Finance    |  70000 |
|  8 | Hari   | Finance    |  90000 |

---

# JOIN Practice Tables

For JOIN questions, use:

### `employees`

| id | name   | department_id | salary |
| -: | ------ | ------------: | -----: |
|  1 | Arun   |           101 |  60000 |
|  2 | Bala   |           102 |  45000 |
|  3 | Charan |           101 |  75000 |
|  4 | Divya  |           103 |  80000 |
|  5 | Esha   |           102 |  50000 |
|  6 | Farhan |           101 |  65000 |
|  7 | Gokul  |           103 |  70000 |
|  8 | Hari   |           103 |  90000 |

### `departments`

| department_id | department_name | location  |
| ------------: | --------------- | --------- |
|           101 | IT              | Chennai   |
|           102 | HR              | Bangalore |
|           103 | Finance         | Mumbai    |
|           104 | Marketing       | Delhi     |

Relationship:

```text
employees.department_id
        ↓
departments.department_id
```

---

# Core SQL Patterns

## 1. Filtering

```sql
SELECT name, department, salary
FROM employees
WHERE salary > 60000;
```

### Pattern

```text
WHERE → filters individual rows
```

---

# 2. GROUP BY + COUNT

```sql
SELECT department,
       COUNT(*) AS employee_count
FROM employees
GROUP BY department
ORDER BY employee_count DESC;
```

### Pattern

```text
GROUP BY → one result per group
COUNT(*) → count rows
```

---

# 3. GROUP BY + HAVING

```sql
SELECT department,
       AVG(salary) AS average_salary
FROM employees
GROUP BY department
HAVING AVG(salary) > 60000;
```

### Pattern

```text
WHERE  → filters rows
HAVING → filters groups
```

---

# 4. Second-highest distinct salary

```sql
SELECT name, department, salary
FROM employees
WHERE salary = (
    SELECT DISTINCT salary
    FROM employees
    ORDER BY salary DESC
    OFFSET 1
    LIMIT 1
);
```

### Pattern

```text
DISTINCT
→ remove duplicate salaries

ORDER BY DESC
→ highest first

OFFSET 1
→ skip highest

LIMIT 1
→ take second
```

### Memory

```text
Nth-highest
→ OFFSET N-1
→ LIMIT 1
```

---

# 5. Third-highest distinct salary

```sql
SELECT name, department, salary
FROM employees
WHERE salary = (
    SELECT DISTINCT salary
    FROM employees
    ORDER BY salary DESC
    OFFSET 2
    LIMIT 1
);
```

---

# 6. Employees above overall average

```sql
SELECT name,
       department,
       salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);
```

### Pattern

```text
Subquery returns one value
→ scalar subquery
```

---

# 7. Employees above their own department average

### Correlated subquery

```sql
SELECT name,
       department,
       salary
FROM employees e
WHERE salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department = e.department
);
```

### CTE + JOIN alternative

```sql
WITH department_avg AS (
    SELECT department,
           AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department
)
SELECT e.name,
       e.department,
       e.salary
FROM employees e
JOIN department_avg d
    ON e.department = d.department
WHERE e.salary > d.avg_salary;
```

### Pattern

```text
Own department average
→ correlated subquery
OR
→ CTE + JOIN
```

---

# 8. Above department average + display department average

This was an important **Q37 recovery**.

```sql
SELECT name,
       department,
       salary,
       AVG(salary) OVER (
           PARTITION BY department
       ) AS department_average
FROM employees e
WHERE salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department = e.department
);
```

### Important distinction

If we need:

```text
One result per department
```

use:

```sql
GROUP BY department
```

If we need:

```text
Every employee + department calculation
```

use:

```sql
AVG(salary) OVER (
    PARTITION BY department
)
```

### Memory

> **GROUP BY collapses rows. Window functions preserve rows.**

---

# 9. Highest-paid employee in each department — including ties

```sql
SELECT department,
       name,
       salary
FROM (
    SELECT department,
           name,
           salary,
           RANK() OVER (
               PARTITION BY department
               ORDER BY salary DESC
           ) AS rnk
    FROM employees
) e
WHERE rnk = 1;
```

### Pattern

```text
Highest per group + ties
→ RANK()
→ PARTITION BY department
→ rnk = 1
```

---

# 10. Top 2 employees from each department — including ties

```sql
SELECT department,
       name,
       salary
FROM (
    SELECT department,
           name,
           salary,
           RANK() OVER (
               PARTITION BY department
               ORDER BY salary DESC
           ) AS rnk
    FROM employees
) e
WHERE rnk <= 2;
```

### Important

```text
LIMIT 2
→ top 2 overall

RANK() + PARTITION BY
→ top 2 per department
```

---

# 11. Third-highest employee in each department — including ties

### Today's Q39

```sql
SELECT department,
       name,
       salary
FROM (
    SELECT department,
           name,
           salary,
           RANK() OVER (
               PARTITION BY department
               ORDER BY salary DESC
           ) AS rnk
    FROM employees
) e
WHERE rnk = 3;
```

### Why RANK?

The question says:

> Include ties.

Therefore:

```text
RANK()
```

### Comparison

```text
ROW_NUMBER()
→ unique position

RANK()
→ ties + gaps

DENSE_RANK()
→ ties + no gaps
```

---

# 12. Nth-highest distinct salary per department

Use `DENSE_RANK()`.

```sql
SELECT department,
       name,
       salary
FROM (
    SELECT department,
           name,
           salary,
           DENSE_RANK() OVER (
               PARTITION BY department
               ORDER BY salary DESC
           ) AS rnk
    FROM employees
) e
WHERE rnk = 2;
```

For third-highest:

```sql
WHERE rnk = 3;
```

### Pattern

```text
Nth-highest distinct per group
→ DENSE_RANK()
→ PARTITION BY department
```

---

# 13. Employees earning more than every HR employee

```sql
SELECT name,
       department,
       salary
FROM employees
WHERE salary > ALL (
    SELECT salary
    FROM employees
    WHERE department = 'HR'
);
```

### Pattern

```text
> ALL
→ greater than every returned value
```

---

# 14. Employees earning more than at least one Finance employee

```sql
SELECT name,
       department,
       salary
FROM employees
WHERE salary > ANY (
    SELECT salary
    FROM employees
    WHERE department = 'Finance'
);
```

### Pattern

```text
> ANY
→ greater than at least one returned value
```

### Memory

```text
> ALL
→ every value

> ANY
→ at least one value
```

---

# 15. Highest-paid employee overall

```sql
SELECT name,
       department,
       salary
FROM employees
ORDER BY salary DESC
LIMIT 1;
```

### Pattern

```text
Highest overall
→ ORDER BY DESC
→ LIMIT 1
```

---

# 16. Lowest-paid employee in each department

```sql
SELECT department,
       name,
       salary
FROM (
    SELECT department,
           name,
           salary,
           RANK() OVER (
               PARTITION BY department
               ORDER BY salary ASC
           ) AS rnk
    FROM employees
) e
WHERE rnk = 1;
```

---

# 17. Departments with at least 2 employees

```sql
SELECT department,
       COUNT(*) AS employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) >= 2;
```

---

# 18. Departments with average salary above overall company average

```sql
SELECT department,
       AVG(salary) AS department_average
FROM employees
GROUP BY department
HAVING AVG(salary) > (
    SELECT AVG(salary)
    FROM employees
);
```

### Pattern

```text
Department average
→ GROUP BY department

Overall average
→ scalar subquery

Compare aggregates
→ HAVING
```

### Important

Do not use a window-function alias directly in `WHERE`.

---

# 19. Employees earning more than highest-paid HR employee

```sql
SELECT name,
       department,
       salary
FROM employees
WHERE salary > (
    SELECT MAX(salary)
    FROM employees
    WHERE department = 'HR'
);
```

### Pattern

```text
Greater than highest
→ > MAX(...)
```

---

# 20. Running total

```sql
SELECT name,
       salary,
       SUM(salary) OVER (
           ORDER BY salary
       ) AS running_total
FROM employees;
```

### Pattern

```text
Running total
→ SUM() OVER (ORDER BY ...)
```

---

# 21. Top 2 employees with unique positions

```sql
SELECT department,
       name,
       salary,
       rn AS position
FROM (
    SELECT department,
           name,
           salary,
           ROW_NUMBER() OVER (
               PARTITION BY department
               ORDER BY salary DESC
           ) AS rn
    FROM employees
) e
WHERE rn <= 2;
```

### Pattern

```text
ROW_NUMBER()
→ unique position
```

---

# 22. Above department average + highest qualifying employee

```sql
WITH above_average AS (
    SELECT name,
           department,
           salary
    FROM employees e
    WHERE salary > (
        SELECT AVG(e2.salary)
        FROM employees e2
        WHERE e2.department = e.department
    )
)
SELECT department,
       name,
       salary
FROM (
    SELECT department,
           name,
           salary,
           DENSE_RANK() OVER (
               PARTITION BY department
               ORDER BY salary DESC
           ) AS drnk
    FROM above_average
) e
WHERE drnk = 1;
```

### Pattern

```text
Filter first
→ employees above department average

Rank second
→ highest qualifying employee
```

---

# 23. Department with highest total salary

### Q31 / Q38 recovery pattern

First aggregate:

```sql
SELECT department,
       SUM(salary) AS total_salary
FROM employees
GROUP BY department;
```

Then rank the departments:

```sql
SELECT department,
       total_salary,
       DENSE_RANK() OVER (
           ORDER BY total_salary DESC
       ) AS drnk
FROM (
    SELECT department,
           SUM(salary) AS total_salary
    FROM employees
    GROUP BY department
) d;
```

To get the highest:

```sql
SELECT department,
       total_salary
FROM (
    SELECT department,
           total_salary,
           DENSE_RANK() OVER (
               ORDER BY total_salary DESC
           ) AS drnk
    FROM (
        SELECT department,
               SUM(salary) AS total_salary
        FROM employees
        GROUP BY department
    ) d
) ranked
WHERE drnk = 1;
```

### Critical pattern

```text
GROUP BY
    ↓
SUM
    ↓
RANK/DENSE_RANK
    ↓
Filter rank
```

### Important

When ranking departments against each other:

```text
❌ PARTITION BY department

✅ No PARTITION BY
```

### Memory

> **Ranking employees inside groups → PARTITION BY.**

> **Ranking the groups themselves → no PARTITION BY.**

---

# 24. Department with second-highest total salary

### Today's Q38

```sql
SELECT department,
       total_salary
FROM (
    SELECT department,
           total_salary,
           DENSE_RANK() OVER (
               ORDER BY total_salary DESC
           ) AS drnk
    FROM (
        SELECT department,
               SUM(salary) AS total_salary
        FROM employees
        GROUP BY department
    ) d
) ranked
WHERE drnk = 2;
```

### Critical thinking

The question is:

> Second-highest **department total**

NOT:

> Second-highest employee salary in each department.

Therefore:

```text
Employees
    ↓
GROUP BY department
    ↓
SUM(salary)
    ↓
Rank departments
    ↓
drnk = 2
```

### Mistake from Q38

Incorrect:

```sql
DENSE_RANK() OVER (
    PARTITION BY department
    ORDER BY SUM(salary) DESC
)
```

Why?

Because this ranks employees **inside each department**.

We need to rank the **departments against each other**.

---

# 25. Employees in the same department as Arun

### Today's Q36

```sql
SELECT name,
       department,
       salary
FROM employees
WHERE department = (
    SELECT department
    FROM employees
    WHERE name = 'Arun'
);
```

### Pattern

```text
Find Arun's department
        ↓
Use that single value
        ↓
Find employees in same department
```

### Memory

> **Same as one employee → scalar subquery.**

---

# 26. Above department average AND above overall average

### Today's Q40

```sql
SELECT name,
       department,
       salary
FROM employees e
WHERE salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department = e.department
)
AND salary > (
    SELECT AVG(salary)
    FROM employees
);
```

### Pattern

Condition 1:

```text
Salary > own department average
```

→ correlated subquery

Condition 2:

```text
Salary > overall average
```

→ scalar subquery

Combine:

```text
AND
```

---

# SQL Mistake Log

## Mistake 1 — LIMIT 2 for second-highest

### Wrong

```sql
LIMIT 2
```

### Correct

```sql
ORDER BY salary DESC
OFFSET 1
LIMIT 1;
```

### Memory

> `LIMIT` = number of rows to take.
> `OFFSET` = number of rows to skip.

---

## Mistake 2 — LIMIT for Top-N per department

### Wrong

```sql
ORDER BY salary DESC
LIMIT 2;
```

### Correct

```sql
RANK() OVER (
    PARTITION BY department
    ORDER BY salary DESC
)
```

### Memory

> LIMIT = overall.
> PARTITION = per group.

---

## Mistake 3 — Scalar comparison with multi-row subquery

### Wrong

```sql
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
    GROUP BY department
);
```

The subquery returns multiple averages.

### Correct

Use:

```text
Correlated subquery
```

or:

```text
CTE + JOIN
```

or `ALL` / `ANY` where appropriate.

### Memory

> `=` / `>` / `<` with a subquery generally expects one value.

---

## Mistake 4 — GROUP BY when individual rows are required

### Wrong

```sql
AVG(salary)
GROUP BY department
```

when we need every employee.

### Correct

```sql
AVG(salary) OVER (
    PARTITION BY department
)
```

### Memory

> **GROUP BY collapses. Window functions preserve rows.**

---

## Mistake 5 — Ranking groups with PARTITION BY

### Wrong

```sql
DENSE_RANK() OVER (
    PARTITION BY department
    ORDER BY total_salary DESC
)
```

when ranking departments against each other.

### Correct

```sql
DENSE_RANK() OVER (
    ORDER BY total_salary DESC
)
```

### Memory

> **Ranking employees inside groups → PARTITION BY.**

> **Ranking groups themselves → no PARTITION BY.**

---

## Mistake 6 — Ranking before aggregation

### Wrong thinking

```text
Rank employees
→ calculate department total
```

### Correct

```text
GROUP BY department
→ SUM(salary)
→ RANK/DENSE_RANK
→ filter rank
```

### Memory

> **Aggregate first → rank second.**

---

## Mistake 7 — Using ROW_NUMBER when ties must be included

If the question says:

> Include ties.

Use:

```sql
RANK()
```

not:

```sql
ROW_NUMBER()
```

---

## Mistake 8 — RANK vs DENSE_RANK

### RANK

```text
100 → 1
90  → 2
90  → 2
80  → 4
```

### DENSE_RANK

```text
100 → 1
90  → 2
90  → 2
80  → 3
```

### Memory

> RANK → gaps.

> DENSE_RANK → no gaps.

---

## Mistake 9 — Unnecessary GROUP BY with window functions

If individual employee rows are required, don't add:

```sql
GROUP BY department
```

just because a window function uses:

```sql
PARTITION BY department
```

`PARTITION BY` does **not** require `GROUP BY`.

---

## Mistake 10 — SELECT alias in WHERE

### Wrong

```sql
SELECT AVG(salary) OVER (...) AS department_average
FROM employees
WHERE department_average > ...;
```

### Problem

The SELECT alias is not available to `WHERE` at that stage.

### Correct

Use a:

```text
CTE
```

or:

```text
subquery
```

or restructure using `GROUP BY + HAVING`.

---

## Mistake 11 — Unnecessary JOIN after ranking

If the ranked result already contains:

```text
department
name
salary
rank
```

don't JOIN back to `employees` just to retrieve the same information.

### Memory

> If the current result already contains what you need, don't add another JOIN.

---

## Mistake 12 — Wrong string quotation

### Wrong

```sql
WHERE department = "HR";
```

### Correct

```sql
WHERE department = 'HR';
```

### Memory

> SQL string literals → single quotes.

---

# Important SQL Decision Framework

Before writing a complex query, ask:

### 1. Do I need individual rows?

```text
YES
→ normal SELECT
→ window function if needed
```

### 2. Do I need one row per group?

```text
YES
→ GROUP BY
```

### 3. Do I need to filter an aggregate?

```text
YES
→ HAVING
```

### 4. Do I need an aggregate beside every individual row?

```text
YES
→ Window function
```

### 5. Is my subquery returning one value?

```text
YES
→ = / > / < etc.
```

### 6. Is my subquery returning multiple values?

```text
YES
→ IN / ANY / ALL
```

### 7. Is the comparison against the employee's own group?

```text
YES
→ Correlated subquery
OR
→ CTE + JOIN
```

### 8. Am I ranking employees inside groups?

```text
YES
→ PARTITION BY
```

### 9. Am I ranking groups against each other?

```text
YES
→ No PARTITION BY
```

### 10. Do ties matter?

```text
YES
→ RANK / DENSE_RANK
```

### 11. Do I need unique positions?

```text
YES
→ ROW_NUMBER
```

---

# Ranking Cheat Sheet

| Requirement                 | Function                            |
| --------------------------- | ----------------------------------- |
| Unique position             | `ROW_NUMBER()`                      |
| Ranking with ties + gaps    | `RANK()`                            |
| Ranking with ties + no gaps | `DENSE_RANK()`                      |
| Highest per group + ties    | `RANK() = 1`                        |
| Top N per group + ties      | `RANK() <= N`                       |
| Nth-highest distinct value  | `DENSE_RANK() = N`                  |
| Ranking groups by aggregate | Aggregate first → `RANK/DENSE_RANK` |

---

# LIMIT / OFFSET Cheat Sheet

```sql
ORDER BY salary DESC
LIMIT 1;
```

→ Highest

```sql
ORDER BY salary DESC
OFFSET 1
LIMIT 1;
```

→ Second-highest

```sql
ORDER BY salary DESC
OFFSET 2
LIMIT 1;
```

→ Third-highest

### Formula

```text
Nth-highest
→ OFFSET N - 1
→ LIMIT 1
```

For distinct salary:

```sql
SELECT DISTINCT salary
FROM employees
ORDER BY salary DESC
OFFSET N-1
LIMIT 1;
```

---

# GROUP BY vs Window Function

## GROUP BY

```sql
SELECT department,
       AVG(salary)
FROM employees
GROUP BY department;
```

Result:

```text
IT
HR
Finance
```

One row per department.

## Window Function

```sql
SELECT name,
       department,
       salary,
       AVG(salary) OVER (
           PARTITION BY department
       ) AS department_average
FROM employees;
```

Result:

```text
Arun
Charan
Farhan
...
```

Every employee remains visible.

### Interview Memory

> **GROUP BY changes the number of rows.**

> **Window functions calculate across rows without removing them.**

---

# Aggregate → Rank Pattern

This is one of the most important patterns learned in the recent sessions.

When asked:

> Find the department with the highest/second-highest/third-highest total/average.

Think:

```text
Employee rows
      ↓
GROUP BY department
      ↓
SUM / AVG / COUNT
      ↓
Rank departments
      ↓
Filter rank
```

Example:

```sql
SELECT department,
       total_salary
FROM (
    SELECT department,
           total_salary,
           DENSE_RANK() OVER (
               ORDER BY total_salary DESC
           ) AS drnk
    FROM (
        SELECT department,
               SUM(salary) AS total_salary
        FROM employees
        GROUP BY department
    ) d
) ranked
WHERE drnk = 2;
```

### Memory

> **Aggregate first → rank second.**

---

# Current Progress

| Topic                 | Understanding | Hands-on | Interview Ready |
| --------------------- | ------------- | -------- | --------------- |
| Filtering             | ✅             | ✅        | ✅               |
| Aggregates            | ✅             | ✅        | ✅               |
| GROUP BY              | ✅             | ✅        | ⚠️              |
| HAVING                | ✅             | ⚠️       | ⚠️              |
| JOINs                 | ✅             | ⚠️       | ⚠️              |
| Scalar Subqueries     | ✅             | ✅        | ✅               |
| Correlated Subqueries | ✅             | ⚠️       | ⚠️              |
| CTEs                  | ✅             | ✅        | ⚠️              |
| LIMIT / OFFSET        | ✅             | ✅        | ✅               |
| ALL / ANY             | ✅             | ✅        | ✅               |
| ROW_NUMBER            | ✅             | ⚠️       | ⚠️              |
| RANK                  | ✅             | ⚠️       | ⚠️              |
| DENSE_RANK            | ✅             | ⚠️       | ⚠️              |
| Window Functions      | ✅             | ⚠️       | ⚠️              |
| Multi-step SQL        | ⚠️            | ⚠️       | ⚠️              |
| Aggregate → Rank      | ⚠️            | ⚠️       | ⚠️              |

---

# Today's Recovery — Q36 to Q40

| Question | Result | Main Concept                  |
| -------- | ------ | ----------------------------- |
| Q36      | ✅      | Scalar subquery               |
| Q37      | ❌      | Window function vs GROUP BY   |
| Q38      | ❌      | Aggregate first → rank groups |
| Q39      | ✅      | RANK + PARTITION BY           |
| Q40      | ✅      | Correlated + scalar subquery  |

### Today's Score

**3 / 5 fully correct**

### Main Weak Area Identified

```text
Ranking employees within groups
        VS
Ranking groups themselves
```

Remember:

```text
Employees within departments
→ PARTITION BY department

Departments against each other
→ NO PARTITION BY
```

---

# Interview Thinking Rule

Don't start with:

> "Which SQL syntax do I remember?"

Start with:

```text
1. What should one output row represent?
2. Individual employee or department?
3. Do I need aggregation?
4. Do I need to preserve individual rows?
5. Is the comparison overall or per department?
6. Does the subquery return one value or many?
7. Are ties required?
8. Am I ranking employees or ranking groups?
9. Do I need to aggregate before ranking?
```

Then choose:

```text
WHERE
GROUP BY
HAVING
JOIN
Subquery
Correlated Subquery
CTE
RANK
DENSE_RANK
ROW_NUMBER
PARTITION BY
ALL
ANY
LIMIT
OFFSET
```

> **Final goal:** Give me an unfamiliar SQL problem and I should be able to identify the approach before writing the query.
