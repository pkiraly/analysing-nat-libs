library(tidyverse)
library(phonics)
setwd('~/git/analysing-nat-libs/place-names')

# source("scripts/normalizePlaceNames.R") 
# normalizePlaceNames('onb')

name <- 'knihoveda' # onb, oszk, bnpl, knihoveda
# df <- read_csv('data_raw/nkp-place-time.csv')
# df <- read_csv('data_raw/onb-place-time.csv')
df <- read_csv(sprintf('data_raw/%s-place-time.csv', name))
nrow(df)

df %>% view()

df2 <- df %>% 
  filter(!is.na(date)) %>% 
  mutate(date = str_replace_all(date, '[\\?u]', '0')) %>% 
  filter(grepl('^\\d+$', date)) %>% 
  
  mutate(term = str_replace(term, " :$", '')) %>% 
  mutate(term = str_replace(term, " (\\[u\\.a\\.\\]|usw\\.)$", '')) %>% 
  mutate(term = str_replace(
    term, 
    "^(S\\.l\\.?|S.L.|s\\.l\\.|o.O.|\\[S.l.\\]|\\[O.O.\\]|S. l|S\\.I\\.|s. l.|O. O.|	
\\[s\\.l\\.\\]|\\[S\\.I\\.\\])$", 'S. l.'
  )) %>% 
  mutate(term = ifelse(term %in% c(
    '[s.l.]', '[S. l.]', '[Ohne Ort]', '[S .l.]', '[S. I.]',
    '[s.l.', '[S.l. ]', '[s.l.].', '[S.l[', '[sine loco', '[S.l.', '[S. l.',
    '[Miejsce nieznane]', '[Miejsce nieznane', '[miejsce nieznane',
    '[Miejsce nieznane:', '[Miejsce nieznane],', '[Miejsce niezanane',
    '[Miejsce nieznane]:', '[Miejsce nieznane,', '[miejsce nieznane]',
    '[Miejsce niezanane]'
    ), 
    'S. l.', term)) %>% 
  mutate(term = str_replace(term, "^Gedruckt zu ", '')) %>% 
  filter(term != 'S. l.') %>% 
  mutate(date = as.integer(date)) %>% 
  filter(date >= 1700 & date <= 1800)

# view(df2)
nrow(df2)
df2 %>% filter(grepl(' et ', term)) %>% arrange(date)

cities_in_onb <- df2 %>% 
  group_by(term) %>% 
  summarise(n = sum(count))
# cities_in_onb %>% view()
names(cities_in_onb) # term, n
n_total <- sum(cities_in_onb$n)
print(n_total)

coord <- read_csv('data_internal/coord.csv')
coord <- coord %>% mutate(
  lat = as.double(lat),
  long = as.double(long)
)
# coord %>% view()

runIt <- function() {
  coord <- read_csv('data_internal/coord.csv')
  coord <- coord %>% mutate(
    lat = as.double(lat),
    long = as.double(long)
  )
  synonyms <- read_csv('data_internal/place-synonyms-normalized.csv', show_col_types = FALSE)
  
  cities_in_onb2 <- cities_in_onb %>%
    left_join(synonyms, by = c('term' = 'original')) %>% 
    mutate(normalized = ifelse(is.na(normalized), term, normalized))

  unknown_cities <- cities_in_onb2 %>% 
    left_join(coord, by = c('normalized' = 'city'))  %>% 
    filter(is.na(geoid))

  n_unknown <- sum(unknown_cities$n)
  print(sprintf("books - total: %d, with unknown location: %d (%.3f%%)",
         n_total, n_unknown, (n_unknown * 100 / n_total)))

  # unknown_cities %>% 
  #   filter(term == normalized) %>% 
  #   arrange(desc(n)) %>% 
  #   view()

  unknown_cities %>% 
    filter(term == normalized) %>% 
    select(term, n) %>% 
    mutate(soundex = soundex(term)) %>% 
    arrange(desc(n)) %>% 
    view()
}
runIt()

synonyms <- read_csv('data_internal/place-synonyms-normalized.csv', show_col_types = FALSE)

cities_in_onb2 <- cities_in_onb %>%
  left_join(synonyms, by = c('term' = 'original')) %>% 
  mutate(
    normalized = ifelse(is.na(normalized), term, normalized),
    factor = ifelse(is.na(factor), 1.0, factor)
  )

# cities_in_onb2 %>% view()

known_cities <- cities_in_onb2 %>% 
  left_join(coord, by = c('normalized' = 'city')) %>% 
  filter(!is.na(geoid))

# known_cities %>% view()

no_countries <- c('Iraq', 'China', 'United States',
'Egypt', 'India', 'Sri Lanka', 'Nicaragua', 'Israel', 'Japan', 'Peru',
'Philippines', 'Mexico', 'Australia', 'Chile')

good_cities <- known_cities %>% 
  filter(!country %in% no_countries)
good_cities %>% select(country) %>% distinct() %>% unlist(use.names = FALSE)

df3 <- df2 %>% 
  left_join(good_cities, by = c('term' = 'term')) %>% 
  filter(!is.na(geoid)) %>% 
  mutate(weighted_count = count * factor) %>% 
  select(-c(n, factor, count)) %>% 
  rename(count = weighted_count)

# df3 %>% view()

df_variants <- df3 %>% 
  select(date, normalized, term) %>% 
  group_by(date, normalized) %>% 
  summarise(variants = paste(term, collapse = '|'))

