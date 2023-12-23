SELECT ActivityDate
FROM dailyactivity_merged;

#Had to import table with ActivityDate in text format since it's not in correct DATE format. Need to change that now:
alter table dailyactivity_merged 
add column new_date DATE;
update dailyactivity_merged
set new_date = str_to_date(`ActivityDate`, '%m/%d/%Y');

#Changing sleep table
alter table sleepday 
add column sleep_date DATE;
update sleepday
set sleep_date = str_to_date(`SleepDay`, '%m/%d/%Y %r');

#updating weight table dates
alter table weightlog
add column weight_date DATE;
update weightlog
set weight_date = str_to_date(`Date`, '%m/%d/%Y %r');

#steps
alter table dailysteps
add column date DATE;
update dailysteps
set date = str_to_date(`ActivityDay`, '%m/%d/%Y');

#intensities
alter table dailyintensities
add column intensitydate DATE;
update dailyintensities
set intensitydate = str_to_date(`ActivityDay`, '%m/%d/%Y');


--- 
     #EXPLORING/CLEANING DATA

#Determining amount of Ids in each table and looking at timeline
SELECT COUNT(DISTINCT(Id)) as Participants, MIN(new_date), MAX(new_date), COUNT(DISTINCT(new_date)) AS Length
FROM dailyactivity_merged;
#33, 04/12/2016 to 05/12/2016, 31 days

SELECT COUNT(DISTINCT(Id)), MIN(intensitydate), MAX(intensitydate)
FROM dailyintensities;
#33, 04/12/2016 to 05/12/2016

SELECT COUNT(DISTINCT(Id)),MIN(date), MAX(date)
FROM dailysteps;
#33, 04/12/2016 to 05/12/2016

SELECT COUNT(DISTINCT(Id)),MIN(sleep_date), MAX(sleep_date)
FROM sleepday;
#24, 04/12/2016 to 05/12/2016

SELECT COUNT(DISTINCT(Id)),MIN(weight_date), MAX(weight_date)
FROM weightlog;
#8, 04/12/2016 to 05/12/2016



#looking for duplicate rows
SELECT ID, new_date, COUNT(*) AS numrow
FROM dailyactivity_merged
GROUP BY ID, new_date
HAVING numrow > 1;
#0 duplicate rows

SELECT Id, intensitydate, COUNT(*) as numrow
FROM dailyintensities
GROUP BY Id, intensitydate
HAVING numrow > 1;
#0 duplicate rows

SELECT Id, date, COUNT(*) as numrow
FROM dailysteps
GROUP BY Id, date
HAVING numrow > 1;
#0 duplicate rows

SELECT Id, sleep_date, COUNT(*) as numrow
FROM sleepday
GROUP BY Id, sleep_date
HAVING numrow > 1;
#3 duplicate rows

#making new table without duplicates
CREATE TABLE sleepday2 SELECT DISTINCT * FROM sleepday;
#confirming new one does not have duplicates anymore
SELECT Id, sleep_date, COUNT(*) as numrow
FROM sleepday2
GROUP BY Id, sleep_date
HAVING numrow > 1;
#0 duplicates

ALTER TABLE sleepday RENAME junk;
DROP TABLE IF EXISTS junk;
ALTER TABLE sleepday2 RENAME sleepday;

SELECT Id, date, COUNT(*) as numrow
FROM weightlog
GROUP BY Id, date
HAVING numrow > 1;
#0 duplicates

SELECT LENGTH(Id)
FROM dailyactivity_merged;

SELECT Id
FROM dailyactivity_merged
WHERE LENGTH(Id) > 10 OR LENGTH(Id) < 10;
#0 results

SELECT Id
FROM dailyintensities
WHERE LENGTH(Id) > 10 OR LENGTH(Id) < 10;
#0 results

SELECT Id
FROM dailysteps
WHERE LENGTH(Id) > 10 OR LENGTH(Id) < 10;
#0 results

SELECT Id
FROM sleepday
WHERE LENGTH(Id) > 10 OR LENGTH(Id) < 10;
#0 results

SELECT Id
FROM weightlog
WHERE LENGTH(Id) > 10 OR LENGTH(Id) < 10;
#0 results


#Looking for rows that have 0 steps -- indicating the user most likely did not wear their watch that day. Though possible, it is unlikely a total of 0 steps were recorded if worn for a day.
SELECT Id, COUNT(StepTotal)
FROM dailysteps
WHERE StepTotal = 0
GROUP BY Id;
#77 entries

