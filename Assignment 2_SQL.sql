-- Retrieve the distinct salaries from the Employees table.
SELECT DISTINCT salary
FROM Employees;

-- Display employee age and salary using the aliases
SELECT
    age AS Employee_Age,
    salary AS Employee_Salary
FROM Employees;

-- Retrieve employees whose salary is greater than 50000 and who were hired before 2016-01-01.
SELECT * FROM Employees
WHERE salary > 50000
AND hire_date < '2016-01-01';

-- Find employees whose designation is missing and update the missing designation to 'Data Scientist'.
UPDATE employee.Employees
SET designation = 'Data Scientist'
WHERE employee_id = 5004;

SELECT employee_name, designation
FROM Employees
WHERE employee_id = 5004;

-- Display employees sorted by department ID in ascending order and salary in descending order.
SELECT * FROM Employees
ORDER BY department_id ASC, salary DESC;

-- Display the first 5 employees hired in 2018.
SELECT * FROM Employees
WHERE YEAR(hire_date) = 2018
ORDER BY hire_date ASC
LIMIT 5;

-- Find the total salary of employees in the Finance department.
SELECT SUM(e.salary) AS Total_Finance_Salary
FROM Employees e
JOIN Departments d
ON e.department_id = d.department_id
WHERE d.department_name = 'Finance';

-- Find the minimum age among all employees.
SELECT MIN(age) AS Minimum_Age
FROM Employees;

-- Find the maximum salary for each location.
SELECT
    l.location, MAX(e.salary) AS Maximum_Salary
FROM Employees e
JOIN Location l
ON e.location_id = l.location_id
GROUP BY l.location;

-- Find the average salary for each designation containing the word 'Analyst'
SELECT designation, AVG(salary) AS Average_Salary
FROM Employees
WHERE designation LIKE '%Analyst%'
GROUP BY designation;

-- Display departments with fewer than 3 employees.
SELECT d.department_name, COUNT(e.employee_id) AS Employee_Count
FROM Departments d
LEFT JOIN Employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(e.employee_id) < 3;

-- Display locations with female employees whose average age is below 30.
SELECT l.location, AVG(e.age) AS Average_Age
FROM Employees e
JOIN Location l ON e.location_id = l.location_id
WHERE e.gender = 'F'
GROUP BY l.location_id, l.location
HAVING AVG(e.age) < 30;

-- Display employee names, designations, and department names for employees assigned to a department.
SELECT e.employee_name, e.designation, d.department_name
FROM Employees e
INNER JOIN Departments d
ON e.department_id = d.department_id;

-- Display all departments and their total employee count.
SELECT d.department_name, COUNT(e.employee_id) AS Total_Employees
FROM Departments d
LEFT JOIN Employees e
ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name;

-- Display all locations and the names of employees assigned to them.
SELECT l.location, e.employee_name
FROM Employees e
RIGHT JOIN Location l
ON e.location_id = l.location_id;