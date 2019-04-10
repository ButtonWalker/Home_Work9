-- Use the Sakila DataBase for all work
USE sakila;
SELECT * FROM actor; 

-- Display First and Last Name for all Actors
SELECT first_name, last_name FROM actor;

-- Display First and Last Name in Single Column all Caps Name colmn Actor Name
SELECT CONCAT((UPPER(first_name)),' ',(UPPER(last_name))) as Actor_Name FROM actor;
-- SELECT CONCAT(UPPER(SUBSTRING(last_name, 1,1)), LOWER(SUBSTRING(last_name FROM 2))) as Actor_Name FROM actor;
-- SELECT CONCAT(UPPER(SUBSTRING(first_name, 1,1)), LOWER(SUBSTRING(first_name FROM 2))) as Actor_Name FROM actor;

-- Find ID number, First and Last Name with first name Joe
SELECT actor_id, first_name, last_name FROM actor WHERE first_name='Joe';

-- All actors whose last name contains GEN
SELECT first_name, last_name FROM actor WHERE last_name REGEXP 'GEN';

-- Actors with last name contains LI Order by Last Name then First Name
SELECT first_name, last_name FROM actor WHERE last_name REGEXP 'LI' ORDER BY last_name;

-- Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT * FROM country;
SELECT country_id, country from country WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- so create a column in the table actor named description and use the data type BLOB:
ALTER TABLE actor ADD COLUMN description blob;
SELECT * FROM actor;

-- Delete the description column.
ALTER TABLE actor DROP COLUMN description;
SELECT * FROM actor;

-- List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS total_count FROM actor GROUP BY last_name;

-- List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS total_count FROM actor GROUP BY last_name HAVING COUNT(last_name) >=2;

-- The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
SELECT first_name, last_name FROM actor WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
UPDATE actor SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
SELECT first_name, last_name FROM actor WHERE last_name = 'WILLIAMS';

-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
SET SQL_SAFE_UPDATES = 0;
UPDATE actor SET first_name = IF(first_name = 'HARPO','GROUCHO', first_name ) WHERE first_name = 'HARPO';
SELECT first_name, last_name FROM actor WHERE last_name = 'WILLIAMS';
SET SQL_SAFE_UPDATES = 1;

-- You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT * FROM staff;
SELECT * FROM address;
SELECT s.first_name, s.last_name, a.address 
	FROM staff s 
	INNER JOIN address a 
	ON s.address_id = a.address_id
;

-- Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT * FROM staff;
SELECT * FROM payment;
SELECT s.first_name, s.last_name, SUM(p.amount) as total_payment
	FROM staff s 
	INNER JOIN payment p 
	ON s.staff_id = p.staff_id
	WHERE p.payment_date REGEXP '^([2005]{2,4})-([0-1][8])-([0-3][0-9])'
	GROUP BY s.staff_id
;

-- List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join on film_id
SELECT * FROM film_actor;
SELECT * FROM film;
SELECT f.title, COUNT(fa.actor_id) as Actor_Count 
	FROM film f 
	INNER JOIN film_actor fa 
	ON f.film_id = fa.film_id 
	GROUP BY f.title
;

-- How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT * FROM inventory;
SELECT f.title, COUNT(i.film_id) as inventory_count 
	FROM film f 
	INNER JOIN inventory i 
	ON f.film_id = i.film_id
    WHERE f.title REGEXP '^Hunc'
	GROUP BY f.film_id 	
;

-- Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT * FROM customer;
SELECT * FROM payment;
SELECT c.first_name, c.last_name, SUM(p.amount) as total_payment 
	FROM customer c
	JOIN payment p 
	ON c.customer_id = p.customer_id 
	GROUP BY c.customer_id 
	ORDER BY c.last_name
;

-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT * FROM film;
SELECT * FROM language;
SELECT title 
	FROM film 
	WHERE language_id 
	IN (SELECT language_id FROM language WHERE name = 'English') 
	AND title 
	REGEXP '^(Q|K)'
