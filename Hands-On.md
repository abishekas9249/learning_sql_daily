# SQL Hands-On Interview Revision

> **Goal:** Solve unfamiliar SQL problems by identifying the correct approach, not by memorizing queries.

## Practice Table

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

# 1. Employees with salary greater than 60000

### Question

Find employees whose salary is greater than 60000.

### Solution

```sql
SELECT name, department, salary
FROM employees
WHERE salary > 60000;
```

### Key Pattern

```text
WHERE → filters individual rows
```

---

# 2. Employee count by department

### Question

Find the number of employees in each department and sort by employee count descending.

### Solution

```sql
SELECT department,
       COUNT(*) AS employee_count
FROM employees
GROUP BY department
ORDER BY employee_count DESC;
```

### Key Pattern

```text
GROUP BY → one result per group
COUNT(*) → count rows
```

---

# 3. Departments with average salary greater than 60000

### Question

Find departments whose average salary is greater than 60000.

### Solution

```sql
SELECT department,
       AVG(salary) AS average_salary
FROM employees
GROUP BY department
HAVING AVG(salary) > 60000;
```

### Mistake

Using:

```sql
HAVING average_salary > 60000
```

Avoid relying on the SELECT alias in PostgreSQL.

### Memory Trick

```text
WHERE  → filters rows
HAVING → filters groups
```

---

# 4. Second-highest distinct salary

### Question

Find all employees earning the second-highest distinct salary.

### Solution

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

### Key Pattern

```text
DISTINCT
→ remove duplicate salaries

DESC
→ highest first

OFFSET 1
→ skip highest

LIMIT 1
→ take second
```

### Memory Trick

```text
Nth-highest distinct
→ DISTINCT + ORDER BY DESC + OFFSET (N-1) + LIMIT 1
```

### Mistake

Using:

```sql
LIMIT 2
```

does **not** mean second-highest.

```text
LIMIT = number of rows to take
OFFSET = number of rows to skip
```

---

# 5. Employees above their own department average

### Question

Find employees whose salary is greater than the average salary of their own department.

### Solution — CTE + JOIN

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

### Alternative — Correlated Subquery

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

### Key Pattern

```text
Own department average
→ correlated subquery
OR
→ CTE + JOIN
```

### Mistake

Incorrect:

```sql
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
    GROUP BY department
);
```

The subquery returns multiple averages, but `>` expects one scalar value.

---

# 6. Highest-paid employee in each department, including ties

### Question

Find the highest-paid employee in every department. Include ties.

### Solution

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

### Key Pattern

```text
Highest per group + ties
→ RANK()
→ PARTITION BY department
→ rnk = 1
```

---

# 7. Top 2 employees from each department, including ties

### Question

Find the top 2 highest-paid employees from each department, including ties.

### Solution

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

### Mistake

Using:

```sql
ORDER BY salary DESC
LIMIT 2
```

returns only two employees **overall**.

### Memory Trick

```text
LIMIT → overall
PARTITION BY + ranking → per group
```

---

# 8. Employees earning more than every HR employee

### Question

Find employees whose salary is greater than every HR employee's salary.

### Solution

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

### Key Pattern

```text
> ALL → greater than every value
> ANY → greater than at least one value
```

---

# 9. Department with highest average salary

### Question

Find the department with the highest average salary.

### Solution

```sql
SELECT department,
       AVG(salary) AS average_salary
FROM employees
GROUP BY department
ORDER BY average_salary DESC
LIMIT 1;
```

### Pattern

```text
Aggregate
→ GROUP BY
→ ORDER BY DESC
→ LIMIT 1
```

---

# 10. Running total of salaries

### Question

Calculate a running total of salaries ordered by salary.

### Solution

```sql
SELECT name,
       salary,
       SUM(salary) OVER (
           ORDER BY salary
       ) AS running_total
FROM employees;
```

### Key Pattern

```text
Running total
→ SUM() OVER (ORDER BY ...)
```

### Important

```text
ORDER BY inside OVER()
→ controls calculation sequence

Outer ORDER BY
→ controls final display order
```

### Mistake

Using:

```sql
SUM(salary)
GROUP BY name
```

does not create a running total.

---

# 11. Lowest-paid employee in each department, including ties

### Question

Find the lowest-paid employee in each department, including ties.

### Solution

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

### Key Pattern

```text
Lowest per group
→ ORDER BY salary ASC
```

---

# 12. Third-highest distinct salary overall

### Question

Find employees earning the third-highest distinct salary.

### Solution

```sql
SELECT name,
       department,
       salary
FROM employees
WHERE salary = (
    SELECT DISTINCT salary
    FROM employees
    ORDER BY salary DESC
    OFFSET 2
    LIMIT 1
);
```

### Memory Trick

