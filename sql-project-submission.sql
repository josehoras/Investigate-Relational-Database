/* QUESTION 1 */
/* What is the weekly revenue increase regarding the previous week 
on rentals in 2005? */
/* Join, Aggregations, CTE, Window Functions*/

WITH rev_per_week AS (SELECT DATE_TRUNC('week', r.rental_date) AS date, 
				            SUM(p.amount) AS revenue
			            FROM rental r
			            JOIN payment p
			            ON r.rental_id = p.rental_id
			            GROUP BY 1
			            ORDER BY 1)
SELECT DATE_PART('week', date) AS calender_week,
	    revenue, 
	    revenue - LAG(revenue) OVER(ORDER BY date) AS weekly_rev_increase
FROM rev_per_week
WHERE DATE_PART('year', date) = 2005


/* QUESTION 2 */
/* Who are the ten customers that more frequently exceeded the rental period? */
/* Join, Aggregations, CTE*/

WITH late_fees AS (SELECT c.first_name || ' ' || c.last_name AS customer,
			            p.amount - f.rental_rate AS late_fee
		            FROM film f
		            JOIN inventory i
		            ON f.film_id = i.film_id
		            JOIN rental r
		            ON i.inventory_id = r.inventory_id
		            JOIN payment p 
		            ON r.rental_id = p.rental_id
		            JOIN customer c
		            ON p.customer_id = c.customer_id)
SELECT customer AS Customer, COUNT(*) AS Number_of_Delays
FROM late_fees
WHERE late_fee > 0
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10


/* QUESTION 3 */
/* What are the film categories in the top quartile by total revenue? */
/* Join, Aggregations, CTE, Window Functions*/

WITH sub AS (SELECT c.name AS category , SUM(p.amount) AS revenue
		    FROM payment p 
		    JOIN rental r 
		    ON r.rental_id = p.rental_id
		    JOIN inventory i
		    ON i.inventory_id = r.inventory_id
		    JOIN film f
		    ON f.film_id = i.film_id
		    JOIN film_category fc
		    ON fc.film_id = f.film_id
		    JOIN category c
		    ON c.category_id = fc.category_id
		    GROUP BY 1),
	table1 AS (SELECT category, revenue,
			            NTILE(4) OVER (ORDER BY revenue) AS quartile
		        FROM sub
		)
SELECT *
FROM table1
WHERE quartile = 4
ORDER BY 2 DESC

/* QUESTION 4 */
/* For the 5 top and bottom customers, what is the average rental rate? */
/* Joins, Aggregations, CTEs*/

WITH rev_per_customer AS (SELECT c.first_name || ' ' || c.last_name AS customer,
				                SUM(p.amount), AVG(f.rental_rate)
			                FROM payment p
			                JOIN customer c
			                ON c.customer_id = p.customer_id
			                JOIN rental r
			                ON c.customer_id = r.customer_id
			                JOIN inventory i
			                ON r.inventory_id = i.inventory_id
			                JOIN film f
			                ON i.film_id = f.film_id
			                GROUP BY 1),
	top_customers AS (SELECT *
			            FROM rev_per_customer
			            ORDER BY 2 DESC
			            LIMIT 5),
	bottom_customers AS (SELECT *
			            FROM rev_per_customer
			            ORDER BY 2 
			            LIMIT 5)
SELECT *
FROM bottom_customers t
UNION
SELECT *
FROM top_customers t
ORDER BY 2 DESC

