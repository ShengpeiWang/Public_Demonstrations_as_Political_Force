# Prep the working environment ----
library(tidyverse)
library(ggpubr)

# Bringing in the data ----
# Mass mobilization record in autocracies 2002-2015
dat_MMAD = read_csv("data/events_Mass_Mobilization_in_Autocracies_Database.csv")
# 76 countries

# The Rulers, Elections, and Irregular Governance Dataset
dat_REIGN = read_csv("data/REIGN_2019_4.csv") 
#summary(dat_REIGN$year)
#length(unique(dat_REIGN$ccode))
# Data on 201 countries from 1950 to now

data_REIGN_sample = head(dat_REIGN %>% select(ccode, country, leader, elected, tenure_months, government))
data_MMAD_sample = head(dat_MMAD %>% select(cowcode, asciiname, event_date, side, mean_avg_numparticipants))

# Data clean-up ----
data_MMAD = 
  dat_MMAD %>% 
  filter(side != 3) %>% 
  rename(ccode = cowcode) %>% 
  mutate(year = lubridate::year(event_date),
         month = lubridate::month(event_date)) %>% 
  mutate(dem_type = case_when(side == 0 ~ "Pro-regime",
                              side == 1 ~ "Anti-regime"),
         dem_type = factor(dem_type, levels = c("Pro-regime","Anti-regime")))

data_REIGN = 
  dat_REIGN %>% 
  mutate(government = as.factor(government),
         government = fct_relevel(government,"Presidential Democracy","Parliamentary Democracy", 
                                  "Dominant Party", "Foreign/Occupied",
                                  "Military", "Military-Personal", 
                                  "Personal Dictatorship", "Party-Personal")) %>% 
  mutate(elected = case_when(elected == 0 ~ "not elected",
                             elected == 1 ~ "elected"))

# Look at the general pattern of demonstrations----
data_REIGN_0315 =
  data_MMAD %>% 
  full_join(data_REIGN %>% filter(year <2016 & year > 2002), 
            by = c("ccode", "year", "month"))  %>% 
  group_by(ccode, year, month, country, leader, government, elected, tenure_months, side) %>% 
  mutate(dem = !is.na(event_date)) %>% 
  summarise(dem_n = sum(dem, na.rm = T)) %>% 
  group_by(ccode, country, leader, government, elected) %>% 
  mutate(max_tenure = max(tenure_months),
         time_of_tenure = tenure_months/ max_tenure)%>%
  mutate(dem_type = case_when(is.na(side) ~ "no demonstration",
                              side == 0 ~ "Pro-regime",
                              side == 1 ~ "Anti-regime"),
         dem_type = factor(dem_type, levels = c("no demonstration","Pro-regime","Anti-regime")))%>% 
  ungroup()

data_REIGN_0315_MMAD <- 
  data_REIGN_0315 %>% 
  semi_join(data_MMAD %>% select("ccode"))

plot_dem_dots = 
  ggplot(data = data_REIGN_0315 %>% filter(!is.na(side)),
         aes(government, time_of_tenure, color = dem_type))+
  geom_point(position = position_jitter(), aes(size = dem_n))+
  coord_flip()+
  scale_color_manual(values = c("#3b8183","#ed303c"), name = " ", guide = guide_legend(reverse = T))+
  scale_size_continuous(name = "size of demonstration")+
  labs(x = " ",
       y = "Time during the tenure of a leader",
       title = "More demonstrations before leadership changes")+
  theme_bw()+
  geom_vline(xintercept = c(1.5,2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 11.5, 12.5, 13.5))
ggsave( "figures/public_dem_are_popular.png", plot = plot_dem_dots, width = 7, height = 5, units = "in")

# Timeing of demonstrations. Are deoms more common in cerntain regimes than others?----
data_total_months = data_REIGN %>% filter(year <2016 & year > 2002) %>% group_by(ccode, government) %>% summarise(total = n())

data_REIGN_0315_wide = 
  data_REIGN_0315 %>% 
  group_by(ccode, country, government, side) %>% 
  summarise(n_months = n()) %>% 
  spread(side, n_months) %>% 
  right_join(data_MMAD %>% select(ccode) %>% unique()) %>% 
  rename(pro = `0`, anti = `1`, non = `<NA>`) %>% 
  left_join(data_total_months) %>% 
  mutate(both_pro_anti = sum(c(pro, anti, non), na.rm = T) - total) %>% 
  mutate(pro_only = pro - both_pro_anti, anti_only = anti - both_pro_anti) %>% 
  mutate(prop_non = non/total)