```text
Nth-highest
→ OFFSET N-1
→ LIMIT 1
```

---

# 13. Fourth-highest distinct salary

### Question

Find the fourth-highest distinct salary.

### Solution

```sql
SELECT DISTINCT salary
FROM employees
ORDER BY salary DESC
OFFSET 3
LIMIT 1;
```

### Memory Trick

```text
4th highest
→ OFFSET 3
→ LIMIT 1
```

---

# 14. Highest-paid employee overall

### Question

Find the highest-paid employee in the company.

### Solution

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

# 15. Departments with total salary greater than 150000

### Question

Find departments whose total salary is greater than 150000.

### Solution

```sql
SELECT department,
       SUM(salary) AS total_salary
FROM employees
GROUP BY department
HAVING SUM(salary) > 150000;
```

### Mistake

Trying:

```sql
SUM(salary) OVER(PARTITION BY department)
```

when the requirement needs **one result per department**.

### Correct Thinking

```text
One result per group
→ GROUP BY

Filter aggregate
→ HAVING
```

---

# 16. Employees earning above overall average

### Question

Find employees whose salary is greater than the overall company average.

### Solution

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

### Key Concept

The subquery returns exactly one value.

```text
Scalar subquery
→ one value
```

---

# 17. Second-highest distinct salary in each department

### Question

Find the second-highest distinct salary in every department.

### Solution

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

### Why DENSE_RANK?

Example:

```text
90000 → 1
80000 → 2
80000 → 2
70000 → 3
```

### Memory Trick

```text
Nth-highest distinct per group
→ DENSE_RANK()
```

---

# 18. Top 2 employees per department with UNIQUE positions

### Question

Find the top 2 employees from each department, but assign a unique position even when salaries are tied.

### Solution

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

### Key Concept

```text
ROW_NUMBER()
→ unique position

RANK()
→ ties with gaps

DENSE_RANK()
→ ties without gaps
```

### Mistake

Do not add unnecessary:

```sql
GROUP BY department
```

because we need individual employee rows.

---

# 19. Employees above department average with average displayed

### Question

Find employees whose salary is above their department average and display the department average beside each employee.

### Solution

```sql
SELECT name,
       department,
       salary,
       AVG(salary) OVER (
           PARTITION BY department
       ) AS department_average
FROM employees e
WHERE salary > (
    SELECT AVG(ed.salary)
    FROM employees ed
    WHERE ed.department = e.department
);
```

### Key Concepts

```text
Correlated subquery
→ determines whether employee is above own department average

Window function
→ displays department average without collapsing rows
```

### Important Interview Difference

```text
GROUP BY
→ collapses rows into groups

PARTITION BY
→ keeps rows and calculates within groups
```

### Mistake

Do not add:

```sql
GROUP BY department
```

because the requirement needs individual employees.

---

# 20. Departments with at least 2 employees

### Question

Find departments having at least 2 employees.

### Solution

```sql
SELECT department,
       COUNT(*) AS employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) >= 2;
```

### Memory Trick

```text
WHERE → rows
HAVING → groups
```

---

# 21. Employees earning more than highest-paid HR employee

### Question

Find employees whose salary is greater than the highest-paid HR employee.

### Solution

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

### Key Pattern

```text
Greater than the highest
→ > MAX(...)
```

### Mistake

Use single quotes for SQL string literals:

```sql
'HR'
```

not:

```sql
"HR"
```

---

# 22. Third-highest distinct salary per department

### Question

Find the third-highest distinct salary in each department and return all employees earning that salary.

### Solution

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
           ) AS drnk
    FROM employees
) e
WHERE drnk = 3;
```

### Key Pattern

```text
DENSE_RANK()
→ same salary gets same rank
→ no gaps
```

### Mistake to Avoid

Do not unnecessarily JOIN the ranked result back to `employees`.

If the ranked query already contains:

```text
department
name
salary
rank
```

just filter the rank.

---

# 23. Above department average + highest among qualifiers

### Question

Find employees who:

1. Earn more than their department average.
2. Have the highest salary among those qualifying employees in their department.

### Solution

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

### Key Pattern

```text
Step 1
→ filter employees above department average

Step 2
→ rank only those employees

Step 3
→ highest qualifying employee per department
```

### Important Lesson

This is a **multi-step SQL problem**.

Think:

```text
Filter first
→ Rank second
```

---

# 24. Department with highest total salary

### Question

Find the department(s) having the highest total salary. Include ties.

### Solution

```sql
SELECT department,
       total_salary
FROM (
    SELECT department,
           SUM(salary) AS total_salary,
           RANK() OVER (
               ORDER BY SUM(salary) DESC
           ) AS rnk
    FROM employees
    GROUP BY department
) d
WHERE rnk = 1;
```

### Correct Thinking

```text
GROUP BY department
        ↓
