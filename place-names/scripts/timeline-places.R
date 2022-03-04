library(tidyverse)
library(ggmap)
source("normalizePlaceNames.r") 
setwd('~/temp/timeline')

library_name <- 'University of Amsterdam'
total_books <- 2690000
prefix <- 'uva'
home_title <- 'published in BeNeLux countries'
home_countries <- c('Netherlands', 'Belgium', 'Luxembourg')
home_coord <-  c(2.7, 7, 49.5, 53.5)

library_name <- 'Polish National Library'
total_books <- 5085000
prefix <- 'bnpl'
home_title <- 'published in Poland'
home_countries <- c('Poland')
home_coord <-  c(14.3, 23.7, 49.2, 54.6)

library_name <- 'Finnish National Library'
total_books <- 893417
prefix <- 'nfi'

library_name <- 'Swedish National Library'
total_books <- 5772546
prefix <- 'libris'

library_name <- 'Portugal National Library'
total_books <- 1100000
prefix <- 'bnpt'

coord <- read_csv('coord.csv', col_types = 'ciccdd')
europe <- c(
  "Austria","Belgium","Bulgaria","Croatia","Cyprus", "Czech Republic",
  "Denmark","Estonia","Finland","France", "Germany","Greece","Hungary",
  "Ireland","Italy","Latvia", "Lithuania","Luxembourg","Malta",
  "Netherlands","Poland", "Portugal","Romania","Slovakia","Slovenia",
  "Spain", "Sweden","UK","Norway","Serbia","Russia", "Ukraine",'Belarus',
  'North Macedonia', 'Bosnia and Herzegovina', 'Montenegro', 'Switzerland')

df <- read_csv(sprintf('%s-place-time-normalized.csv', prefix))

total2 <- sum(df$count)
total2
total <- sum(df_date$count)
total

# df_name %>% filter(grepl('I Stockholm', term2)) %>% view()

df2 <- df %>% 
  select(-c(term)) %>%
  group_by(term2) %>% 
  # mutate(rank2 = min(rank)) %>% 
  group_by(term2, date) %>% 
  mutate(count2 = sum(count)) %>% 
  select(-c(count)) %>% 
  ungroup() %>% 
  distinct()
#filter(sum > 3) %>% 
# view()

df2 %>% view()

df2 %>% 
  # filter(term2 %in% c('Amsterdam', 'London', 'Paris')) %>% 
  # filter(term2 %in% c('Köln', 'Venezia', 'Roma')) %>% 
  filter(term2 %in% c('Warszawa', 'Kraków', 'Poznań')) %>% 
  # filter(term2 %in% c('Jerusalem')) %>% 
  #filter(date < 1800) %>% 
  arrange(date) %>% 
  ggplot(aes(x = date, y = count2, color = term2)) +
  geom_point() +
  xlab('publication date') +
  ylab('number of publications') +
  theme_bw() +
  scale_color_discrete(name ='Place') +
  facet_wrap(~ term2, ncol = 1) +
  theme(legend.position = 'none') +
  scale_y_log10()

start <- 1500
end <- 1800
end <- 2200
all_names <- df2 %>% 
  filter(date >= start & date < end) %>% 
  select(term2, count2) %>% 
  group_by(term2) %>% 
  mutate(sum = sum(count2)) %>% 
#  mutate(sum = sum(count2), term2 = paste0('<', term2, '>')) %>% 
  select(term2, sum) %>% 
  distinct() %>% 
  arrange(desc(sum))

all_names %>% view()

map.europe <- map_data("world")
map.europe %>% view()

prepare_map(all_names, start, end, TRUE)

