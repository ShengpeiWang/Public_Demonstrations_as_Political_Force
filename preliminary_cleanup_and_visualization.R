# Prep the working envi.
library(tidyverse)

# Bringing in the data
# Mass mobilization record in autocracies 2002-2015
dat_MMAD = read_csv("data/events_Mass_Mobilization_in_Autocracies_Database.csv")
# 76 countries

# Country code from The correlates of war project
dat_COW = read_csv("data/COW country codes.csv") 

# The Rulers, Elections, and Irregular Governance Dataset
dat_REIGN = read_csv("data/REIGN_2019_4.csv") 
#summary(dat_REIGN$year)
#length(unique(dat_REIGN$ccode))
# Data on 201 countries from 1950 to now