SUM(salary)
        ↓
Rank department totals
        ↓
rnk = 1
```

### Mistake

Incorrect approach:

```sql
RANK() OVER (
    PARTITION BY department
    ORDER BY SUM(salary)
)
```

Why?

Because we first need **one total per department**, then rank the departments.

### Memory Trick

> **Aggregate first → rank second.**

---

# 25. Salary higher than at least one Finance employee

### Question

Find employees whose salary is higher than at least one employee in Finance.

### Solution

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

### Key Pattern

```text
> ANY
→ greater than at least one returned value
```

### Comparison

```text
> ALL
→ greater than every value

> ANY
→ greater than at least one value
```

### Mistake

Our sample data uses:

```sql
'Finance'
```

so the department value should match the stored value.

---

# 26. Lowest-paid employee per department, including ties

### Question

Find the lowest-paid employee in every department, including ties.

### Solution

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

### Key Pattern

```text
Lowest + ties
→ RANK()
→ ASC
```

> This question appeared in earlier practice, so keep it as a revision pattern rather than treating it as a new problem.

---

# 27. Running total ordered by salary

### Question

Calculate a running total ordered by salary descending.

### Solution

```sql
SELECT name,
       salary,
       SUM(salary) OVER (
           ORDER BY salary DESC
       ) AS running_total
FROM employees;
```

### Key Pattern

```text
SUM() OVER (ORDER BY ...)
→ running total
```

---

# 28. Aggregate salary and rank departments

### Question

Find the department with the highest total salary.

### Solution

```sql
SELECT department,
       total_salary
