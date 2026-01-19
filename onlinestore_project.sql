create table Books
(Book_id INT PRIMARY KEY,
Title VARCHAR(100),
Author VARCHAR(100),
Genre VARCHAR(50),
Published_year INT,
Price DECIMAL(10,2),
Stock INT);
show create table books;
select * from books;

create table Customers
(Customer_id INT PRIMARY KEY,
Name VARCHAR(100),
Email VARCHAR(100),
Phone VARCHAR (15),
City VARCHAR(50),
Country VARCHAR(150)
);
SHOW create table customers;
select * from customers;

Create table Orders
(Order_id INT PRIMARY KEY,
Customer_id INT REFERENCES Customers(customer_id),
Book_id INT REFERENCES Books(Book_id),
Order_date DATE,
Quantity INT,
Total_Amount DECIMAL(10,2)
);
show create table orders;
select * from orders;

-- 1) Retrieve all books in the 'fiction' genre:
select * from books
where genre = 'fiction';

-- 2) Find books published after the year 1950:-
select * from books
where published_year >1950;

-- 3) List all customers from the canada:-
select * from customers
where country= 'Canada';

-- 4)Show orders placed in November 2023:--
select * from orders
where order_date between '2023-11-01' and '2023-11-30';

-- 5) Retrieve the total stock of books available:-
select sum(stock) as total_stock from books;

-- 6) Find the details of most expensive books:-
select * from books order by price desc limit 1;

-- 7) Show all customers who ordered more than 1 quantity of a book
select * from orders where quantity >1;

-- 8) Retrieve all orders where the total amount exceeds $20:-
select * from orders where Total_Amount>20;

-- 9) List all genres available in books table:-
select distinct genre from books;

-- 10) Find the book with the lowest stock:-
select * from books order by stock limit 1;

-- 11) Calculate the total revenue generated from all the orders:-
select sum(total_amount) as Revenue from orders;

-- Advanced Queries--
-- 1) Retrieve the total number of books sold for each genre:-
select b.genre,
sum(o.quantity) as total_books_sold
from orders o
join books b on o.book_id= b.book_id
group by b.genre;

-- 2)Find the average price of books in the 'fantasy' genre:--
select avg(price) as avg_price from books
where genre= 'fantasy';

-- 3) List customers who have placed at least 2 orders:-
select customer_id,
count(order_id) as total_count
from orders 
group by customer_id
having count(order_id)>=2;

-- With name column--(Additional query)
select c.name,
o.customer_id,
count(o.order_id) as order_count
from orders o
join customers c on o.customer_id= c.customer_id
group by o.customer_id,c.name
having count(o.order_id)>=2;

-- 4) Find the most frequently ordered book:-
select book_id,
count(order_id) as most_ordered
from orders
group by book_id
order by most_ordered desc limit 1;

-- with book title name-(Additional query)
select o.book_id,
b.title,
count(o.order_id) as most_ordered 
from orders o
join books b on o.book_id= b.book_id
group by o.book_id,b.title
order by most_ordered desc limit 1;

-- 5) Show the top 3 most expensive books of fantasy genre:-
select book_id,title,price from books 
where genre= 'fantasy'
order by price desc limit 3;

-- for each genre--(Additional query)
SELECT genre ,MAX(price) AS most_expensive
FROM books
group by genre;

-- 6) Retrieve the total quantity of books sold by each author:--
select b.author,
sum(o.quantity)as total_books
from orders o
join books b on o.book_id= b.book_id
group by b.author;

-- 7) List the cities where customers who spent over $30 are located:-
select distinct c.city,
o.total_amount
from orders o
join customers c on o.Customer_id= c.Customer_id
where Total_Amount> 30;

-- 8) Find the customers who spent the most on orders:--
select c.customer_id,
c.name,
sum(o.total_amount) as total_spent
from orders o
join customers c on o.Customer_id=c.Customer_id
group by c.customer_id,c.name
order by total_spent desc limit 1;

-- 9) Calculate the stock remaining after fullfilling all orders:-

select b.book_id,b.title,b.stock,
coalesce(sum(o.quantity),0) as order_quantity ,
b.stock- coalesce(sum(o.quantity),0) as remaining_quantity
from books b 
left join orders o on b.Book_id= o.Book_id
group by book_id;
































































