;

-- Use subqueries to display all actors who appear in the film Alone Trip.
SELECT * FROM actor;
SELECT first_name, last_name 
	FROM actor 
    WHERE actor_id 
		IN (SELECT actor_id 
			FROM film_actor WHERE film_id 
		IN (SELECT film_id 
			FROM film WHERE title = 'Alone Trip'))
;

-- You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT * FROM customer;
SELECT * FROM address;
SELECT * FROM country;
SELECT * FROM city;
SELECT c.first_name, c.last_name, c.email 
	FROM customer c 
	INNER JOIN address a 
	ON c.address_id = a.address_id 
		INNER JOIN city ct 
		ON a.city_id = ct.city_id
			INNER JOIN country co
            ON co.country_id = ct.country_id
			WHERE co.country = 'Canada' 
			GROUP BY c.first_name, c.last_name, c.email
;

-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT * FROM film;
SELECT * FROM film_category;
SELECT * FROM category;
SELECT title 
FROM film 
WHERE film_id IN 
	(SELECT film_id 
    FROM film_category 
    WHERE category_id 
    IN 
		(SELECT category_id 
        FROM category 
        WHERE name = 'Family'))
;

-- Display the most frequently rented movies in descending order.
SELECT * FROM film;
SELECT * FROM rental;
SELECT * FROM inventory;
SELECT title, COUNT(r.rental_id) 
FROM film f 
	INNER JOIN inventory i 
	ON f.film_id = i.film_id 
		INNER JOIN rental r 
		ON i.inventory_id = r.inventory_id 
		GROUP BY title 
		ORDER BY COUNT(r.rental_id) DESC
;

-- Write a query to display how much business, in dollars, each store brought in.
SELECT * FROM payment;
SELECT * FROM store;
SELECT * FROM rental;
SELECT * FROM inventory;
SELECT s.store_id, SUM(p.amount) AS Total 
FROM payment p 
	INNER JOIN rental r ON p.rental_id = r.rental_id 
		INNER JOIN inventory i ON i.inventory_id = r.inventory_id 
			INNER JOIN store s ON s.store_id = i.store_id 
				GROUP BY s.store_id
;

-- Write a query to display for each store its store ID, city, and country.
SELECT * FROM store;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;
SELECT s.store_id, c.city, co.country 
FROM store s 
	INNER JOIN address a 
	ON s.address_id = a.address_id 
		INNER JOIN city c 
		ON c.city_id = a.city_id 
			INNER JOIN country co
			ON co.country_id = c.country_id
;

-- List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT * FROM category;
SELECT * FROM film_category;
SELECT * FROM inventory;
SELECT * FROM payment;
SELECT * FROM rental;
SELECT c.name, SUM(p.amount) AS Gross 
FROM category c 
	INNER JOIN film_category fc 
    ON c.category_id = fc.category_id 
		INNER JOIN inventory i
        ON fc.film_id = i.film_id
			INNER JOIN rental r
			ON i.inventory_id = r.inventory_id 
				INNER JOIN payment p 
				ON r.rental_id = p.rental_id 
					GROUP BY c.name 
						ORDER BY Gross 
							LIMIT 5
;

-- In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top5_revenue AS
SELECT c.name, SUM(p.amount) AS Gross 
FROM category c 
	INNER JOIN film_category fc 
    ON c.category_id = fc.category_id 
		INNER JOIN inventory i
        ON fc.film_id = i.film_id
			INNER JOIN rental r
			ON i.inventory_id = r.inventory_id 
				INNER JOIN payment p 
				ON r.rental_id = p.rental_id 
					GROUP BY c.name 
						ORDER BY Gross 
							LIMIT 5
;
-- How would you display the view that you created in 8a?
SELECT * FROM top5_revenue;

-- You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top5_revenue;