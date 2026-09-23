# Daily SQL Learning — Day 07

# SQL Window Functions

## 1. Context

Window functions are used to perform calculations across related rows **without combining those rows into a single row**.

This is the major difference between:

```sql
GROUP BY
```

and:

```sql
Window Functions
```

### GROUP BY

`GROUP BY` combines rows.

```sql
SELECT
    department,
    AVG(salary)
FROM employees
GROUP BY department;
```

Result:

| department | avg_salary |
| ---------- | ---------: |
| IT         |   66666.67 |
| HR         |      47500 |
| Finance    |      80000 |

We get one row per department.

### Window Function

```sql
SELECT
    name,
    department,
    salary,
    AVG(salary) OVER(
        PARTITION BY department
    ) AS department_average
FROM employees;
```

Result:

| name   | department | salary | department_average |
| ------ | ---------- | -----: | -----------------: |
| Arun   | IT         |  60000 |           66666.67 |
| Charan | IT         |  75000 |           66666.67 |
| Farhan | IT         |  65000 |           66666.67 |
| Bala   | HR         |  45000 |              47500 |
| Esha   | HR         |  50000 |              47500 |

The original employee rows are preserved.

---

# 2. Employee Table

We use this table throughout Day 07.

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

# 3. Basic Window Function — `OVER()`

`OVER()` tells SQL that we want to perform a calculation as a window function.

### Example

```sql
SELECT
    name,
    salary,
    SUM(salary) OVER() AS total_salary
FROM employees;
```

The total salary is calculated across all employees.

### Important

```sql
SUM(salary)
```

with `GROUP BY` can reduce rows.

```sql
SUM(salary) OVER()
```

keeps the individual employee rows.

---

# 4. `PARTITION BY`

`PARTITION BY` divides the rows into logical groups.

Think of it as:

> "Perform this calculation separately for each group."

### Example

```sql
SELECT
    name,
    department,
    salary,
    SUM(salary) OVER(
        PARTITION BY department
    ) AS department_total_salary
FROM employees;
```

For IT, SQL calculates the total only for IT employees.

For HR, SQL calculates the total only for HR employees.

For Finance, SQL calculates the total only for Finance employees.

---

# 5. Window Average

```sql
SELECT
    name,
    department,
    salary,
    AVG(salary) OVER(
        PARTITION BY department
    ) AS department_average_salary
FROM employees;
```

Every employee receives the average salary of their department.

This is extremely useful for interview questions such as:

> Find employees earning more than their department average.

---

# 6. `ORDER BY` Inside `OVER()`

The `ORDER BY` inside a window function determines the order in which the window calculation operates.

Example:

```sql
ROW_NUMBER() OVER(
    ORDER BY salary DESC
)
```

Employees are numbered from highest salary to lowest.

Important:

```sql
ORDER BY salary DESC
```

inside `OVER()` is different from the final:

```sql
ORDER BY salary DESC
```

The first controls the window calculation.

The second controls the final output order.

---

# 7. `ROW_NUMBER()`

`ROW_NUMBER()` assigns a unique sequential number to every row.

```sql
SELECT
    name,
    salary,
    ROW_NUMBER() OVER(
        ORDER BY salary DESC
    ) AS row_num
FROM employees;
```

Example:

| name   | salary | row_num |
| ------ | -----: | ------: |
| Hari   |  90000 |       1 |
| Divya  |  80000 |       2 |
| Charan |  75000 |       3 |
| Gokul  |  70000 |       4 |

Even if two employees have the same salary, `ROW_NUMBER()` gives them different numbers.

---

# 8. `ROW_NUMBER()` with `PARTITION BY`

This is one of the most important interview patterns.

```sql
ROW_NUMBER() OVER(
    PARTITION BY department
    ORDER BY salary DESC
)
```

It means:

> Number employees from highest salary to lowest, restarting the numbering for every department.

Example:

| name   | department | salary | row_num |
| ------ | ---------- | -----: | ------: |
| Charan | IT         |  75000 |       1 |
| Farhan | IT         |  65000 |       2 |
| Arun   | IT         |  60000 |       3 |
| Hari   | Finance    |  90000 |       1 |
| Divya  | Finance    |  80000 |       2 |
| Gokul  | Finance    |  70000 |       3 |
| Esha   | HR         |  50000 |       1 |
| Bala   | HR         |  45000 |       2 |

---

# 9. `RANK()`

`RANK()` assigns the same rank when values are tied.

Example:

| salary | RANK |
| -----: | ---: |
|  90000 |    1 |
|  80000 |    2 |
|  80000 |    2 |
|  70000 |    4 |

Notice that rank **3 is skipped**.

Therefore:

> `RANK()` = ties + gaps

---

# 10. `DENSE_RANK()`

`DENSE_RANK()` also gives the same rank to tied values, but it does not leave gaps.

Example:

| salary | DENSE_RANK |
| -----: | ---------: |
|  90000 |          1 |
|  80000 |          2 |
|  80000 |          2 |
|  70000 |          3 |

Therefore:

> `DENSE_RANK()` = ties + no gaps

---

# 11. `ROW_NUMBER()` vs `RANK()` vs `DENSE_RANK()`

This is a very important interview question.

| Function     | Duplicate values  | Gaps after ties? |
| ------------ | ----------------- | ---------------- |
| ROW_NUMBER() | Different numbers | Not applicable   |
| RANK()       | Same rank         | Yes              |
| DENSE_RANK() | Same rank         | No               |

### Easy memory trick

```text
ROW_NUMBER  → Unique
RANK        → Gap
DENSE_RANK  → No Gap
```

---

# 12. Top-N Employees Per Department

This is one of the most common SQL interview questions.

### Requirement

