# SQL Hands-On Revision — Days 1–7

> **Goal:** Recover and strengthen SQL hands-on skills through interview-oriented problems.
>
> **Learning method:** Learn briefly → Write SQL → Execute/Think → Review → Correct → Learn from mistake → Increase difficulty.

---

## Practice Table

```sql
employees (
    id,
    name,
    department,
    salary
)
```

### Sample Data

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

# Day 8 — Mixed Hands-On Revision

## Q1. Employees with salary greater than 60000

```sql
SELECT name, department, salary
FROM employees
WHERE salary > 60000;
```

### Concept

`WHERE` filters individual rows.

---

## Q2. Employee count by department

```sql
SELECT department,
       COUNT(*) AS employee_count
FROM employees
GROUP BY department
ORDER BY employee_count DESC;
```

### Concept

`GROUP BY` creates one result per department.

---

## Q3. Departments with average salary greater than 60000

### Correct solution

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

is not portable to PostgreSQL because the SELECT alias should not be relied upon in `HAVING`.

### Memory trick

> `WHERE` → filters rows
> `HAVING` → filters groups

---

## Q4. Second-highest distinct salary

```sql
SELECT name, salary
FROM employees
WHERE salary = (
    SELECT DISTINCT salary
    FROM employees
    ORDER BY salary DESC
    OFFSET 1
    LIMIT 1
);
```

### Concept

```text
DISTINCT
→ remove duplicate salaries

ORDER BY DESC
→ highest to lowest

OFFSET 1
→ skip highest

LIMIT 1
→ take second
```

### Memory trick

> **Nth-highest distinct salary**
>
> `DISTINCT + DESC + OFFSET (N-1) + LIMIT 1`

---

## Q5. Employees earning more than their own department average

```sql
WITH average_department AS (
    SELECT department,
           AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
)
SELECT e.name,
       e.department,
       e.salary
FROM employees e
JOIN average_department ad
    ON ad.department = e.department
WHERE e.salary > ad.average_salary;
```

### Concept

1. Calculate department average.
2. Join it back to employees.
3. Compare employee salary with department average.

### Memory trick

> **Own department average** → connect employee to the average of their department.

---

## Q6. Highest-paid employee in each department, including ties

```sql
SELECT department, name, salary
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

### Concept

```text
PARTITION BY department
→ ranking restarts for every department

ORDER BY salary DESC
→ highest salary first

RANK()
→ include ties

rnk = 1
→ highest-paid employees
```

### Memory trick

> **Highest per group + ties → `RANK() + PARTITION BY`**

---

## Q7. Top 2 employees from each department, including ties

```sql
SELECT department, name, salary
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

### Important distinction

This is **not**:

```sql
LIMIT 2
```

because `LIMIT 2` gives only two rows overall.

### Memory trick

> `LIMIT` → overall
> `PARTITION BY` + ranking → per group

---

## Q8. Employees earning more than every HR employee

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

### Concept

If HR salaries are:

```text
45000
50000
```

Then:

```sql
salary > ALL (...)
```

means:

```text
salary > 45000
AND
salary > 50000
```

### Memory trick

> `ALL` → every value
> `ANY` → at least one value

---

## Q9. Department with the highest average salary

```sql
SELECT department,
       AVG(salary) AS average_salary
FROM employees
GROUP BY department
ORDER BY average_salary DESC
LIMIT 1;
```

### Concept

Aggregate → group → sort → take highest.

---

## Q10. Running total of salaries

```sql
SELECT name,
       salary,
       SUM(salary) OVER (
           ORDER BY salary
       ) AS running_total
FROM employees;
```

### Concept

A running total requires a **window function**.

### Memory trick

> Running total → `SUM(...) OVER (ORDER BY ...)`

---

# Recovery — LIMIT, OFFSET, ALL, PARTITION BY

## LIMIT

```sql
ORDER BY salary DESC
LIMIT 2;
```

Means:

> Return only the first 2 rows of the final result.

### Example

```text
90000
80000
75000
70000
```

`LIMIT 2` returns:

```text
90000
80000
```

### Important

`LIMIT 2` does **not** mean second-highest salary.

---

# OFFSET

```sql
OFFSET 1
LIMIT 1
```

Means:

> Skip 1 row and take the next 1 row.

### Pattern

