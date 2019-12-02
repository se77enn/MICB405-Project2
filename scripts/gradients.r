library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(cowplot)

library(tidyverse)
library(cowplot)

raw_dat <- read_csv("Saanich_TimeSeries_Chemical_DATA.csv")

dat <- 
  raw_dat %>%
  select(Depth, Mean_CH4) %>%
  filter(!is.na(Mean_CH4)) %>%
  rename(CH4_uM=Mean_CH4) %>%
  mutate(Depth_m=Depth)

dat %>%
  select(Depth_m, CH4_uM) %>% 
  gather(key="Chemical", value="Concentration", -Depth_m) %>% 
  ggplot(aes(x=Concentration, y=Depth_m, shape=Chemical, color=Chemical)) +
  geom_point() +
  scale_y_reverse(limits=c(200, 0)) +
  facet_wrap(~Chemical, scales="free_x") +
  theme_bw() +
  theme(legend.position="none") +
  labs(y="Depth in m", x="Concentration in uM")

