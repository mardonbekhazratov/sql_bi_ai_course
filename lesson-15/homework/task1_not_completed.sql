
drop procedure if exists getProperties;
go

create procedure getProperties @rank INT
AS
BEGIN

    declare @query nvarchar(MAX) = '';
    declare @numOfColumns int;

    -- Get the number of valid columns
    with columns as (
        select name, 
               ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rnk
        from sys.columns 
        where object_id = OBJECT_ID('Contacts') 
              AND name NOT IN ('identifier_name', 'identifier_value')
    )
    select @numOfColumns = MAX(rnk) from columns;

    -- Build the UNPIVOT column list
    with columns as (
        select name, 
               ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rnk
        from sys.columns 
        where object_id = OBJECT_ID('Contacts') 
              AND name NOT IN ('identifier_name', 'identifier_value')
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
        FROM unpivoted
        WHERE (rnk - 1) / ', @numOfColumns, ' + 1 = ', @rank
    );

    -- Execute the dynamic query
    declare @temp table (
        col varchar(50), val varchar(50), rnk int
    );

    insert into @temp
    exec sp_executesql @query;

    declare @ans varchar(max);
    select @ans = concat(@ans, case when rnk > 1 then ',' end,
    '
    {
        "property" : "', col, 
        '",
        "value" : "', val,
    '"
    }') from @temp;
    select @ans as name;
END;

GO

declare @properties table(
    name varchar(max)
)

insert into @properties
exec getProperties @rank = 10;



declare @ans varchar(max) = '[';



select @ans = concat(@ans, case when ROW_NUMBER() over(order by (select null)) > 1 then ',' end,
    '
    {
        "', 
        identifier_name, '" : "', identifier_value, 
    '", 
        "properties": [',
    '
    ]')
from Contacts;

select @ans;