| Requirement | Pattern            |
| ----------- | ------------------ |
| 1st         | `OFFSET 0 LIMIT 1` |
| 2nd         | `OFFSET 1 LIMIT 1` |
| 3rd         | `OFFSET 2 LIMIT 1` |
| 4th         | `OFFSET 3 LIMIT 1` |

### Memory trick

> `OFFSET` = skip
> `LIMIT` = take

---

# ALL

```sql
salary > ALL (
    SELECT salary
    FROM employees
    WHERE department = 'HR'
)
```

Means:

> Salary must be greater than **every salary** returned by the subquery.

### ALL vs ANY

```text
> ALL → greater than everyone
> ANY → greater than at least one
```

---

# PARTITION BY

```sql
RANK() OVER (
    PARTITION BY department
    ORDER BY salary DESC
)
```

Means:

> Rank employees separately inside every department.

### Example

```text
IT       → ranks restart
HR       → ranks restart
Finance  → ranks restart
```

---

# Q11. Lowest-paid employee in each department, including ties

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

### Memory trick

> Lowest per group → `ORDER BY salary ASC`

---

# Q12. Third-highest distinct salary

```sql
SELECT name, salary
FROM employees
WHERE salary = (
    SELECT DISTINCT salary
    FROM employees
    ORDER BY salary DESC
    OFFSET 2
    LIMIT 1
);
```

### Concept

```text
DISTINCT → remove duplicate salaries
DESC     → highest first
OFFSET 2 → skip first two
LIMIT 1  → take third
```

### Memory trick

> Nth-highest → `OFFSET N-1 LIMIT 1`

---

# Q13. Employees earning more than their own department average

### Incorrect approach

```sql
SELECT name, salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
    GROUP BY department
);
```

### Why incorrect?

The subquery returns **multiple averages**:

```text
IT average
HR average
Finance average
```

But `>` expects one scalar value.

### Correct correlated subquery

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

### Concept

The inner query depends on the current outer employee.

### Memory trick

> **Own department → correlated subquery**

---

# Q14. Top 2 employees from each department, including ties

### Correct solution

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

If the requirement says **include ties**, prefer:

```sql
RANK()
```

instead of:

```sql
ROW_NUMBER()
```

---

# Q15. Running total ordered by salary

```sql
SELECT name,
       salary,
       SUM(salary) OVER (
           ORDER BY salary DESC
       ) AS running_total
FROM employees;
```

### Important distinction

There are two different `ORDER BY`s:

```sql
SUM(salary) OVER (ORDER BY salary DESC)
```

controls the **calculation sequence**.

```sql
ORDER BY ...
```

outside the window function controls the **final display order**.

### Memory trick

> `ORDER BY` inside `OVER()` → calculation
> Outer `ORDER BY` → display

---

# Q16. Fourth-highest distinct salary

```sql
SELECT DISTINCT salary
FROM employees
ORDER BY salary DESC
OFFSET 3
LIMIT 1;
```

### Concept

```text
4th highest
→ OFFSET 3
→ LIMIT 1
```

### Memory trick

> `OFFSET = N - 1`

---

# Q17. Employees earning more than every HR employee

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

### Concept

```text
> ALL
```

means greater than **every returned value**.

---

# Q18. Top 2 highest-paid employees from each department, including ties

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

### Mistake to remember

Using:

```sql
ROW_NUMBER()
```

does not properly represent ties because every row receives a unique number.

### Ranking functions

| Function       | Same salary      | Gaps |
| -------------- | ---------------- | ---- |
| `ROW_NUMBER()` | Different number | No   |
| `RANK()`       | Same rank        | Yes  |
| `DENSE_RANK()` | Same rank        | No   |

---

# Mixed Interview Drill — Q19 to Q24

## Q19. Highest-paid employee in the company

```sql
SELECT name,
       department,
       salary
FROM employees
ORDER BY salary DESC
LIMIT 1;
```

### Pattern

> Highest overall → `ORDER BY DESC LIMIT 1`

---

# Q20. Departments where total salary is greater than 150000

### Correct solution

```sql
SELECT department,
       SUM(salary) AS total_salary
FROM employees
GROUP BY department
HAVING SUM(salary) > 150000;
```

### Mistake made

Trying to use:

```sql
SUM(salary) OVER(PARTITION BY department)
```

with `GROUP BY`.

### Correct thinking

If the question asks for:

> **one result per department**

and asks for an aggregate:

```text
GROUP BY + aggregate
```

If you need to filter that aggregate:

```text
HAVING
```