FROM (
    SELECT department,
           SUM(salary) AS total_salary,
           RANK() OVER (
               ORDER BY SUM(salary) DESC
           ) AS rnk
    FROM employees
    GROUP BY department
) d
WHERE rnk = 1;
```

# 29. Departments with average salary above overall company average

### Question

Find departments where the average salary is greater than the overall company average salary.

Return:

department, department_average

### Solution

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
### Important

This is the same underlying pattern as Q24 and should be considered **one learned pattern**, not a separate topic:

```text
Aggregate
→ rank aggregate
→ filter rank
```

---

# 🔥 Core Interview Patterns

## LIMIT

```sql
ORDER BY salary DESC
LIMIT 2;
```

```text
LIMIT → take rows from overall result
```

---

## OFFSET

```sql
OFFSET 1
LIMIT 1;
```

```text
OFFSET → skip
LIMIT  → take
```

### Nth-highest

```text
OFFSET = N - 1
```

---

## ALL vs ANY

```sql
salary > ALL (...)
```

```text
Greater than every value
```

```sql
salary > ANY (...)
```

```text
Greater than at least one value
```

---

## GROUP BY vs PARTITION BY

```text
GROUP BY
→ collapses rows
→ one result per group
```

```text
PARTITION BY
→ keeps rows
→ calculation/ranking restarts per group
```

---

# Ranking Cheat Sheet

| Requirement                  | Function           |
| ---------------------------- | ------------------ |
| Unique position              | `ROW_NUMBER()`     |
| Ranking with ties + gaps     | `RANK()`           |
| Ranking with ties + no gaps  | `DENSE_RANK()`     |
| Highest per group + ties     | `RANK() = 1`       |
| Top N per group + ties       | `RANK() <= N`      |
| Nth distinct value per group | `DENSE_RANK() = N` |

### Example

```text
Salary       RANK       DENSE_RANK       ROW_NUMBER
100000         1             1                1
90000          2             2                2
90000          2             2                3
80000          4             3                4
```

---

# 📝 Consolidated SQL Mistake Log

## Mistake 1 — LIMIT 2 for second-highest

### Wrong

```sql
LIMIT 2
```

### Correct

```sql
SELECT DISTINCT salary
FROM employees
ORDER BY salary DESC
OFFSET 1
LIMIT 1;
```

### Memory

> `LIMIT 2` = two rows, **not** second-highest.

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

> LIMIT = overall
> PARTITION = per group

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

### Problem

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

or `ALL` / `ANY` when appropriate.

### Memory

> `=` / `>` / `<` with a subquery normally expects one value.

---

## Mistake 4 — Incorrect ORDER BY syntax

### Wrong

```sql
ORDER BY DESC
```

### Correct

```sql
ORDER BY salary DESC
```

### Memory

> `DESC` modifies a column.

---

## Mistake 5 — Running total with GROUP BY

### Wrong

```sql
SUM(salary)
GROUP BY name
```

### Correct

```sql
SUM(salary) OVER (
    ORDER BY salary
)
```

### Memory

> Running total → `SUM() OVER()`.

---

## Mistake 6 — ROW_NUMBER when ties must be included

### Wrong

```sql
ROW_NUMBER()
```

### Correct

```sql
RANK()
```

when the question says:

> Include ties.

---

## Mistake 7 — Confusing RANK and DENSE_RANK

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

> `RANK` → gaps
> `DENSE_RANK` → no gaps

---

## Mistake 8 — Unnecessary GROUP BY with window functions

### Wrong

```sql
ROW_NUMBER() OVER (...)
...
GROUP BY department;
```

when individual employee rows are required.

### Correct

Use the window function and filter the generated rank/row number.

### Memory

> Need individual rows → don't unnecessarily collapse them.

---

## Mistake 9 — Ranking before aggregation

### Wrong thinking

```text
Rank employees
→ calculate department total
```

### Correct thinking

```text
GROUP BY department
→ calculate SUM/AVG
→ rank the aggregate result
```

### Memory

> **Aggregate first → rank second.**

---

## Mistake 10 — Using SELECT alias in WHERE

### Wrong

```sql
SELECT AVG(salary) OVER (...) AS department_average
FROM employees
WHERE department_average > ...;
```

### Problem

`WHERE` is evaluated before the SELECT alias is available.

### Correct

Use a CTE/subquery, or use `GROUP BY + HAVING` if the problem asks for one row per group.

### Memory

> `WHERE` happens before `SELECT`.

---

## Mistake 11 — Unnecessary JOIN after ranking

### Problem

After calculating:

```sql
DENSE_RANK() OVER (...)
```

the result already contains:

```text
department
name
salary
rank
```

Joining back to `employees` just to retrieve the same columns is unnecessary.

### Memory

> If the current result already contains what you need, don't add another JOIN.

---

## Mistake 12 — Wrong string quotation

### Wrong

```sql
WHERE department = "HR"
```

### Correct

```sql
WHERE department = 'HR'
```

### Memory

> SQL string literals → single quotes.

---

# 🎯 Most Important Decision Patterns

### "Highest-paid employee overall?"

```text
ORDER BY salary DESC
LIMIT 1
```

### "Highest-paid employee in each department?"

```text
RANK()
PARTITION BY department
ORDER BY salary DESC
WHERE rnk = 1
```

### "Top N per department with ties?"

```text
RANK()
PARTITION BY department
ORDER BY salary DESC
WHERE rnk <= N
```

### "Top N per department with unique positions?"

```text
ROW_NUMBER()
PARTITION BY department
ORDER BY salary DESC
```

### "Nth-highest distinct salary overall?"

```text
DISTINCT
ORDER BY salary DESC
OFFSET N-1
LIMIT 1
```

### "Nth-highest distinct salary per department?"

```text
DENSE_RANK()
PARTITION BY department
ORDER BY salary DESC
WHERE rank = N
```

### "Above overall average?"

```text
Scalar subquery
```

### "Above own department average?"

```text
Correlated subquery
OR
CTE + JOIN
```

### "Greater than every HR salary?"

```text
> ALL (...)
```

### "Greater than at least one Finance salary?"

```text
> ANY (...)
```

### "One aggregate result per department?"

```text
GROUP BY department
```

### "Display aggregate alongside every employee?"

```text
Window function + PARTITION BY
```

### "Filter an aggregate?"

```text
HAVING
```

### "Running total?"

```text
SUM() OVER (ORDER BY ...)
```

---

# 📊 Current Weak Areas

Based on actual practice performance:

| Topic                 | Status                       |
| --------------------- | ---------------------------- |
| Filtering             | ✅                            |
| Aggregates            | ✅                            |
| GROUP BY              | ✅                            |
| HAVING                | ⚠️ Needs more practice       |
| JOINs                 | ⚠️ Needs more mixed practice |
| Scalar Subqueries     | ✅                            |
| Correlated Subqueries | ⚠️ Improving                 |
| CTEs                  | ✅                            |
| LIMIT / OFFSET        | ✅                            |
| ALL / ANY             | ✅                            |
| RANK                  | ⚠️ Improving                 |
| DENSE_RANK            | ⚠️ Improving                 |
| ROW_NUMBER            | ⚠️ Improving                 |
| Window Functions      | ⚠️ Improving                 |
| Multi-step SQL        | ⚠️ Improving                 |

---

# 🚀 Main Interview Lesson So Far

Do not start by asking:

> "Which SQL syntax do I remember?"

Start by asking:

```text
1. Do I need individual rows or grouped rows?
2. Is the comparison overall or per department?
3. Does the subquery return one value or multiple values?
4. Are ties required?
5. Do I need to aggregate first?
6. Do I need to rank after aggregation?
7. Do I need to keep the individual rows?
```

Then choose:

```text
GROUP BY
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

> **Goal: Give me an unfamiliar SQL problem and I should be able to identify the approach before writing the query.**
