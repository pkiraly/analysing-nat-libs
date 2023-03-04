library(tidyverse)
# output_dir <- '/home/kiru/Documents/marc21/_output'
# names <- c('oszk', 'nkp', 'kbr')

args = commandArgs(trailingOnly=TRUE)
if (length(args) != 2) {
  stop("You should give two arguments: the QA catalogue's output directory, and the library names (comma separated).", call.=FALSE)
} else if (length(args) == 1) {
  # default output file
  print(args)
  output_dir <- args[1]
  names <- unlist(strsplit(args[2], ','))
}

interestingPaths <- c(
  '600$a', '600$b', '600$c', '600$d', '600$g', '600$j', '600$m',
  '600$t', '650$a', '650$c', '651$a', '653$a', '655$a'
)

df <- tibble(path = '0', 'number-of-record' = 0, catalog = 'dummy')

for (name in names) {
  df <- union(df, readCatalogue(name))
}

df <- df %>% filter(catalog != 'dummy')
view(df)

readCatalogue <- function(name) {
  df <- read_csv(sprintf('%s/%s/marc-elements.csv', output_dir, name))
  
  counts <- df %>% 
    filter(documenttype == 'all') %>% 
    filter(path %in% interestingPaths) %>% 
    select(path, 'number-of-record') %>% 
    mutate(catalog = name)

  return(counts)  
}
