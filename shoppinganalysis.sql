#Using "Consumer Behavior and Shopping Habits Dataset" from Kaggle (https://www.kaggle.com/datasets/zeesolver/consumer-behavior-and-shopping-habits-dataset/code)
#Analyzing data with the goal of identifying relationships between purchases and consumer demographics, seasons, subscriber status, etc to identify best possible areas for marketing



#Exploring the data/Checking for duplicates, typos, and outliers
SELECT MIN(age),MAX(age),AVG(age)
FROM shopping_behavior;

SELECT DISTINCT(GENDER), COUNT(*) AS AMOUNT
FROM shopping_behavior
GROUP BY GENDER;

SELECT DISTINCT(SEASON)
FROM shopping_behavior;

SELECT id, COUNT(*)
FROM shopping_behavior
GROUP BY ID
HAVING COUNT(*) > 1;
#0 results

SELECT DISTINCT(LOCATION), COUNT(*) AS AMOUNT
FROM shopping_behavior
GROUP BY LOCATION
ORDER BY AMOUNT DESC;
#top three states with entries Montana(96), California(95), Idaho(93)



#shopping trend differences between genders
 
SELECT gender, total
FROM 
	(SELECT gender,COUNT(*) as total
    FROM shopping_behavior
    GROUP BY gender) as x 
GROUP BY gender;
#2652 male and 1248 female entries, 3900 total

#Overall category breakdown
SELECT category, total, total/3900 * 100 AS percentage
FROM 
	(SELECT category,COUNT(*) as total
    FROM shopping_behavior
    GROUP BY category) as x 
GROUP BY category;
#Clothing top category

SELECT item_purchased,Count(*)
FROM shopping_behavior
GROUP BY item_purchased
ORDER BY COUNT(*) DESC;
#Blouse, pants, and jewelry tied for top items overall at 171 each

#Male vs Female category purchase percent comparison
SELECT CATEGORY, total_female/1248 * 100 as femalepercent, total_male/2652 * 100 as malepercent
FROM
	(SELECT category,
	SUM(CASE WHEN gender = "Female" THEN 1 ELSE 0 END) as total_female,
	SUM(CASE WHEN gender = "Male" THEN 1 else 0 END) as total_male
	FROM shopping_behavior
    GROUP BY CATEGORY) AS X
GROUP BY category;
#not significantly different between genders, clothing is top category for both


#Clothing was top category, what are the top products of that category?
SELECT item_purchased, total, total/1248 * 100 AS percentage
FROM 
	(SELECT item_purchased,COUNT(*) as total
    FROM shopping_behavior
	WHERE gender = "Female" AND category = "Clothing"
    GROUP BY item_purchased) as x 
GROUP BY item_purchased
ORDER BY total DESC;
#Blouse, shirt, and socks are top item purchases for females


SELECT item_purchased, total, total/2652 * 100 AS percentage
FROM 
	(SELECT item_purchased,COUNT(*) as total
    FROM shopping_behavior
	WHERE gender = "Male" AND category = "Clothing"
    GROUP BY item_purchased) as x 
GROUP BY item_purchased
ORDER BY total DESC;
#Pants, sweater, and dress were top item purchases for males

#Age comparisons
SELECT 
	CASE
		WHEN Age between 18 and 31 then '18-31'
        WHEN Age between 32 and 45 then '32-45'
        WHEN Age between 46 and 59 then '46-59'
        ELSE '60 and up' 
        END as ranges,
	COUNT(AGE) as total,
   SUM(CASE WHEN promocode = "Yes" THEN 1 ELSE 0 END) AS promo_used,
   SUM(CASE WHEN discount_applied = "Yes" THEN 1 ELSE 0 END) as discount_used,
   SUM(CASE WHEN subscription_status = "Yes" THEN 1 ELSE 0 END) AS subscriber
	FROM shopping_behavior
    GROUP BY ranges
    ORDER BY ranges;
#The ages are more or less distributed evenly, 60+ being the smallest by about 200 less but everything else differing by about 10-50
#age group 46-59 most likely to be a subscriber and to use a promocode/discount
#Age group 60+ least amount of subscribers

