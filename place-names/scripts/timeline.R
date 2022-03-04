library(tidyverse)

df <- read_csv('uva.csv')

df %>% select(rank, term) %>% distinct() %>% view()

df2 <- df %>% 
  filter(grepl('^\\d+$', date)) %>% 
  mutate(date2 = as.integer(date)) %>% 
  select(-c(date)) %>%
  mutate(term2 = str_replace(term, '\\.$', '')) %>% 
  select(-c(term)) %>%
  group_by(term2) %>% 
  mutate(rank2 = min(rank)) %>% 
  group_by(term2, date2) %>% 
  mutate(count2 = sum(count)) %>% 
  select(-c(rank, count)) %>% 
  ungroup() %>% 
  distinct()

terms <- df2 %>% 
  group_by(term2) %>% 
  mutate(sum = sum(count2)) %>% 
  select(term2, sum) %>% 
  distinct() %>% 
  arrange(desc(sum)) %>% 
  select(term2) %>% 
  distinct() %>% unlist(use.names = F)

df3 <- df2 %>% 
  mutate(term = factor(term2, levels = terms)) %>% 
  select(-term2)

df3

df3 %>% 
  #filter(date2 >= 1850) %>% 
  ggplot(aes(x = date2, y = reorder(term, desc(term)))) +
  geom_point(aes(size = count2, color = count2), alpha = 0.6) +
  theme_bw() +
  labs(
    title = 'History of subjects',
    subtitle = 'The application of most frequent subject terms (650$a Subject Added Entry - Topical Term)\nterms are ordered by popularity, size and color are proportional to the number of books'
  ) +
  xlab('publication date') +
  ylab('subject term') +
  theme(legend.position = 'none')
  
