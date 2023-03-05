library(tidyverse)
library(ggplot2)

source('scripts/codes.R')
versions <- c('6xx', '583')
version <- versions[1]

paths6xx <- tribble(
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

paths583 <- tribble(
  ~path,   ~description_hu, ~description_en,
  '583$ind1', '', 'ind1 Privacy',
  '583$a', '', '$a Action',
  '583$b', '', '$b Action identification',
  '583$c', '', '$c Time/date of action',
  '583$d', '', '$d Action interval',
  '583$e', '', '$e Contingency for action',
  '583$f', '', '$f Authorization',
  '583$h', '', '$h Jurisdiction',
  '583$i', '', '$i Method of action',
  '583$j', '', '$j Site of action',
  '583$k', '', '$k Action agent',
  '583$l', '', '$l Status',
  '583$n', '', '$n Extent (R)',
  '583$o', '', '$o Type of unit',
  '583$u', '', '$u Uniform Resource Identifier',
  '583$x', '', '$x Nonpublic note',
  '583$z', '', '$z Public note',
  '583$2', '', '$2 Source of term',
  '583$3', '', '$3 Materials specified',
  '583$5', '', '$5 Institution to which field applies',
  '583$6', '', '$6 Linkage',
  '583$7', '', '$7 Data provenance',
  '583$8', '', '$8 Field link and sequence number'
)

if (version == '583') {
  paths <- paths583
  df <- read_csv('data_raw/583.csv')
  img_file <- 'action-notes'
} else if (version == '6xx') {
  paths <- paths6xx
  df <- read_csv('data_raw/6xx.csv')
  img_file <- 'subject-access'
}

catalogOrder <- c('loc', 'dnb', 'onb', 'nfi', 'libris', 'bnpl', 'kbr', 'nli',
                  'kb', 'nkp', 'oszk')

stat <- df %>% 
  left_join(libraries, by = c('catalog' = 'catalogue')) %>% 
  mutate(lib_desc = english) %>% 
  select(-c(is_national, hungarian, english)) %>% 
  mutate(percent = `number-of-record` * 100 / records) %>% 
  select(-c(`number-of-record`, records)) %>% 
  left_join(paths) %>% 
  mutate(path_desc = ifelse(is.na(description_en), path, description_en)) %>% 
  select(-c(description_hu, description_en))

stat
library_list <- stat %>% select(lib_desc) %>% distinct() %>%
  unlist(use.names = FALSE)
description_list <- stat %>% select(path_desc) %>% distinct() %>%
  arrange(desc(path_desc)) %>% unlist(use.names = FALSE)

description_list
l <- paths$description_en
extra <- setdiff(description_list, l)
extra
description_list2 <- c(l, extra)
description_list2

language <- 'en'
if (language == 'en') {
  if (version == '6xx') {
    title = 'Subject Access'
    subtitle = 'How much percent of the records has subject terms?'
  } else {
    title = 'Action Note'
    subtitle = 'How much percent of the records has action notes?'
  }
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
      y = factor(path_desc, levels=rev(description_list2)),
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

ggsave(sprintf('img/%s.png', img_file),
       width = 15, height = 15, units = "cm", dpi=300)