### Memory trick

```text
WHERE  → rows
HAVING → groups
```

---

# Q21. Employees earning above overall average salary

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

### Concept

The subquery returns exactly **one value**, so it is a scalar subquery.

---

# Q22. Highest-paid employee in each department, including ties

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
per department
+
highest
+
include ties

→ RANK() + PARTITION BY
```

---

# Q23. Employees earning above their own department average

```sql
WITH average_department AS (
    SELECT department,
           AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
)
SELECT e.name,
       e.department,
       e.salary
FROM employees e
JOIN average_department ad
    ON ad.department = e.department
WHERE e.salary > ad.average_salary;
```

### Pattern

```text
CTE
→ calculate department average

JOIN
→ attach average to each employee

WHERE
→ compare salary with department average
```

---

# Q24. Second-highest distinct salary in each department

### Recommended solution

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

### Why `DENSE_RANK()`?

Suppose a department has:

```text
90000
80000
80000
70000
```

`DENSE_RANK()` produces:

```text
90000 → 1
80000 → 2
80000 → 2
70000 → 3
```

So rank 2 represents the **second distinct salary**.

### Memory trick

> **Nth-highest distinct per group → `DENSE_RANK()`**

---

# Critical Interview Patterns Learned

## 1. Top N Overall

```sql
SELECT *
FROM employees
ORDER BY salary DESC
LIMIT 2;
```

> `LIMIT` works on the overall result.

---

## 2. Nth-highest distinct salary

```sql
SELECT DISTINCT salary
FROM employees
ORDER BY salary DESC
OFFSET N-1
LIMIT 1;
```

> `OFFSET` skips → `LIMIT` takes.

---

## 3. Top N Per Group

```sql
RANK() OVER (
    PARTITION BY department
    ORDER BY salary DESC
)
```

Then:

```sql
WHERE rnk <= N
```

> `PARTITION BY` makes ranking happen separately for each group.

---

## 4. Highest per Group — Include Ties

```sql
RANK() OVER (
    PARTITION BY department
    ORDER BY salary DESC
)
```

Then:

```sql
WHERE rnk = 1
```

---

## 5. Second-highest Distinct Per Group

```sql
DENSE_RANK() OVER (
    PARTITION BY department
    ORDER BY salary DESC
)
```

Then:

```sql
WHERE rnk = 2
```

---

## 6. Overall Average

```sql
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
)
```

> One average → scalar subquery.

---

## 7. Own Department Average

### CTE approach

```sql
WITH department_avg AS (
    SELECT department,
           AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department
)
SELECT ...
FROM employees e
JOIN department_avg d
    ON e.department = d.department
WHERE e.salary > d.avg_salary;
```

### Correlated subquery approach

```sql
SELECT ...
FROM employees e
WHERE salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department = e.department
);
```

---

## 8. Greater Than Every Value

```sql
salary > ALL (
    SELECT salary
    FROM employees
    WHERE department = 'HR'
)
```

> `ALL` = every value.

---

## 9. Aggregate Filtering

```sql
SELECT department,
       SUM(salary)