df3 %>%
  select(normalized, geoid, date, count, country, lat, long) %>% 
  group_by(normalized, country, geoid, lat, long, date) %>% 
  summarise(n = sum(count), .groups = "keep") %>% 
  ungroup() %>% 
  left_join(df_variants, by = c("date" = "date", "normalized" = "normalized")) %>% 
  rename(city = normalized, id = geoid) %>% 
  write_csv(sprintf('data/%s-place-time-normalized.csv', name))

#########

map.europe <- map_data("world")
min(good_cities$long)

minx <- min(good_cities$long)
maxx <- max(good_cities$long)
miny <- min(good_cities$lat)
maxy <- max(good_cities$lat)
print(paste(minx, maxx, miny, maxy))
step <- 1
years = seq(1700, 1800, step)
dir <- paste0('img/', name)
if (!dir.exists(dir)) {
  dir.create(dir)
}
for (i in years) {
  j <- i + step - 1
  title <- ifelse(i == j, paste0(i), paste0(i, '-', j))
  print(title)
  
  decade <- df3 %>% 
    filter(date >= i & date <= j & !is.na(term)) %>% 
    select(normalized, date, count, lat, long) %>% 
    group_by(normalized, lat, long) %>% 
    summarise(n = sum(count), .groups = "keep") %>% 
    ungroup()
  if (nrow(decade) > 0) {
    n_places <- decade %>% select(normalized) %>% nrow()
    n_books <- decade %>% select(n) %>% sum() %>% unlist(use.names = FALSE)
  } else {
    n_places <- 0
    n_books <- 0
  }
  
  ggplot() +
    geom_polygon(
      data = map.europe,
      aes(x = long, y = lat, group = group),
      fill = '#ffffff',
      colour = '#999999'
    ) +
    geom_point(
      data = decade,
      aes(x = long, y = lat, size = n),
      color = "red",
      alpha = .8) +
    geom_text(
      data = decade,
      mapping = aes(x = long, y = lat, label = normalized),
      nudge_y = -0.05,
      size = 1.8
    ) +
    coord_cartesian(
      xlim = c(minx, maxx),
      ylim = c(miny, maxy),
    ) +
    ggtitle(
      paste0(title, ': ', n_books, ' publications published in ',
             n_places, ' locations')
      # subtitle = 'Hungarian literature in foreign languages'
    ) +
    theme(
      legend.position = 'none',
      axis.title = element_blank(),
      axis.ticks = element_blank(),
      axis.text = element_blank(),
    )
  
  ggsave(paste0(dir, '/', name, '-', title, '.jpg'), 
         width = 5.5, height = 4, units = 'in', dpi = 300)
}

df3
top20 <- df3 %>% 
  group_by(normalized) %>% 
  summarise(n = sum(count)) %>% 
  arrange(desc(n)) %>% 
  head(50)

top20
places <- top20 %>% select(normalized) %>% unlist(use.names = FALSE)
places

df3 %>% 
  left_join(top20, by = c('normalized' = 'normalized')) %>% 
  filter(!is.na(n)) %>% 
  select(normalized, date, count) %>% 
  ggplot(aes(x = date, y = factor(normalized, levels = rev(places)))) +
  geom_point(aes(color = count)) +
  scale_color_continuous(trans = 'log10', type = "viridis") +
  theme_bw() +
  ggtitle(
    '18th century books in ÖNB',
    subtitle = 'top 50 publication place'
  ) +
  xlab('year of publication') +
  ylab('publication place') +
  labs(color = "nr of\nbooks")

topN <- 10
top5 <- df3 %>% 
  group_by(normalized) %>% 
  summarise(n = sum(count)) %>% 
  arrange(desc(n)) %>% 
  head(topN)
top5

joined <- df3 %>% 
  left_join(top5, by = c('normalized' = 'normalized'))

joined %>% view()

df4 <- df3 %>% 
  left_join(top5, by = c('normalized' = 'normalized')) %>% 
  filter(!is.na(n)) %>% 
  select(normalized, date, count) %>% 
  group_by(normalized, date) %>% 
  summarise(n = sum(count), .groups = 'keep') %>% 
  ungroup()

max <- max(df4$n)
max

df4 %>% 
  ggplot(aes(x = date, y = factor(normalized, levels = rev(places)))) +
  geom_line(aes(y = n, color=normalized))


cities <- top5 %>% select(normalized) %>% unlist(use.names = FALSE)

ddd <- data.frame(city = cities, 
                  x = rep(1700, topN), 
                  y = ((seq(topN-1, 0) * max)),
                  min = 0)
ddd
seq(1700, 1800, 10)
p <- df4 %>% ggplot() +
  labs(x = NULL, y = NULL,
       title = paste('Top', topN, 'publishing places in 18th century collection of ÖNB')) +
  theme_bw() +
  theme(
    axis.ticks.y = element_blank(),
    axis.text.y = element_blank(),
    panel.grid = element_blank(),
    legend.position = "none"
  ) +
  scale_x_continuous(breaks = seq(1700, 1800, 10)) + 
  geom_hline(yintercept = ddd$y, color = '#eeeeee') + 
  geom_vline(xintercept = seq(1700, 1800, 10), color = '#eeeeee') + 
  geom_text(
    data = ddd, 
    aes(x = x, y = y + 350, label = city, 
        hjust='left', vjust='top'))

j = topN
for (i in cities) {
  delta <- (j-1) * max
  print(delta)
  ddd[j, c('min')] <- df4 %>% filter(normalized == i) %>% select(n) %>% min() %>% unlist(use.names = FALSE)
  dat <- df4 %>% filter(normalized == i) %>% 
    mutate(h = n + delta)
  p <- p + geom_point(data = dat, 
                      aes(x = date, y = h, alpha=n), 
                      color = 'blue')
  j = j - 1
}

p
