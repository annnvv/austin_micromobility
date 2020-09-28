  library(readr)
  library(dplyr)
  library(ggplot2)
  
  df <- readr::read_rds("03_clean_data/austin_mm_april_scooters_clean.rds")
  
  data_src <- "Data Source: City of Austin Open Data Portal \n https://data.austintexas.gov/"
  loc <- "Location: Austin, TX"
  
  ## collapse number of trips by census tract start/end combos in 2020 (with more than 30 trips)
  census_tract_2020 <- df %>% 
    filter(year == 2020) %>% 
    group_by(census_geoid_start, census_geoid_end) %>% 
    summarise(num_trips = n()
              # ,ave_trip_dist = round(mean(trip_dist_mi, na.rm = TRUE), 2),
              # ave_trip_dur = round(mean(trip_dur_min, na.rm = TRUE),2),
              # ave_trip_speed = round(mean(trip_ave_speed_mph, na.rm = TRUE),2), 
              # prc_trip_apr = round((num_trips/10966)*100, 2)
              ) %>% 
    arrange(desc(num_trips)) %>% 
    filter(num_trips >= 10)

  ## heatmap - all April 2020 data
  ggplot(census_tract_2020, aes(census_geoid_start, 
                                census_geoid_end)) + 
    geom_tile(aes(fill = num_trips)) +
    geom_text(aes(label = format(num_trips, big.mark = ",")), 
              col = 'black', size = 1.5) +
    scale_fill_gradient(low = "white", high = "red", na.value = NA) +
    theme_bw() +
    labs(title = "Number of Scooter Trips - in April 2020 by Census Tract", 
         subtitle = paste0("Census tracts with fewer than 10 trips are not displayed \n", loc),
         caption = data_src, 
         fill = "# of trips") +
    xlab("Census tract where trip started") +
    ylab("Census tract where trip ended") +
    theme(text = element_text(size = 9),
          axis.text.x = element_text(angle = 90),
          axis.ticks = element_blank(),
          # axis.line = element_blank(),
          panel.border = element_blank(),
          panel.grid.major = element_line(color = '#eeeeee')) 
  
  
  ## heatmap - Noon - 5pm April 2020 data
  census_tract_2020_12_17 <- df %>% 
    filter(year == 2020) %>% 
    filter(hour >= 12 & hour <= 17) %>% 
    group_by(census_geoid_start, census_geoid_end) %>% 
    summarise(num_trips = n(),
              ave_trip_dist = round(mean(trip_dist_mi, na.rm = TRUE), 2),
              ave_trip_dur = round(mean(trip_dur_min, na.rm = TRUE),2),
              ave_trip_speed = round(mean(trip_ave_speed_mph, na.rm = TRUE),2), 
              prc_trip_apr = round((num_trips/10966)*100, 2)) %>% 
    arrange(desc(num_trips)) %>% 
    filter(num_trips >= 10)
  
  ggplot(census_tract_2020_12_17, aes(census_geoid_end,
                                      census_geoid_start)) + 
    geom_tile(aes(fill = num_trips)) +
    geom_text(aes(label = format(num_trips, big.mark = ",")), 
              col = 'black', size = 1.5) +
    scale_fill_gradient(low = "white", high = "red", na.value = NA) +
    theme_bw() +
    labs(title = "Number of Scooter Trips - in April 2020 by Census Tract (between noon and 5 pm)", 
         subtitle = paste0("Census tracts with fewer than 10 trips are not displayed \n", loc),
         caption = data_src, 
         fill = "# of trips") +
    xlab("Census tract where trip ended") +
    ylab("Census tract where trip started") +
    theme(text = element_text(size = 9),
          axis.text.x = element_text(angle = 90),
          axis.ticks = element_blank(),
          # axis.line = element_blank(),
          panel.border = element_blank(),
          panel.grid.major = element_line(color = '#eeeeee'))  
  
  ggsave("graphics/heatmap_trips_2020_12_17.png", plot = last_plot(), 
         device = "png", dpi = 320) 
  
  ## heatmap - 7pm - midnight April 2020 data
  census_tract_2020_19_24 <- df %>% 
    filter(year == 2020) %>% 
    filter(hour >= 19 | hour == 0) %>% 
    group_by(census_geoid_start, census_geoid_end) %>% 
    summarise(num_trips = n(),
              ave_trip_dist = round(mean(trip_dist_mi, na.rm = TRUE), 2),
              ave_trip_dur = round(mean(trip_dur_min, na.rm = TRUE),2),
              ave_trip_speed = round(mean(trip_ave_speed_mph, na.rm = TRUE),2), 
              prc_trip_apr = round((num_trips/10966)*100, 2)) %>% 
    arrange(desc(num_trips)) %>% 
    filter(num_trips >= 10)
  
  ggplot(census_tract_2020_19_24, aes(census_geoid_end,
                                      census_geoid_start)) + 
    geom_tile(aes(fill = num_trips)) +
    geom_text(aes(label = format(num_trips, big.mark = ",")), 
              col = 'black', size = 1.5) +
    scale_fill_gradient(low = "white", high = "red", na.value = NA) +
    theme_bw() +
    labs(title = "Number of Scooter Trips - in April 2020 by Census Tract (between 7pm  and midnight)", 
         subtitle = paste0("Census tracts with fewer than 10 trips are not displayed \n", loc),
         caption = data_src, 
         fill = "# of trips") +
    xlab("Census tract where trip ended") +
    ylab("Census tract where trip started") +
    theme(text = element_text(size = 9),
          axis.text.x = element_text(angle = 90),
          axis.ticks = element_blank(),
          # axis.line = element_blank(),
          panel.border = element_blank(),
          panel.grid.major = element_line(color = '#eeeeee'))  

  ggsave("graphics/heatmap_trips_2020_19_24.png", plot = last_plot(), 
         device = "png", dpi = 320)  