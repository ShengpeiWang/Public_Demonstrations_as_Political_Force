Are Public Demonstrations a Driving Force for Politics?
================
Sheng Pei Wang
May 6, 2019

Is protesting useful?
=====================

Public demonstrations have a long history of driving political changes around the globe, such as the Civil Rights Movement in the US, the Indian Independence Movement in India, and The Defiance Campaign in South Africa. The effects of demonstrations have been studied in detail in some specific cases, such as the Tea Party movement in the US (Madestam *et. al* 2011). However, whether demonstrations are generally effective as a political force is still unclear.

A complicating factor affecting the effectiveness of demonstrations is the political environment in which demonstrations happen. We may expect that people are more inclined to attend public demonstrations in democratic systems, because attending demonstrations might be seen as an effective political action. Alternatively, demonstrations could be more common in authoritarian regimes, because alternative political actions may not be available or perceived to be effective, such as in the case of the Arab Spring Uprising in Egypt. Given the increasing social impacts of demonstrations through social media, it is more urgent than ever to understand the prevalence and effectiveness of public demonstrations in different political systems.

I propose to investigate the prevalence and effectiveness of demonstrations by integrating information from two large public datasets: The Rulers, Elections, and Irregular Governance Dataset (REIGN; Bell 2016) and the Mass Mobilization in Autocracies Database (MMAD; Weidmann *et. al* forthcoming). The REIGN data records the leader and regime information from 201 countries between 1950-current, while the MMAD data records incidents of political demonstrations in 76 countries between 2002 and 2015. By combining both data sources, I plan to examine both the political environments and the political outcomes of public demonstrations across the world,

I have four major questions/objectives of interest:

-   **What types of public demonstrations happen in democratic regime versus autocratic regimes?**
    -   Are pro-regime demonstrations more or less common than anti-regime demonstrations?
    -   Does the frequency of pro- vs anti-regime demonstration differ depending on the types of regimes?
-   **What types of public demonstrations have the largest impact on society?**
    -   Which demonstrations do people attend?
    -   Do elections change the size of demonstrations?
    -   Are demonstration sizes or locations correlated with different election results?
    -   Are demonstration sizes or locations correlated with changes in the leadership?
-   **Which is the cause: Do governments respond to demonstrations or do people demonstrate in response to governments?**
    -   What kinds of demonstrations happen before an election or leadership change?
    -   What kinds of demonstrations happen after an election or leadership change?
    -   Are elections or leadership changes more likely to happen before or after demonstrations?
    -   Are authoritarian leaders more likely to step down after demonstrations?
-   **Can we predict the political changes given the current political environment and the prevalence of demonstrations around the world?**
    -   Build a machine learning algorithm that predicts whether elections or leadership changes will happen given the current government regimes and the type and amount of demonstrations.
    -   Build a machine learning algorithm that predicts what kinds of demonstrations will happen given the political environment.

Answering these questions will help us understand roles of public demonstrations in driving political changes. The results can help inform citizens when making political decisions regarding activism. The insights can further help policy makers understand, predict, and possibly prepare for political trajectories of different countries around the world.

Methods
=======

I will investigate these questions by joining the two datasets and investigate the correlations among the different factors in each question. There are two major ways I plan to structure the data. One way is to examine the political environments and demonstrations that occur during the same time period, and this will give us whether these factors are correlated in different countries. An alternative way is to examine the temporal order of events that represents political changes and demonstrations, and I will data in this structure to untangle the causal factors as well as to build the predicative models.

I will use a variety of statistical and machine learning approaches to test alternative hypotheses and use different visualizions to communicate the results. I will use xi-squared test and logistic regression for many of the questions about correlations. I will use linear mixed models and clustering analysis to build the predicative models.

I plan to extend these analyses to include other important factors such as the economic, social, and religious situations of each country over time. These factors can affect both the political environment and people's willingness and desire to demonstrate. I have obtained data from the Human Mortality Database that contains historical demographic information of different countries. I have also obtained and the World Religion Data that details the religious composition of each country (Maoz and Henderson 2013). Integration of these additional data sources will allow me to obtain a more holistic view of the drivers of political changes around the world.

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
-   "side" represents whether the demonstration is pro-regime (0), anti-regime (1) or domestic public/non-government (3). Domestic demonstrations are rare and does not affect my questions, so I will removed them for my analyses.
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
