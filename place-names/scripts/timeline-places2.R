library(tidyverse)
library(ggmap)
library(wesanderson)

setwd('~/temp/timeline')

europe <- c(
  "Austria","Belgium","Bulgaria","Croatia","Cyprus", "Czech Republic",
  "Denmark","Estonia","Finland","France", "Germany","Greece","Hungary",
  "Ireland","Italy","Latvia", "Lithuania","Luxembourg","Malta",
  "Netherlands","Poland", "Portugal","Romania","Slovakia","Slovenia",
  "Spain", "Sweden","UK","Norway","Serbia","Russia", "Ukraine",'Belarus',
  'North Macedonia', 'Bosnia and Herzegovina', 'Montenegro', 'Switzerland',
  'Albania')
map.europe <- map_data("world")
eu <- map.europe %>% filter(region %in% europe | region == 'UK')

#' BottleRocket1, BottleRocket2, Rushmore1, Royal1, Royal2, 
#' Zissou1, Darjeeling1, Darjeeling2, Chevalier1, FantasticFox1,
#' Moonrise1, Moonrise2, Moonrise3, Cavalcanti1, 
#' GrandBudapest1, GrandBudapest2, IsleofDogs1, IsleofDogs2
# p <- wes_palette(name="Royal1")
#palette <- c('#000000', '#dd7e6b', '#4a86e8') #, '#e6b8af')
# palette <- c('#000000', 'maroon', 'blue') #, '#e6b8af')
palette <- c('maroon', '#666666', '#666666') #, '#e6b8af')

df <- NULL
libs <- c('uva', 'bnpl', 'bnpt')
for (lib in libs) {
  df_ <- read_csv(sprintf('%s-place-time-normalized.csv', lib)) %>% mutate('lib' = lib)
  if (is.null(df)) {
    df <- df_
  } else {
    df <- df %>% union(df_)
  }
}

# df$lib <- factor(
#   df$lib,
#   levels = c("bnpt", "uva", "bnpl"), 
#   labels = c("Portugal National Library", "University of Amsterdam", "Polish National Library"))

df2 <- df %>% 
  select(-c(term)) %>%
  group_by(normalized) %>% 
  # mutate(rank2 = min(rank)) %>% 
  group_by(normalized, date, lib) %>% 
  mutate(count2 = sum(count)) %>% 
  select(-c(count)) %>% 
  ungroup() %>% 
  distinct()

nrow(df2)

all_names <- df2 %>% 
  # filter(date >= start & date < end) %>% 
  select(normalized, count2, lib) %>% 
  group_by(normalized, lib) %>% 
  mutate(sum = sum(count2)) %>% 
  select(normalized, sum, lib) %>% 
  distinct() %>% 
  arrange(desc(sum))

coord <- read_csv('coord.csv', col_types = 'ciccdd')
coord %>% select(city, geoid) %>% group_by(geoid) %>% count() %>% 
  filter(n > 1) %>% 
  left_join(coord) %>% view()
# coord %>% filter(city == 'Belfast')

new_york <- all_names %>% 
  left_join(coord, by = c("normalized" = "city")) %>% 
  ungroup() %>%
  filter(normalized == 'New York') %>% 
  mutate(nr_of_libraries = 3, sum = 0)

all_names %>% 
  left_join(coord, by = c("normalized" = "city")) %>%
  ungroup() %>% 
  select(normalized, sum, geoid) %>% 
  filter(is.na(geoid)) %>% 
  view()

all_names %>% 
  left_join(coord, by = c("normalized" = "city")) %>%
  ungroup() %>% 
  select(normalized, sum, geoid) %>% 
  mutate(type = ifelse(
    is.na(geoid), 
    ifelse(normalized == 'S. l.',  
           's. l.',
           ifelse(sum == 1,
                  'singleton',
                  ifelse(sum <= 10,
                         '2-10',
                         'to resolve'))), 
    'known')) %>% 
  group_by(type) %>% 
  summarise(total = sum(sum), c = n())

all_names %>% 
  left_join(coord, by = c("normalized" = "city")) %>% 
  filter(is.na(geoid)) %>% 
  ungroup() %>% 
  select(normalized, sum) %>% 
  group_by(normalized) %>% 
  mutate(sum2 = sum(sum)) %>% 
  select(normalized, sum2) %>% 
  distinct() %>% 
  arrange(desc(sum2)) %>% 
  view()

