
-- Lab Work 4 / Лабораторная работа 4
-- Topic: SQL Queries, Functions and Operators / Тема: SQL-запросы, функции и операторы

-- Drop old tables if exist / Удаление старых таблиц, если они существуют
DROP TABLE IF EXISTS assignments;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS employees;

-- Create table employees / Создание таблицы сотрудников
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary NUMERIC(10,2),
    hire_date DATE,
    manager_id INTEGER,
    email VARCHAR(100)
);

-- Create table projects / Создание таблицы проектов
CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    budget NUMERIC(12,2),
    start_date DATE,
    end_date DATE,
    status VARCHAR(20)
);

-- Create table assignments / Создание таблицы назначений
CREATE TABLE assignments (
    assignment_id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(employee_id),
    project_id INTEGER REFERENCES projects(project_id),
    hours_worked NUMERIC(5,1),
    assignment_date DATE
);

-- Insert data into employees / Вставка данных в таблицу сотрудников
INSERT INTO employees (first_name, last_name, department, salary, hire_date, manager_id, email) VALUES
('John', 'Smith', 'IT', 75000.00, '2020-01-15', NULL, 'john.smith@company.com'),
('Sarah', 'Johnson', 'IT', 65000.00, '2020-03-20', 1, 'sarah.j@company.com'),
('Michael', 'Brown', 'Sales', 55000.00, '2019-06-10', NULL, 'mbrown@company.com'),
('Emily', 'Davis', 'HR', 60000.00, '2021-02-01', NULL, 'emily.davis@company.com'),
('Robert', 'Wilson', 'IT', 70000.00, '2020-08-15', 1, NULL),
('Lisa', 'Anderson', 'Sales', 58000.00, '2021-05-20', 3, 'lisa.a@company.com');

-- Insert data into projects / Вставка данных в таблицу проектов
INSERT INTO projects (project_name, budget, start_date, end_date, status) VALUES
('Website Redesign', 150000.00, '2024-01-01', '2024-06-30', 'Active'),
('CRM Implementation', 200000.00, '2024-02-15', '2024-12-31', 'Active'),
('Marketing Campaign', 80000.00, '2024-03-01', '2024-05-31', 'Completed'),
('Database Migration', 120000.00, '2024-01-10', NULL, 'Active');

-- Insert data into assignments / Вставка данных в таблицу назначений
INSERT INTO assignments (employee_id, project_id, hours_worked, assignment_date) VALUES
(1, 1, 120.5, '2024-01-15'),
(2, 1, 95.0, '2024-01-20'),
(1, 4, 80.0, '2024-02-01'),
(3, 3, 60.0, '2024-03-05'),
(5, 2, 110.0, '2024-02-20'),
(6, 3, 75.5, '2024-03-10');

-- Part 1: Basic SELECT Queries / Часть 1: Основные SELECT-запросы
SELECT employee_id, first_name || ' ' || last_name AS full_name, department, salary
FROM employees
ORDER BY employee_id;

SELECT DISTINCT department FROM employees ORDER BY department;

SELECT project_id, project_name, budget,
    CASE
        WHEN budget > 150000 THEN 'Large'
        WHEN budget BETWEEN 100000 AND 150000 THEN 'Medium'
        ELSE 'Small'
    END AS budget_category
FROM projects
ORDER BY project_id;

SELECT employee_id, first_name || ' ' || last_name AS full_name,
       COALESCE(email, 'No email provided') AS email
FROM employees
ORDER BY employee_id;

-- Part 2: WHERE Clause and Comparison Operators / Часть 2: WHERE и операторы сравнения
SELECT employee_id, first_name || ' ' || last_name AS full_name, hire_date
FROM employees
WHERE hire_date > '2020-01-01'
ORDER BY hire_date;

SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
FROM employees
WHERE salary BETWEEN 60000 AND 70000
ORDER BY salary DESC;

SELECT employee_id, first_name || ' ' || last_name AS full_name, last_name
FROM employees
WHERE last_name LIKE 'S%' OR last_name LIKE 'J%'
ORDER BY last_name;

SELECT employee_id, first_name || ' ' || last_name AS full_name, manager_id, department
FROM employees
WHERE manager_id IS NOT NULL AND department = 'IT'
ORDER BY employee_id;

-- Part 3: String and Math Functions / Часть 3: Строковые и математические функции
SELECT employee_id,
       UPPER(first_name || ' ' || last_name) AS full_name_upper,
       LENGTH(last_name) AS last_name_length,
       SUBSTRING(email FROM 1 FOR 3) AS email_first3
