drop table if exists items;
go

create table items
(
	ID						varchar(10),
	CurrentQuantity			int,
	QuantityChange   		int,
	ChangeType				varchar(10),
	Change_datetime			datetime
);
go

insert into items values
    ('A0013', 278,   99 ,   'out', '2020-05-25 0:25'), 
    ('A0012', 377,   31 ,   'in',  '2020-05-24 22:00'),
    ('A0011', 346,   1  ,   'out', '2020-05-24 15:01'),
    ('A0010', 347,   1  ,   'out', '2020-05-23 5:00'),
    ('A009',  348,   102,   'in',  '2020-04-25 18:00'),
    ('A008',  246,   43 ,   'in',  '2020-04-25 2:00'),
    ('A007',  203,   2  ,   'out', '2020-02-25 9:00'),
    ('A006',  205,   129,   'out', '2020-02-18 7:00'),
    ('A005',  334,   1  ,   'out', '2020-02-18 6:00'),
    ('A004',  335,   27 ,   'out', '2020-01-29 5:00'),
    ('A003',  362,   120,   'in',  '2019-12-31 2:00'),
    ('A002',  242,   8  ,   'out', '2019-05-22 0:50'),
    ('A001',  250,   250,   'in',  '2019-05-20 0:45');


-- select * from items;/

declare @lastday datetime = (select top 1 change_datetime from items order by Change_datetime desc);
declare @in table (
    quantity int,
    date datetime,
    rnk int
);
declare @out table (
    quantity int,
    date datetime,
    rnk int
);


insert into @in
select QuantityChange, Change_datetime, row_number() over(order by change_datetime desc)
from items
where ChangeType = 'in';

insert into @out
select QuantityChange, Change_datetime, row_number() over(order by change_datetime asc)
from items
where ChangeType = 'out';

-- select * from @temp;
declare @i int = (select max(rnk) from @in);
declare @j int = 0;
declare @numOut int = (select count(*) from items where ChangeType = 'out');

while @j < @numOut
begin
    set @j = @j + 1;

    declare @cnt int = (select quantity from @out where rnk = @j);
    
    while @cnt > (select quantity from @in where rnk = @i)
    begin

        set @cnt = @cnt - (select quantity from @in where rnk = @i);

        update @in
        set quantity = 0
        where rnk = @i;

        set @i = @i - 1;

    end

    update @in
    set quantity = quantity - @cnt
    where rnk = @i;
end

delete from @in
where quantity = 0;

set @i = 0;

create table #ans(
    starting int,
    ending int,
    count int
)

declare @last int = 0;

while @i < (select count(*) from @in)
begin
    set @i = @i + 1;

    declare @diff int = datediff(day, (select date from @in where rnk = @i), @lastday) + 1;

    while @last < @diff
    begin
        insert into #ans
        values (@last + 1, @last + 90, 0);
        set @last = @last + 90;
    end

    update #ans
    set count = count + (select quantity from @in where rnk = @i)
    where starting <= @diff and ending >= @diff;

end;

declare @query nvarchar(max);

select @query = concat(@query, 
    case when row_number() over(order by (select null)) <> 1 then ',' end,
    '[', starting, '-', ending, ' days old]')
from #ans

set @query = concat(
    'select *
    from (select concat(starting, ''-'', ending, '' days old'') as interval, count from #ans) t
    pivot
    (
        max(count) for interval in (', @query, ')
    ) pvt;'
)

exec sp_executesql @query;