# Austin, TX Micromobility

<b>Status</b>: Work in Progress

<b>Data source</b>: https://data.austintexas.gov/Transportation-and-Mobility/Shared-Micromobility-Vehicle-Trips/7d8e-dm7r 

<b>Research Question</b>: Did scooter usage differ in April 2020 compared to April 2019 and April 2018? More specifically differ in usage (duration and distance), days of the week, times of day.

<b>Lessons Learned</b>:
1. The Austin micromobility data is quite messy (surprisingly so). A few examples of messiness:
  - Some trips have durations that are longer than 24 hours. My suspicion is that in these cases the scooter forgot to be returned.
  - Some trips have distance traveled are longer than 500 miles. No idea how this could happen (especially if duration is shorter than 24 hours). The city of Austin covers a roughly 25 by 25 mile area. 
    - When I removed any rides that do are longer than 24 hours, distances longer than 500 miles, and distances that are zero, I was left with about one-third of the original dataset!
  - Some trips have an average speed faster than 100 miles per hour. There is no way that this is possible on an electric scooter. This is likely a result of the errors in distance or duration mentioned above. 
  - End_time and start_time variables do not have capture seconds (all seconds are 00). While the duration variable is in seconds. Durations do not match end_time minus start_time (it is close, but not exact). 
  - Some trips have end_time values that equal the start_time values, but have durations that are not zero!
2. It is hard to visualize distributions and/or challenging to make nice looking ridge plots.
