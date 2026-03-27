-- Preview Tables
SELECT * FROM users
SELECT * FROM businesses
SELECT * FROM reviews

-- Dataset Size Overview
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM businesses;
SELECT COUNT(*) FROM reviews;

-- Top 10 Businesses
SELECT name, city, stars, review_count 
FROM businesses 
ORDER BY stars DESC, review_count DESC
LIMIT 10;

-- Most Reviewed Business
-- Luke 4554
SELECT name, review_count
FROM businesses 
WHERE review_count = (
	SELECT MAX(review_count) FROM businesses
);

-- Most Active User
-- Bruce: 16567
SELECT name, review_count 
FROM users 
WHERE review_count = (
	SELECT MAX(review_count) FROM users
);

-- Average Business Rating by City
SELECT city, AVG(stars) AS avg_rating
FROM businesses 
GROUP BY city
ORDER BY avg_rating DESC;

-- Review Rating Distribution
-- 5: 22220, 4: 12721, 3: 2677, 2: 1003, 1: 5379
SELECT stars, COUNT(*) AS count 
FROM reviews 
GROUP BY stars 
ORDER BY stars DESC;

-- Business Density by City
SELECT city, COUNT(*) AS count 
FROM businesses 
GROUP BY city
ORDER BY count DESC;

-- User engagement (Reviews per User)
-- 82.35
SELECT AVG(review_count) AS avg_reviews_per_user
FROM users;


-- Review-Level Data Integration (User + Business + Review)
SELECT r.review_id, u.name AS user_name, b.name AS business_name, r.stars
FROM reviews AS r
JOIN users AS u ON r.user_id = u.user_id
JOIN businesses AS b ON r.business_id = b.business_id
LIMIT 10;

-- Business Popularity Based on Review Count (Derived from Reviews table)
-- LUKE 503
SELECT b.name AS business_name, COUNT(*) AS count
FROM businesses AS b
JOIN reviews AS r ON b.business_id = r.business_id
GROUP BY b.business_id
ORDER BY count DESC;

-- True Business Rating Based on Review table
SELECT b.name AS business_name, AVG(r.stars) AS avg_review_rating
FROM businesses AS b
JOIN reviews AS r ON b.business_id = r.business_id
GROUP BY b.business_id, b.name
ORDER BY avg_review_rating DESC
;

-- High-Quality Businesses (High Rating + High Review Volume)
-- Blues City Deli 4.87 stars, 90 reviews
SELECT b.name AS business_name, AVG(r.stars) AS avg_review_rating, COUNT(*) AS count
FROM businesses AS b
JOIN reviews AS r ON b.business_id = r.business_id
GROUP BY b.business_id
HAVING COUNT(*) > 50
ORDER BY avg_review_rating DESC, count DESC
;

-- User Rating Behavior
-- more reviews avg: 3.78
SELECT AVG(avg_review_rating)
FROM (
	SELECT user_id, AVG(stars) AS avg_review_rating, COUNT(*) AS count
	FROM reviews
	GROUP BY user_id
	ORDER BY count DESC
	LIMIT 100
)t;

-- more reviews avg: 4.03
SELECT AVG(avg_review_rating)
FROM (
	SELECT user_id, AVG(stars) AS avg_review_rating, COUNT(*) AS count
	FROM reviews
	GROUP BY user_id
	ORDER BY count
	LIMIT 100
)t;

-- Business Rating Consistency (Stored vs Actual Review Average)
-- different: 4829, similar: 3197
SELECT diff, COUNT(*)
FROM (
	SELECT b.name AS business_name, 
		AVG(r.stars) AS avg_review_rating, 
		b.stars AS business_rating,
		CASE
			WHEN ABS(b.stars - AVG(r.stars)) <= 0.5 THEN 'Similar'
			ELSE 'Different'
		END AS diff
	FROM businesses AS b
	JOIN reviews AS r ON b.business_id = r.business_id
	GROUP BY b.business_id
)
GROUP BY diff
;

-- Business Availability by State
SELECT state, 
       SUM(is_open) AS open_businesses,
       COUNT(*) AS total_businesses,
       ROUND(SUM(is_open)::decimal / COUNT(*), 2) AS open_ratio
FROM businesses
GROUP BY state
ORDER BY open_ratio DESC
;

-- Business Ranking and Performance Relative to City Average
SELECT performance_vs_city, COUNT(*) AS count
FROM (
	SELECT name, city, review_count, stars,
       RANK() OVER (ORDER BY review_count DESC) AS popularity_rank,
	   CASE
	        WHEN stars > AVG(stars) OVER (PARTITION BY city) 
	            THEN 'Above City Average'
	        WHEN stars = AVG(stars) OVER (PARTITION BY city) 
	            THEN 'Equal to City Average'
	        ELSE 'Below City Average'
	    END AS performance_vs_city
	FROM businesses
)
GROUP BY performance_vs_city
ORDER BY count DESC
;