show <- function(start, end, is_debug = FALSE) {
  print(sprintf('%d / %d', start, end))
  all_names <- df2 %>% 
    filter(date >= start & date < end) %>% 
    select(term2, count2) %>% 
    group_by(term2) %>% 
    mutate(sum = sum(count2)) %>% 
    select(term2, sum) %>% 
    distinct() %>% 
    arrange(desc(sum))

  # all_names %>% view()
  top <- all_names %>% head(40)
  # top %>% view()

  maP <- prepare_map(all_names, start, end, TRUE, is_debug)
  if (is_debug == TRUE) {
    print(maP)
  } else {
    filename <- sprintf('%s-map-home-%s-%s.jpg', prefix, start, end)  
    ggsave(filename, plot = maP, device = 'jpeg', scale = 1,
           width = 800, height = 800, units = "px", dpi = 150,
    )
    maP <- prepare_map(all_names, start, end, FALSE)
    filename <- sprintf('%s-map-abroad-%s-%s.jpg', prefix, start, end)  
    ggsave(filename, plot = maP, device = 'jpeg', scale = 1,
           width = 800, height = 800, units = "px", dpi = 150,
    )
  }
  
  statistics <- top %>% ungroup() %>% summarise(total_books = sum(sum), min_books = min(sum))
  nr_books <- unlist(statistics$total_books, use.names = FALSE) / 1.04
  min_books <- floor(unlist(statistics$min_books, use.names = FALSE) / 1.04)
  print(sprintf('min book: %d', min_books))
  #/ 1.04
  percent <- nr_books * 100 / total_books
  #print(nr_books)
  #print(percent)

  termsByDate <- top %>%
    left_join(df2, by='term2') %>%
    mutate(start = min(date)) %>%
    select(term2, start) %>%
    distinct() %>%
    arrange(start) %>%
    select(term2) %>%
    distinct() %>% unlist(use.names = F)
  termsBySum <- top %>%
    arrange(desc(sum)) %>%
    select(term2) %>%
    distinct() %>% unlist(use.names = F)

  df3 <- top %>%
    left_join(df2, by='term2') %>%
    filter(date >= start & date < end) %>%
    mutate(term = factor(term2, levels = termsBySum)) %>%
    # select(term, date, count2) %>%
    ungroup()
  
  left_labels <- top %>% ungroup() %>% select(term2) %>% unlist(use.names = FALSE)
  right_labels <- top %>% ungroup() %>% select(sum) %>% unlist(use.names = FALSE)
  right_labels <- floor(right_labels / 1.04)

  p <- df3 %>%
    ggplot(aes(x = date, y = as.numeric(term))) +
    geom_point(aes(size = count2, color = count2), alpha = 0.6) +
    theme_bw() +
    labs(title = sprintf('Where from did the books go to %s? (%d-%d)',
                         library_name, start, (end-1)),
      subtitle = paste(
        sprintf('top 40 publication places (published >=%d books) %.2f%% of all books', min_books, percent),
        'ordered by number of publication',
        sep = '\n'
      ),
      caption = 'in memoriam Zbigniew Namysłowski'
    ) +
    xlab('publication date') +
    ylab('publication place') +
    theme(
      legend.position = 'none',
      axis.text.y.right = element_text(hjust=0.95)
    ) +
    scale_y_continuous(
      trans = "reverse",
      breaks = 1:length(left_labels),
      labels = left_labels,
      sec.axis = sec_axis(
        ~.,
        breaks = 1:length(right_labels),
        labels = right_labels
      )
    )

  filename <- sprintf('%s-%s-%s.jpg', prefix, start, end)  
  ggsave(filename,
    plot = p,
    device = 'jpeg',
    scale = 1,
    width = 1200,
    height = 1200,
    units = "px",
    dpi = 150,
  )
}

prepare_map <- function(all_names, start, end, is_home, is_debug=FALSE) {
  print(paste('is_home: ', is_home))

  # all_names %>% 
  #  left_join(coord, by = c("term2" = "city")) %>%
  #  view()
    
  geo <- all_names %>% 
    left_join(coord, by = c("term2" = "city")) %>% 
    filter(!is.na(geoid)) %>% 
    filter(long > -20.0 & long < 50 & lat > 32.5) %>%
    select(term2, sum, country, lat, long)
  
  if (is_home == TRUE) {
    geo <- geo %>% filter(country %in% home_countries) 
  } else {
    geo <- geo %>% filter(!(country %in% home_countries))
  } 
  geo <- geo %>% head(100)

  eu <- map.europe %>% filter(region %in% europe | region == 'UK')
  render_map(eu, geo, start, end, is_home)
}

