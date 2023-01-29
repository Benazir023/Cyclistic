# Cyclistic

#Upload the 12 csv files into BigQuery
#Merge them using

INSERT INTO `vaulted-quarter-375910.Cyclistic.202201-divvy-tripdata`
SELECT *
FROM `vaulted-quarter-375910.Cyclistic.202202-divvy-tripdata`

#Repeat the same for all 11 files, adjust the from clause e.g vaulted-quarter-375910.Cyclistic.202203-divvy-tripdata copies March data 
#Confirm the total no. of observations

SELECT COUNT (*)
FROM `vaulted-quarter-375910.Cyclistic.202201-divvy-tripdata` 

#My count is 5,667,717
#To confirm the blanks in the data use:

SELECT *
FROM `vaulted-quarter-375910.Cyclistic.202201-divvy-tripdata`
WHERE ride_id IS NULL

#Repeat the same for all other columns
#columns with missing information
