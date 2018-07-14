# Shiny app documentation

## Description
This app plots trends in various violent crimes that have occurred in Baltimore City, MD, USA over different time periods (day, week, etc.) covering a specified date range.

The data powering this app is collected and made publicly available by the Baltimore Police Department on Baltimore's Open Data portal, [Open Baltimore](https://data.baltimorecity.gov/). as ["Part 1 Victim Based Crime Data"](https://data.baltimorecity.gov/Public-Safety/BPD-Part-1-Victim-Based-Crime-Data/wsfq-mvij). For more information, including what data is available and when it is updated, please use the link to the data set.

## How to Customize the Plot
1. Select a start and end date of data to plot.
    - Data are available from `r min(crime$date)` to `r max(crime$date)`.
2. Choose the time period you'd like to group crimes into (day, week, month, or year).
3. Choose whether you'd like to compare the `count` or `distribution` of the data.
    - **Count** is the number of crimes during the specified period.
    - **Distribution** is the _density_ of crimes during the specified period. Use `Distribution` to compare trends in crimes with very different counts.
4. Choose which crimes to plot.
5. Choose whether to plot totals.
    - **Total - SELECTED crimes** is the total of crimes currently included in the plot
    - **Total - ALL crimes** is the total of all crimes in the data set.