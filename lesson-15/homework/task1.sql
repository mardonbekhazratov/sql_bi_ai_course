DROP TABLE IF EXISTS Contacts;
CREATE TABLE Contacts
(
	identifier_name NVARCHAR(50),
	identifier_value NVARCHAR(255),
	firstname NVARCHAR(255),
	lastname NVARCHAR(255),
	website NVARCHAR(255),
	company NVARCHAR(255),
	phone NVARCHAR(255),
	address NVARCHAR(255),
	city NVARCHAR(255),
	state NVARCHAR(255),
	zip NVARCHAR(255),
);

INSERT INTO Contacts(identifier_name, identifier_value, firstname, lastname, website, company, phone, address, city, state, zip)
VALUES 
	('vid', '259429', 'Harper', 'Wolfberg', 'http://hubspot.com', 'HubSpot', '555-122-2323', '25 First Street', 'Cambridge', 'MA', '02139'),
	('email', 'testingapis@hubspot.com', 'Codey', 'Huang', 'http://hubspot.com', 'HubSpot', '555-122-2323', '25 First Street', 'Cambridge', 'MA', '02139'),
    ('email', 'john.doe@example.com', 'John', 'Doe', 'http://example.org', 'Example Inc', '555-345-6789', '456 Oak St', 'Boston', 'MA', '02110'),
    ('email', 'alice.wonderland@fable.com', 'Alice', 'Wonderland', 'http://fable.com', 'Fable Enterprises', '555-987-6543', '102 Rabbit Hole', 'Wonderland', 'CA', '90210'),
	('vid', '543210', 'Ava', 'Smith', 'http://example.com', 'Example Corp', '555-233-4545', '123 Maple Ave', 'Springfield', 'IL', '62701'),
    ('vid', '987654', 'Jane', 'Roe', 'http://company.net', 'Company LLC', '555-678-1234', '789 Pine Rd', 'New York', 'NY', '10001'),
    ('email', 'emily.brown@company.com', 'Emily', 'Brown', 'http://company.com', 'Company Ltd', '555-222-3333', '88 Blueberry Lane', 'Austin', 'TX', '73301'),
    ('vid', '321987', 'Robert', 'Johnson', 'http://robertj.com', 'RJ Consulting', '555-111-2222', '22 Lincoln Way', 'Columbus', 'OH', '43215'),
    ('vid', '654321', 'Michael', 'Davis', 'http://davistech.com', 'Davis Technologies', '555-444-5555', '99 Tech Park', 'Seattle', 'WA', '98109'),
    ('email', 'oliver.queen@starcity.com', 'Oliver', 'Queen', 'http://starcity.com', 'Star City Industries', '555-777-8888', '567 Arrow St', 'Star City', 'CA', '94016');

-- select * from Contacts;



GO

declare @ans varchar(max) = '[';
declare @i int = 0;
declare @numberOfContacts int = (select max(rnk) from (select *, row_number() over(order by (select null)) as rnk from Contacts) t);
declare @numOfColumns int = (select count(*)
        from INFORMATION_SCHEMA.COLUMNS 
        where TABLE_NAME = 'Contacts'
                AND column_name NOT IN ('identifier_name', 'identifier_value')
    );

declare @query nvarchar(MAX) = '';

-- Build the UNPIVOT column list
with columns as (
    select column_name as name, 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rnk
    from INFORMATION_SCHEMA.COLUMNS 
    where TABLE_NAME = 'Contacts'
        AND column_name NOT IN ('identifier_name', 'identifier_value')
)
select @query = CONCAT(@query, CASE WHEN rnk > 1 THEN ', ' ELSE '' END, name)
from columns;

-- Construct the UNPIVOT query with a CTE
set @query = CONCAT('
    WITH unpivoted AS (
        SELECT col, val, 
                ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rnk
        FROM Contacts 
        UNPIVOT (val FOR col IN (', @query, ')) AS unpvt
    )
    SELECT col, val, row_number() over(order by (select null)) as rnk
    FROM unpivoted'
);

-- Execute the dynamic query
declare @columns table (
    col varchar(50), val varchar(50), rnk int
);

insert into @columns
exec sp_executesql @query;

while @i < @numberOfContacts
BEGIN

    set @i = @i + 1;

    select @ans = concat(@ans, case when @i <> 1 then ',' end);
    
    -- Add identifier
    with cte as(
        select *, 
            row_number() over(order by (select null)) as rnk 
        from Contacts
    )
    select @ans = concat(@ans, 
        case when ROW_NUMBER() over(order by (select null)) > 1 then ', ' end,
        '
    {
        "', identifier_name, '" : "', identifier_value, 
        '", 
        "properties": ['
    ) from cte
    where @i = rnk;


    select @ans = concat(@ans, case when rnk % @numOfColumns <> 1 then ',' end,
    '
            {
                "property" : "', col, 
                '",
                "value" : "', val,
                '"
            }') from @columns
    where (rnk - 1) / @numOfColumns + 1 = @i;

    select @ans = concat(@ans, 
        '
        ]
    }')

END;

select @ans = concat(@ans, ']')

select @ans;