SELECT *, ROUND(SedentaryMinutes/60,2) AS Sendentaryhours
FROM dailyactivity_merged
WHERE TotalSteps = 0;
#Majority of these showed 24 hours or sedentary activity, indicating the FitBit was most likely not worn that day.
#I've decided to remove these entries for not being representative of the entries 

DELETE FROM dailyactivity_merged
WHERE TotalSteps = 0;

SELECT *
FROM dailyactivity_merged
WHERE TotalSteps = 0;
#0 records, deleted properly



			#Analysis of FitBit Data
SELECT CASE
	WHEN WEEKDAY(new_date) = 0 THEN "Monday"
    WHEN WEEKDAY(new_date) = 1 then "Tuesday"
    WHEN WEEKDAY(new_date) = 2 then "Wednesday"
    WHEN WEEKDAY(new_date) = 3 then "Thursday"
    WHEN WEEKDAY(new_date) = 4 then "Friday"
    WHEN WEEKDAY(new_date) = 5 then "Saturday"
    WHEN WEEKDAY(new_date) = 6 then "Sunday"
    ELSE NULL end AS dayweek, AVG(Totalsteps) as avg_steps, MAX(Totalsteps) as max_steps, MIN(Totalsteps) as min_steps, AVG(TotalMinutesAsleep) as avg_sleepminutes, AVG(totalminutesasleep/60) as avghoursasleep, AVG(totaltimeinbed) as avg_timeinbed,
    AVG(totaltimeinbed-totalminutesasleep) as avg_fallasleeptime, AVG(Calories) as avg_calories
FROM dailyactivity_merged
INNER JOIN SleepDay ON dailyactivity_merged.new_date = sleepday.sleep_date 
GROUP BY dayweek
ORDER BY avg_steps DESC;

SELECT new_date AS date, Totalsteps, calories, totalminutesasleep, totaltimeinbed, totaltimeinbed - totalminutesasleep AS fallasleeptime
FROM dailyactivity_merged
INNER JOIN SleepDay ON dailyactivity_merged.new_date = sleepday.sleep_date;


SELECT Id, intensitydate, AVG(LightlyActiveMinutes), AVG(FairlyActiveMinutes), AVG(VeryActiveMinutes)
FROM dailyintensities
GROUP BY Id, intensitydate;


#How many participants get CDC recommended 10,000 steps and how many times during duration of data collection
SELECT Id, COUNT(Id) as amount_goal_hit
FROM dailysteps
WHERE StepTotal > 10000
GROUP BY Id;

#how participants acted over time in distance, calories, and steps
SELECT new_date, id, SUM(totalsteps), SUM(totaldistance), SUM(calories)
FROM dailyactivity_merged
GROUP BY new_date, id;

SELECT Id, new_date, TotalSteps, Calories
FROM dailyactivity_merged;

SELECT dailyactivity_merged.Id, new_date, veryactiveminutes, fairlyactiveminutes, lightlyactiveminutes, sedentaryminutes, totalminutesasleep, sedentaryminutes - totalminutesasleep as sedentary_awake_minutes, totaltimeinbed - totalminutesasleep as fallasleeptime
FROM dailyactivity_merged
INNER JOIN sleepday ON dailyactivity_merged.id = sleepday.id AND dailyactivity_merged.new_date = sleepday.sleep_date;
#Assumed sedentaryminutes included sleep time but when subtracting, got multiple negative values 
#would seek some clarity from data source if sedentary minutes includes sleeping minutes or if the fitbit designates them differently

#How many participants get CDC minimum recommended amount of sleep (min 7 hours) and how many times during the duration of data collection
SELECT Id, COUNT(Id) as amount_goal_hit
FROM sleepday
WHERE TotalMinutesAsleep > 420
GROUP BY Id;


#sleep efficiency score (total sleep time/total time in bed * 100) compared to activity levels and time during the day
SELECT sleepday.Id, sleepday.sleep_date, totalminutesasleep, totaltimeinbed, totalminutesasleep/totaltimeinbed * 100 AS sleep_efficiency, veryactiveminutes, fairlyActiveminutes, lightlyactiveminutes
FROM dailyactivity_merged
INNER JOIN sleepday 
ON dailyactivity_merged.new_date = sleepday.sleep_date AND dailyactivity_merged.id = sleepday.id;


#a good/normal sleep efficiency score is considered >85%. seeing how many participants hit this recommendation
#(https://www.hypersomniafoundation.org/glossary/sleep-efficiency/#:~:text=Sleep%20efficiency%20is%20the%20percentage,to%20be%2085%25%20or%20higher.)
SELECT Id, COUNT(Id)
FROM sleepday
WHERE totalminutesasleep/totaltimeinbed * 100 >= 85.0
GROUP BY Id;

