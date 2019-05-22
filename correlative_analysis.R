# Run stats on the patterns I have found.
# depends on the data from "preliminary_cleanup_and_visualization"

# prep env. for jags
library(rjags)
library(runjags)
library(lme4)

calc_r_squared_glm = function(model){
  r_sq = 1 - model$deviance/model$null.deviance
  return(r_sq)
}

#  More demonstrations during autocracies?----
# Test how wether demonstrations happen more or less in diff. gov.s
# need data_REIGN_0315_MMAD 

# Number of demonstrations by month and country
data_month_dem =
  data_REIGN_0315_MMAD %>% 
  group_by(ccode, year, month, country, leader, government, elected, tenure_months) %>% 
  summarise(total_dem = sum(dem_n)) %>% 
  mutate(is_dem = total_dem >0)
# The is_dem (is there a demonstration in that month) is super 0 inflated

# Look at data distribution, not great..
ggplot(data = data_REIGN_0315_wide)+
  facet_wrap(~government)+
  geom_histogram(aes(prop_non))

# Run an ANOVA:  
fit_pro_non_month = aov(prop_non ~ government, data = data_REIGN_0315_wide )
# plot(fit_pro_non_month)
# Residules is not skewed
summary(fit_pro_non_month)
# Significant differences among governments.
# F = 2.634, and p = 0.0033
plot(TukeyHSD(fit_pro_non_month))
# only Personal Dictatorship is significantly different than Presidential Democracy after post hoc correction

# Test the effect of election in # of months when demonstrations happen-----
data_total_months_elected = 
  data_REIGN %>% filter(year <2016 & year > 2002) %>% group_by(ccode, government, elected) %>% summarise(total = n())

data_REIGN_0315_wide_elected = 
  data_REIGN_0315 %>% 
  group_by(ccode, country, government, side, elected) %>% 
  summarise(n_months = n()) %>% 
  spread(side, n_months) %>% 
  right_join(data_MMAD %>% select(ccode) %>% unique()) %>% 
  rename(pro = `0`, anti = `1`, non = `<NA>`) %>% 
  left_join(data_total_months_elected) %>% 
  rowwise() %>% 
  mutate(both_pro_anti = sum(c(pro, anti, non), na.rm = T) - total) %>% 
  mutate(pro_only = pro - both_pro_anti, anti_only = anti - both_pro_anti) %>% 
  mutate(prop_non = non/total, prop_pro = pro/total, prop_anti = anti/total) %>% 
  mutate(prop_pro = if_else(is.na(prop_pro), 0, prop_pro),
         prop_anti= if_else(is.na(prop_anti), 0, prop_anti)) %>% 
  select(country, government, elected, prop_pro, prop_anti) %>% 
  gather("type", "prop", -country, -government, -elected)

# For pro demonstrations
fit_pro_type_month = lm(prop ~ elected*government, 
                         data = data_REIGN_0315_wide_elected %>% filter(type == "prop_pro"))
plot(fit_pro_type_month)
summary(fit_pro_type_month)
# Election does not change how many months either pro or anti demonstrations happen.
# Except marginally for Personal Dictatorship


# For anti demonstrations
fit_pro_type_month_anti = lm(prop ~  elected*government, 
                         data = data_REIGN_0315_wide_elected %>% filter(type == "prop_anti"))
summary(fit_pro_type_month_anti)
# Sinificantly more anti_demonstrations in Military-Personal and Personal Dictatorship

# Test the effect of election in # of demonstrations per month----
data_MMAD_gov = 
  data_REIGN_0315 %>% 
  group_by(ccode, country, government, dem_type, elected) %>% 
  summarise(size_mean = mean(dem_n)) %>% 
  filter(dem_type != "no demonstration")
hist(log(data_MMAD_gov$size_mean))

fit_num_type_month = lm(log(size_mean) ~ elected*government, 
                         data = data_MMAD_gov %>% filter(dem_type == "Pro-regime"))
plot(fit_num_type_month)
summary(fit_num_type_month)
# gOvernment has a huge effect, while election marginally
# Party-Personal-Military Hybrid has significantly higher intensities

fit_num_type_month_anti = lm(log(size_mean) ~ elected*government, 
                         data = data_MMAD_gov %>% filter(dem_type == "Anti-regime"))
plot(fit_num_type_month_anti)
summary(fit_num_type_month_anti)
# Foreign/Occupied has siginifcantly higher intensities
# Significant interaction for democracies only

# Test larger elections elected or not ----
fit_num_elected = 
  glm(side ~ elected + government,
        family = binomial(link = 'logit'),
       data = data_MMAD_REIGN)
summary(fit_num_elected)

fit_size_elected_raw = 
  lmer(mean_avg_numparticipants ~ elected*dem_type + government + (1|country), 
       data = data_MMAD_REIGN)
summary(fit_size_elected_raw)