data_summary_gov  =
  data_REIGN_0315_wide%>% 
  group_by(government) %>% 
  summarise(pro = sum(pro_only, na.rm = T), anti = sum(anti_only, na.rm = T), total = sum(total, na.rm = T),
            both_pro_anti = sum(both_pro_anti, na.rm = T)) %>% 
  mutate(p_pro = pro/total, p_anti = anti/total, p_both = both_pro_anti/total) %>% 
  arrange(desc(p_anti)) %>% 
  select(government, p_pro, p_anti, p_both) %>% 
  gather(type, prop, -government) %>% 
  group_by(government) %>% 
  mutate(prop_max = sum(prop)) %>% 
  ungroup() %>% 
  mutate(government = reorder(government, prop_max)) %>% 
  mutate(type = factor(type, levels = c("p_pro","p_both", "p_anti"), c("Pro-regime", "Both", "Anti-regime")))

# Are there more of one type of demonstrations?
# Do anti and pro_ dems tend to happen at the same time?
plot_freq_dem = 
  ggplot(data_summary_gov,aes(government, prop, fill = "#d07290"))+
  geom_col()+
  coord_flip()+
  ylim(0,1)+
  labs(y = "Proportion of months when demonstrations happened",
       x = " ",
       title = "More demonstration during autocracies")+
  theme(legend.position = "none",
        panel.border = element_rect(fill = NA), 
        panel.background = element_rect(fill = NA))
ggsave( "figures/more_dem_during_autocracies_by_type.png", plot = plot_freq_dem, width = 7, height = 4, units = "in")

# military personal really stands out:
data_portion = 
  data_REIGN %>% 
  filter(year <2016 & year > 2002, government == "Military-Personal") %>% 
  right_join(data_MMAD %>% select(ccode) %>% unique())

# Anti-regime demonstrations are more often than pro-regime ones
# pro-regime demonstration almost never happens without anti-regime ones around the same time.
# Besides party-personal.

# Are anti- vs pro-regime demonstrations more or less common in different regimes? ----
plot_prop_dem = 
  ggplot(data_summary_gov,aes(government, prop, fill = type))+
  geom_col()+
  coord_flip()+
  ylim(0,1)+
  scale_fill_manual(values = c("#3b8183", "#bf99cb","#ed303c"), name = " ", guide = guide_legend(reverse = T))+
  labs(y = "Proportion of months when demonstrations happened",
       x = " ",
       title = "Most demonstrations are anti-regime")+
  theme(panel.background = element_rect(fill = NA, colour = "black"),
        legend.position = c(0.6,0.2))
ggsave( "figures/pro_regime_don't_happen_alone.png", plot = plot_prop_dem, width = 7, height = 4, units = "in")

# Look at party-personal seperately:
data_mobilization_party_personal = 
  data_MMAD_REIGN %>% 
  filter(government == "Party-Personal") %>% 
  group_by(ccode, elected, dem_type, country) %>% 
  summarise(n = n()) %>% 
  ungroup() %>% 
  mutate(country = factor(country, 
                          levels = c("Uzbekistan", "Turkmenistan","Cuba",
                                     "Gabon", "Eritrea", "Korea North"),
                          labels =  c("Uzbekistan", "Turkmenistan","Cuba",
                                      "Gabon", "Eritrea", "North Korea")))
plot_cuba_nkorea = 
  ggplot(data = data_mobilization_party_personal, aes(elected, n, fill = dem_type))+
  facet_wrap(.~country, ncol = 3) +
  geom_bar(stat = "identity", position = "fill", alpha = 0.9)+
  scale_fill_manual(values = c("#3b8183","#ed303c"), name = " ")+
  labs(x= "Was the leader elected?", y = "Proportion of demonstrations", 
       title = "Cuba and North Korea were very different")+
  theme(axis.text.x = element_text(angle = 30))
ggsave( "figures/cuba_nkorea.png", plot = plot_cuba_nkorea, width = 7, height = 4, units = "in")


# NUmber of demonstrations. Are there more or less pro and anti? size of dem? ----
data_MMAD_REIGN = 
  data_MMAD %>% 
  left_join(data_REIGN, by = c("ccode", "year", "month"))

data_mobilization_government = 
  data_MMAD_REIGN %>% 
  group_by(government, elected, dem_type) %>% 
  summarise(n = n()) %>% 
  ungroup() %>% 
  group_by(government, dem_type) %>% 
  mutate(n_side = n()) %>% 
  group_by(government, elected) %>% 
  mutate(n_elect = n()) %>% 
  mutate(government_sorted = factor(government, levels = levels(data_summary_gov$government)))

plot_protest_by_government <-
  ggplot(data = data_mobilization_government, 
         aes(government_sorted, n, fill = dem_type))+
  geom_col(position = "fill", alpha = 0.9)+
  coord_flip()+
  scale_fill_manual(values = c("#3b8183","#ed303c"), name = " ")+
  labs(x= " ", y = "Proportion of demonstrations (number)", 
       title = "Democracies have More Anti-government Protests",
       subtitle = "Especially under legitimate leaders")
