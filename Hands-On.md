# SQL Hands-On Interview Revision

## Base Table

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

# 1. Employees earning above 60,000

```sql
SELECT name, department, salary
FROM employees
WHERE salary > 60000;
```

**Pattern:** `WHERE` filters rows.

---

# 2. Employee count by department

```sql
SELECT department,
       COUNT(*) AS employee_count
FROM employees
GROUP BY department
ORDER BY employee_count DESC;
```

**Pattern:** `GROUP BY` creates one result per group.

---

# 3. Departments with average salary above 60,000

```sql
SELECT department,
       AVG(salary) AS average_salary
FROM employees
GROUP BY department
HAVING AVG(salary) > 60000;
```

**Mistake:** Using `WHERE` for aggregate filtering.

**Memory:**
`WHERE → rows`
`HAVING → groups`

---

# 4. Second-highest distinct salary

```sql
SELECT DISTINCT salary
FROM employees
ORDER BY salary DESC
OFFSET 1
LIMIT 1;
```

**Pattern:**

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

**Memory:** `OFFSET = skip`, `LIMIT = take`.

---

# 5. Third-highest distinct salary

```sql
SELECT DISTINCT salary
FROM employees
ORDER BY salary DESC
OFFSET 2
LIMIT 1;
```

**Pattern:** `Nth highest → OFFSET N-1 + LIMIT 1`

---

# 6. Fourth-highest distinct salary

```sql
SELECT DISTINCT salary
FROM employees
ORDER BY salary DESC
OFFSET 3
LIMIT 1;
```

**Important:** `LIMIT 2` means two rows, **not second-highest**.

---

# 7. Highest-paid employee overall

```sql
SELECT name, department, salary
FROM employees
ORDER BY salary DESC
LIMIT 1;
```

**Pattern:** Overall Top-N → `ORDER BY + LIMIT`.

---

# 8. Employees above overall average salary

```sql
SELECT name, department, salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);
```

**Concept:** Scalar subquery.

The subquery returns exactly one value.

---

# 9. Employees earning more than every HR employee

```sql
SELECT name, department, salary
FROM employees
WHERE salary > ALL (
    SELECT salary
    FROM employees
    WHERE department = 'HR'
);
```

**Pattern:**

```text
> ALL → greater than every returned value
> ANY → greater than at least one returned value
```

---

# 10. Employees earning more than the highest HR salary

```sql
SELECT name, department, salary
FROM employees
WHERE salary > (
    SELECT MAX(salary)
    FROM employees
    WHERE department = 'HR'
);
```

**Pattern:**
"Greater than the highest" → `> MAX(...)`

---

# 11. Employees earning more than ANY Finance employee

```sql
SELECT name, department, salary
FROM employees
WHERE salary > ANY (
    SELECT salary
    FROM employees
    WHERE department = 'Finance'
);
```

**Memory:**

```text
ALL → every value
ANY → at least one value
```

---

# 12. Employees earning above their own department average

### CTE solution

```sql
WITH department_avg AS (
    SELECT department,
           AVG(salary) AS average_salary
    FROM employees
    GROUP BY department
)
SELECT e.name,
       e.department,
       e.salary
FROM employees e
JOIN department_avg da
    ON e.department = da.department
WHERE e.salary > da.average_salary;
```

### Correlated subquery solution

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

**Important mistake:**

```sql
SELECT AVG(salary)
FROM employees
GROUP BY department
```

returns multiple values, so it cannot directly be compared with:

```sql
salary > (...)
```

**Memory:**
Own department → correlated subquery or CTE + JOIN.

---

# 13. Highest-paid employee in each department, including ties

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
) x
WHERE rnk = 1;
```

**Pattern:**

```text
Per department
+ highest
+ include ties

→ RANK()
→ PARTITION BY department
→ rnk = 1
```

---

# 14. Lowest-paid employee in each department, including ties

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
) x
WHERE rnk = 1;
```

**Memory:**
Highest → `DESC`
Lowest → `ASC`

---

