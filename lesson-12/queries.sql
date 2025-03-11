ALTER proc generate_numbers @upto int
as
begin
	declare @num int = 0;
	declare @numbers table (num int);

	while @num <= @upto
	begin
		insert into @numbers
		select @num;

		set @num = @num + 1;

	end;

	select num from @numbers;
end;

exec generate_numbers 20;

drop table if exists emp;
create table emp(
	id int,
	name varchar(50)
);

insert into emp
values 
	(1, 'name1'),
	(4, 'name4'),
	(7, 'name7'),
	(11, 'name11'),
	(19, 'name19')

declare @t table (
    num int
);

insert into @t
exec generate_numbers 20;

select num
from @t
left join emp
    on id = num
where id is null;


go

alter proc sp_select_all @table_name varchar(255), @top_k int = NULL
as
begin

	declare @cmd varchar(max) = 'select';

	if @top_k is NULL
	BEGIN
		set @cmd = concat(@cmd, ' * FROM ', @table_name);
	END
	else
	begin
		set @cmd  = concat(@cmd, ' TOP ', @top_k, ' * FROM ', @table_name);
	end
	exec(@cmd);

end;

exec sp_select_all 'emp';

GO


-- declare @name varchar(255);
-- declare @i int = 1;
-- declare @count int;
-- select @count = count(1)
-- from sys.databases-- where name not in ('master', 'tempdb', 'model', 'msdb')


-- while @i < @count
-- begin
-- 	;with cte as (
-- 		select name, ROW_NUMBER() OVER(order BY name) as rn
-- 		from sys.databases --where name not in ('master', 'tempdb', 'model', 'msdb')
-- 	)
-- 	select @name=name from cte
-- 	where rn = @i;

-- 	declare @cmd varchar(max) = 'select 
-- 		TABLE_CATALOG as DatabaseName,
-- 		TABLE_SCHEMA as SchemaName,
-- 		TABLE_NAME as TableName,
-- 		COLUMN_NAME as ColumnName,
-- 		concat(
-- 			DATA_TYPE,\'(\'+ 
-- 				case when cast(CHARACTER_MAXIMUM_LENGTH as varchar) = \'-1\'
-- 				then \'max\'
-- 				else cast(CHARACTER_MAXIMUM_LENGTH as varchar) end
-- 			+\')\'
-- 		) as DataType
-- 	from ';
-- 	print @cmd;
-- 	-- set @cmd = concat(@cmd, @name, '.INFORMATION_SCHEMA.COLUMNS;');
-- 	-- exec(@cmd);

-- 	set @i = @i + 1;

-- end