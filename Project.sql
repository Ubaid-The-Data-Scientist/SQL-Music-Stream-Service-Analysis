-- EASY QUESTIONS:
-- 1. Who is the senior most employee based on job title?

SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1

-- 2. Which countries have the most Invoices?

SELECT COUNT(*) AS Invoices, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY Invoices DESC

-- 3. What are top 3 values of total invoice?

SELECT total
FROM invoice
ORDER BY total DESC
LIMIT 3

-- 4. Which city has the best customers? We would like to throw a promotional Music 
-- Festival in the city we made the most money. Write a query that returns one city that 
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice 
-- totals

SELECT SUM(total) AS total_invoices, billing_city
FROM invoice
GROUP BY billing_city
ORDER BY total_invoices DESC
LIMIT 1

-- 5. Who is the best customer? The customer who has spent the most money will be 
-- declared the best customer. Write a query that returns the person who has spent the 
-- most money.

SELECT cus.customer_id, cus.first_name, cus.last_name, SUM(inv.total) AS total_spendings
FROM customer AS cus
JOIN invoice AS inv ON inv.customer_id = cus.customer_id
GROUP BY cus.customer_id
ORDER BY total_spendings DESC
LIMIT 1


-- MEDIUM QUESTIONS:
-- 1. Write query to return the email, first name, last name, & Genre of all Rock Music 
-- listeners. Return your list ordered alphabetically by email starting with A.

SELECT DISTINCT first_name, last_name, email
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON genre.genre_id = track.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email

-- 2. Let's invite the artists who have written the most rock music in our dataset. Write a 
-- query that returns the Artist name and total track count of the top 10 rock bands.

SELECT artist.artist_id, artist.name, COUNT(track_id) AS no_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
GROUP BY artist.artist_id
ORDER BY no_of_songs DESC
LIMIT 10

-- 3. Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the 
-- longest songs listed first.

SELECT name,milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS Avg_Lenght
	FROM track
)
ORDER BY milliseconds DESC


-- ADVANCED QUESTIONS
-- 1. Find how much amount spent by each customer on artists? Write a query to return
-- customer name, artist name and total spent.

WITH Artist_sales AS(
	SELECT art.artist_id, art.name, SUM(il.unit_price*il.quantity) AS Total_Sales
	FROM invoice_line AS il
	JOIN track AS tr ON tr.track_id = il.track_id
	JOIN album AS alb ON alb.album_id = tr.album_id
	JOIN artist AS art ON art.artist_id = alb.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
)
SELECT c.customer_id, c.first_name, c.last_name, sale.name, SUM(il.unit_price*il.quantity) AS Amount_spent
FROM customer AS c
JOIN invoice AS i ON i.customer_id = c.customer_id
JOIN invoice_line AS il ON il.invoice_id = i.invoice_id
JOIN track AS tr ON tr.track_id = il.track_id
JOIN album AS alb ON alb.album_id = tr.album_id
JOIN Artist_sales AS sale ON sale.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC

-- OR -- 

SELECT c.customer_id, c.first_name, c.last_name, art.name, SUM(il.unit_price*il.quantity) AS Amount_spent
FROM customer AS c
JOIN invoice AS i ON i.customer_id = c.customer_id
JOIN invoice_line AS il ON il.invoice_id = i.invoice_id
JOIN track AS tr ON tr.track_id = il.track_id
JOIN album AS alb ON alb.album_id = tr.album_id
JOIN artist AS art ON art.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC

-- 2. We want to find out the most popular music Genre for each country. We determine the 
-- most popular genre as the genre with the highest amount of purchases. Write a query 
-- that returns each country along with the top Genre. For countries where the maximum 
-- number of purchases is shared return all Genres.

WITH popular_genre AS(
	SELECT c.country, g.name AS genre, g.genre_id, COUNT(il.quantity) AS Purchases,
			ROW_NUMBER() OVER(PARTITION BY c.country
							  ORDER BY COUNT(il.quantity) DESC) AS row_no
	FROM invoice_line AS il
	JOIN invoice AS i ON i.invoice_id = il.invoice_id
	JOIN customer AS c ON c.customer_id = i.customer_id
	JOIN track AS tr ON tr.track_id = il.track_id
	JOIN genre AS g ON g.genre_id = tr.genre_id
	GROUP BY 1,2,3
	ORDER  BY 1 ASC,4 DESC
)
SELECT *
FROM popular_genre
WHERE row_no = 1

-- 3. Write a query that determines the customer that has spent the most on music for each 
-- country. Write a query that returns the country along with the top customer and how
-- much they spent. For countries where the top amount spent is shared, provide all 
-- customers who spent this amount.

WITH max_spendings AS(
	SELECT c.country, c.customer_id, c.first_name, c.last_name, SUM(total) AS Spendings,
			ROW_NUMBER() OVER(PARTITION BY c.country
							ORDER BY SUM(total) DESC) AS row_no
	FROM invoice AS i
	JOIN customer AS c ON c.customer_id = i.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 1
)
SELECT country, customer_id, first_name, last_name, Spendings
FROM max_spendings
WHERE row_no = 1