fit_size_elected_raw_reduced = 
  lmer(mean_avg_numparticipants ~ government + (1|country), 
       data = data_MMAD_REIGN)

anova(fit_size_elected_raw, fit_size_elected_raw_reduced)
# Test the effect of election on demonstration size----
fit_size_elected = 
  lmer(log(mean_avg_numparticipants) ~ elected*government + age + male + militarycareer + (1|country), 
       data = data_MMAD_REIGN %>% filter(dem_type == "Pro-regime"))
summary(fit_size_elected)
fit_size_elected_reduced = lmer(log(mean_avg_numparticipants) ~ government + age + male + militarycareer + (1|country), 
       data = data_MMAD_REIGN %>% filter(dem_type == "Pro-regime"))
anova(fit_size_elected_reduced, fit_size_elected)
# Bigger 

fit_size_elected_anti = 
  lmer(log(mean_avg_numparticipants) ~ elected*government + age + male + militarycareer + (1|country), 
       data = data_MMAD_REIGN %>% filter(dem_type == "Anti-regime"))
summary(fit_size_elected_anti)
fit_size_elected_reduced_anti = lmer(log(mean_avg_numparticipants) ~ government + age + male + militarycareer + (1|country), 
       data = data_MMAD_REIGN %>% filter(dem_type == "Anti-regime"))
anova(fit_size_elected_reduced_anti, fit_size_elected_anti)
# The effects of election is small


# More demonstration at the beginning or the end of tenure?
data_REIGN_0315_analysis = 
  data_REIGN_0315 %>% 
  mutate(time_before_after = if_else(time_of_tenure > 0.5, "before", "after")) %>% 
  mutate(time_from_leader = if_else(time_of_tenure > 0.5, time_of_tenure - 1, time_of_tenure)) %>% 
  mutate(time_from_leader_abs = if_else(time_of_tenure > 0.5, 1 - time_of_tenure, time_of_tenure)) %>% 
  mutate(time_quarter = case_when(time_of_tenure <= 0.25 ~ "1st",
                                  time_of_tenure <= 0.5 ~ "2nd",
                                  time_of_tenure <= 0.75 ~ "3rd",
                                  TRUE ~ "4th")) #%>% 
  #filter(dem_n >0)

hist(log(data_REIGN_0315_analysis$dem_n))

fit_before_or_after_all = 
  glm(dem_n ~ dem_type + time_before_after + time_from_leader_abs + time_of_tenure +
      government + country, 
      family = quasipoisson(link = "log"), data = data_REIGN_0315_analysis)
summary(fit_before_or_after_all)
calc_r_squared_glm(fit_before_or_after_all)
# explains 83.17% of the variation
#time_before_afterbefore                   1.418e-01  1.878e-02   7.552 4.42e-14 ***
#time_from_leader_abs                     -8.337e-01  5.671e-02 -14.703  < 2e-16 ***

fit_before_or_after = 
  glm(dem_n ~ dem_type + time_before_after + time_from_leader_abs + government + country, 
      family = poisson(link = "log"), data = data_REIGN_0315_analysis %>% filter(dem_n >0))
summary(fit_before_or_after)
# dem_typeAnti-regime                       0.991589   0.022920  43.262  < 2e-16 ***
# time_before_afterbefore                   0.141818   0.018606   7.622 2.49e-14 ***
# time_from_leader_abs                     -0.833738   0.056181 -14.840  < 2e-16 ***
calc_r_squared_glm(fit_before_or_after)
# Explains 40.85% of variation

# Permutate to test the effectiveness of the model
fit_before_or_after_all_reduced = 
  glm(dem_n ~ dem_type + time_before_after + time_from_leader_abs + government, 
      family = quasipoisson(link = "log"), data = data_REIGN_0315_analysis)
summary(fit_before_or_after_all_reduced)
calc_r_squared_glm(fit_before_or_after_all_reduced)
# The fit of the recuded model (without government) has very good fit: 75.52%
# But the outcome is different than before:
#time_before_afterbefore                   -0.08708    0.02476  -3.517 0.000437 ***
#time_from_leader_abs                      -0.77959    0.07584 -10.279  < 2e-16 ***






fit_quartered = 
  glm(dem_n ~ dem_type + time_quarter + time_from_leader_abs + government + country, 
      family = quasipoisson(link = "log"), data = data_REIGN_0315_analysis)
summary(fit_quartered)
# time_quarter2nd                           9.494e-02  3.787e-02   2.507 0.012169 *  
# time_quarter3rd                           2.936e-01  3.457e-02   8.492  < 2e-16 ***
# time_quarter4th                           5.822e-02  2.699e-02   2.157 0.030999 *  
# time_from_leader_abs                     -1.431e+00  1.020e-01 -14.035  < 2e-16 ***
calc_r_squared_glm(fit_quartered)
# 83.33% variation
# The effect of adding government is important

ggplot(data =  data_REIGN_0315_analysis)+
  geom_violin(aes(time_quarter, log(dem_n)))
