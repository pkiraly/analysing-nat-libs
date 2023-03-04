library(tidyverse)
library(grid)

source('control-fields/scripts/codes.R')

runAPair <- function(i) {
  prefix <- configuration[[i]]$prefix
  print(sprintf('::: %d/%d processing %s :::', i, total, prefix))
  runAll(configuration[[i]]$prefix, configuration[[i]]$codeA, configuration[[i]]$codeB)
}

counts <- read_csv('control-fields/data_raw/counts.csv')
libs <- libraries %>% filter(is_national == TRUE) %>% 
  select(catalogue) %>% unlist(use.names = FALSE)
libs
source('control-fields/scripts/functions.R')
runAnAspect(1)

total <- length(configuration)
for (i in 1:total) {
  runAPair(i)
}
print('Done')

# print(g, vp = viewport(width = unit(400, "points"),
#                        height = unit(500, "points"),
#                        angle = 360-45))

