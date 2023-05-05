--Upload the files to BigQuery and merge using
INSERT INTO `vaulted-quarter-375910.Cyclistic.202201-divvy-tripdata`
SELECT *
FROM `vaulted-quarter-375910.Cyclistic.202202-divvy-tripdata`


--Query above copies data from table 202202-divvy-tripdata to 202201-divvytripdata. Copy the rest of the tables too
--After copying confirm total using
SELECT COUNT (*)
FROM `vaulted-quarter-375910.Cyclistic.202201-divvy-tripdata`


--Confirm if there are any nulls using
SELECT *
FROM `vaulted-quarter-375910.Cyclistic.202201-divvy-tripdata`
WHERE ride_id IS NULL


--Repeat the same for all other columns
--833,064 mulls in the start_station_name & start_station_id columns
--892,742 nulls in end_station_name & end_station_id columns
--5,858 nulls in end_lng & end_lat columns
--We'll proceed since we can still answer the business problem with the rest of the information
--To clean data(with all 5,667,717 observations) use

SELECT
 ride_id,
 rideable_type,
 member_casual AS membership,
 start_station_name,
 end_station_name,
 EXTRACT(date FROM started_at) AS start_date,
 EXTRACT(time FROM started_at) AS start_time,
 EXTRACT(date FROM ended_at) AS end_date,
 EXTRACT(time FROM ended_at) AS end_time,
 date_diff(ended_at,started_at, MINUTE) AS ride_length,
FROM
 `vaulted-quarter-375910.Cyclistic.202201-divvy-tripdata`

--Saved results in new table as clean-data

--Clean data (without nulls)
SELECT
 ride_id,
 rideable_type,
 member_casual AS membership,
 start_station_name,
 end_station_name,
 EXTRACT(date FROM started_at) AS start_date,
 EXTRACT(time FROM started_at) AS start_time,
 EXTRACT(date FROM ended_at) AS end_date,
 EXTRACT(time FROM ended_at) AS end_time,
 date_diff(ended_at,started_at, MINUTE) AS ride_length,
FROM
 `vaulted-quarter-375910.Cyclistic.202201-divvy-tripdata`
WHERE
 start_station_name IS NOT NULL AND
 end_station_name IS NOT NULL;
--Explore the clean data and save results in tables for visualization(I exported to Excel and created pivot charts and tables)

--Number of rides per start_hour
SELECT
 membership,
 EXTRACT(hour FROM start_time) AS start_hour,
 COUNT(*) AS rides_per_hour
FROM
 `vaulted-quarter-375910.Cyclistic.clean-data`
GROUP BY
 EXTRACT(hour FROM start_time),membership

--peak hours for annual members are 7-9 am & 4-6 pm. This could mean they mostly use the rides for commuting to work.As for casual me
mbers, the number steadily increases throughout the day and peaks at 3-6 pm which could mean they use the bikes to for short runs e.g to run errands.

--Number of rides per end_hour
SELECT
 membership,
 EXTRACT(hour FROM end_time) AS end_hour,
 COUNT(*) AS rides_per_hour
FROM
 `vaulted-quarter-375910.Cyclistic.clean-data`
GROUP BY
 EXTRACT(hour FROM end_time),membership

--Interpretation same as rides per start_hour
--Number of rides according to weekday
SELECT
 EXTRACT(dayofweek FROM start_date) AS start_day,
 membership,
 COUNT(*)
FROM
 `vaulted-quarter-375910.Cyclistic.clean-data`
GROUP BY
 EXTRACT(dayofweek FROM start_date),membership

--number of rides per weekday for members is almost constant throughtout the week but tends to reduce from day 6 to 1. In BigQuery 1=Monday, 2=Tuesday, etc. Meaning they use
the bikes to commute to work. For casual riders it's a downward slope from the beginning of the week. It increases on Saturday & Sunday meaning they use the bikes for leisure, to exercise, run errands, etc.

--Number of rides according to month
SELECT
 EXTRACT(month FROM start_date) AS start_month,
 membership,
 COUNT(*) as num_of_rides
FROM
 `vaulted-quarter-375910.Cyclistic.double_clean`
GROUP BY
 EXTRACT(month FROM start_date),membership

--Weather is a factor in bike usage. There's an increase during summer months.

--Popularity of bikes according to type
SELECT
 membership,
 rideable_type,
 COUNT(*)
FROM
 `vaulted-quarter-375910.Cyclistic.clean-data`
GROUP BY
 rideable_type, membership