render_map <- function(eu, geo, start, end, is_home) {
  print(paste('is_home: ', is_home))

  p <- ggplot() +
    geom_polygon(
      data = eu,
      aes(x = long, y = lat, group = group), # fill = region
      fill='#ffffff',
      colour = '#999999'
    ) +
    geom_point(
      data = geo,
      aes(x = long, y = lat, size = sum),
      color = "red",
      alpha = .8
    ) +
    geom_text(
      data = geo,
      mapping = aes(x = long, y = lat, label = term2),
      nudge_y = -0.1,
      size = 3
    )

  if (is_home == TRUE) {
    # p <- p + coord_cartesian(xlim = c(14.0, 25), ylim = c(48, 55))
    p <- p + coord_cartesian(
       xlim = c(home_coord[1], home_coord[2]), 
       ylim = c(home_coord[3], home_coord[4]),
    )
  } else {
    p <- p + coord_cartesian(xlim = c(-10.0, 30), ylim = c(35, 65))
  }

  p <- p + theme_bw() +
    theme(
      legend.position = 'none',
      axis.title = element_blank(),
      #axis.ticks = element_blank(),
      #axis.text = element_blank(),
    ) +
    labs(title = sprintf(
      "UvA books %s %d-%d", 
      ifelse(is_home == TRUE, home_title, 'published abroad'), start, end))
  
  return(p)
}

by <- 10
for (i in seq(1500, (2020-by), by)) {
  show(i, i + by)
}

show(1500, 1600, TRUE)
show(1600, 1700)
show(1700, 1800)
show(1500, 1800)
show(1800, 1945)
show(1945, 2023)

sprintf("%s is %f feet tall\n", "Sven", 7.1)
sprintf('%s is %f feet or %d cm tall\n', "Sven", 7.1, 180)

df2 %>% 
  filter(date < 1800) %>% 
  # filter(date > 1800 & date < 1850) %>% 
  select(term2, count2) %>% 
  group_by(term2) %>% 
  mutate(sum = sum(count2)) %>% 
  select(term2, sum) %>% 
  distinct() %>% 
  arrange(desc(sum)) %>% 
  #filter(sum > 3) %>% 
  view()

df2 %>% 
  # filter(term2 %in% c('Amsterdam', 'London', 'Paris')) %>% 
  # filter(term2 %in% c('Köln', 'Venezia', 'Roma')) %>% 
  filter(term2 %in% c('Warszawa', 'Kraków', 'Poznań')) %>% 
  # filter(term2 %in% c('Jerusalem')) %>% 
  #filter(date < 1800) %>% 
  arrange(date) %>% 
  ggplot(aes(x = date, y = count2, color = term2)) +
  geom_point() +
  xlab('publication date') +
  ylab('number of publications') +
  theme_bw() +
  scale_color_discrete(name ='Place') +
  facet_wrap(~ term2, ncol = 1) +
  theme(legend.position = 'none')

top <- df2 %>% 
  # filter(date > 1800 & date < 1850) %>% 
  filter(date <= 1800) %>% 
  select(term2, count2) %>% 
  group_by(term2) %>% 
  mutate(sum = sum(count2)) %>% 
  select(term2, sum) %>% 
  distinct() %>% 
  arrange(desc(sum)) %>% 
  #filter(sum > 10000)# %>% 
  head(40)

top %>% view()

termsByDate <- top %>% 
  left_join(df2, by='term2') %>% 
  mutate(start = min(date)) %>%
  select(term2, start) %>% 
  distinct() %>% 
  arrange(start) %>% 
  select(term2) %>% 
  distinct() %>% unlist(use.names = F)

termsByDate

termsBySum <- top %>% 
  arrange(desc(sum)) %>% 
  select(term2) %>% 
  distinct() %>% unlist(use.names = F)

termsBySum

df3 <- top %>% 
  left_join(df2, by='term2') %>% 
  filter(date <= 1800) %>% 
  mutate(term = factor(term2, levels = termsByDate)) %>% 
  select(term, date, count2) %>% 
  ungroup()

covered <- sum(df3$count2)
covered
(covered / 1.04) / 5085000
percent <- sprintf("%.2f%%", covered * 100 / total)  
percent

df3 %>% 
  ggplot(aes(x = date, y = reorder(term, term))) +
  geom_point(aes(size = count2, color = count2), alpha = 0.6) +
  theme_bw() +
  labs(
    title = 'Where from did the books go to Polish National Library?',
    # title = 'Where from did the books go to University of Amsterdam?',
    # subtitle = 'top publication places (10 000+ books)\nplaces are ordered by popularity (top-down), dot size and color are proportional to the number of books'
    subtitle = paste(
      'top publication places (10 000+ books)',
      'places are ordered by first publication (bottom-up), dot size and color are proportional to the number of books',
      sep = '\n'
    ),
    caption = 'in memoriam Zbigniew Namysłowski'
  ) +
  xlab('publication date') +
  ylab('publication place') +
  theme(
    legend.position = 'none',
    #axis.text.y=element_blank()
  )

