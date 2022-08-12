# Austin, TX Scooter Micromobility

<b>Status</b>: Complete

<b>Data source</b>: [City of Austin Open Data Portal](https://data.austintexas.gov/Transportation-and-Mobility/Shared-Micromobility-Vehicle-Trips/7d8e-dm7r)

<b>Research Question</b>: Did scooter usage differ in April 2020 compared to April 2019 and April 2018? More specifically differ in usage (duration and distance), days of the week, times of day.

<b> Analysis</b>: Scooter ridership was just beginning in April 2018 and the data show that most often scooter trips started between noon and 1 pm. The next year in April the trend looks pretty different with the peak number of trips starting at 5 pm. This April, the trend again is different with the peak number of trips starting at 7 pm.

However, that is not the most interesting finding in this graph. When reading graphs, it is important to analyze what the graph is showing, but also equally important to see what the graph is not showing. The April 2018 and April 2019 data show a steady drop in the number of scooter trips from 7 pm to midnight, which is a logical trend. In April 2020, however, that drop-off did not happen during that five-hour window; the number of trips was pretty steady.

Additionally, there are more trips happening between 7 pm and midnight than between noon and 5 pm (the time frame where the most trips happened in April 2019). 

![Graph](/graphics/04_april_by_hour.png)

I also extended this analysis by creating parametrized reports (see 05_parametrized_reports folder) to create individual html reports for April, May, June, and July.

<b>Skills Learned</b>:
1. Parametrizing rmarkdown reports
2. Learning and utilizing the Austin, TX Socrata Open Data API for Shared Micromobility Vehicle Trips data
3. Learning and utilizing tidyverse functions: select(), mutate(), group_by(), summarise(), arrange()

<b>Skills Utilized</b>:
1. Queried an API
2. Cleaned and exploring data using tidyverse functions
3. Visualized data using the ggplot2 package
4. Created r markdown reports using rmarkdown package
5. Created an animated gif using maggick package

<b>Lessons Learned</b>:
1. The Austin micromobility data is quite messy (surprisingly so). A few examples of messiness:
  - Some trips have durations that are longer than 24 hours. My suspicion is that in these cases the scooter forgot to be returned.
  - Some trips have distance traveled are longer than 500 miles. No idea how this could happen (especially if duration is shorter than 24 hours). The city of Austin covers a roughly 25 by 25 mile area. 
    - When I removed any rides that do are longer than 24 hours, distances longer than 500 miles, and distances that are zero, I was left with about one-third of the original dataset!
  - Some trips have an average speed faster than 100 miles per hour. There is no way that this is possible on an electric scooter. This is likely a result of the errors in distance or duration mentioned above. 
  - End_time and start_time variables do not have capture seconds (all seconds are 00). While the duration variable is in seconds. Durations do not match end_time minus start_time (it is close, but not exact). 
  - Some trips have end_time values that equal the start_time values, but have durations that are not zero!
2. It is hard to visualize distributions and/or challenging to make nice looking ridge plots.
