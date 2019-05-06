Are Public Demonstrations a Driving Force for Politics?
================
Shengpei Wang
May 6, 2019

Is protest useful?
==================

Public demonstrations have a long history to driving political changes around the globe, such as the Civil Rights Movement in the US, the Indian Independence Movement in Idia, and The Defiance Campaign in South Africa. The effects of demonstrations have been studied in detail in some specific cases, such as the Tea Party movement in the US (Madestam *et. al* 2011). However, wether demonstrations are generally effective as a political force is still unclear.

A complicating factor affecting the effectiveness of demonstrations is the political environment in which demonstrations happen. We may expect that people are more prone to attend public demonstrations in democratic systems, becuase attending demonstrations might be seen as an effective political action. Alternatively, demonstrations could be more common in authoritarian regimes, because alternative political actions were unavailable, such as in the case of the Arab Spring Uprising in Egypt. Given the increasing social impacts of demonstrations through social media, it is more urgen than ever to undersand the prevelence and effectiveness of public demonstrations in different political systems.

I propose to investige the prevelence and effectiveness of demonstrations by intigrating information from two large public datasets: The Rulers, Elections, and Irregular Governance Dataset (REIGN; Bell 2016) and the Mass Mobilization in Autocracies Database (MMAD; Weidmann *et. al* forthcoming). The REIGN data records the leader and regime information for 201 countries from 1950, whiel the MMAD data records incidents of political demonstrations in 76 countries from 2002 to 2015. By combining both data sources, I will be able to examine both the political environment and the political outcome of public demonstrations across the world,

Data Sources and description:
=============================

Both datasets are publicly available on their websites:

-   REIGN: <https://oefresearch.org/datasets/reign>
-   MMAD: <https://mmadatabase.org/>

The REIGN dataset. I downloaded the most recent full dataset from their archive.

This is a fairly complicated dataset, and I will be focusing on only some of the variables for the preliminary exploration. Each row records the leader and political environment of a single month in each country.

-   "ccode" is the country code based on the The Correlates of War Project
-   "country" is the name of the country
-   "leader" is the name of the leader during the recorded time
-   "elected" represents whether the leader is elected to office (1) or not (0).
-   "tenure\_months" is the length of the tenure of the leader for the month of record
-   "government" is the type of political regime of the country at the month of record.

<!-- -->

    ## # A tibble: 6 x 6
    ##   ccode country leader elected tenure_months government            
    ##   <dbl> <chr>   <chr>    <dbl>         <dbl> <chr>                 
    ## 1     2 USA     Truman       1            58 Presidential Democracy
    ## 2     2 USA     Truman       1            59 Presidential Democracy
    ## 3     2 USA     Truman       1            60 Presidential Democracy
    ## 4     2 USA     Truman       1            61 Presidential Democracy
    ## 5     2 USA     Truman       1            62 Presidential Democracy
    ## 6     2 USA     Truman       1            63 Presidential Democracy

Look at the MMAD dataset. I obtained the data describing the incidents of each recorded event.

-   "cowcode" is the unique country code also based on the The Correlates of War Project.
-   "asciiname" is the city where the demonstration happened.
-   "event\_date" is the date when the demonstration happened.
-   "side" represents whether the demonstration is pro-regime (0), anti-regime (1) or domestic public/non-government (3). I will
-   "mean\_avg\_numparticipants" represent the best estimate of the size of the demonstrations.

<!-- -->

    ## # A tibble: 6 x 5
    ##   cowcode asciiname        event_date  side mean_avg_numparticipants
    ##     <dbl> <chr>            <date>     <dbl>                    <dbl>
    ## 1      40 Vertientes       2003-05-11     0                      NA 
    ## 2      40 Velasco          2011-11-24     1                      NA 
    ## 3      40 Santiago de Cuba 2003-05-01     0                      NA 
    ## 4      40 Santiago de Cuba 2003-12-07     0                    2000 
    ## 5      40 Santiago de Cuba 2004-06-14     0                      NA 
    ## 6      40 Santiago de Cuba 2007-12-04     1                     217.

Bibliography
------------

Madestam, A., Shoag, D., Veuger, S. and Yanagizawa-Drott, D., 2013. Do political protests matter? evidence from the tea party movement. The Quarterly Journal of Economics, 128(4), pp.1633-1685.

Bell, Curtis. 2016. The Rulers, Elections, and Irregular Governance Dataset (REIGN). Broomfield, CO: OEF Research. Available at oefresearch.org

Weidmann, Nils B. and Espen Geelmuyden Rød. The Internet and Political Protest in Autocracies. Chapter 4. Oxford University Press, forthcoming.
