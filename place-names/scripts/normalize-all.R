library(tidyverse)
library(ggmap)
source("scripts/normalizePlaceNames.R") 

normalizePlaceNames('bnr')
read_csv('bnr-place-time-normalized.csv', show_col_types = FALSE) %>% 
  select(normalized) %>% 
  group_by(normalized) %>% 
  count() %>% 
  arrange(desc(n)) %>% 
  view()


prefixes <- c('uva', 'bnpl', 'bnpt'
              # , 'nfi', 'libris'
              )

for (prefix in prefixes) {
  print(paste('Normalizing', prefix))
  normalizePlaceNames(prefix)
}