FROM employees
ORDER BY employee_id;

SELECT employee_id, first_name || ' ' || last_name AS full_name,
       salary AS annual_salary,
       ROUND(salary / 12.0, 2) AS monthly_salary,
       ROUND(salary * 0.10, 2) AS raise_10_percent
FROM employees
ORDER BY employee_id;

SELECT project_id,
       format('Project: %s - Budget: $%s - Status: %s',
              project_name,
              to_char(budget, 'FM999,999,990.00'),
              status) AS project_summary
FROM projects
ORDER BY project_id;

SELECT employee_id, first_name || ' ' || last_name AS full_name,
       DATE_PART('year', AGE(current_date, hire_date))::INT AS years_with_company
FROM employees
ORDER BY years_with_company DESC, employee_id;

-- Part 4: Aggregate Functions and GROUP BY / Часть 4: Агрегатные функции и GROUP BY
SELECT department, ROUND(AVG(salary),2) AS avg_salary
FROM employees
GROUP BY department
ORDER BY department;

SELECT p.project_id, p.project_name, ROUND(SUM(a.hours_worked),1) AS total_hours
FROM projects p
LEFT JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_id, p.project_name
ORDER BY total_hours DESC NULLS LAST;

SELECT department, COUNT(*) AS num_employees
FROM employees
GROUP BY department
HAVING COUNT(*) > 1
ORDER BY num_employees DESC;

SELECT MAX(salary) AS max_salary, MIN(salary) AS min_salary, SUM(salary) AS total_payroll
FROM employees;

-- Part 5: Set Operations / Часть 5: Операции с множествами
SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
FROM employees
WHERE salary > 65000

UNION

SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
FROM employees
WHERE hire_date > '2020-01-01'
ORDER BY full_name;

SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
FROM employees
WHERE department = 'IT'

INTERSECT

SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
FROM employees
WHERE salary > 65000
ORDER BY full_name;

SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
FROM employees

EXCEPT

SELECT DISTINCT e.employee_id, e.first_name || ' ' || e.last_name AS full_name, e.salary
FROM employees e
JOIN assignments a ON e.employee_id = a.employee_id
ORDER BY full_name;

-- Part 6: Subqueries / Часть 6: Подзапросы
SELECT e.employee_id, e.first_name || ' ' || e.last_name AS full_name
FROM employees e
WHERE EXISTS (SELECT 1 FROM assignments a WHERE a.employee_id = e.employee_id)
ORDER BY e.employee_id;

SELECT DISTINCT e.employee_id, e.first_name || ' ' || e.last_name AS full_name
FROM employees e
JOIN assignments a ON e.employee_id = a.employee_id
WHERE a.project_id IN (SELECT project_id FROM projects WHERE status = 'Active')
ORDER BY full_name;

SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
FROM employees
WHERE salary > ANY (SELECT salary FROM employees WHERE department = 'Sales')
ORDER BY salary DESC;

-- Part 7: Complex Queries / Часть 7: Сложные запросы
WITH emp AS (
    SELECT employee_id, first_name || ' ' || last_name AS full_name, department, salary
    FROM employees
),
avg_hours AS (
    SELECT employee_id, ROUND(AVG(hours_worked),1) AS avg_hours
    FROM assignments
    GROUP BY employee_id
)
SELECT emp.employee_id, emp.full_name, emp.department, COALESCE(avg_hours.avg_hours, 0) AS avg_hours,
       RANK() OVER (PARTITION BY emp.department ORDER BY emp.salary DESC) AS dept_salary_rank
FROM emp
LEFT JOIN avg_hours ON emp.employee_id = avg_hours.employee_id
ORDER BY emp.department, dept_salary_rank;

SELECT p.project_id, p.project_name,
       ROUND(SUM(a.hours_worked),1) AS total_hours,
       COUNT(DISTINCT a.employee_id) AS num_employees
FROM projects p
JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_id, p.project_name
HAVING SUM(a.hours_worked) > 150
ORDER BY total_hours DESC;

SELECT e.department,
       COUNT(*) AS total_employees,
       ROUND(AVG(e.salary),2) AS avg_salary,
       (SELECT first_name || ' ' || last_name
        FROM employees e2
        WHERE e2.department = e.department
        ORDER BY e2.salary DESC
        LIMIT 1) AS highest_paid_employee,
       GREATEST(MAX(e.salary), AVG(e.salary)) AS greatest_between_max_and_avg,
       LEAST(MIN(e.salary), AVG(e.salary)) AS least_between_min_and_avg
FROM employees e
GROUP BY e.department
ORDER BY total_employees DESC;
