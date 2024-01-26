SELECT patient_id, COUNT(patient_id)
FROM hospitaldata
GROUP BY patient_id
HAVING COUNT(patient_id)>1;
#no duplicates or repeat patients over this duration

					##EXPLORING THE DATASET

SELECT MIN(date) AS startdate, MAX(date) AS enddate
FROM hospitaldata;
#April 1, 2019 to October 30, 2020

SELECT MIN(patient_age), MAX(patient_age)
FROM hospitaldata;
#between 1 and 79 years old

SELECT COUNT(patient_id)
FROM hospitaldata;
#9,216 patients seen over the course of this data collection

SELECT DISTINCT(department_referral)
FROM hospitaldata;
#8 different outcomes here

SELECT MIN(patient_sat_score), MAX(patient_sat_score), AVG(patient_sat_score)
FROM hospitaldata
WHERE patient_sat_score <> ' ';
#highest score was a 9, lowest a 0, average overall was 4.99 after accounting for the null entries
#Patient rating seems to be an optional survey so a lot of entries are missing this value entirely


					##Analysis
#Questions I'm seeking to answer: 
#How does waittime affect avg rating?
#Which departments are seeing the most referrals and does this follow a pattern?
#Are we seeing a certain race/age group/gender having lower satisfaction scores than the rest?
#What times/days have the longest waittime and potentially the lowest rating so we can change staffing needs?


SELECT department_referral, COUNT(department_referral) AS amount, AVG(patient_age)
FROM hospitaldata
GROUP BY department_referral
ORDER BY amount desc;

SELECT HOUR(date) as hour, DAYNAME(date) as weekday, AVG(patient_waittime)
FROM hospitaldata
GROUP BY hour, weekday
ORDER BY weekday, hour;
#good for showing avg fluctuations in waittime over weekdays/times

SELECT patient_race, COUNT(patient_race)
FROM hospitaldata
GROUP BY patient_race;
#variation in races treated

SELECT DISTINCT(patient_gender), COUNT(*)
FROM hospitaldata
GROUP BY patient_gender;
#gender variation

SELECT patient_race, COUNT(patient_race), AVG(patient_sat_score)
FROM hospitaldata
WHERE patient_sat_score <> ' '
GROUP BY patient_race;
#variation in satisfaction score of different races

SELECT CASE 
	WHEN patient_age between 0 and 10 THEN "0-10 years old"
    WHEN patient_age between 11 and 20 then "11-20 years old"
    WHEN patient_age between 21 and 30 then "21-30 years old"
    WHEN patient_age between 31 and 40 then "31-40 years old"
    WHEN patient_age between 41 and 50 then "41-50 years old"
    WHEN patient_age between 51 and 60 then "51-60 years old"
    WHEN patient_age between 61 and 70 then "61-70 years old"
    WHEN patient_age between 71 and 80 then "71-80 years old"
    ELSE NULL end AS agegroup, COUNT(*)
FROM hospitaldata
GROUP BY agegroup;


SELECT DATE(date) AS erdate, COUNT(*) as patients, avg(patient_waittime) as avgwait
FROM hospitaldata
GROUP BY DATE(date)
ORDER BY DATE(date);
#patients seen per day (used to evaluate over the month) and effect on waittime 


SELECT DATE(date), AVG(patient_waittime)
FROM hospitaldata
GROUP BY DATE(date);