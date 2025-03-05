with fibonacci(Fibonacci_number, Prev) as 
(
    select 1, 0
    union ALL
    select Fibonacci_number + Prev, Fibonacci_number
    from fibonacci
    where Fibonacci_number + Prev < 101
)
select Fibonacci_number from fibonacci;

