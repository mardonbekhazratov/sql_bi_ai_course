;WITH factorial(Num, Factorial) as 
(
    select 1, 1
    union all
    select Num + 1, Factorial * (Num + 1)
    from factorial
    where Num < 10
)
select * from factorial;