# 15. Top 2 employees from each department, including ties

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
) x
WHERE rnk <= 2;
```

**Important mistake:**

```sql
LIMIT 2
```

returns only two rows overall.

For Top-N **per department**:

```text
PARTITION BY department
+
RANK()
```

---

# 16. Second-highest distinct salary per department

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
) x
WHERE drnk = 2;
```

**Memory:**
Nth-highest **distinct** per group → `DENSE_RANK()`.

---

# 17. Third-highest distinct salary per department

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
) x
WHERE drnk = 3;
```

---

# 18. Third-ranked employee per department using RANK

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
) x
WHERE rnk = 3;
```

### RANK vs DENSE_RANK

```text
Salaries: 100, 90, 90, 80

RANK:
100 → 1
90  → 2
90  → 2
80  → 4

DENSE_RANK:
100 → 1
90  → 2
90  → 2
80  → 3
```

**Memory:**

```text
RANK → ties + gaps
DENSE_RANK → ties + no gaps
ROW_NUMBER → unique number
```

---

# 19. Running total of salaries

```sql
SELECT name,
       salary,
       SUM(salary) OVER (
           ORDER BY salary
       ) AS running_total
FROM employees;
```

**Pattern:**

```text
Running total
→ SUM() OVER(ORDER BY ...)
```

**Mistake:** Using `GROUP BY` for a running total.

---

# 20. Departments with at least 2 employees

```sql
SELECT department,
       COUNT(*) AS employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) >= 2;
```

**Pattern:** Aggregate result filtering → `HAVING`.

---

# 21. Department with highest average salary

```sql
SELECT department,
       AVG(salary) AS average_salary
FROM employees
GROUP BY department
ORDER BY average_salary DESC
LIMIT 1;
```

**Pattern:**

```text
GROUP BY
→ AVG
→ ORDER BY DESC
→ LIMIT 1
```

---

# 22. Department with highest total salary

```sql
SELECT department,
       SUM(salary) AS total_salary
FROM employees
GROUP BY department
ORDER BY total_salary DESC
LIMIT 1;
```

**Pattern:** Aggregate first, then sort.

---

# 23. Departments with total salary above 150,000

```sql
SELECT department,
       SUM(salary) AS total_salary
FROM employees
GROUP BY department
HAVING SUM(salary) > 150000;
```

**Memory:**

```text
SUM + filter
→ GROUP BY + HAVING
```

---

# 24. Second-highest department by total salary

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
    ) x
) ranked
WHERE drnk = 2;
```

**Critical pattern:**

```text
Employee rows
    ↓
GROUP BY department
    ↓
SUM(salary)
    ↓
DENSE_RANK departments
    ↓
drnk = 2
```

**Important mistake:**

Do **not** use:

```sql
PARTITION BY department
```

when ranking departments against each other.

**Memory:**

```text
Employees within department
→ PARTITION BY department

Departments against each other
→ NO PARTITION BY
```

---

# 25. Employees above department average AND overall average

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

**Concepts combined:**

```text
Correlated subquery
+
Scalar subquery
+
AND
```

---

# 26. Employees in the same department as Arun

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

**Concept:** Scalar subquery.

**Memory:**
Find Arun's department first → use it in outer query.

---

# 27. Above department average with average displayed

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

**Important concept:**

```text
GROUP BY
→ collapses rows

PARTITION BY
→ keeps employee rows
```

---

# 28. Employee + Department details

## JOIN Tables

### departments

```text
department_id | department_name | location
101           | IT              | Chennai
102           | HR              | Bangalore
103           | Finance         | Mumbai
104           | Marketing       | Delhi
```

### employees JOIN version

```text
id | name   | department_id | salary
1  | Arun   | 101           | 60000
2  | Bala   | 102           | 45000
3  | Charan | 101           | 75000
4  | Divya  | 103           | 80000
5  | Esha   | 102           | 50000
6  | Farhan | 101           | 65000
7  | Gokul  | 103           | 70000
8  | Hari   | 103           | 90000
```

### Question

Return:

```text
name
department_name
location
salary
```

### Solution

```sql
SELECT e.name,
       d.department_name,
       d.location,
       e.salary
