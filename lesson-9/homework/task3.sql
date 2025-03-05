with fibonacci(n, Fibonacci_number, Prev) as 
(
    select 1, 1, 0
    union ALL
    select n + 1, Fibonacci_number + Prev, Fibonacci_number
    from fibonacci
    where n < 10
)
select n, Fibonacci_number from fibonacci;

