-- Part A
-- 1
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS projects;

CREATE TABLE employees (
	emp_id serial PRIMARY KEY,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	department VARCHAR(50),
	salary INT,
	hire_date DATE,
	status VARCHAR(50) DEFAULT 'Active'
);

CREATE TABLE departments (
	dept_id serial PRIMARY KEY,
	dept_name VARCHAR(50),
	budget INT,
	manager_id INT
);

CREATE TABLE projects (
	project_id serial PRIMARY KEY,
	project_name VARCHAR(50),
	dept_id INT,
	start_date DATE,
	end_date DATE,
	budget INT
);

-- Part B
-- 2
INSERT INTO employees (first_name, last_name, department)
VALUES ('Yeskendir', 'Abdrakhman', 'Backend developing');

-- 3
INSERT INTO employees (salary, status)
VALUES (DEFAULT, DEFAULT);

-- 4
INSERT INTO departments (dept_name, budget, manager_id)
VALUES 
('Backend developing', 0, NULL),
('Cyber security', 0, NULL),
('IT', 0, NULL);

-- 5
INSERT INTO employees (first_name, last_name, salary, hire_date)
VALUES ('Alua', 'Amanbek', 50000 * 1.1, CURRENT_DATE);

-- 6
CREATE TEMP TABLE temp_employees AS
SELECT * FROM employees WHERE department = 'IT';

-- Part C
-- 7
UPDATE employees
SET salary = salary * 1.1;

-- 8
UPDATE employees
SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';

-- 9
UPDATE employees
SET department = CASE
	WHEN salary > 80000 THEN 'Management'
	WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
	ELSE 'Junior'
END;

-- 10
UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

-- 11
UPDATE departments d
SET budget = (
	SELECT AVG(e.salary) * 1.2
	FROM employees e
	WHERE e.department = d.dept_name
);

-- 12
UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

-- Part D
-- 13
DELETE FROM employees
WHERE status = 'Terminated';

-- 14
DELETE FROM employees
WHERE salary < 40000 AND hire_date > '2023-01-01' AND department IS NULL;

-- 15
DELETE FROM departments
WHERE dept_name NOT IN (
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);

-- 16
DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

-- Part E
-- 17
INSERT INTO employees (first_name, last_name, salary, department, hire_date)
VALUES ('Null', 'Employee', NULL, NULL, CURRENT_DATE);

-- 18
UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

-- 19
DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;

-- Part F
-- 20
INSERT INTO employees (first_name, last_name, salary, department, hire_date)
VALUES ('Emily', 'Stone', 55000, 'HR', CURRENT_DATE)
RETURNING emp_id, first_name || ' ' || last_name AS full_name;

-- 21
UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, (salary - 5000) AS old_salary, salary AS new_salary;

-- 22
DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

-- Part G
-- 23
INSERT INTO employees (first_name, last_name, salary, department, hire_date)
SELECT 'Anna', 'Ivanova', 60000, 'Finance', CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM employees 
    WHERE first_name = 'Anna' AND last_name = 'Ivanova'
);

-- 24
UPDATE employees e
SET salary = salary *
    (CASE
        WHEN (SELECT budget FROM departments d WHERE d.dept_name = e.department) > 100000 
        THEN 1.10
        ELSE 1.05
     END);

-- 25
INSERT INTO employees (first_name, last_name, salary, department, hire_date)
VALUES
('Mark', 'Smith', 40000, 'Sales', CURRENT_DATE),
('Sara', 'Brown', 42000, 'Sales', CURRENT_DATE),
('Tom', 'Davis', 43000, 'Sales', CURRENT_DATE),
('Linda', 'Wilson', 44000, 'Sales', CURRENT_DATE),
('Jack', 'Taylor', 45000, 'Sales', CURRENT_DATE);

UPDATE employees
SET salary = salary * 1.10
WHERE department = 'Sales' AND hire_date = CURRENT_DATE;

-- 26
CREATE TABLE IF NOT EXISTS employee_archive AS
SELECT * FROM employees WHERE 1=0;

INSERT INTO employee_archive
SELECT * FROM employees WHERE status = 'Inactive';

DELETE FROM employees WHERE status = 'Inactive';

-- 27
UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000
  AND (
      SELECT COUNT(*) 
      FROM employees e 
      WHERE e.department = (
          SELECT dept_name FROM departments d WHERE d.dept_id = p.dept_id
      )
  ) > 3;
