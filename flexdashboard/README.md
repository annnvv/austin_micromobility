# Austin, TX Scooter Micromobility

**Status**: IN PROGRESS

**Purpose**: I have always wanted to make a dashboard, this micromobility dataset provided an opportunity to do so. 
Additionally, I wanted to create an interactive dashboard. Using flexdashboard with shiny reactive objects, I was able to do this. 

**Data source**: [City of Austin Open Data Portal](https://data.austintexas.gov/Transportation-and-Mobility/Shared-Micromobility-Vehicle-Trips/7d8e-dm7r)

**Skills Learned/Utilized**:
1. Shiny reactivity in rmarkdown
2. Flexdashboard in rmarkdown


**Areas of Improvement/Known Issues**:
- The app is quite slow to download the data via the RSocrata API and refresh the app. I hypothesize that using the `httr` package would be faster.
- Issues with dates for the API request and that BETWEEN is inclusive of the end date.
