DROP TABLE IF EXISTS [dbo].[EMPLOYEES_N];

CREATE TABLE [dbo].[EMPLOYEES_N]
(
    [EMPLOYEE_ID] [int] NOT NULL,
    [FIRST_NAME] [varchar](20) NULL,
    [HIRE_DATE] [date] NOT NULL
)

INSERT INTO [dbo].[EMPLOYEES_N]
VALUES
	(1001,'Pawan','1975-02-21'),
	(1002,'Ramesh','1976-02-21'),
	(1003,'Avtaar','1977-02-21'),
	(1004,'Marank','1979-02-21'),
	(1008,'Ganesh','1979-02-21'),
	(1007,'Prem','1980-02-21'),
	(1016,'Qaue','1975-02-21'),
	(1155,'Rahil','1975-02-21'),
	(1102,'Suresh','1975-02-21'),
	(1103,'Tisha','1975-02-21'),
	(1104,'Umesh','1972-02-21'),
	(1024,'Veeru','1975-02-21'),
	(1207,'Wahim','1974-02-21'),
	(1046,'Xhera','1980-02-21'),
	(1025,'Wasil','1975-02-21'),
	(1052,'Xerra','1982-02-21'),
	(1073,'Yash','1983-02-21'),
	(1084,'Zahar','1984-02-21'),
	(1094,'Queen','1985-02-21'),
	(1027,'Ernst','1980-02-21'),
	(1116,'Ashish','1990-02-21'),
	(1225,'Bushan','1997-02-21');

SELECT 
	* 
FROM
(
	SELECT
		CONCAT(LAG(max_hire_year) OVER(order by min_hire_year) + 1, '-', min_hire_year - 1) as Years
	FROM
	(
		SELECT
			MIN(hire_year) as min_hire_year,
			MAX(hire_year) as max_hire_year
		FROM
		(
			SELECT
				hire_year,
				hire_year - ROW_NUMBER() OVER(ORDER BY hire_year) as groupID
			FROM
			(
				SELECT
					DISTINCT YEAR(HIRE_DATE) as hire_year
				FROM EMPLOYEES_N
				WHERE YEAR(HIRE_DATE) >= 1975
				UNION ALL
				SELECT YEAR(GETDATE()) + 1
			) as t
		) as t
		GROUP BY groupID
	) as t
) as t
WHERE Years <> '-1974';