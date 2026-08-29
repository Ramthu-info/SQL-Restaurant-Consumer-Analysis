
CREATE DATABASE IF NOT EXISTS restaurant_db;

USE restaurant_db;

CREATE TABLE consumers (
    Consumer_ID VARCHAR(10) PRIMARY KEY,
    City VARCHAR(255),
    State VARCHAR(255),
    Country VARCHAR(255),
    Latitude DECIMAL(10, 7),
    Longitude DECIMAL(10, 7),
    Smoker VARCHAR(10),
    Drink_Level VARCHAR(50),
    Transportation_Method VARCHAR(50),
    Marital_Status VARCHAR(50),
    Children VARCHAR(50),
    Age INT,
    Occupation VARCHAR(50),
    Budget VARCHAR(20)
);

-- ========================================================
-- TABLE 2: RESTAURANTS
-- ========================================================
CREATE TABLE restaurants (
    Restaurant_ID INT PRIMARY KEY,
    Name VARCHAR(255),
    City VARCHAR(255),
    State VARCHAR(255),
    Country VARCHAR(255),
    Zip_Code VARCHAR(20),
    Latitude DECIMAL(10, 8),
    Longitude DECIMAL(11, 8),
    Alcohol_Service VARCHAR(50),
    Smoking_Allowed VARCHAR(10),
    Price VARCHAR(20),
    Franchise VARCHAR(5),
    Area VARCHAR(50),
    Parking VARCHAR(50)
);

-- ========================================================
-- TABLE 3: CONSUMER_PREFERENCES
-- ========================================================
CREATE TABLE consumer_preferences (
    Consumer_ID VARCHAR(10),
    Preferred_Cuisine VARCHAR(255),
    FOREIGN KEY (Consumer_ID) REFERENCES consumers(Consumer_ID) ON DELETE CASCADE,
    INDEX idx_consumer (Consumer_ID),
    INDEX idx_cuisine (Preferred_Cuisine)
);

-- ========================================================
-- TABLE 4: RESTAURANT_CUISINES
-- ========================================================
CREATE TABLE restaurant_cuisines (
    Restaurant_ID INT,
    Cuisine VARCHAR(255),
    FOREIGN KEY (Restaurant_ID) REFERENCES restaurants(Restaurant_ID) ON DELETE CASCADE,
    INDEX idx_restaurant (Restaurant_ID),
    INDEX idx_cuisine (Cuisine)
);

-- ========================================================
-- TABLE 5: RATINGS
-- ========================================================
CREATE TABLE ratings (
    Consumer_ID VARCHAR(10),
    Restaurant_ID INT,
    Overall_Rating INT,
    Food_Rating INT,
    Service_Rating INT,
    FOREIGN KEY (Consumer_ID) REFERENCES consumers(Consumer_ID) ON DELETE CASCADE,
    FOREIGN KEY (Restaurant_ID) REFERENCES restaurants(Restaurant_ID) ON DELETE CASCADE,
    INDEX idx_consumer (Consumer_ID),
    INDEX idx_restaurant (Restaurant_ID),
    INDEX idx_overall_rating (Overall_Rating)
);

-- ========================================================
-- VERIFICATION
-- ========================================================
SHOW TABLES;

select * from consumers;
SELECT * FROM RATINGS;
SELECT * FROM CONSUMER_PREFERENCES;
SELECT * FROM RESTAURANT_CUISINES;
SELECT * FROM RESTAURANTS;

desc consumers;

-- List all details of consumers who live in the city of 'Cuernavaca'.
Select * 
from consumers
where city = 'Cuernavaca';

-- Find the Consumer_ID, Age, and Occupation of all consumers who are 'Students' AND are'Smokers'. 

select Consumer_ID, Age,Smoker
from consumers
where Occupation = 'Student'AND Smoker = 'Yes';

-- List the Name, City, Alcohol_Service, and 
-- Price of all restaurants that serve 'Wine & Beer' and have a 'Medium' price level.
select * from restaurants;

select Name,city,Alcohol_Service,Price from restaurants
where Price = 'Medium' AND Alcohol_Service = 'Wine & Beer';

-- Find the names and cities of all restaurants that are part of a 'Franchise'
select * from restaurants;
select name,city 
from restaurants 
where Franchise = "yes";

/*Show the Consumer_ID, Restaurant_ID, and Overall_Rating for all ratings where the
Overall_Rating was 'Highly Satisfactory' (which corresponds to a value of 2, according to the
data dictionary).*/
select * from ratings;
select Consumer_ID, Restaurant_ID,Overall_Rating 
from ratings
where Overall_Rating = 2;

