## Day 07 — Window Functions

### Topics Covered

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
* Second-highest salary per department
* Practical interview problems

### Key Concepts Learned

#### 1. `OVER()`

Used to perform calculations across rows without collapsing the result into a single row.

```sql
SELECT
    name,
    salary,
    SUM(salary) OVER() AS total_salary
FROM employees;
```

#### 2. `PARTITION BY`

Divides rows into logical groups while keeping individual rows.

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

#### 3. `ROW_NUMBER()`

Assigns a unique sequential number to each row.

```sql
ROW_NUMBER() OVER(
    ORDER BY salary DESC
)
```

With `PARTITION BY`, numbering restarts for each department:

```sql
ROW_NUMBER() OVER(
    PARTITION BY department
    ORDER BY salary DESC
)
```

#### 4. `RANK()`

Assigns the same rank to tied values but leaves gaps.

```text
1, 2, 2, 4
```

#### 5. `DENSE_RANK()`

Assigns the same rank to tied values without leaving gaps.

```text
1, 2, 2, 3
```

### Important Interview Pattern — Top N Per Department

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

### Important Interview Pattern — Nth Highest Salary

Use `DENSE_RANK()` when looking for the Nth **distinct** salary:

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

### `LAG()` and `LEAD()`

```text
LAG()  → previous row
LEAD() → next row
```

Example:

```sql
LAG(salary) OVER(
    PARTITION BY department
    ORDER BY salary
)
```

### Key Interview Rule

```text
GROUP BY
→ summarizes and reduces rows

Window Function
→ analyzes related rows while preserving individual rows
```

### Day 07 Status

| Topic                              | Status |
| ---------------------------------- | ------ |
| `OVER()`                           | ✅      |
| `PARTITION BY`                     | ✅      |
| Window `ORDER BY`                  | ✅      |
| `ROW_NUMBER()`                     | ✅      |
| `RANK()`                           | ✅      |
| `DENSE_RANK()`                     | ✅      |
| `LAG()`                            | ✅      |
| `LEAD()`                           | ✅      |
| Running totals                     | ✅      |
| Top-N per department               | ✅      |
| Window-function interview patterns | ✅      |

**Day 07 completed.**

Next topic: **Day 08 — CASE, COALESCE & NULL Handling**
