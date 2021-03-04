-- Top 2 acquiring channels
select 
user_channel as channel,
count(user_id) as number_users
from taxfix
group by user_channel
order by number_users DESC 
LIMIT 2;


-- Time it took to each each to submit their tax form since they registered
with dates as 
(
select
user_id,
datetime(substr(submission_date, 7, 4) || '-' || substr(submission_date, 4, 2) || '-' || substr(submission_date, 1, 2) || ' ' || substr(submission_date, 12, 2) || ':' || substr(submission_date, 15, 2) || ':' || substr(submission_date, 18, 2)) as sub_date,
datetime(substr(registration_date , 7, 4) || '-' || substr(registration_date , 4, 2) || '-' || substr(registration_date , 1, 2) || ' ' || substr(registration_date, 12, 2) || ':' || substr(registration_date, 15, 2) || ':' || substr(registration_date, 18, 2)) as reg_date
from taxfix
where submission_date is not null
group by user_id 
)
select 
user_id,
sub_date,
reg_date,
(STRFTIME('%s' ,sub_date) - STRFTIME('%s' ,reg_date)) * 1.0 / 60 / 60  as difference
from dates
order by difference DESC;


-- Average a user takes from registering to submit their tax application in seconds
with dates as 
(
select
user_id,
datetime(substr(submission_date, 7, 4) || '-' || substr(submission_date, 4, 2) || '-' || substr(submission_date, 1, 2) || ' ' || substr(submission_date, 12, 2) || ':' || substr(submission_date, 15, 2) || ':' || substr(submission_date, 18, 2)) as sub_date,
datetime(substr(registration_date , 7, 4) || '-' || substr(registration_date , 4, 2) || '-' || substr(registration_date , 1, 2) || ' ' || substr(registration_date, 12, 2) || ':' || substr(registration_date, 15, 2) || ':' || substr(registration_date, 18, 2)) as reg_date
from taxfix	
where submission_date is not null
)
select 
round((avg(STRFTIME('%s' ,sub_date) - STRFTIME('%s' ,reg_date))) / 60 / 60) as avg_time_days
from dates;


-- Conversion rate (submissions/registrations) per day
SELECT 
DATE(substr(registration_date, 7, 4) || '-' || substr(registration_date , 4, 2) || '-' || substr(registration_date, 1, 2)) AS registration_date,
COUNT(user_id) AS count_reg_users,
COUNT(submission_date) AS count_submissions,
round(COUNT(submission_date)*1.0 / COUNT(user_id), 2) AS conversion_rate
FROM taxfix
GROUP BY substr(registration_date, 1, 10)
ORDER BY registration_date;

--Exploratory analysis
select 
Country 
from taxfix
group by Country ;


-- Create cleaned table
Create TABLE IF NOT EXISTS cleaned_sample AS
SELECT
user_id,
datetime(substr(registration_date , 7, 4) || '-' || substr(registration_date , 4, 2) || '-' || substr(registration_date , 1, 2) || ' ' || substr(registration_date, 12, 2) || ':' || substr(registration_date, 15, 2) || ':' || substr(registration_date, 18, 2)) as registration_date,
REPLACE(REPLACE(app_version, '#N/A', 'unknown_version'), 'unknown', 'unknown_version') as app_version,
REPLACE(REPLACE(REPLACE(user_channel, '#N/A', 'unknown_channel'), 'n/a', 'unknown_channel'), 'unknown', 'unknown_channel') as user_channel,
datetime(substr(submission_date, 7, 4) || '-' || substr(submission_date, 4, 2) || '-' || substr(submission_date, 1, 2) || ' ' || substr(submission_date, 12, 2) || ':' || substr(submission_date, 15, 2) || ':' || substr(submission_date, 18, 2)) as submission_date,
REPLACE(REPLACE(user_platform, '#N/A', 'unknown_platform'), 'n/a', 'unknown_platform') as user_platform,
LOWER(REPLACE(REPLACE(City, '#N/A', 'unknown_city'), 'n/a', 'unknown_city')) as city,
LOWER(Country) as country
FROM taxfix;

select *
from cleaned_set;

-- Table where the failred records are inserted due to the trigger
CREATE TABLE failed_records (
	user_id text PRIMARY KEY,
	registration_date text,
	app_version text,
	user_channel text,
	submission_date text,
	user_platform text,
	city text,
	country text
);

user_platform

--Trigger
CREATE TRIGGER IF NOT EXISTS sub_time_check
AFTER INSERT ON taxfix
FOR EACH ROW
WHEN 
	submission_date IS NOT NULL 
	AND registration_date IS NULL
BEGIN 
	INSERT INTO failed_records (
		user_id,
		registration_date,
		app_version,
		user_channel,
		submission_date,
		user_platform,
		city,
		country
	)
	VALUES (
		taxfix.user_id,
		taxfix.registration_date,
		taxfix.app_version,
		taxfix.user_channel,
		taxfix.submission_date,
		taxfix.user_platform,
		taxfix.city,
		taxfix.country
	);
END;