#how often do participants hit their sleep efficiency goal per day of the week
SELECT CASE
	WHEN WEEKDAY(sleep_date) = 0 THEN "Monday"
    WHEN WEEKDAY(sleep_date) = 1 then "Tuesday"
    WHEN WEEKDAY(sleep_date) = 2 then "Wednesday"
    WHEN WEEKDAY(sleep_date) = 3 then "Thursday"
    WHEN WEEKDAY(sleep_date) = 4 then "Friday"
    WHEN WEEKDAY(sleep_date) = 5 then "Saturday"
    WHEN WEEKDAY(sleep_date) = 6 then "Sunday"
    ELSE NULL end AS dayweek, COUNT(Id) as sleepefficiencygoalreached
FROM sleepday
WHERE totalminutesasleep/totaltimeinbed * 100 >= 85.0
GROUP BY dayweek;

#how often do participants hit their sleep amount goal (7hrs min) per day of the week
SELECT CASE
	WHEN WEEKDAY(sleep_date) = 0 THEN "Monday"
    WHEN WEEKDAY(sleep_date) = 1 then "Tuesday"
    WHEN WEEKDAY(sleep_date) = 2 then "Wednesday"
    WHEN WEEKDAY(sleep_date) = 3 then "Thursday"
    WHEN WEEKDAY(sleep_date) = 4 then "Friday"
    WHEN WEEKDAY(sleep_date) = 5 then "Saturday"
    WHEN WEEKDAY(sleep_date) = 6 then "Sunday"
    ELSE NULL end AS dayweek, COUNT(Id) as sleepgoalreached
FROM sleepday
WHERE totalminutesasleep > 420
GROUP BY dayweek;



SELECT id, weight_date, AVG(weightpounds)
from weightlog
GROUP BY id, weight_date;


SELECT id, COUNT(id)
FROM weightlog
GROUP BY id;

SELECT Id, weight_date, weightpounds
FROM weightlog
WHERE id = "6962181067";
#this participant entered a log every single day

select MIN(weight_date), MAX(weight_date)
from weightlog;
#2016-04-12 and 2016-05-12

SELECT weight_date, AVG(Weightpounds) as avg_weight, AVG(BMI) as avg_bmi 
FROM weightlog
GROUP BY weight_date;

SELECT Id, weight_date, Weightpounds
FROM weightlog;

#correlation between calories burned vs time asleep or time to fall asleep
SELECT dailyactivity_merged.id, dailyactivity_merged.new_date, calories as caloriesburned, totalminutesasleep/60 as hoursasleep, (totaltimeinbed - totalminutesasleep) as fallingasleeptime
FROM dailyactivity_merged
INNER JOIN sleepday ON dailyactivity_merged.id = sleepday.id AND dailyactivity_merged.new_date = sleepday.sleep_date;

#correlation between calories and time asleep night before
SELECT dailyactivity_merged.id, dailyactivity_merged.new_date, calories as caloriesburned, totalminutesasleep/60 as hoursasleepnightofactivity, (totaltimeinbed - totalminutesasleep) as fallingasleeptime_minutes,
	LAG(totalminutesasleep, 1) OVER (ORDER BY dailyactivity_merged.id, dailyactivity_merged.new_date) /60 AS hourssleptdaybefore
FROM dailyactivity_merged
INNER JOIN sleepday ON dailyactivity_merged.id = sleepday.id AND dailyactivity_merged.new_date = sleepday.sleep_date;


SELECT id, new_date, trackerdistance, loggedactivitiesdistance
FROM dailyactivity_merged;

SELECT COUNT(DISTINCT Id)
FROM dailyactivity_merged
WHERE loggedactivitiesdistance <> 0;
#only 4 participants out of 33 logged their activity distance, manually. This means that majority of participants experience automatic tracking of their distancce
#That is data that participant would not otherwise know without this feature since they do not manually track

SELECT SUM(trackerdistance)
FROM dailyactivity_merged 
WHERE loggedactivitiesdistance = 0;
#a total of 4,687.609 miles were documented automatically for the 33 participants, without any manual logging
#a good feature for people who do not remember to set their fitness tracker/want to know their daily stats 

SELECT new_date, veryactivedistance, moderatelyactivedistance, lightactivedistance, calories
FROM dailyactivity_merged;

SELECT DAYNAME(new_date) as DayofWeek, COUNT(*) as amount
FROM dailyactivity_merged as d
 LEFT JOIN sleepday as s
 ON d.new_date = s.sleep_date AND d.id = s.id
 WHERE s.totalminutesasleep is NULL
GROUP BY dayofweek
ORDER BY amount desc; 




