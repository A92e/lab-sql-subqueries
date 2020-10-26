-- Lab | SQL Subqueries

use sakila;



-- 1- How many copies of the film Hunchback Impossible exist in the inventory system?


select f.film_id,title, count(i.film_id) from film f
join inventory i
on f.film_id=i.film_id
where title='Hunchback Impossible';


select film_id, count(film_id) as num_inv from inventory
where film_id in (select film_id from film where title='Hunchback Impossible');











-- 2- List all films longer than the average.



select film_id,title,length from film 
where length > (select round(avg(length),2) as avg_length from film)
order by film_id;








-- 3- Use subqueries to display all actors who appear in the film Alone Trip.


select actor_id,film_id from film_actor

where film_id in ( select film.film_id from film where title='Alone Trip');






-- 4- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

select film_id,category_id from film_category
where category_id in ( select category_id from category where name='family');








--  5- Get name and email from customers from Canada using subqueries. Do the same with joins.

select customer_id,first_name,last_name,email from customer
where address_id in ( select address_id from address 
where city_id in (select city_id from city 
where country_id in (select country_id from country where country='Canada'))) ;


select * from film_actor;


--  6-Which are films starred by the most prolific actor?
/*
select actor_id, film_id,count(film_id) as num_films from film_actor
group by actor_id 
order by num_films desc;



select actor_id,max(num_films) from (select actor_id, film_id,count(film_id) as num_films from film_actor
group by actor_id ) sub1;




select film_id,actor_id   from film_actor
where actor_id in (

select max(num_films) as maxf from (
select actor_id, film_id,count(film_id) as num_films from film_actor
group by actor_id ) as sub1);




select film_id,actor_id,count(film_id)  from film_actor
where (select count(film_id)  from film_actor)  in (
select max(num_films) from (
select actor_id, film_id,count(film_id) as num_films from film_actor
 group by actor_id
) as sub1);




select film_id,actor_id,  count(film_id) as num_films, dense_rank() over (partition by film_id order by count(film_id) desc ) as 'rank' from film_actor
group by actor_id
order by count(film_id) desc
limit 1;

select actor_id,  dense_rank() over (partition by film_id order by count(film_id) desc ) as 'rank' from film_actor
group by actor_id
order by count(film_id) desc
limit 1;



select film_id,actor_id  from film_actor
where actor_id in (
select actor_id from(
select actor_id,max(num_films) from (
select actor_id, film_id,count(film_id) as num_films from film_actor
 group by actor_id
) as sub1)as sub2);

*/

-- The solution --------------------------



select actor_id,  dense_rank() over (partition by film_id order by count(film_id) desc ) as 'rank' from film_actor
group by actor_id
order by count(film_id) desc
limit 1;




select film_id,actor_id  from film_actor
where actor_id  in (
select actor_id from(
select actor_id,  dense_rank() over (partition by film_id order by count(film_id) desc ) as 'rank' from film_actor
group by actor_id
order by count(film_id) desc
limit 1
) as sub2);










select actor_id
from sakila.actor
inner join sakila.film_actor
using (actor_id)
inner join sakila.film
using (film_id)
group by actor_id
order by count(film_id) desc
limit 1;

-- now get the films starred by the most prolific actor
select concat(first_name, ' ', last_name) as actor_name, film.title, film.release_year
from sakila.actor
inner join sakila.film_actor
using (actor_id)
inner join film
using (film_id)
where actor_id = (
  select actor_id
  from sakila.actor
  inner join sakila.film_actor
  using (actor_id)
  inner join sakila.film
  using (film_id)
  group by actor_id
  order by count(film_id) desc
  limit 1
)
order by release_year desc;







--  7- Films rented by most profitable customer.


---- solution

-- 1-
select customer_id,max(total_money) from (select customer_id,sum(amount) as total_money from payment
group by customer_id ) sub1;

select customer_id, sum(amount), dense_rank() over (order by sum(amount) desc ) as 'rank' from payment
group by customer_id
order by amount desc;

select film_id, title  from film
where film_id in (
select film_id from inventory
where inventory_id in (select inventory_id from rental
where customer_id in ( select customer_id from(
select customer_id from( 
select customer_id,  dense_rank() over (order by sum(amount) desc ) as 'rank' from payment
group by customer_id
order by amount desc
limit 1) s1) s2)));


-- 2- 

select customer_id
from sakila.ustomer
inner join payment using (customer_id)
group by customer_id
order by sum(amount) desc
limit 1;

-- films rented by most profitable customer
select film_id, title, rental_date, amount
from sakila.film
inner join inventory using (film_id)
inner join rental using (inventory_id)
inner join payment using (rental_id)
where rental.customer_id = (
  select customer_id
  from customer
  inner join payment
  using (customer_id)
  group by customer_id
  order by sum(amount) desc
  limit 1
)
order by rental_date desc;





-- ------------------------------------
/*


select title from film 
where film_id in (
select film_id from inventory 
where inventory_id in (
select inventory_id from rental
 where customer_id in (
select customer_id from (
select customer_id , sum(amount) as money_spent , row_number() over (order by sum(amount) desc) as 'rank'from payment
group by customer_id
limit 1) as sub1));




select film_id,payment.customer_id from inventory
join rental
on inventory.inventory_id=rental.inventory_id
join payment 
on rental.rental_id=payment.rental_id 
where payment.customer_id in (
select payment.customer_id from(
select payment.customer_id,  dense_rank() over (order by amount desc ) as 'rank' from film_actor
group by payment.customer_id
order by amount desc
limit 1) s1) s2)));


select customer_id,amount from payment
group by customer_id
order by amount desc;


select film_id,payment.customer_id, payment.amount from inventory
join rental
on inventory.inventory_id=rental.inventory_id
join payment 
on rental.rental_id=payment.rental_id 
where payment.customer_id in (select payment.customer_id  from (
select  payment.customer_id,max(amount) from (
select payment.customer_id, amount from film_actor
 group by payment.customer_id) s2) s1)
 group by film_id ;


*/



--  8- Customers who spent more than the average.


-- 1-
select customer_id , sum(amount) as money from payment
group by customer_id
having sum(amount) > (select avg(money) from (select customer_id , sum(amount) as money
 from payment group by customer_id) as sub1);


-- 2-

select customer_id, sum(amount) as payment
from sakila.customer
inner join payment using (customer_id)
group by customer_id
having sum(amount) > (
  select avg(total_payment)
  from (
    select customer_id, sum(amount) total_payment
    from payment
    group by customer_id
  ) t
)
order by payment desc;





