FROM employees
GROUP BY department
HAVING SUM(salary) > 150000;
```

> `HAVING` filters aggregated groups.

---

## 10. Running Total

```sql
SUM(salary) OVER (
    ORDER BY salary
)
```

> Running total → aggregate as a window function.

---

# Ranking Function Cheat Sheet

| Requirement                    | Function           |
| ------------------------------ | ------------------ |
| Unique row number              | `ROW_NUMBER()`     |
| Ranking with ties and gaps     | `RANK()`           |
| Ranking with ties without gaps | `DENSE_RANK()`     |
| Highest per group + ties       | `RANK() = 1`       |
| Top N per group + ties         | `RANK() <= N`      |
| Nth distinct value per group   | `DENSE_RANK() = N` |

---

# SQL Mistake Log

## Mistake 1 — LIMIT 2 for second-highest

**Mistake:**

```sql
LIMIT 2
```

**Correct pattern:**

```sql
DISTINCT
ORDER BY salary DESC
OFFSET 1
LIMIT 1
```

**Memory trick:**

> LIMIT 2 = two rows, NOT second-highest.

---

## Mistake 2 — LIMIT for Top N per department

**Mistake:**

```sql
ORDER BY salary DESC
LIMIT 2
```

**Correct pattern:**

```sql
RANK() OVER (
    PARTITION BY department
    ORDER BY salary DESC
)
```

**Memory trick:**

> LIMIT = overall
> PARTITION = per group

---

## Mistake 3 — Forgetting aggregate alias in CTE

**Mistake:**

```sql
AVG(salary)
```

and later trying:

```sql
ad.salary
```

**Correct:**

```sql
AVG(salary) AS average_salary
```

Then:

```sql
ad.average_salary
```

**Memory trick:**

> Give aggregate columns meaningful aliases.

---

## Mistake 4 — Incorrect ORDER BY syntax

**Mistake:**

```sql
ORDER BY DESC
```

**Correct:**

```sql
ORDER BY salary DESC
```

**Memory trick:**

> `DESC` modifies a column; it is not the column itself.

---

## Mistake 5 — Running total using GROUP BY

**Mistake:**

```sql
SUM(salary)
GROUP BY name
```

**Correct:**

```sql
SUM(salary) OVER (
    ORDER BY salary
)
```

**Memory trick:**

> Running total → `SUM() OVER()`.

---

## Mistake 6 — Using scalar comparison with multi-row subquery

**Mistake:**

```sql
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
    GROUP BY department
)
```

The subquery returns multiple rows.

**Correct options:**

* Correlated subquery
* CTE + JOIN
* Appropriate `ALL` / `ANY` depending on requirement

**Memory trick:**

> `=` / `>` / `<` with `(subquery)` usually expects one value.

---

## Mistake 7 — ROW_NUMBER when ties must be included

**Mistake:**

```sql
ROW_NUMBER()
```

**Correct:**

```sql
RANK()
```

when the requirement says:

> Include ties.

---

## Mistake 8 — Confusing RANK and DENSE_RANK

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

**Memory trick:**

> `RANK` → gaps
> `DENSE_RANK` → no gaps

---

# Progress After Today's Recovery

| Topic                          | Understanding | Hands-on               |
| ------------------------------ | ------------- | ---------------------- |
| Filtering                      | ✅             | ✅                      |
| Aggregates                     | ✅             | ✅                      |
| GROUP BY                       | ✅             | ✅                      |
| HAVING                         | ✅             | ⚠️ Needs more practice |
| JOINs                          | ✅             | ⚠️                     |
| Subqueries                     | ✅             | ⚠️ Improving           |
| CTEs                           | ✅             | ✅                      |
| Window Functions               | ✅             | ⚠️ Improving           |
| LIMIT / OFFSET                 | ✅             | ✅                      |
| ALL / ANY                      | ✅             | ✅                      |
| RANK / ROW_NUMBER / DENSE_RANK | ✅             | ⚠️ Improving           |

---

# Key Recovery Takeaways

Before an interview, remember these first:

```text
LIMIT
→ overall rows

OFFSET
→ skip rows

ALL
→ every value

ANY
→ at least one value

PARTITION BY
→ restart calculation/ranking per group

RANK
→ ties + gaps

DENSE_RANK
→ ties + no gaps

ROW_NUMBER
→ unique row numbers

WHERE
→ filter rows

HAVING
→ filter groups

GROUP BY
→ one result per group

SUM() OVER()
→ running/analytical calculation
```

## Most Important Decision Patterns

### "Highest-paid employee overall?"

```text
ORDER BY salary DESC
LIMIT 1
```

### "Highest-paid employee in each department?"

```text
RANK()
PARTITION BY department
```

### "Top 2 in each department?"

```text
RANK()
PARTITION BY department
WHERE rank <= 2
```

### "Second-highest distinct salary overall?"

```text
DISTINCT
ORDER BY DESC
OFFSET 1
LIMIT 1
```

### "Second-highest distinct salary per department?"

```text
DENSE_RANK()
PARTITION BY department
WHERE rank = 2
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

---

# Tomorrow's Recovery Plan

Before moving to new SQL topics, continue with **mixed interview practice from Days 1–7**.

### Focus areas

1. `GROUP BY + HAVING`
2. JOIN decision-making
3. Scalar vs multi-row subqueries
4. Correlated subqueries
5. CTE + JOIN
6. `ROW_NUMBER` vs `RANK` vs `DENSE_RANK`
7. Top-N per group
8. Nth-highest problems
9. `ALL` / `ANY`
10. Running totals and window ordering

### Rule for tomorrow

> **No concept will be given in the question. You decide the SQL approach first.**

Only after the recovery practice is strong should we move to the next new SQL topics.
