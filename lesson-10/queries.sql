DROP TABLE IF EXISTS OrderDetails;
DROP TABLE IF EXISTS Orders;
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    OrderDate DATE
);
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductName VARCHAR(100),
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);
INSERT INTO Orders VALUES 
    (1, 'Alice', '2024-03-01'),
    (2, 'Bob', '2024-03-02'),
    (3, 'Charlie', '2024-03-03');
INSERT INTO OrderDetails VALUES 
    (1, 1, 'Laptop', 1, 1000.00),
    (2, 1, 'Mouse', 2, 50.00),
    (3, 2, 'Phone', 1, 700.00),
    (4, 2, 'Charger', 1, 30.00),
    (5, 3, 'Tablet', 1, 400.00),
    (6, 3, 'Keyboard', 1, 80.00);

-- 1-solution

;WITH cte as
(
    select o.OrderID, o.CustomerName, max(od.UnitPrice) as max
    from Orders o
    join OrderDetails od
        on o.OrderID = od.OrderID
    group by o.OrderID, o.CustomerName
),
ctee as
(
    select cte.CustomerName, od.ProductName, od.Quantity, od.UnitPrice
    from cte
    join OrderDetails od
        on cte.max = od.UnitPrice
)
select * from ctee;

-- 2-solution 

select CustomerName, ProductName, Quantity, Unitprice
from (
    select o.CustomerName, od.ProductName, od.Quantity, od.UnitPrice, row_number() over(partition by o.CustomerName order by od.UnitPrice desc) as rnk
    from orders o 
    join OrderDetails od 
    on o.OrderID = od.orderid) as t1 
where rnk = 1;

-- 3-solution

select o.CustomerName, od.ProductName, od.Quantity, od.Unitprice
from OrderDetails od
join orders o on o.orderid = od.ORDERid
join 
(select o.CustomerName,o.orderid, max(od.unitprice) as mxprice
    from orders o 
    join OrderDetails od 
    on o.OrderID = od.orderid
group by customerName, o.orderid) as t2
on od.orderid = t2.orderid and od.unitprice = t2.mxprice;

-- 4-solution

select o.OrderID, o.CustomerName, od.ProductName, 
    od.UnitPrice
from Orders o
cross apply (
    select top 1 OrderID, ProductName, UnitPrice
    from OrderDetails od
    where od.OrderID = o.OrderID
    order by od.UnitPrice desc
) as od;


-- task 2

DROP TABLE IF EXISTS TestMax;

CREATE TABLE TestMax
(
    Year1 INT
    ,Max1 INT
    ,Max2 INT
    ,Max3 INT
);
INSERT INTO TestMax 
VALUES
    (2001,10,101,87)
    ,(2002,103,19,88)
    ,(2003,21,23,89)
    ,(2004,27,28,91);

select Year1,
    (
        select max(mx) 
        from 
        (
            select Max1 as mx from TestMax t1 where t1.Year1 = t.Year1
            union all 
            select Max2 from TestMax t1 where t1.Year1 = t.Year1
            union all 
            select Max3 from TestMax t1 where t1.Year1 = t.Year1
        ) as mx
    )
from TestMax t;

select Year1,
    (
        select max(val)
        from (values (max1), (max2), (max3)) as t(val)
    ) as mx
from TestMax;