FROM employees e
INNER JOIN departments d
    ON e.department_id = d.department_id;
```

**Mistake to remember:**

Never forget the JOIN relationship:

```sql
ON e.department_id = d.department_id
```

---

# 29. Employee count including departments with zero employees

```sql
SELECT d.department_name,
       COUNT(e.id) AS employee_count
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.department_id
GROUP BY d.department_id,
         d.department_name;
```

**Why LEFT JOIN?**

Marketing has no employees but must still appear:

```text
Marketing → 0
```

**Why `COUNT(e.id)`?**

Because unmatched employees have:

```text
e.id = NULL
```

and `COUNT(e.id)` returns `0`.

**Memory:**

```text
Need all departments
→ LEFT JOIN

Need zero count
→ COUNT(employee.id)
```

---

# 30. Department total salary above 150,000 with department name

```sql
SELECT d.department_name,
       SUM(e.salary) AS total_salary
FROM employees e
INNER JOIN departments d
    ON e.department_id = d.department_id
GROUP BY d.department_id,
         d.department_name
HAVING SUM(e.salary) > 150000;
```

**Pattern:**

```text
JOIN
→ GROUP BY
→ SUM
→ HAVING
```

---

# 31. Above department average + department name + average

```sql
WITH department_avg AS (
    SELECT department_id,
           AVG(salary) AS department_average
    FROM employees
    GROUP BY department_id
)
SELECT e.name,
       d.department_name,
       e.salary,
       da.department_average
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
JOIN department_avg da
    ON e.department_id = da.department_id
WHERE e.salary > da.department_average;
```

**Concepts combined:**

```text
JOIN
+
CTE
+
GROUP BY
+
AVG
+
WHERE
```

**Mistake to remember:**
Salary comes from `employees`, not `departments`.

---

# 32. Second-highest department total salary with department name

```sql
SELECT department_name,
       total_salary
FROM (
    SELECT department_name,
           total_salary,
           DENSE_RANK() OVER (
               ORDER BY total_salary DESC
           ) AS drnk
    FROM (
        SELECT d.department_name,
               SUM(e.salary) AS total_salary
        FROM employees e
        INNER JOIN departments d
            ON e.department_id = d.department_id
        GROUP BY d.department_id,
                 d.department_name
    ) x
) ranked
WHERE drnk = 2;
```

**Mental model:**

```text
JOIN
 ↓
GROUP BY department
 ↓
SUM salary
 ↓
DENSE_RANK
 ↓
rank = 2
```

**Memory:**
**Aggregate first → rank second.**

---

# 33. Employees above both department and company averages

```sql
SELECT e.name,
       e.department,
       e.salary
FROM employees e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department = e.department
)
AND e.salary > (
    SELECT AVG(salary)
    FROM employees
);
```

**Note:** This is intentionally retained because it combines two different subquery types:

```text
Department average → correlated
Overall average → scalar
```

---

# 34. Highest-paid employee above department average

```sql
WITH above_avg AS (
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
    FROM above_avg
) x
WHERE drnk = 1;
```

**Pattern:**

```text
Filter above average
→ Rank
→ Highest
```

**Memory:**
**Filter first → rank second.**

---

# Ranking Cheat Sheet

| Requirement                        | Use                |
| ---------------------------------- | ------------------ |
| Unique position                    | `ROW_NUMBER()`     |
| Ranking with ties + gaps           | `RANK()`           |
| Ranking with ties + no gaps        | `DENSE_RANK()`     |
| Highest per department + ties      | `RANK() = 1`       |
| Top N per department + ties        | `RANK() <= N`      |
| Nth distinct salary per department | `DENSE_RANK() = N` |

---

# Subquery Cheat Sheet

| Requirement                | Pattern                 |
| -------------------------- | ----------------------- |
| One returned value         | Scalar subquery         |
| Same department comparison | Correlated subquery     |
| Multiple possible values   | `IN`                    |
| Greater than every value   | `> ALL`                 |
| Greater than at least one  | `> ANY`                 |
| Highest value              | `MAX()`                 |
| Overall average            | `AVG()` scalar subquery |

---

# LIMIT / OFFSET Cheat Sheet

```text
LIMIT 1
→ one row

