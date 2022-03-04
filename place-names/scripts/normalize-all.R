library(tidyverse)
library(ggmap)
source("scripts/normalizePlaceNames.R") 

prefixes <- c('uva', 'bnpl', 'bnpt'
              # , 'nfi', 'libris'
              )

for (prefix in prefixes) {
  print(paste('Normalizing', prefix))
  normalizePlaceNames(prefix)
}
