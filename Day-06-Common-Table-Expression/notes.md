# Day 06 — Common Table Expressions (CTEs)

## 1. What is a CTE?

CTE stands for **Common Table Expression**.

A CTE allows us to create a temporary named result set using the `WITH` keyword and then use it in the main query.

### Basic syntax

```sql
WITH cte_name AS (
    SELECT ...
)
SELECT ...
FROM cte_name;
```

A CTE exists only for the duration of the query.

---

# 2. Why use CTEs?

CTEs are useful when:

* A query is becoming complex
* We need to break a large query into smaller logical steps
* We need to reuse an intermediate result
* We want better readability
* We need multiple stages of filtering/aggregation
* We are building reporting queries

### Backend example

Suppose an API needs to return:

> Departments with their average salary and employee count.

Instead of writing one complicated query, we can calculate the intermediate results using CTEs and then combine them.

---

# 3. Employee Table

We use the following table throughout Day 06.

| id | name   | department | salary |
| -- | ------ | ---------- | -----: |
| 1  | Arun   | IT         |  60000 |
| 2  | Bala   | HR         |  45000 |
| 3  | Charan | IT         |  75000 |
| 4  | Divya  | Finance    |  80000 |
| 5  | Esha   | HR         |  50000 |
| 6  | Farhan | IT         |  65000 |
| 7  | Gokul  | Finance    |  70000 |
| 8  | Hari   | Finance    |  90000 |

---

# 4. Simple CTE

### Example

```sql
WITH average_department AS (
    SELECT
        department,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
)
SELECT
    department,
    average_salary
FROM average_department;
```

### Result

| department | average_salary |
| ---------- | -------------: |
| IT         |       66666.67 |
| HR         |          47500 |
| Finance    |          80000 |

The CTE creates an intermediate result called `average_department`.

The main query then reads from that result.

---

# 5. CTE with Filtering

We can filter the result produced by a CTE.

```sql
WITH average_department AS (
    SELECT
        department,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
)
SELECT
    department,
    average_salary
FROM average_department
WHERE average_salary > 60000;
```

### Result

| department | average_salary |
| ---------- | -------------: |
| IT         |       66666.67 |
| Finance    |          80000 |

---

# 6. CTE with COUNT

A CTE can also contain aggregate functions such as `COUNT()`.

```sql
WITH department_count AS (
    SELECT
        department,
        COUNT(*) AS employee_count
    FROM employees
    GROUP BY department
)
SELECT
    department,
    employee_count
FROM department_count;
```

### Result

| department | employee_count |
| ---------- | -------------: |
| IT         |              3 |
| HR         |              2 |
| Finance    |              3 |

---

# 7. CTE + Filtering Aggregate Results

Example:

> Find departments having more than 2 employees.

```sql
WITH department_count AS (
    SELECT
        department,
        COUNT(*) AS employee_count
    FROM employees
    GROUP BY department
)
SELECT
    department,
    employee_count
FROM department_count
WHERE employee_count > 2;
```

### Result

| department | employee_count |
| ---------- | -------------: |
| IT         |              3 |
| Finance    |              3 |

This is one advantage of CTEs: the aggregate result gets a meaningful name and can then be filtered easily.

---

# 8. CTE with Multiple Aggregates

We can calculate multiple values inside one CTE.

```sql
WITH department_summary AS (
    SELECT
        department,
        COUNT(*) AS employee_count,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
)
SELECT
    department,
    employee_count,
    average_salary
FROM department_summary
WHERE employee_count >= 3
  AND average_salary > 60000;
```

### Result

| department | employee_count | average_salary |
| ---------- | -------------: | -------------: |
| IT         |              3 |       66666.67 |
| Finance    |              3 |          80000 |

---

# 9. CTE + JOIN

One of the most important interview patterns is joining the original table with an aggregated CTE.

### Requirement

> Find employees whose salary is greater than their department average.

First calculate the average salary:

```sql
WITH department_average AS (
    SELECT
        department,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
)
```

Then join it with employees:

```sql
SELECT
    e.name,
    e.department,
    e.salary,
    da.average_salary
FROM employees e
INNER JOIN department_average da
    ON e.department = da.department
WHERE e.salary > da.average_salary;
```

### Complete query

```sql
WITH department_average AS (
    SELECT
        department,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
)
SELECT
    e.name,
    e.department,
    e.salary,
    da.average_salary
FROM employees e
INNER JOIN department_average da
    ON e.department = da.department
WHERE e.salary > da.average_salary;
```

### Result

| name   | department | salary | average_salary |
| ------ | ---------- | -----: | -------------: |
| Charan | IT         |  75000 |       66666.67 |
| Divya  | Finance    |  80000 |          80000 |
| Hari   | Finance    |  90000 |          80000 |
| Esha   | HR         |  50000 |          47500 |

> Note: If the requirement is strictly "greater than", Divya with salary equal to the Finance average should not be included. The actual strict result is Charan, Hari, and Esha.

---

# 10. Multiple CTEs

A query can contain multiple CTEs.

Syntax:

```sql
WITH cte_one AS (
    ...
),
cte_two AS (
    ...
)
SELECT ...
```

