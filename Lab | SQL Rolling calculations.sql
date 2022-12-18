use sakila;

-- 1 Get number of monthly active customers.

select * from rental;

select rental_date as month, count(customer_id) from rental
group by rental_date;

-- this subquery below is the result

select left(rental_date, 7) month, count(customer_id) monthly_active_c from rental
group by left(rental_date, 7);

select extract(month from'2022-05-15 00:00'); -- was just a try from internet

-- 2 Active users in the previous month.

-- this one from my hands but not too clean

select right(left(rental_date, 7),2), count(customer_id) from rental
where right(left(rental_date, 7),2) = 11
group by right(left(rental_date, 7),2);

-- this one from internet that I improved a bit seems better

select rental_date, count(customer_id) from rental
where rental_date > now() - interval 1 month
group by rental_date;

-- 3 Percentage change in the number of active customers.

select * from rental;

-- Step 1 get the month and active customer

create view sakila.customer_activity as
	select left(rental_date, 7) month, count(customer_id) monthly_active_c from rental
	group by left(rental_date, 7);

select * from customer_activity;

-- Step 2 putting the lag

create or replace view sakila.percentage_increase as
	select month,monthly_active_c, lag(monthly_active_c) over() as previous_month from sakila.customer_activity;
    
select * from percentage_increase;

-- step 3 get the percentage

select month, monthly_active_c, previous_month,
(((monthly_active_c - previous_month) / previous_month) * 100)
from percentage_increase;

-- 4 Retained customers every month. (nb client restés le mois suivant)

-- step 1

create or replace view rental_id_month as
	select rental_id , left(rental_date, 7) month,customer_id as nb_customer_id from rental
    group by rental_id, rental_date;

select * from rental_id_month;

-- step 2 putting the lag

create or replace view add_lag as
	select rental_id, month, nb_customer_id, lag(nb_customer_id) over () as month_after from rental_id_month
    group by rental_id;

select * from add_lag;

-- step 3 FINAL

create or replace view nb_customers_retained as
	select rental_id, month, nb_customer_id, IF(month_after >= nb_customer_id, month_after - nb_customer_id, - (nb_customer_id - month_after)) as difference from add_lag;

select * from nb_customers_retained;

