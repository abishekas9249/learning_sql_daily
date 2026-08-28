# Day 02 — Aggregate Functions

## Topics Covered

- COUNT()
- SUM()
- AVG()
- MIN()
- MAX()
- Aggregate functions with WHERE
- Column aliases using AS
- Introduction to subqueries

## Key Concepts

COUNT() → number of rows/non-NULL values

SUM() → total value

AVG() → average value

MIN() → minimum value

MAX() → maximum value

WHERE filters rows before aggregation.

## Interview Takeaways

- Use COUNT(*) when counting rows.
- Use WHERE to filter rows before applying aggregate functions.
- AS can be used to give meaningful names to calculated columns.
- Aggregate functions can be combined in a single SELECT.
- A subquery can calculate a value that is then used by the outer query.

## Important Pattern

Find employees earning more than the overall average:

SELECT *
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);

## Mistakes

Q6, Q7 and Q9 initially used `role`
instead of the table's `department` column.

The SQL logic was correct; the schema column name needed correction.

## Result

9.5/10

## Next Topic

Day 03 — GROUP BY and HAVING