-- ======================================================
-- Questions JOINs with Subqueries
-- ======================================================

/* 1. List the names and cities of all restaurants that have an Overall_Rating of 2 (Highly
Satisfactory) from at least one consumer. */

select e.Name,e.city,r.Overall_Rating from restaurants e
join ratings r
on r.Restaurant_ID = e.Restaurant_ID
where r.Overall_Rating = 2;

-- QUESTION 2: Find Consumer_ID and Age of consumers who rated restaurants in 'San Luis Potosi'
SELECT DISTINCT c.Consumer_ID, c.Age
FROM consumers c
INNER JOIN ratings r ON c.Consumer_ID = r.Consumer_ID
INNER JOIN restaurants res ON r.Restaurant_ID = res.Restaurant_ID
WHERE res.City = 'San Luis Potosi';

-- QUESTION 3: List restaurant names that serve 'Mexican' cuisine AND rated by consumer 'U1001'
SELECT DISTINCT res.Name
FROM restaurants res
INNER JOIN restaurant_cuisines rc ON res.Restaurant_ID = rc.Restaurant_ID
INNER JOIN ratings r ON res.Restaurant_ID = r.Restaurant_ID
WHERE rc.Cuisine = 'Mexican' 
  AND r.Consumer_ID = 'U1001';

-- QUESTION 4: Find all details of consumers who prefer 'American' cuisine AND have 'Medium' budget
SELECT DISTINCT c.*
FROM consumers c
INNER JOIN consumer_preferences cp ON c.Consumer_ID = cp.Consumer_ID
WHERE cp.Preferred_Cuisine = 'American' 
  AND c.Budget = 'Medium';

-- QUESTION 5: List restaurants (Name, City) with Food_Rating lower than average Food_Rating
SELECT DISTINCT res.Name, res.City
FROM restaurants res
INNER JOIN ratings r ON res.Restaurant_ID = r.Restaurant_ID
WHERE r.Food_Rating < (
    SELECT AVG(Food_Rating)
    FROM ratings
);

-- QUESTION 6: Find consumers (Consumer_ID, Age, Occupation) who rated at least one restaurant BUT NOT Italian
-- Step 1: Get all consumers who have rated at least one restaurant
-- Step 2: Remove any consumer who has rated an Italian restaurant
-- Step 3: Show Consumer_ID, Age, Occupation

SELECT DISTINCT c.Consumer_ID, c.Age, c.Occupation
FROM consumers c
INNER JOIN ratings r ON c.Consumer_ID = r.Consumer_ID
WHERE c.Consumer_ID NOT IN (
    -- This finds all Consumer_IDs who HAVE rated Italian restaurants
    SELECT r.Consumer_ID
    FROM ratings r
    INNER JOIN restaurant_cuisines rc ON r.Restaurant_ID = rc.Restaurant_ID
    WHERE rc.Cuisine = 'Italian'
);

-- QUESTION 7: List restaurant Names that received ratings from consumers older than 30
SELECT DISTINCT res.Name
FROM restaurants res
INNER JOIN ratings r ON res.Restaurant_ID = r.Restaurant_ID
INNER JOIN consumers c ON r.Consumer_ID = c.Consumer_ID
WHERE c.Age > 30;

-- QUESTION 8: Find Consumer_ID and Occupation of consumers preferring 'Mexican' who gave Overall_Rating = 0
SELECT DISTINCT c.Consumer_ID, c.Occupation
FROM consumers c
INNER JOIN consumer_preferences cp ON c.Consumer_ID = cp.Consumer_ID
WHERE cp.Preferred_Cuisine = 'Mexican'
  AND c.Consumer_ID IN (
      -- Find all Consumer_IDs who gave a rating of 0
      SELECT r.Consumer_ID
      FROM ratings r
      WHERE r.Overall_Rating = 0
  );
-- QUESTION 9: List Names and Cities of 'Pizzeria' restaurants in cities with at least one 'Student' consumer
SELECT DISTINCT res.Name, res.City
FROM restaurants res
INNER JOIN restaurant_cuisines rc ON res.Restaurant_ID = rc.Restaurant_ID
WHERE rc.Cuisine = 'Pizzeria'
  AND res.City IN (
      SELECT DISTINCT City
      FROM consumers
      WHERE Occupation = 'Student'
  );

