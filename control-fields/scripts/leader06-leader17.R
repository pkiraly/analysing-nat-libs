library(tidyverse)
library(grid)

source('control-fields/scripts/codes.R')
libs <- libraries %>% filter(is_national == TRUE) %>% 
  select(catalogue) %>% unlist(use.names = FALSE)
source('control-fields/scripts/functions.R')

for (i in 1:length(configuration)) {
  prefix <- configuration[[i]]$prefix
  print(sprintf('::: processing %s :::', prefix))
  runAll(prefix, configuration[[i]]$codeA, configuration[[i]]$codeB)
}

# print(g, vp = viewport(width = unit(400, "points"),
#                        height = unit(500, "points"),
#                        angle = 360-45))

