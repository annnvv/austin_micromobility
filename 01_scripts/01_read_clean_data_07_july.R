  library(readr)
  library(tibble)
  library(dplyr)
  
  # library(config)
  # library(RSocrata)
  ## data from City of Austin, TX Shared Micromobility Vehicle Trips
  ## https://data.austintexas.gov/Transportation-and-Mobility/Shared-Micromobility-Vehicle-Trips/7d8e-dm7r
  
  ## Note that our official trip reporting metrics only include trips which meet the following criteria:
  ## - trip distance greater than or equal to .1 miles and less than 500 miles
  ## - trip duration less than 24 hours
  ## av.note: will need to filter data to match this criteria
  
  ##total number of observations: 9.04M (as of 2020-05-04)
  
  # config vignette: https://cran.r-project.org/web/packages/config/vignettes/introduction.html
  config <- config::get(file = "00_config/config.yml", use_parent = FALSE)
  
  raw <- RSocrata::read.socrata("https://data.austintexas.gov/resource/7d8e-dm7r.csv?month=7&vehicle_type=scooter",
                                app_token = config$app_token,
                                email     = config$email,
                                password  = config$password,
                                stringsAsFactors = FALSE
  )
  (raw <- dplyr::as_tibble(raw))
  
  #saving raw data so I don't have to keep running the query (can reload this later)
  write_rds(raw, "02_raw_data/austin_mm_july_scooters.rds")
  # 
  # raw <- readr::read_rds("02_raw_data/austin_mm_july_scooters.rds")
  
  # preview data with glimpse
  raw %>% 
    tibble::glimpse()
  #trip duration in seconds
  #trip distance in meters
  
  length(unique(raw$trip_id)) ##unique identifier for trips
  
  length(unique(raw$device_id))# 18591 unique scooters, though not a useful var to analyze
  
  table(raw$vehicle_type) # all scooters (as per query); can drop var from data
  table(raw$month)
  table(raw$year) #2018, 2019, and 2020!
  
  length(unique(raw$council_district_start)) #12 unique council districts
  length(unique(raw$council_district_end)) #12 unique council districts
  ## though there are only 10 districts in Austin
  table(raw$council_district_end)
  table(raw$council_district_start)
  ## issues with empty string, 0, and None (will probably drop these two vars)
  
  length(unique(raw$census_geoid_start)) #161 unique 2010 census tracks
  length(unique(raw$census_geoid_end)) #167 unique 2010 census tracks
  # will need to clean the above vars as well: empty string 0, and OUT_OF_BOUNDS
  ## probably will want to use census tracks, as oppose to council districts, 
  ## smaller unit of geographic analysis
  
  summary(raw$trip_duration)
  hist(raw$trip_duration/60/60, nclass = 60) #in hours
  prop.table(table(raw$trip_duration > 24*60*60))*100 #24 hours
  
  summary(raw$trip_distance/1000) #ugh, negative distances (in km)
  prop.table(table(raw$trip_distance < 0))*100 #all false
  prop.table(table(raw$trip_distance > 500*1609.34))*100 #500 miles
  
  table(raw$trip_duration == 0 & raw$trip_distance == 0)
  
  ## want to add following variables:
  ## - convert day of week (from numeric to Mon through Sun)
  ## - day of month
  ## - weekend or weekday
  ## drop vars:
  ## - vehicle_type
  ## - modified_date
  ## - council_district_start and council_district_end
  ## - device_id
  
  scooters_clean <- raw
  # drop trips where there are no durations and no distances!
  table(scooters_clean$trip_duration == 0 & scooters_clean$trip_distance == 0)
  scooters_clean <- scooters_clean[raw$trip_duration != 0 & raw$trip_distance != 0, ]
  
  ##make NA an trip that was longer than 24 hours
  scooters_clean$trip_duration[scooters_clean$trip_duration > 24*60*60] <- NA
  ##make NA any trip that had a distance less than zero or more than 500 miles 
  scooters_clean$trip_distance[scooters_clean$trip_distance < 0] <- NA
  scooters_clean$trip_distance[scooters_clean$trip_distance >= 500*1609.34] <- NA
  
  # generate several vars and remove unncessary ones
  scooters_clean2 <- scooters_clean %>%
    select(-vehicle_type,  -council_district_start, -council_district_end,
           -modified_date,
           -device_id) %>% 
    mutate(
      day_of_month = substr(start_time, 9, 10),
      day_of_week_str = weekdays(start_time, abbreviate = FALSE),
      trip_dur_min = round(trip_duration/60, 4),
      trip_dist_mi = round(trip_distance*0.000621371, 4), 
      trip_ave_speed_mph = round((trip_distance*0.000621371)/(trip_dur_min/60), 4),
      stayed_same_census = ifelse(census_geoid_start == census_geoid_end, 1, 0)
    ) %>% 
    select(-day_of_week) #, -census_geoid_start, -census_geoid_end
  
  #create a weekend variable
  scooters_clean2$weekend <- NA
  scooters_clean2$weekend[scooters_clean2$day_of_week_str == "Saturday" | scooters_clean2$day_of_week_str == "Sunday"] <- 1
  scooters_clean2$weekend[is.na(scooters_clean2$weekend)] <- 0
  table(scooters_clean2$day_of_week_str, scooters_clean2$weekend)
  
  # clean up average speed var (make any speed more than 55 mph NA, any faster is implausable on a scooter)
  summary(scooters_clean2$trip_ave_speed_mph)
  scooters_clean2$trip_ave_speed_mph[scooters_clean2$trip_ave_speed_mph >= 55] <- NA 
  hist(scooters_clean2$trip_ave_speed_mph)
  
  # clean up census_geoid vars a bit
  scooters_clean2$census_geoid_end[scooters_clean2$census_geoid_end == "None"] <- ""
  scooters_clean2$census_geoid_end[scooters_clean2$census_geoid_end == "0"] <- ""
  scooters_clean2$census_geoid_end[scooters_clean2$census_geoid_end == "OUT_OF_BOUNDS"] <- ""
  
  scooters_clean2$census_geoid_start[scooters_clean2$census_geoid_start == "0"] <- ""
  scooters_clean2$census_geoid_start[scooters_clean2$census_geoid_start == "OUT_OF_BOUNDS"] <- ""
  
  write_rds(scooters_clean2, "03_clean_data/austin_mm_july_scooters_clean.rds") 