-- QUESTION 10: Find Consumer_ID and Age of 'Social Drinkers' who rated restaurants with 'No' parking
SELECT DISTINCT c.Consumer_ID, c.Age
FROM consumers c
INNER JOIN ratings r ON c.Consumer_ID = r.Consumer_ID
INNER JOIN restaurants res ON r.Restaurant_ID = res.Restaurant_ID
WHERE c.Drink_Level = 'Social Drinker'
  AND res.Parking = 'No';

-- =====================================================================
-- SECTION 2: WHERE CLAUSE & ORDER OF EXECUTION 

-- QUESTION 1: List Consumer_IDs and count of restaurants rated for 'Student' consumers who rated > 2 restaurants
SELECT c.Consumer_ID, COUNT(r.Restaurant_ID) AS restaurants_rated
FROM consumers c
INNER JOIN ratings r ON c.Consumer_ID = r.Consumer_ID
WHERE c.Occupation = 'Student'
GROUP BY c.Consumer_ID
HAVING COUNT(r.Restaurant_ID) > 2;

-- QUESTION 2: List Consumer_ID, Age, Engagement_Score for 'Public' transport users with Engagement_Score = 2
SELECT c.Consumer_ID, c.Age, (c.Age DIV 10) AS Engagement_Score
FROM consumers c
WHERE c.Transportation_Method = 'Public'
  AND (c.Age DIV 10) = 2;

-- QUESTION 3: List restaurant Name, City, avg Overall_Rating in 'Cuernavaca' with avg > 1.0
SELECT res.Name, res.City, AVG(r.Overall_Rating) AS avg_overall_rating
FROM restaurants res
INNER JOIN ratings r ON res.Restaurant_ID = r.Restaurant_ID
WHERE res.City = 'Cuernavaca'
GROUP BY res.Restaurant_ID, res.Name, res.City
HAVING AVG(r.Overall_Rating) > 1.0;

-- QUESTION 4: Find Consumer_ID, Age of 'Married' consumers where Food_Rating = Service_Rating (with Overall_Rating = 2)
SELECT DISTINCT c.Consumer_ID, c.Age
FROM consumers c
INNER JOIN ratings r ON c.Consumer_ID = r.Consumer_ID
WHERE c.Marital_Status = 'Married'
  AND r.Food_Rating = r.Service_Rating
  AND r.Overall_Rating = 2;

-- QUESTION 5: List Consumer_ID, Age, restaurant Name for 'Employed' consumers with Food_Rating = 0 in 'Ciudad Victoria'
SELECT c.Consumer_ID, c.Age, res.Name
FROM consumers c
INNER JOIN ratings r ON c.Consumer_ID = r.Consumer_ID
INNER JOIN restaurants res ON r.Restaurant_ID = res.Restaurant_ID
WHERE c.Occupation = 'Employed'
  AND r.Food_Rating = 0
  AND res.City = 'Ciudad Victoria';

-- =====================================================================
-- SECTION 3: ADVANCED SQL CONCEPTS (Questions 1-12)

-- QUESTION 1: CTE to find consumers in 'San Luis Potosi' who rated Mexican restaurants with Overall_Rating = 2
WITH SLP_Consumers AS (
    SELECT DISTINCT c.Consumer_ID, c.Age
    FROM consumers c
    WHERE c.City = 'San Luis Potosi'
)
SELECT sc.Consumer_ID, sc.Age, res.Name
FROM SLP_Consumers sc
INNER JOIN ratings r ON sc.Consumer_ID = r.Consumer_ID
INNER JOIN restaurants res ON r.Restaurant_ID = res.Restaurant_ID
INNER JOIN restaurant_cuisines rc ON res.Restaurant_ID = rc.Restaurant_ID
WHERE rc.Cuisine = 'Mexican'
  AND r.Overall_Rating = 2;

-- QUESTION 2: For each Occupation, find average age of consumers who have rated (using Derived Table)
SELECT dt.Occupation, AVG(dt.Age) AS avg_age
FROM (
    SELECT DISTINCT c.Consumer_ID, c.Occupation, c.Age
    FROM consumers c
    INNER JOIN ratings r ON c.Consumer_ID = r.Consumer_ID
) AS dt
GROUP BY dt.Occupation;

