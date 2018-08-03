========================================================
autosize: true
css: slide_styles.css

<h1 class="title">How Does Violent Crime Change in a Major US City?</h1>

<p class="title author">J. Allen Baron<br>
August 3, 2018</span></p>

Slide2
========================================================
title: false
incremental: true
class: catchy

<p>You've lived a few years now...</p>
<p>Does it seem things are getting <span class="violent">worse</span>?</p>
<p><span class="violent">Violent crimes</span> are constantly in the news.
<img src="images/news-97862_1280.png"> </p>
<p>But, has it really gotten that <span class="violent">bad</span>?</p>



Now you can check yourself!
========================================================
class: larger
incremental: true

Check out the new interactive graphing app, <br>
<a href = "https://jabaron-phd.shinyapps.io/Baltimore_crime_trends/" class = "violent"> Violent Crime Trends in Baltimore, Maryland, USA</a>, <br> where you can explore how crimes change over time.

<section style = "font-size: 70%; line-height: 1;">
<p>To get you started here are just a few interesting questions you can ask:</p>
- Are violent crimes affected by seasons?
    - Hint: Look at the total crimes over the entire date range.
- How do different crimes change after a major violent events?
    - Hint: Compare crimes before and after the violent protests initiated by the death of <a href="https://en.wikipedia.org/wiki/2015_Baltimore_protests">Freddy Gray</a> in late April 2015.
- Do all violent crimes change in similar patterns?
- Are there relationships between specific types of crimes?
</section>

For More Intense Explorers: Events!
========================================================

<small>
To go <span style = "font-weight: bold; font-style: italic;">deeper</span>, see how 
<span class = "violent">crimes</span> are affected by various annual events. A list can be found on <a href = "https://en.wikipedia.org/wiki/List_of_events_in_Baltimore">Wikipedia</a>.

Some interesting events include (collected with R, see next slide for code):



<!--html_preserve--><ul><li><a href="https://en.wikipedia.org/wiki/Maryland_Film_Festival" title="Maryland Film Festival">Maryland Film Festival</a></li> <li><a href="https://en.wikipedia.org/wiki/Baltimore_Comic-Con" title="Baltimore Comic-Con">Baltimore Comic-Con</a></li> <li><a href="https://en.wikipedia.org/wiki/Kinetic_sculpture_race" title="Kinetic sculpture race">Kinetic sculpture race</a></li> <li><a href="https://en.wikipedia.org/wiki/Preakness_Stakes" title="Preakness Stakes">Preakness Stakes</a></li> <li><a href="https://en.wikipedia.org/wiki/HonFest" title="HonFest">HonFest</a></li> <li><a href="https://en.wikipedia.org/wiki/Insubordination_Fest" title="Insubordination Fest">Insubordination Fest</a></li> <li><a href="https://en.wikipedia.org/wiki/Grand_Prix_of_Baltimore" title="Grand Prix of Baltimore">Grand Prix of Baltimore</a></li></ul><!--/html_preserve-->

</small>


Have fun exploring!
========================================================

P.S. Baltimore is truly a unique and beautiful city:  <i>Charm City</i>.

Code used for previous slide:

```r
library(rvest)
library(stringr)
library(htmltools)
```


```r
events_wiki <- read_html("https://en.wikipedia.org/wiki/List_of_events_in_Baltimore")
selected <- c(4, 6, 7:8, 10, 12, 16)
links <- html_nodes(events_wiki, "h2 ~ ul a") %>%
    as.character() %>%
    .[selected] %>%
    str_replace(
        pattern = "/wiki/",
        replacement = "https://en.wikipedia.org/wiki/"
        ) %>%
    paste0("<li>", ., "</li>", collapse = " ") %>%
    paste0("<ul>", ., "</ul>") %>%
    HTML()
links
```