Example:

```sql
WITH average_department AS (
    SELECT
        department,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
),
count_department AS (
    SELECT
        department,
        COUNT(*) AS employee_count
    FROM employees
    GROUP BY department
)
SELECT
    ad.department,
    ad.average_salary,
    cd.employee_count
FROM average_department ad
INNER JOIN count_department cd
    ON ad.department = cd.department;
```

### Result

| department | average_salary | employee_count |
| ---------- | -------------: | -------------: |
| IT         |       66666.67 |              3 |
| HR         |          47500 |              2 |
| Finance    |          80000 |              3 |

---

# 11. CTE for Finding Maximum Aggregate

A common mistake is trying to write:

```sql
SELECT department, MAX(AVG(salary))
FROM employees
GROUP BY department;
```

This does not work because `AVG()` is already an aggregate and `MAX()` cannot simply be applied around it at the same query level.

Instead, calculate the average first, then find the maximum.

```sql
WITH average_department AS (
    SELECT
        department,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
)
SELECT
    department,
    average_salary
FROM average_department
ORDER BY average_salary DESC
LIMIT 1;
```

### Result

| department | average_salary |
| ---------- | -------------: |
| Finance    |          80000 |

---

# 12. CTE for Finding the Highest-Salary Department

```sql
WITH total_expenditure AS (
    SELECT
        department,
        SUM(salary) AS total_salary
    FROM employees
    GROUP BY department
)
SELECT
    department,
    total_salary
FROM total_expenditure
ORDER BY total_salary DESC
LIMIT 1;
```

### Department totals

| department | total_salary |
| ---------- | -----------: |
| IT         |       200000 |
| HR         |        95000 |
| Finance    |       240000 |

Therefore:

**Finance has the highest total salary expenditure.**

---

# 13. Important CTE Pattern

Remember this interview pattern:

```text
Step 1 → Calculate intermediate result
Step 2 → Give it a meaningful name
Step 3 → Use the CTE in the main query
Step 4 → JOIN / FILTER / ORDER the result
```

For example:

```text
employees
    ↓
GROUP BY department
    ↓
AVG(salary)
    ↓
department_average CTE
    ↓
JOIN employees
    ↓
Compare employee salary with department average
```

---

# 14. CTE vs Subquery

| Feature               | CTE       | Subquery                |
| --------------------- | --------- | ----------------------- |
| Readability           | High      | Can become difficult    |
| Naming                | Yes       | Usually no              |
| Multiple steps        | Easy      | More difficult          |
| Multiple CTEs         | Supported | Nested queries required |
| Temporary result      | Yes       | Yes                     |
| Recursive queries     | Supported | Not normally            |
| Interview readability | Excellent | Good                    |

---

# 15. CTE vs Temporary Table

| CTE                                | Temporary Table                                  |
| ---------------------------------- | ------------------------------------------------ |
| Exists only during query execution | Exists for a session/transaction depending on DB |
| Mainly for query readability       | Useful for intermediate data                     |
| No separate table creation         | Creates a temporary table                        |
| Lightweight for query logic        | Useful when reused across multiple statements    |

---

# 16. Interview Questions to Remember

### Question 1

What is a CTE?

**Answer:**

A CTE is a temporary named result set created using the `WITH` clause. It improves query readability and allows complex SQL logic to be divided into smaller steps.

### Question 2

Why use CTE instead of a subquery?

**Answer:**

CTEs make complex queries easier to read, organize and maintain. They are especially useful when multiple intermediate results or multiple query stages are required.

### Question 3

Can we have multiple CTEs?

**Answer:**

Yes.

```sql
WITH cte_one AS (...),
     cte_two AS (...)
SELECT ...
```

### Question 4

Can a CTE be joined with the original table?

**Answer:**

Yes. This is a common pattern for comparing row-level data with aggregated data.

---

# 17. Day 06 Interview Takeaway

The most important concept from Day 06 is:

> **Use a CTE to calculate an intermediate result and then use that result in the main query.**

Especially remember:

```sql
WITH department_average AS (
    SELECT
        department,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
)
SELECT ...
FROM employees e
JOIN department_average da
    ON e.department = da.department;
```

This pattern is very common in backend development, reporting systems and interview SQL questions.

---

# Day 06 Progress

| Topic                       | Status |
| --------------------------- | ------ |
| CTE basics                  | ✅      |
| CTE + GROUP BY              | ✅      |
| CTE + COUNT                 | ✅      |
| CTE + AVG                   | ✅      |
| CTE + filtering             | ✅      |
| CTE + JOIN                  | ✅      |
| Multiple CTEs               | ✅      |
| Maximum aggregate using CTE | ✅      |
| Complex CTE query           | ✅      |
| Interview challenge         | ✅      |

**Day 06 completed successfully.**

Next topic:

# Day 07 — SQL Window Functions

Important concepts:

* `OVER()`
* `PARTITION BY`
* `ORDER BY` inside `OVER()`
* `ROW_NUMBER()`
* `RANK()`
* `DENSE_RANK()`
* `LAG()`
* `LEAD()`
* Running totals
* Top-N per department
* Interview-style ranking problems