show <- function(selected_country, start, end, coords, 
                 is_debug = FALSE, extra_countries = NULL) {
  print(sprintf("%s %d-%d", selected_country, start, end))
  if (is.null(extra_countries)) {
    criteria <- c(selected_country)
  } else {
    criteria <- extra_countries
  }

  all_names <- df2 %>% 
    filter(date >= start & date < end) %>% 
    select(term2, count2, lib) %>% 
    group_by(term2, lib) %>% 
    mutate(sum = sum(count2)) %>% 
    select(term2, sum, lib) %>% 
    distinct() %>% 
    arrange(desc(sum))

  geo <- all_names %>% 
    left_join(coord, by = c("term2" = "city")) %>% 
    filter(!is.na(geoid)) %>% 
    filter(country %in% criteria)

  nr_of_libraries <- geo %>% 
    select(term2, lib) %>% 
    distinct() %>% 
    group_by(term2) %>% 
    mutate(nr_of_libraries = n()) %>% 
    select(-lib) %>% 
    distinct()
  
  geo <- geo %>% 
    left_join(nr_of_libraries, by = c("term2" = "term2"))
  
  geo <- geo %>% union(new_york)
  geo$nr_of_libraries <- factor(geo$nr_of_libraries)
    
  if (is_debug == TRUE) {
    # geo %>% view()
  }
  
  
  # if (nrow(geo) > 0) {
    maP <- ggplot() +
      geom_polygon(
        data = eu,
        aes(x = long, y = lat, group = group), # fill = region
        fill='#ffffff',
        colour = '#999999'
      ) +
      geom_point(
        data = geo,
        aes(x = long, y = lat, size = sum, # alpha = sum,
            colour=nr_of_libraries
            # alpha=1/nr_of_libraries
        ),
        # color = "red",
        # alpha = .8
      ) +
      scale_size(range = c(0, 6), breaks=seq(0, 1000, 100)) +
      # scale_radius()+
      geom_text(
        data = geo,
        mapping = aes(
          x = long, y = lat, label = term2, 
          colour=nr_of_libraries
          #alpha = 1/nr_of_libraries
          ),
        #colour='#3c78d8',
        nudge_y = ifelse(selected_country == 'Benelux', -0.1, -0.2),
        size = 2
      ) + 
      coord_cartesian(xlim = c(coords[1], coords[2]), ylim = c(coords[3], coords[4])) + 
      # scale_color_discrete(l=40, c=35) +
      # scale_color_manual(values=c("#999999", "#E69F00", "#56B4E9")) +
      # scale_color_manual(breaks = c("0", "1", "2"),
      #                    values=c("red", "blue", "green")) +
      scale_color_manual(breaks = c(1, 2, 3), values = palette) +
      theme_bw() +
      facet_wrap(.~lib) +
      labs(title = sprintf("books published in %s %d-%d",
                           selected_country, start, end),
           subtitle = 'as seen from')

    if (is_debug == TRUE) {
      maP <- maP +
        theme(
          legend.position = 'none',
          axis.title = element_blank(),
        )
    } else {
      maP <- maP +
        theme(
          legend.position = 'none',
          axis.title = element_blank(),
          axis.ticks = element_blank(),
          axis.text = element_blank(),
        )
    }
    
    ratio = (coords[2] - coords[1]) * 0.8 / (coords[4] - coords[3])
    
    width <- 1400
    height <- ((width/3) / ratio) + 200

    if (is_debug == TRUE) {
      print(maP)
    } else {
      filename <- sprintf('%s-map-%s-%s.jpg', 
            str_replace(selected_country, ' ', '-'), start, end)
      ggsave(filename, plot = maP, device = 'jpeg', scale = 1,
             width = width, height = height, units = "px", dpi = 150)
    }
  # }
}

by <- 10
for (i in seq(1500, (2010-by), by)) {
  show('Germany', i, i + by, c(6, 15, 47.5, 54.7))
  show('France', i, i + by, c(-4.4, 8, 42.6, 50.7))
  show('Italy', i, i + by, c(7, 18, 37, 46.7))
  show('Iberia', i, i + by, c(-9.2, 2.9, 36.2, 43.5), FALSE, c('Spain', 'Portugal'))
  show('Benelux', i, i + by, c(2.7, 7, 49.5, 53.5), FALSE, c('Netherlands', 'Belgium', 'Luxembourg'))
  show('British Isles', i, i + by, c(-10, 2, 50, 59), FALSE, c('United Kingdom', 'Ireland'))
}

show('France', 1620, 1630, c(-4.4, 8, 42.6, 50.7), TRUE)
show('Germany', 1810, 1820, c(6, 15, 47.5, 54.5), TRUE)
show('Italy', 1810, 1820, c(7, 18, 37, 46.7), TRUE)
show('Iberia', 1500, 1600, c(-9.2, 2.9, 36.2, 43.5), TRUE, c('Spain', 'Portugal'))
show('BeNeLux', 1500, 1600, c(2.7, 7, 49.5, 53.5), TRUE, c('Netherlands', 'Belgium', 'Luxembourg'))
show('British Isles', 1810, 1820, c(-10, 2, 50, 59), TRUE, c('United Kingdom', 'Ireland'))