-- QUESTION 3: CTE for Cuernavaca ratings ranked by Overall_Rating within each restaurant
WITH Cuernavaca_Ratings AS (
    SELECT r.Restaurant_ID, r.Consumer_ID, r.Overall_Rating
    FROM ratings r
    INNER JOIN restaurants res ON r.Restaurant_ID = res.Restaurant_ID
    WHERE res.City = 'Cuernavaca'
)
SELECT 
    Restaurant_ID, 
    Consumer_ID, 
    Overall_Rating,
    ROW_NUMBER() OVER (PARTITION BY Restaurant_ID ORDER BY Overall_Rating DESC) AS RatingRank
FROM Cuernavaca_Ratings;

-- QUESTION 4: Show each rating with average Overall_Rating for that consumer
SELECT 
    r.Consumer_ID, 
    r.Restaurant_ID, 
    r.Overall_Rating,
    AVG(r.Overall_Rating) OVER (PARTITION BY r.Consumer_ID) AS consumer_avg_rating
FROM ratings r;

-- QUESTION 5: CTE for 'Student' consumers with 'Low' budget, top 3 preferred cuisines
WITH Low_Budget_Students AS (
    SELECT Consumer_ID
    FROM consumers
    WHERE Occupation = 'Student' AND Budget = 'Low'
),
Ranked_Preferences AS (
    SELECT 
        lbs.Consumer_ID, 
        cp.Preferred_Cuisine,
        ROW_NUMBER() OVER (PARTITION BY lbs.Consumer_ID ORDER BY cp.Consumer_ID, cp.Preferred_Cuisine) AS pref_rank
    FROM Low_Budget_Students lbs
    INNER JOIN consumer_preferences cp ON lbs.Consumer_ID = cp.Consumer_ID
)
SELECT Consumer_ID, Preferred_Cuisine
FROM Ranked_Preferences
WHERE pref_rank <= 3;

-- QUESTION 6: Consumer 'U1008' ratings with next restaurant rated (Derived Table + Window Function)
SELECT 
    Restaurant_ID, 
    Overall_Rating,
    LEAD(Overall_Rating) OVER (ORDER BY Restaurant_ID) AS next_restaurant_rating
FROM (
    SELECT Restaurant_ID, Overall_Rating
    FROM ratings
    WHERE Consumer_ID = 'U1008'
    ORDER BY Restaurant_ID
) AS u1008_ratings;

-- QUESTION 7: CREATE VIEW for highly-rated Mexican restaurants (avg rating > 1.5)
CREATE VIEW HighlyRatedMexicanRestaurants AS
SELECT 
    res.Restaurant_ID, 
    res.Name, 
    res.City,
    AVG(r.Overall_Rating) AS avg_overall_rating
FROM restaurants res
INNER JOIN restaurant_cuisines rc ON res.Restaurant_ID = rc.Restaurant_ID
INNER JOIN ratings r ON res.Restaurant_ID = r.Restaurant_ID
WHERE rc.Cuisine = 'Mexican'
GROUP BY res.Restaurant_ID, res.Name, res.City
HAVING AVG(r.Overall_Rating) > 1.5;

-- QUESTION 8: Use view from Q7 to find Mexican-preferring consumers who haven't rated those restaurants

WITH Mexican_Preferring_Consumers AS (
    SELECT DISTINCT cp.Consumer_ID
    FROM consumer_preferences cp
    WHERE cp.Preferred_Cuisine = 'Mexican'
)
SELECT mpc.Consumer_ID
FROM Mexican_Preferring_Consumers mpc
WHERE NOT EXISTS (
    SELECT 1
    FROM ratings r
    INNER JOIN HighlyRatedMexicanRestaurants hrm
        ON r.Restaurant_ID = hrm.Restaurant_ID
    WHERE r.Consumer_ID = mpc.Consumer_ID
);
-- QUESTION 9: CREATE STORED PROCEDURE to get ratings above threshold

DELIMITER //

CREATE PROCEDURE GetRestaurantRatingsAboveThreshold(
    IN p_restaurant_id INT,
    IN p_min_rating DECIMAL(2,1)
)
BEGIN
    SELECT 
        Consumer_ID,
        Overall_Rating,
        Food_Rating,
        Service_Rating
    FROM ratings
    WHERE Restaurant_ID = p_restaurant_id
      AND Overall_Rating >= p_min_rating;
END //

DELIMITER ;

