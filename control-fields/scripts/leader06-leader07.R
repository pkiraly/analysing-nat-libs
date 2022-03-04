library(tidyverse)
library(grid)

source('control-fields/script/codes.R')

file <- 'control-fields/data_raw/ldr06-ldr07.csv'
df <- read_csv(file)
max_count <- max(df$count)

df %>% 
  left_join(libraries) %>% 
  mutate(
    catalogue = factor(catalogue, levels=libraries$catalogue),
    leader06_typeOfRecord_ss = 
      ifelse(nchar(leader06_typeOfRecord_ss) == 1 |
               is.na(leader06_typeOfRecord_ss), '[invalid]', 
             leader06_typeOfRecord_ss)
  ) %>% 
  left_join(code_ldr06, by = c('leader06_typeOfRecord_ss' = 'solr')) %>% 
  filter(is_national == TRUE) %>%
  select(leader06_typeOfRecord_ss, english06, hungarian06) %>% 
  filter(is.na(english06)) %>% 
  view()

df_normalized <- df %>% 
  mutate(
    leader07_bibliographicLevel_ss = 
      ifelse(nchar(leader07_bibliographicLevel_ss) == 1 |
               is.na(leader07_bibliographicLevel_ss), '[invalid]', 
             leader07_bibliographicLevel_ss),
    leader06_typeOfRecord_ss = 
      ifelse(nchar(leader06_typeOfRecord_ss) == 1 |
               is.na(leader06_typeOfRecord_ss), '[invalid]', 
             leader06_typeOfRecord_ss)
  ) %>% 
  left_join(libraries) %>% 
  left_join(code_ldr06, by = c('leader06_typeOfRecord_ss' = 'solr')) %>% 
  left_join(code_ldr07, by = c('leader07_bibliographicLevel_ss' = 'solr')) %>% 
  mutate(
    catalogue = factor(catalogue, levels=libraries$catalogue),
    hungarian = factor(hungarian, levels=libraries$hungarian),
    english = factor(english, levels=libraries$english),
    hungarian06 = factor(hungarian06, levels=code_ldr06$hungarian06),
    english06 = factor(english06, levels=code_ldr06$english06),
    hungarian07 = factor(hungarian07, levels=code_ldr07$hungarian07),
    english07 = factor(english07, levels=code_ldr07$english07)
  ) %>% 
  filter(is_national == TRUE)

language <- 'english'
language <- 'hungarian'
if (language == 'hungarian') {
  df_language <- df_normalized %>% 
    mutate(x = hungarian07, y = hungarian06, library = hungarian) %>% 
    select(x, y, count, library)
  txt_title <- 'Rekordtípus és bibliográfiai szint'
  txt_subtitle <- 'nemzeti könyvtárakban'
  txt_xlab <- 'bibliográfiai szint (rekordfej/07)'
  txt_ylab <- 'rekordtípus (rekordfej/06)'
} else {
  df_language <- df_normalized %>% 
    mutate(x = english07, y = english06, library = english) %>% 
    select(x, y, count, library)
  txt_title <- 'Type of record and bibliographic level'
  txt_subtitle <- 'in national libraries'
  txt_xlab <- 'bibliographic level (leader/07)'
  txt_ylab <- 'type of record (leader/06)'
}

g <- df_language %>% 
  ggplot(aes(x = x, y = reorder(y, desc(y)))) +
  geom_point(aes(size = count), colour = 'red') +
  labs(title = txt_title, subtitle = txt_subtitle) +
  xlab(txt_xlab) +
  ylab(txt_ylab) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 0, vjust = 0),
    # axis.text.y = element_text(angle = 45),
    # axis.title.x = element_blank(),
    # axis.title.y = element_blank(),
    # title = element_blank(),
    legend.position = "none",
    plot.margin = unit(c(0.2,2,0.2,0.2), "cm")
  ) +
  scale_size(range = c(0, 6), breaks=seq(0, max_count, 100)) +
  scale_x_discrete(position = "top") +
  facet_wrap(vars(library))

filename <- sprintf('control-fields/img/ldr06-ldr07-nat.%s.jpg', language)
ggsave(filename, g, device = 'jpeg', scale = 1,
       width = 1300, height = 1500, units = "px", dpi = 150)

# print(g, vp = viewport(width = unit(400, "points"),
#                        height = unit(500, "points"),
#                        angle = 360-45))