LIMIT 2
→ two rows

OFFSET 1 LIMIT 1
→ second row

OFFSET 2 LIMIT 1
→ third row

OFFSET N-1 LIMIT 1
→ Nth row
```

For **Nth-highest distinct salary**:

```sql
SELECT DISTINCT salary
FROM employees
ORDER BY salary DESC
OFFSET N-1
LIMIT 1;
```

---

# JOIN Cheat Sheet

```text
INNER JOIN
→ matching rows only

LEFT JOIN
→ all rows from left table

RIGHT JOIN
→ all rows from right table

FULL JOIN
→ all rows from both tables
```

### Interview pattern

```text
Need all departments
+ employees may not exist
→ departments LEFT JOIN employees
```

---

# Mistake Log

### 1. `LIMIT 2` ≠ second-highest

```text
LIMIT 2 → return two rows
OFFSET 1 LIMIT 1 → second row
```

---

### 2. LIMIT cannot solve Top-N per department

```text
LIMIT → overall result
PARTITION BY + ranking → per group
```

---

### 3. Scalar operator with multi-row subquery

Wrong:

```sql
salary > (
    SELECT AVG(salary)
    FROM employees
    GROUP BY department
)
```

The subquery returns multiple values.

Use:

```text
Correlated subquery
OR
CTE + JOIN
OR
ALL / ANY when appropriate
```

---

### 4. Forgetting `PARTITION BY`

For:

> Top 2 employees in every department

Use:

```sql
RANK() OVER (
    PARTITION BY department
    ORDER BY salary DESC
)
```

---

### 5. Ranking departments incorrectly

Wrong:

```sql
DENSE_RANK() OVER (
    PARTITION BY department
    ORDER BY total_salary DESC
)
```

Correct:

```sql
DENSE_RANK() OVER (
    ORDER BY total_salary DESC
)
```

when ranking departments against each other.

---

### 6. Ranking before aggregation

Wrong thinking:

```text
RANK employees
→ calculate department total
```

Correct:

```text
GROUP BY department
→ SUM(salary)
→ RANK/DENSE_RANK
```

---

### 7. GROUP BY vs Window Function

```text
GROUP BY
→ collapses rows

Window function
→ preserves rows
```

---

### 8. Forgetting JOIN condition

Wrong:

```sql
INNER JOIN departments d
```

Correct:

```sql
INNER JOIN departments d
    ON e.department_id = d.department_id
```

**Memory:**
JOIN → immediately ask **"How are these tables related?"**

---

### 9. Wrong table for salary

```text
employees → salary
departments → department information
```

---

### 10. LEFT JOIN zero-count mistake

Use:

```sql
COUNT(e.id)
```

instead of:

```sql
COUNT(*)
```

when counting employees through a LEFT JOIN and needing zero for unmatched departments.

---

### 11. RANK vs DENSE_RANK

```text
RANK → gaps
DENSE_RANK → no gaps
```

---

### 12. Strings use single quotes

Correct:

```sql
WHERE department = 'HR'
```

Not:

```sql
WHERE department = "HR"
```

---

# Interview Decision Framework

Before writing a complex SQL query:

```text
1. What should ONE output row represent?

2. Employee or department?

3. Do I need aggregation?

4. Should individual rows remain?

5. Is the comparison overall or per group?

6. Does the subquery return one value or many?

7. Are ties required?

8. Am I ranking employees or groups?

9. Do I need to aggregate before ranking?

10. Do unmatched rows need to remain?

11. Which JOIN preserves the required rows?
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
ROW_NUMBER
RANK
DENSE_RANK
PARTITION BY
ALL
ANY
LIMIT
OFFSET
```

---

# Final Goal

> **Given an unfamiliar SQL problem, identify the required approach first and then write the query.**

The priority remains:

**HANDS-ON > THEORY**
