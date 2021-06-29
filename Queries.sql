/*Query 1 used for first insight - Slide 1*/

WITH top10 AS (SELECT country.country,
	   	      COUNT(r.rental_id) rentals
                      FROM country
                      JOIN city
                        ON country.country_id = city.country_id
                      JOIN address a
                        ON city.city_id = a.city_id
                      JOIN customer
                        ON a.address_id = customer.address_id
                      JOIN rental r
                        ON customer.customer_id = r.customer_id
                     GROUP BY 1
                     ORDER BY 2 DESC
                     LIMIT 10),

    rentaldates AS (SELECT DATE_PART('year',rental_date) rental_year,
                           DATE_PART('month',rental_date) rental_month,
                           country,
                           COUNT(r.rental_id) rentals
                      FROM country
                      JOIN city
                        ON country.country_id = city.country_id
                      JOIN address a
                        ON city.city_id = a.city_id
                      JOIN customer
                        ON a.address_id = customer.address_id
                      JOIN rental r
                        ON customer.customer_id = r.customer_id
                    GROUP BY 1,2,3)
        
SELECT CONCAT(rentaldates.rental_month, ' ', rentaldates.rental_year) AS date,
              top10.country,
              rentaldates.rentals
  FROM top10
  JOIN rentaldates
	ON top10.country = rentaldates.country
 GROUP BY 1, 2, 3
 ORDER BY 1,2,3;

/*Query 2 used for second insight. I didn't use the pay_countpermonth in the graph, as to not show too much information at once.
Displaying a data table at the bottom of the chart would also have been useful to see the exact sums spent per person and per month, however this was not the main objective of the graph so I chose not to display it. */

WITH top10 AS (SELECT c.customer_id,
                      CONCAT(first_name,' ',last_name) fullname,
                      SUM(amount)
                 FROM customer c
                 JOIN payment p
                   ON c.customer_id=p.customer_id
                GROUP BY 1,2
                ORDER BY 3 DESC
                LIMIT 10)
       
SELECT DATE_TRUNC('month',p.payment_date) pay_month,
       top10.fullname,
       COUNT(p.payment_id) AS pay_countpermonth,
       SUM(p.amount) pay_amount
  FROM top10
  JOIN customer c
    ON c.customer_id = top10.customer_id
  JOIN payment p
    ON c.customer_id = p.customer_id
 GROUP BY 1,2
 ORDER BY 2;

/*Query 3 used for third insight - slide 3*/

WITH t1 AS (SELECT f.title film_title, 
                   c.name category_name, 
                   COUNT(r.rental_id) rentals, 
                   ROW_NUMBER() OVER(PARTITION BY c.name
                                ORDER BY COUNT(r.rental_id) DESC) AS rank
              FROM film f
              JOIN film_category fc
                ON f.film_id = fc.film_id
              JOIN category c
                ON c.category_id = fc.category_id
              JOIN inventory i
                ON f.film_id = i.film_id 
              JOIN rental r
                ON i.inventory_id = r.inventory_id
            GROUP BY 1,2)

SELECT CONCAT(t1.category_name, ' - ', t1.film_title) categ_movietitle,
       CASE WHEN t1.category_name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music') THEN 'family_movie' ELSE 'other_public' END AS public,
       t1.rentals
  FROM t1
 WHERE t1.rank = 1
 ORDER BY 3 DESC
 ORDER BY 2 DESC;

/*Query 4 used for fourth insight*/
SELECT city.city,
	   country,
       SUM(p.amount) paid
  FROM city
  JOIN country
    ON country.country_id = city.country_id
  JOIN address a
    ON city.city_id = a.city_id
  JOIN customer
    ON a.address_id = customer.address_id
  JOIN payment p
    ON customer.customer_id = p.customer_id
 GROUP BY 1,2
HAVING country.country = 'France'
 ORDER BY 3 DESC;