--Electric bikes are more preferred by the casual riders. Docked bikes are only used by casual members because of their nature. Preference is almost the same for annual members.

--Total ride length per day
SELECT
 EXTRACT(dayofweek FROM start_date) AS weekday,
 sum(ride_length) AS total_ride_length,
 membership
FROM
 `vaulted-quarter-375910.Cyclistic.clean-data`
GROUP BY
 EXTRACT(dayofweek FROM start_date),membership


--Average ride length per day
SELECT
 EXTRACT(dayofweek FROM start_date) AS weekday,
 avg(ride_length) AS average_ride_length,
 membership
FROM
 `vaulted-quarter-375910.Cyclistic.double_clean`
GROUP BY
 EXTRACT(dayofweek FROM start_date),membership;

--On average, casual riders ride the bikes longer than annual members.It’s consistent for annual members maybe because their schedules are more consistent after commuting to work mostly between day 1 and 5 i.e Monday to Friday

--Descriptive statistics
SELECT
 membership,
 max(ride_length) AS max,
 min(ride_length) AS min,
 avg(ride_length) AS average,
FROM
 `vaulted-quarter-375910.Cyclistic.clean-data`
GROUP BY
 Membership


--A closer look at observations with negative ride_length
SELECT
 start_date,
 start_time,
 end_date,
 end_time,
 ride_length
FROM
 `vaulted-quarter-375910.Cyclistic.clean-data`
WHERE
 ride_length = -138 OR ride_length = -10353;


--Min ride_length for casual riders and annual members were -138 & -10353 respectively

--Established that started_at & ended_at had been reversed
SELECT
 start_date,
 start_time,
 end_date,
 end_time,
 ride_length
FROM
 `vaulted-quarter-375910.Cyclistic.clean-data`
WHERE
 ride_length <0
ORDER BY
 ride_length;

--Revealed that 77 observations had start and end times reversed
SELECT
 start_date,
 start_time,
 end_date,
 end_time,
 ride_length
FROM
 `vaulted-quarter-375910.Cyclistic.clean-data`
WHERE
 ride_length =0


--95,957 results.Cleaned the data again and omitted ride_length <=0 and repeated all above steps for analysis

--Rides per time intervals.1 - 60mins
SELECT
 COUNT(*),
 membership
FROM
 `vaulted-quarter-375910.Cyclistic.clean-data`
WHERE
 ride_length <60 AND ride_length !=0
GROUP BY
 membership;


--1 to 3 hrs
SELECT
 COUNT(*),
 membership
FROM
 `vaulted-quarter-375910.Cyclistic.clean-data`
WHERE
 ride_length BETWEEN 61 AND 180
GROUP BY
 membership;

--3 to 6 hrs
SELECT
 COUNT(*),
 membership
FROM
 `vaulted-quarter-375910.Cyclistic.clean-data`
WHERE
 ride_length BETWEEN 181 AND 360
GROUP BY
 membership;

--6 to 12 hrs
SELECT
 COUNT(*),
 membership
FROM
 `vaulted-quarter-375910.Cyclistic.clean-data`
WHERE
 ride_length BETWEEN 360 AND 720
GROUP BY
 membership;

--12 to 24 hrs
SELECT
 COUNT(*),
 membership
FROM
 `vaulted-quarter-375910.Cyclistic.clean-data`
WHERE
 ride_length BETWEEN 721 AND 1440
GROUP BY
 membership;

--24 to 72 hrs
SELECT
 COUNT(*),
 membership
FROM
 `vaulted-quarter-375910.Cyclistic.clean-data`
WHERE
 ride_length BETWEEN 1441 AND 4320
GROUP BY
 membership;

--Above 72hrs
SELECT
 COUNT(*),
 membership
FROM
 `vaulted-quarter-375910.Cyclistic.clean-data`
WHERE
 ride_length >4320
GROUP BY
 membership;


--These results would be for pricing flexibility and discounted prices (according to time intervals)
--Top 20 start locations
SELECT
 DISTINCT start_station_name,
 membership,
 count (*) AS count,
FROM
 `vaulted-quarter-375910.Cyclistic.clean-data`
WHERE
 start_station_name IS NOT NULL
GROUP BY
 start_station_name, membership
ORDER BY
 count DESC
LIMIT 20;


--Out of the top 20 start_stations where most rides were started 13/20 had casual riders. 4/5 of the first 5 stations had casual riders
--Location is a factor and marketing may consider targeting the environs near the first 5 start_stations where most casual riders started their rides




