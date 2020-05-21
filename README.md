# Overview

This is the first project of the Udacity "Programming for Data Science with R" Nanodegree. Here SQL is used to explore a relational database related to movie rentals. The project asks to produce four question of interest about the data in the database, answer the question using a SQL query, and create a supporting visualization with the query output.

# Investigate a Relational Database

In this project we use [Sakila DVD Rental database](https://www.postgresqltutorial.com/postgresql-sample-database/). The Sakila Database holds fictional information about a company that rents movie DVDs. This relational database contains 15 tables, as shown in the ER diagram below.

[!Im](dvd-rental-sample-database-diagram.png)

The following questions where explored:

```
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
```