CALL GetRestaurantRatingsAboveThreshold(123, 2.5);
-- QUESTION 10: Top 2 highest-rated restaurants per cuisine type (Window Function + Filtering)
WITH Ranked_Restaurants AS (
    SELECT 
        rc.Cuisine,
        res.Name AS Restaurant_Name,
        res.City,
        AVG(r.Overall_Rating) AS avg_overall_rating,
        RANK() OVER (PARTITION BY rc.Cuisine ORDER BY AVG(r.Overall_Rating) DESC) AS cuisine_rank
    FROM restaurants res
    INNER JOIN restaurant_cuisines rc ON res.Restaurant_ID = rc.Restaurant_ID
    INNER JOIN ratings r ON res.Restaurant_ID = r.Restaurant_ID
    GROUP BY rc.Cuisine, res.Restaurant_ID, res.Name, res.City
)
SELECT Cuisine, Restaurant_Name, City, avg_overall_rating
FROM Ranked_Restaurants
WHERE cuisine_rank <= 2;

-- QUESTION 11

-- Step 1: Create VIEW for consumer average ratings
CREATE VIEW ConsumerAverageRatings AS
SELECT
    Consumer_ID,
    AVG(Overall_Rating) AS avg_overall_rating,
    COUNT(*) AS total_ratings
FROM ratings
GROUP BY Consumer_ID;


-- Step 2: Find top 5 consumers
WITH Top5_Consumers AS (
    SELECT
        Consumer_ID,
        avg_overall_rating
    FROM ConsumerAverageRatings
    ORDER BY avg_overall_rating DESC
    LIMIT 5
)

-- Step 3: Count Mexican restaurants rated by each top consumer
SELECT
    tc.Consumer_ID,
    tc.avg_overall_rating,
    COUNT(DISTINCT CASE
        WHEN rc.Cuisine = 'Mexican'
        THEN r.Restaurant_ID
    END) AS mexican_restaurants_rated
FROM Top5_Consumers tc
LEFT JOIN ratings r
    ON tc.Consumer_ID = r.Consumer_ID
LEFT JOIN restaurant_cuisines rc
    ON r.Restaurant_ID = rc.Restaurant_ID
GROUP BY
    tc.Consumer_ID,
    tc.avg_overall_rating;

-- QUESTION 12: STORED PROCEDURE for consumer segment and restaurant performance
DELIMITER //
CREATE PROCEDURE GetConsumerSegmentAndRestaurantPerformance(
    IN p_consumer_id VARCHAR(10)
)
BEGIN
    WITH consumer_ratings AS (
        SELECT 
            c.Consumer_ID,
            c.Budget,
            res.Name AS Restaurant_Name,
            r.Overall_Rating AS consumer_rating,
            res.Restaurant_ID
        FROM consumers c
        INNER JOIN ratings r ON c.Consumer_ID = r.Consumer_ID
        INNER JOIN restaurants res ON r.Restaurant_ID = res.Restaurant_ID
        WHERE c.Consumer_ID = p_consumer_id
    ),
    restaurant_averages AS (
        SELECT 
            Restaurant_ID,
            AVG(Overall_Rating) AS restaurant_avg_rating
        FROM ratings
        GROUP BY Restaurant_ID
    ),
    combined_data AS (
        SELECT 
            cr.Consumer_ID,
            cr.Restaurant_Name,
            cr.consumer_rating,
            ra.restaurant_avg_rating,
            cr.Budget,
            CASE 
                WHEN cr.Budget = 'Low' THEN 'Budget Conscious'
                WHEN cr.Budget = 'Medium' THEN 'Moderate Spender'
                WHEN cr.Budget = 'High' THEN 'Premium Spender'
                ELSE 'Unknown Budget'
            END AS spending_segment,
            CASE 
                WHEN cr.consumer_rating > ra.restaurant_avg_rating THEN 'Above Average'
                WHEN cr.consumer_rating = ra.restaurant_avg_rating THEN 'At Average'
                ELSE 'Below Average'
            END AS performance_flag,
            RANK() OVER (PARTITION BY cr.Consumer_ID ORDER BY cr.consumer_rating DESC) AS rating_rank
        FROM consumer_ratings cr
        INNER JOIN restaurant_averages ra ON cr.Restaurant_ID = ra.Restaurant_ID
    )
    SELECT 
        spending_segment,
        Restaurant_Name,
        consumer_rating,
        ROUND(restaurant_avg_rating, 2) AS restaurant_avg_rating,
        performance_flag,
        rating_rank
    FROM combined_data
    ORDER BY rating_rank;
END //
DELIMITER ;

CALL GetConsumerSegmentAndRestaurantPerformance('U1001');


