# Set up work environment

# Install packages and load using library functions

library(tidyverse)
library(skimr)
library(janitor)
library(stringr)
library(lubridate)
library(readr)
library(dplyr)

# Importing datasets

df1 <- read.csv("./202201-divvy-tripdata.csv")
df2 <- read.csv("./202202-divvy-tripdata.csv")
df3 <- read.csv("./202203-divvy-tripdata.csv")
df4 <- read.csv("./202204-divvy-tripdata.csv")
df5 <- read.csv("./202205-divvy-tripdata.csv")
df6 <- read.csv("./202206-divvy-tripdata.csv")
df7 <- read.csv("./202207-divvy-tripdata.csv")
df8 <- read.csv("./202208-divvy-tripdata.csv")
df9 <- read.csv("./202209-divvy-publictripdata.csv")
df10 <- read.csv("./202210-divvy-tripdata.csv")
df11 <- read.csv("./202211-divvy-tripdata.csv")
df12 <- read.csv("./202212-divvy-tripdata.csv")

# DATA WRANGLING

# Combine to one data frame

all_rides <- rbind(df1,df2,df3,df4,df5,df6,df7,df8,df9,df10,df11,df12)

# Get an overview of the combined data frame

colnames(all_rides)
glimpse(all_rides)
head(all_rides)
str(all_rides)
dim(all_rides)
View(all_rides)
skimr::skim_without_charts(all_rides)

# Changing data type from chr to date for started_at & ended_at columns
# The observations have different date formats. For df1-df7 and df8-df12 use code chunks below respectively.
# Substitute the df accordingly

df1$started_at <- lubridate::mdy_hm(df1$started_at)
df1$ended_at <- lubridate::mdy_hm(df1$ended_at)

df8$started_at <- lubridate::ymd_hms(df8$started_at)
df8$ended_at <- lubridate::ymd_hms(df8$ended_at)

# Combine the 12 data frames again, date issue now fixed

full_year <- rbind(df1,df2,df3,df4,df5,df6,df7,df8,df9,df10,df11,df12)

# Skim_without_charts() function revealed:
# a.5858 missing values in end_lat and lng columns - we'll delete lng & lat columns since they're not needed in our analysis
# b.833064 missing values in both start_station_name and id columns - further enquiry from the boss revealed they're bikes acquired from Planet9 Bikes, we'll replace station name with Planet9 and station id with NA
# c.892742 missing values in end_station_name & id columns - same case as blanks in start_station_name & id
# These are about 15% of the population so we’ll need to address these before proceeding

full_year2 <- full_year[,-c(9,10,11,12)]

# Deleted all lng & lat columns which were the 9th, 10th, 11th & 12th columns in our dataframe

full_year2$start_station_name[full_year2$start_station_name == ""] <- "Planet9"
full_year2$start_station_id[full_year2$start_station_id == ""] <- NA
full_year2$end_station_name[full_year2$end_station_name == ""] <- "Planet9"
full_year2$end_station_id[full_year2$end_station_id == ""] <- NA

# Change name to more meaningful

bike_rides <- full_year2

# Extract dates, month, day_of_month, day_of_week, hours

bike_rides$start_date <- as.Date(bike_rides$started_at)
bike_rides$end_date <- as.Date(bike_rides$ended_at)
bike_rides$month <- format(as.Date(bike_rides$start_date),"%m")
bike_rides$day <- format(as.Date(bike_rides$start_date),"%d")
bike_rides$day_of_week <- format(as.Date(bike_rides$start_date),"%A")
bike_rides$start_hour <- lubridate::hour(bike_rides$started_at)
bike_rides$end_hour <- lubridate::hour(bike_rides$ended_at)

# Summary of the data

skimr::skim_without_charts(bike_rides)

# Calculate ride_length

bike_rides$ride_length_hours <- difftime(bike_rides$ended_at,bike_rides$started_at,units="hours")
bike_rides$ride_length_mins <- difftime(bike_rides$ended_at,bike_rides$started_at,units="mins")

# ANALYSIS

# Filter rows with negative ride_length. Started_at and ended_at details were captured in reverse order. They're 97 obs.