# No clear pattern of when pro- is more or less common besides Party-personal system.

# Do legitimate leaders change the type of demonstrations?
data_mobilization_government_elect =
  data_mobilization_government %>% 
  filter(n_side > 1 & n_elect >1 & government != "Presidential Democracy") %>% 
  group_by(government, elected) %>% 
  mutate(n_total = sum(n),
         prop = n/n_total) %>% 
  filter(government != "Party-Personal")
  
data_mobilization_elect = 
  data_mobilization_government_elect %>% 
  group_by(elected, dem_type) %>% 
  summarise(prop = mean(prop))


plot_pro_prop = 
  ggplot(data = data_mobilization_elect %>% filter(dem_type == "Pro-regime"),
         aes(elected, prop))+
  geom_col(fill = "#3b8183", alpha = 0.5)+
  geom_line(data = data_mobilization_government_elect %>% filter(dem_type == "Pro-regime"), 
            aes(elected, prop, group = government, linetype = government))+
  geom_text(data = data_mobilization_government_elect %>% 
              filter(dem_type == "Pro-regime" & elected == "not elected"), 
            aes(2, prop, label = government),
            hjust = 0, nudge_x = 0.1)+
  expand_limits(x = c(1, 3.7))+
  labs(x = "Was the leader elected?", 
       y = "Proportion of pro-regime demonstrations",
       title = "More and bigger pro-regime demonstrations\nwith legetimate leaders")+
  theme_classic()+
  theme(legend.position = "none")

plot_anti_prop = 
  ggplot(data = data_mobilization_elect %>% filter(dem_type == "Anti-regime"),
         aes(elected, prop))+
  geom_col(fill = "#ed303c", alpha = 0.5)+
  labs(x = "Was the leader elected?", 
       y = "Proportion of anti-regime demonstrations",
       title = "Larger anti-regime demonstrations\nwith illegitimate leaders")+
  theme_classic()+
  theme(legend.position = "none")

# Size of demonstrations:
data_size_mobilization = 
  data_MMAD_REIGN %>% 
  filter(!is.na(mean_avg_numparticipants)) %>% 
  group_by(government, dem_type, elected, country) %>%
  summarise(m_size = mean(mean_avg_numparticipants), 
            sd_size = sd(mean_avg_numparticipants)) %>% 
  ungroup() %>% 
  filter(country != "Korea North" & country != "Cuba")
# Remove North Korea and Cuba from this analysis because these two countries behave rather differently
# Country level data
plot_pro_size = 
  ggplot(data = data_size_mobilization %>% filter(dem_type == "Pro-regime"),
       aes(elected, m_size))+
  scale_y_log10(breaks = c(100, 1000, 10000, 100000), 
                labels = c("100", "1000", "10,000", "100,000")) +
  geom_boxplot(color = "#3b8183")+
 # ylim(0,10000)+
  labs(x= "Was the leader elected?", y = "Size of demonstrations")+
  theme_classic()

plot_anti_size =
  ggplot(data = data_size_mobilization %>% filter(dem_type == "Anti-regime"),
       aes(elected, m_size))+
  scale_y_log10(breaks = c(100, 1000, 10000, 100000), 
                labels = c("100", "1000", "10,000", "100,000")) +
  geom_boxplot(color = "#ed303c")+
 # ylim(0,10000)+
  labs(x= "Was the leader elected?", y = "Size of demonstrations")+
  theme_classic()

plot_pro_election = 
  ggarrange(plot_pro_prop, plot_pro_size, widths = c(1.7, 1.2),
            ncol = 2, nrow = 1, align = "h")
plot_anti_election = 
  ggarrange(plot_anti_prop, plot_anti_size, widths = c(1.3, 1.2),
            ncol = 2, nrow = 1, align = "h")
ggsave("figures/more_and_bigger_pro_for_legitimate.png", 
       plot = plot_pro_election, 
       width = 8, height = 5, units = "in")
ggsave("figures/bigger_anti_for_illegitimate.png", 
       plot = plot_anti_election, 
       width = 7, height = 5, units = "in")


# Save objects----
save(data_REIGN_sample, data_MMAD_sample, 
     plot_dem_dots, plot_freq_dem, plot_prop_dem,
     plot_cuba_nkorea, plot_pro_election, plot_anti_election,
     data_REIGN_0315_wide, fit_pro_non_month, fit_size_elected_raw,
     fit_before_or_after_all, fit_before_or_after_all_reduced,
     file = "figures_and_data_for_markdown.RData")