Find the top 2 highest-paid employees in every department.

First assign row numbers:

```sql
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
```

Then filter:

```sql
SELECT
    name,
    department,
    salary
FROM ranked_employees
WHERE row_num <= 2;
```

### Complete pattern

```sql
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
```

### Interview pattern

Remember:

```text
Window Function
      ↓
Assign Rank/Row Number
      ↓
CTE / Subquery
      ↓
Filter the Rank
```

---

# 13. Second-Highest Salary Per Department

Use `DENSE_RANK()` when the requirement concerns the **second distinct salary**.

```sql
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
```

### Why DENSE_RANK?

Suppose:

| Employee | Salary |
| -------- | -----: |
| A        |  75000 |
| B        |  75000 |
| C        |  65000 |
| D        |  60000 |

Ranking:

```text
75000 → 1
75000 → 1
65000 → 2
60000 → 3
```

Therefore, 65000 is the second-highest **distinct** salary.

---

# 14. `LAG()`

`LAG()` allows us to access a value from a previous row.

Example:

```sql
LAG(salary) OVER(
    PARTITION BY department
    ORDER BY salary
)
```

For IT:

| Employee | Salary | Previous Salary |
| -------- | -----: | --------------: |
| Arun     |  60000 |            NULL |
| Farhan   |  65000 |           60000 |
| Charan   |  75000 |           65000 |

The first row has no previous row, so its value is `NULL`.

### Memory trick

```text
LAG  → Previous
LEAD → Next
```

---

# 15. Finding Employees Earning More Than the Previous Employee

```sql
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
```

The CTE is useful because we cannot normally reference a window-function alias directly in the same `WHERE` clause where it is created.

---

# 16. `LEAD()`

`LEAD()` accesses the value from the next row.

```sql
SELECT
    name,
    department,
    salary,
    LEAD(salary) OVER(
        PARTITION BY department
        ORDER BY salary
    ) AS next_salary
FROM employees;
```

### Remember

```text
LAG()  → previous row
LEAD() → next row
```

---

# 17. Running Total

A window function can calculate a running total.

```sql
SELECT
    name,
    salary,
    SUM(salary) OVER(
        ORDER BY salary
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM employees;
```

Conceptually:

```text
Row 1 → Salary 1
Row 2 → Salary 1 + Salary 2
Row 3 → Salary 1 + Salary 2 + Salary 3
...
```

This is useful for reporting and financial calculations.

---

# 18. Window Functions vs GROUP BY

| GROUP BY                    | Window Function                           |
| --------------------------- | ----------------------------------------- |
| Combines rows               | Keeps individual rows                     |
| Usually reduces result rows | Usually preserves result rows             |
| Aggregate per group         | Aggregate/calculation across related rows |
| Good for summaries          | Good for rankings/comparisons             |
| Example: department average | Example: employee + department average    |

### Simple rule

> **GROUP BY summarizes. Window functions analyze without losing the rows.**

---

# 19. Most Important Interview Patterns

### Pattern 1 — Department average

```sql
AVG(salary) OVER(
    PARTITION BY department
)
```

### Pattern 2 — Ranking within department

```sql
ROW_NUMBER() OVER(
    PARTITION BY department
    ORDER BY salary DESC
)
```

### Pattern 3 — Top N per group

```sql
WITH ranked AS (
    SELECT
        ...,
        ROW_NUMBER() OVER(
            PARTITION BY department
            ORDER BY salary DESC
        ) AS rn
    FROM employees
)
SELECT *
FROM ranked
WHERE rn <= 2;
```

### Pattern 4 — Nth highest distinct value

```sql
DENSE_RANK() OVER(
    PARTITION BY department
    ORDER BY salary DESC
)
```

Then:

```sql
WHERE salary_rank = N
```

### Pattern 5 — Previous row

```sql
LAG(column) OVER(
    PARTITION BY ...
    ORDER BY ...
)
```

### Pattern 6 — Next row

```sql
LEAD(column) OVER(
    PARTITION BY ...
    ORDER BY ...
)
```

---

# 20. Day 07 Interview Takeaways

The most important concepts to remember:

1. `OVER()` turns an aggregate/calculation into a window calculation.
2. `PARTITION BY` divides rows into groups without removing them.
3. `ORDER BY` inside `OVER()` controls calculation order.
4. `ROW_NUMBER()` gives unique sequential numbers.
5. `RANK()` allows ties but creates gaps.
6. `DENSE_RANK()` allows ties without gaps.
7. `LAG()` accesses the previous row.
8. `LEAD()` accesses the next row.
9. Top-N-per-group questions commonly use `ROW_NUMBER()` + CTE.
10. Nth-highest distinct-value questions commonly use `DENSE_RANK()`.

---

# Day 07 Practice Result

| Question | Topic                         | Result     |
| -------- | ----------------------------- | ---------- |
| Q1       | `SUM() OVER()`                | ✅ Correct  |
| Q2       | `PARTITION BY`                | ✅ Correct  |
| Q3       | `AVG() OVER()`                | ✅ Correct  |
| Q4       | `ROW_NUMBER()`                | ✅ Correct  |
| Q5       | `ROW_NUMBER()` + partition    | ✅ Correct  |
| Q6       | `RANK()`                      | ✅ Correct  |
| Q7       | `DENSE_RANK()`                | ✅ Correct  |
| Q8       | Top 2 per department          | 📚 Learned |
| Q9       | Second-highest per department | 📚 Learned |
| Q10      | `LAG()`                       | 📚 Learned |

## Day 07 Status

**Completed: SQL Window Functions**

Next: **Day 08 — CASE, COALESCE & NULL Handling**

Focus will be on conditional SQL, handling missing data, and interview problems involving `NULL`.
