  library(readr)
  library(dplyr)
  library(ggplot2)
  library(tigris)  
  options(tigris_use_cache = TRUE)
  library(sf)
  library(purrr)
  # detach("package:sp", unload = TRUE)
  
  df <- readr::read_rds("03_clean_data/austin_mm_april_scooters_clean.rds")
  
  # clean up census_geoid vars a bit
  df$census_geoid_end[df$census_geoid_end == "None"] <- NA
  df$census_geoid_end[df$census_geoid_end == "0"] <- NA
  df$census_geoid_end[df$census_geoid_end == "OUT_OF_BOUNDS"] <- NA
  
  df$census_geoid_start[df$census_geoid_start == "0"] <- NA
  df$census_geoid_start[df$census_geoid_start == "OUT_OF_BOUNDS"] <- NA
  
  ## collapse number of trips by census tract start/end combos in 2020
  census_tract_2020 <- df %>% 
    filter(year == 2020) %>% 
    group_by(census_geoid_start, census_geoid_end) %>% 
    summarise(num_trips = n(),
              ave_trip_dist = round(mean(trip_dist_mi, na.rm = TRUE), 2),
              ave_trip_dur = round(mean(trip_dur_min, na.rm = TRUE),2),
              ave_trip_speed = round(mean(trip_ave_speed_mph, na.rm = TRUE),2), 
              prc_trip_apr = round((num_trips/10966)*100, 2)) %>% 
    arrange(desc(num_trips)) %>% 
    filter(num_trips >= 30)
  
  unique_tracts <- unique(c(df$census_geoid_start, df$census_geoid_end))

  ##download 2010 census tracts from the tigris package for Travis County, Texas
  travis_tracts <- tigris::tracts(state = "TX", county = "travis", year = 2010) #2010 specified by data  
  plot(travis_tracts)
  
  str(travis_tracts@data)
  names(travis_tracts)
  travis_tracts <- travis_tracts[ , c("GEOID10", "INTPTLAT10", "INTPTLON10")]
  names(travis_tracts)[2:3] <- c("lat10", "long10")
  travis_tracts$lat10 <- parse_number(travis_tracts$lat10) #make latitude numeric
  travis_tracts$long10 <- parse_number(travis_tracts$long10) # make longitude numeric
  
  length(unique(travis_tracts$GEOID10)) #218 unique census tracks in Travis County, Texas
  
  travis_tracts_uniq <- travis_tracts[travis_tracts$GEOID10 %in% unique_tracts, ]
  plot(travis_tracts_uniq)
  
  # travis_tracts_uniq_wgs84 <- spTransform(travis_tracts_uniq, CRSobj = CRS("+init=epsg:4326"))
  
  #add lat/long coords to census tract start and end locations
  flow_2020 <- census_tract_2020

  flow_2020 <- base::merge(flow_2020, travis_tracts,
                           by.x = "census_geoid_start", by.y = "GEOID10",
                           all.x = TRUE, all.y = FALSE)
  names(flow_2020)[(length(flow_2020) - 1):length(flow_2020)] <- c("s_lat10", "s_long10")

  flow_2020 <- base::merge(flow_2020, travis_tracts,
                           by.x = "census_geoid_end", by.y = "GEOID10",
                           all.x = TRUE, all.y = FALSE)
  names(flow_2020)[(length(flow_2020) - 1):length(flow_2020)] <- c("e_lat10", "e_long10")

  
  #based on: https://www.findingyourway.io/blog/2018/02/28/2018-02-28_great-circles-with-sf-and-leaflet/
  journeys_to_sf <- function(df, start_long = start.long, start_lat = start.lat,
                             end_long = end.long, end_lat = end.lat) {
    quo_start_long <- enquo(start_long)
    quo_start_lat <- enquo(start_lat)
    quo_end_long <- enquo(end_long)
    quo_end_lat <- enquo(end_lat)
    
    df %>%
      select(!! quo_start_long, !! quo_start_lat, !! quo_end_long, !! quo_end_lat) %>%
      transpose() %>%
      map(~ matrix(flatten_dbl(.), nrow = 2, byrow = TRUE)) %>%
      map(st_linestring) %>%
      st_sfc(crs = 4326) %>%
      st_sf(geometry = .) %>%
      bind_cols(df) %>%
      select(everything(), geometry)
  }
  
  
  new_df <- flow_2020 %>%
    journeys_to_sf(start_long = s_long10, start_lat = s_lat10, 
                   end_long = e_long10, end_lat = e_lat10) %>%
    st_segmentize(units::set_units(50, m)) 
  
  leaflet(new_df) %>%
    setView(lng = -97.74266, lat = 30.26648, zoom = 13) %>% 
    addProviderTiles(providers$CartoDB.Positron) %>%
    addPolygons(data = travis_tracts_uniq, fillOpacity = 0, 
                color = "darkgray", weight = 1, opacity = 0.5,
                label = ~GEOID10,
                labelOptions = labelOptions(noHide = T, 
                                            textOnly = TRUE, 
                                            textsize = "6px", 
                                            direction = "bottom")) %>% 
    addPolylines(weight = ~log10(num_trips), color = "sienna", opacity = 0.5,
                 highlightOptions = c(color = "turquoise", bringToFront = TRUE)) %>%
    addCircleMarkers(lng = ~s_long10, lat = ~s_lat10,
                     color = "green", opacity = 0.5, 
                     radius = 1.5, popup = ~census_geoid_start) %>%
    addCircleMarkers(lng = ~e_long10, lat = ~e_lat10,
                     color = "red", opacity = 0.5, 
                     radius = 0.5, popup = ~census_geoid_end) %>%
    addLegend(colors = c("green", "red"), labels = c("Journey start", "Journey end"))  
   
  #build out a shiny map: https://stackoverflow.com/questions/48781380/shiny-how-to-highlight-an-object-on-a-leaflet-map-when-selecting-a-record-in-a
  
  # library(tmap)
  # tmap_mode("view")
  # tm_basemap("CartoDB.Positron") +
  # tm_shape(travis_tracts) +
  #   tm_polygons("GEOID10", alpha = 0.5)

  # 
  # census_tract_2018 <- df %>% 
  #   filter(year == 2018) %>% 
  #   group_by(census_geoid_start, census_geoid_end) %>% 
  #   summarise(num_trips = n(),
  #             ave_trip_dist = round(mean(trip_dist_mi, na.rm = TRUE), 2),
  #             ave_trip_dur = round(mean(trip_dur_min, na.rm = TRUE), 2),
  #             ave_trip_speed = round(mean(trip_ave_speed_mph, na.rm = TRUE), 2), 
  #             prc_trip_apr = round((num_trips/54265)*100, 2)) %>% 
  #   arrange(desc(num_trips)) %>% 
  #   filter(num_trips >= 30)
  # 
  # census_tract_2019 <- df %>%
  #   filter(year == 2019) %>%
  #   group_by(census_geoid_start, census_geoid_end) %>%
  #   summarise(num_trips = n(),
  #             ave_trip_dist = round(mean(trip_dist_mi, na.rm = TRUE), 2),
  #             ave_trip_dur = round(mean(trip_dur_min, na.rm = TRUE), 2),
  #             ave_trip_speed = round(mean(trip_ave_speed_mph, na.rm = TRUE), 2),
  #             prc_trip_apr = round((num_trips/511212)*100, 2)) %>%
  #   arrange(desc(num_trips)) %>%
  #   filter(num_trips >= 30)
  # census_tract_2019 <- census_tract_2019[census_tract_2019$census_geoid_start != "" | census_tract_2019$census_geoid_end != "", ]
  
  # df_sub <- df %>% 
  #   filter(df$year == 2020) %>% 
  #   filter(day_of_month != 31) %>% 
  #   filter(hour >= 19 | hour == 0)
  # 
  # #make sure filtering worked properly
  # table(df_sub$year)
  # table(df_sub$hour)
  
  # length(unique(df_sub$census_geoid_start))
  # 
  # census_start <- df_sub %>% 
  #   select(census_geoid_start) %>% 
  #   group_by(census_geoid_start) %>% 
  #   summarise(count_start = n()) %>% 
  #   arrange(desc(count))
  # 
  # length(unique(df_sub$census_geoid_end))
  #   
  # (census_end <- df_sub %>% 
  #   select(census_geoid_end) %>% 
  #   group_by(census_geoid_end) %>% 
  #   summarise(count_end = n()) %>% 
  #   arrange(desc(count))) 