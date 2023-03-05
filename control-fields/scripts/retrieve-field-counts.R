library(tidyverse)
# output_dir <- '/home/kiru/Documents/marc21/_output'
# names <- c('oszk', 'nkp', 'kbr')

readCatalogue <- function(name, path) {
  df <- read_csv(sprintf('%s/%s/marc-elements.csv', output_dir, name))
  
  subfields_pattern <- paste0(path, '\\$')
  
  counts <- df %>% 
    filter(documenttype == 'all') %>% 
    filter(str_starts(path, subfields_pattern)) %>% 
    select(path, 'number-of-record') %>% 
    mutate(catalog = name)
  
  return(counts)  
}

args = commandArgs(trailingOnly=TRUE)
if (length(args) != 4) {
  stop("You should give arguments: 1) the QA catalogue's output directory, 2) the library names (comma separated) 3) the field 4) output file.", call.=FALSE)
} else {
  # default output file
  print(args)
  output_dir <- args[1]
  names <- unlist(strsplit(args[2], ','))
  field <- args[3]
  output_file <- args[4]
}

df <- tibble(path = '0', 'number-of-record' = 0, catalog = 'dummy')

for (i in 1:length(names)) {
  df <- union(df, readCatalogue(names[i], field))
}

df <- df %>% filter(catalog != 'dummy')
write_csv(df, output_file) # 'data_raw/6xx.csv'

