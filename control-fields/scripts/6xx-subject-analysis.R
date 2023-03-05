library(tidyverse)
library(ggplot2)

source('scripts/codes.R')
paths <- tribble(
  ~path,   ~description_hu,        ~description_en,
  '600$a', '600a személynév',      '600a Personal name',
  '600$b', '600b uralk. sorsz.',   '600b Numeration',
  '600$c', '600c mélt., fogl.',    '600c Titles',
  '600$d', '600d kronolog. kie.',  '600d Dates',
  '600$g', '600g áll. mellékn.',   '600g Miscellaneous',
  '600$j', '600j egyéni név.',     '600j Attribution',
  '600$m', '600m rokons.kieg.',    '600m Medium',
  '600$t', '600t címreláció',      '600t Title of a work',
  '650$a', '650a tárgyszó',        '650a Topical term',
  '650$c', '650c esem. helye',     '650c Location',
  '651$a', '651a földr. név',      '651a Geographic name',
  '653$a', '653a szabadon vál.',   '653a Uncontrolled term',
  '655$a', '655a formai tárgysz.', '655a Genre/form'
)

catalogOrder <- c('loc', 'dnb', 'onb', 'nfi', 'libris', 'bnpl', 'kbr', 'nli',
                  'kb', 'nkp', 'oszk')
df <- read_csv('data_raw/6xx.csv')
names(df)

stat <- df %>% 
  left_join(libraries, by = c('catalog' = 'catalogue')) %>% 
  mutate(lib_desc = english) %>% 
  select(-c(is_national, hungarian, english)) %>% 
  mutate(percent = `number-of-record` * 100 / records) %>% 
  select(-c(`number-of-record`, records)) %>% 
  left_join(paths) %>% 
  mutate(path_desc = description_en) %>% 
  select(-c(description_hu, description_en))

stat
library_list <- stat %>% select(lib_desc) %>% distinct() %>%
  unlist(use.names = FALSE)
description_list <- stat %>% select(path_desc) %>% distinct() %>%
  arrange(desc(path_desc)) %>% unlist(use.names = FALSE)

language <- 'en'
if (language == 'en') {
  title = 'Subject Access'
  subtitle = 'How much percent of the records has subject terms?'
  legend <- 'percent'
} else {
  title = 'Tárgyszavak'
  subtitle = 'A rekordok hány százalékában találhatók szaktárgyszavak?'
  legend <- 'százalék'
}

stat %>% 
  ggplot(
    aes(
      x = factor(lib_desc, levels=library_list),
      y = factor(path_desc, levels=description_list),
      size = percent,
      # color = percent
    )
  )+
  geom_point() +
  labs(
    title = title,
    subtitle = subtitle,
    x = NULL,
    y = NULL
  ) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, vjust = 0, hjust=0)) +
  scale_size_continuous(name = legend) +
  scale_x_discrete(position = "top") 
