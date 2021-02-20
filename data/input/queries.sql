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
)
select 
user_id,
sub_date,
reg_date,
STRFTIME('%s' ,sub_date) - STRFTIME('%s' ,reg_date)  as difference
from dates
order by difference;


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
round(avg(STRFTIME('%s' ,sub_date) - STRFTIME('%s' ,reg_date)),2) as avg_time
from dates;


--Trigger
CREATE TRIGGER sub_time_check
AFTER INSERT ON taxfix
FOR EACH ROW
WHEN registration_date < submission_date
BEGIN 

