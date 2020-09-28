  library(readr)
  library(dplyr)
  library(ggplot2)
  theme_set(theme_bw())
  
  
  #color palettes to be used in graphics
  col2 <- c("1" = "#F2A900", #Pure (or mostly pure) orange
            "0" = "#a2a4a1"  #Silver 
  )
  col3 <- c("2018" = "#00B140", #Dark cyan - lime green
            "2019" = "#003594", #Dark blue
            "2020" = "#BF0D3E"  #Strong pink
  )
  
  data_src <- "Data Source: City of Austin Open Data Portal \n https://data.austintexas.gov/"
  loc <- "Location: Austin, TX"
  
  
  
  apr <- readr::read_rds("03_clean_data/austin_mm_april_scooters_clean.rds")
    apr$month_str <- "April"
  may <- readr::read_rds("03_clean_data/austin_mm_may_scooters_clean.rds")
    may$month_str <- "May"
  jun <- readr::read_rds("03_clean_data/austin_mm_june_scooters_clean.rds")
    jun$month_str <- "June"
  jul <- readr::read_rds("03_clean_data/austin_mm_july_scooters_clean.rds")
    jul$month_str <- "July"
  
  df <- rbind(apr, may, jun, jul)  
  rm(apr, may, jun, jul)
    
  
  mo_levels = c("April", "May", "June", "July")
  
  count_by_hour <- df %>% 
    group_by(year, month_str, hour) %>% 
    summarise(count = n()) %>% 
    mutate(month = factor(month_str, levels = mo_levels)) %>% 
    arrange(hour, month, year) 
    
  count_by_hour_APR <- count_by_hour[count_by_hour$month == "April", ]
  count_by_hour_MAY <- count_by_hour[count_by_hour$month == "May", ]
  count_by_hour_JUN <- count_by_hour[count_by_hour$month == "June", ]
  count_by_hour_JUL <- count_by_hour[count_by_hour$month == "July", ]
  
  ggplot(count_by_hour_JUL, 
         aes(x = hour, y = count, fill = as.character(year))) +
    geom_col() +
    geom_text(aes(label = format(count, big.mark = ",")), vjust = -0.3, size = 2) +
    facet_wrap(vars(year), nrow = 3, scales = "free_y") +
    labs(title = "Number of Scooter Trips by Hour - in July by Year", 
         subtitle = loc,     
         caption = data_src) +
    ylab("Number of Scooter Trips") +
    xlab("Hour of day [0-23]") +
    # theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
    scale_x_continuous(breaks = seq(0, 23, 1)) +
    scale_fill_manual(values = col3, guide = FALSE) 
  
  library(magick)
  library(purrr)
  
  list.files(path = "graphics", 
             pattern = "*_by_hour.png", full.names = TRUE) %>% 
    map(image_read) %>% # reads each path file
    image_join() %>% # joins image
    # the larger the frames per second (fps) the faster the image transition, 
    # a lower fps means the images change more slowly
    image_animate(fps = 0.25) %>% # animates, can opt for number of loops 
    image_write("graphics/by_hour_GIF.gif") # write to current dir
  