bike_rides_neg <- bike_rides %>%
  filter(ride_length_mins < 0)

# Filter rows with 0 ride_length, we can assume they were not used. They are 37569 obs

bike_rides_zero <- bike_rides %>%
  filter(ride_length_mins == 0)

# Proceed to analyze the 'good' data. They're 5630051 obs

bike_rides_clean <- bike_rides %>%
  filter(ride_length_mins > 0)

# Export cleaned dataframe to new csv

write_csv(bike_rides_clean, "2022-divvy-tripdata-clean.csv")
df <- read_csv("2022-divvy-tripdata-clean.csv")

# Descriptive Analysis

mean(bike_rides_clean$ride_length_mins) #total ride_length/total rides
median(bike_rides_clean$ride_length_mins) #midpoint when ride_length arranged in order
mode(bike_rides_clean$ride_length_mins) #
max(bike_rides_clean$ride_length_mins) #longest ride_length
min(bike_rides_clean$ride_length_mins) #shortest ride_length

# Compare aggregates for members and casual riders

aggregate(bike_rides_clean$ride_length_mins ~ bike_rides_clean$member_casual, FUN = mean)
aggregate(bike_rides_clean$ride_length_mins ~ bike_rides_clean$member_casual, FUN = median)
aggregate(bike_rides_clean$ride_length_mins ~ bike_rides_clean$member_casual, FUN = max)
aggregate(bike_rides_clean$ride_length_mins ~ bike_rides_clean$member_casual, FUN = min)

# Average ride_length per weekday for members and casual riders

aggregate(bike_rides_clean$ride_length_mins ~ bike_rides_clean$day_of_week + bike_rides_clean$member_casual, FUN = mean)

# Order days_of_week first

bike_rides_clean$day_of_week <- ordered(bike_rides_clean$day_of_week,levels=c("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"))

# Ridership by type and day_of_week

bike_rides_clean %>%
  mutate(weekday = wday(started_at, label = TRUE)) %>%  
  group_by(member_casual,weekday) %>%
  summarize(number_of_rides = n(),
            average_duration = mean(ride_length_mins)) %>%
  arrange(member_casual,weekday)

# Visualize ridership by type and day_of_week

bike_rides_clean %>%
  mutate(weekday = wday(started_at, label = TRUE)) %>%
  group_by(member_casual,weekday) %>%
  summarize(number_of_rides = n(),
            average_duration = mean(ride_length_mins)) %>%
  arrange(member_casual,weekday) %>%
  ggplot(aes(x = weekday, y = number_of_rides, fill = member_casual))+geom_col(position="dodge")

# Visualize average duration of ride per rider type

bike_rides_clean %>%
  mutate(weekday = wday(started_at, label = TRUE)) %>%
  group_by(member_casual,weekday) %>%
  summarize(number_of_rides = n(),
            average_duration = mean(ride_length_mins)) %>%
  arrange(member_casual,weekday) %>%
  ggplot(aes(x = weekday, y = average_duration, fill = member_casual))+geom_col(position="dodge")

# Export summary files for further analysis
# Average ride_length & total rides per weekday

weekday_summary <- bike_rides_clean %>%
  mutate(weekday = wday(started_at, label = TRUE)) %>%
  group_by(member_casual,weekday) %>%
  summarize(number_of_rides = n(),
            average_duration = mean(ride_length_mins)) %>%
  arrange(member_casual,weekday)
write_csv(weekday_summary, "ride_length per weekday.csv")

# Average ride_length & total rides per month

month_summary <- bike_rides_clean %>%
  mutate(month = month(started_at, label = TRUE)) %>%
  group_by(member_casual,month) %>%
  summarize(number_of_rides = n(),
            average_duration = mean(ride_length_mins)) %>%
  arrange(member_casual,month) 
write_csv(month_summary, "average ride_length per month.csv")

# Station most used per rider type

summary_station <- bike_rides_clean %>%
  mutate(station = start_station_name) %>%
  group_by(start_station_name, member_casual) %>%
  summarise(number_of_rides = n()) %>%
  arrange(number_of_rides)
write_csv(summary_station, "summary_stations.csv")
