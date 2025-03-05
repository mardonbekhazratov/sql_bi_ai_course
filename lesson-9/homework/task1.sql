DROP TABLE IF EXISTS Employees;
CREATE TABLE Employees
(
	EmployeeID  INTEGER PRIMARY KEY,
	ManagerID   INTEGER NULL,
	JobTitle    VARCHAR(100) NOT NULL
);
INSERT INTO Employees (EmployeeID, ManagerID, JobTitle) 
VALUES
	(1001, NULL, 'President'),
	(2002, 1001, 'Director'),
	(3003, 1001, 'Office Manager'),
	(4004, 2002, 'Engineer'),
	(5005, 2002, 'Engineer'),
	(6006, 2002, 'Engineer');

;WITH cte AS
(
    select *, 0 as Depth
    from employees
    where ManagerID is NULL
    union all
    select e.*, Depth + 1
    from employees e
    join cte
        on e.ManagerID = cte.EmployeeID
    
)
SELECT *
FROM cte;