SELECT Category, COUNT(Category) AS TOTAL
FROM shopping_behavior
WHERE Age between 18 and 31
GROUP BY Category
ORDER BY TOTAL DESC;

SELECT Category, COUNT(Category) AS TOTAL
FROM shopping_behavior
WHERE Age between 32 and 45
GROUP BY Category
ORDER BY TOTAL DESC;

SELECT Category, COUNT(Category) AS TOTAL
FROM shopping_behavior
WHERE Age between 46 and 59
GROUP BY Category
ORDER BY TOTAL DESC;

SELECT Category, COUNT(Category) AS TOTAL
FROM shopping_behavior
WHERE Age between 60 and 73
GROUP BY Category
ORDER BY TOTAL DESC;
#No significant difference in category purchases between age groups

SELECT AVG(purchase_amount)
FROM shopping_behavior
WHERE age between 18 and 31;
#60.45

SELECT AVG(purchase_amount)
FROM shopping_behavior
WHERE age between 32 and 45;
#59.23

SELECT AVG(purchase_amount)
FROM shopping_behavior
WHERE age between 46 and 59;
#59.80

SELECT AVG(purchase_amount)
FROM shopping_behavior
WHERE age between 60 and 73;
#59.51
#The age group of 18-31 spent approximately 60cents to 1 dollar more per purchase than the other age groups




#Location analysis

SELECT Location, ROUND(AVG(rating), 1), MIN(rating), MAX(rating)
FROM shopping_behavior
GROUP BY location
ORDER BY location;

SELECT location, AVG(purchase_amount), MIN(purchase_amount), MAX(purchase_amount)
FROM shopping_behavior
GROUP BY location
ORDER BY AVG(Purchase_Amount) DESC;
##higheset avg spending is Alaska, lowest Connecticut

SELECT location,SUM(previous_purchases) AS repeat_customer, ROUND(AVG(rating), 2) AS avgrating
FROM shopping_behavior
GROUP BY location
ORDER BY SUM(previous_purchases) DESC;
#Create map showing distribution of repeat customers across United States vs avg statewide rating 

SELECT location, ROUND(AVG(rating), 2) AS avgrating
FROM shopping_behavior
GROUP BY location
ORDER BY avgrating DESC
LIMIT 5;
#Texas 3.91, Wisconsin 3.89, Iowa 3.85, Maine 3.84, California 3.83

SELECT location, COUNT(subscription_status) as substat
FROM shopping_behavior
WHERE subscription_status = "Yes"
GROUP BY location
ORDER BY substat DESC
LIMIT 5;
#Nevada 30, California 29, Delaware 28, West Virginia 28, Missouri 27

SELECT location, SUM(previous_purchases) as repeats
FROM shopping_behavior
GROUP BY location
ORDER BY repeats DESC
LIMIT 5;
#Illinois 2447, Alabama 2443, Montana 2426, California 2327, Minnesota 2307

#California was in the top 5 for highest rating, highest amount of subscribers, and most about of repeat customers. Arguably, California would be a great state to market to for the likelihood of sales
#The best population to market to would be people between the age of 46-59 that reside in California. The gender does not matter. Clothing is the most likely to be purchased



#Season effect on consumer behavior
SELECT item_purchased, Count(*)
FROM shopping_behavior
WHERE Season = "Winter"
GROUP BY item_purchased
ORDER BY COUNT(*) DESC;

SELECT item_purchased, Count(*)
FROM shopping_behavior
WHERE Season = "Spring"
GROUP BY item_purchased
ORDER BY COUNT(*) DESC;

SELECT item_purchased, Count(*)
FROM shopping_behavior
WHERE Season = "Summer"
GROUP BY item_purchased
ORDER BY COUNT(*) DESC;

SELECT item_purchased, Count(*)
FROM shopping_behavior
WHERE Season = "Fall"
GROUP BY item_purchased
ORDER BY COUNT(*) DESC;






