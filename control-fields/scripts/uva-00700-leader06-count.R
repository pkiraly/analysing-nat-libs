library(tidyverse)
library(grid)

file <- '/home/kiru/git/_research/national-libraries/uva-00700-leader06-count.csv'
df <- read_delim(file, delim = '|')

g <- df %>% 
  ggplot(aes(x = `00700`, y = leader06)) +
  geom_point(aes(size = count), colour = 'red') +
  #labs(
  #  title = 'Collocation of category of material (007/00) \nand type of record (LDR/06)',
  #  subtitle = 'in UvA catalogue'
  #) +
  #xlab('category of material (007/00)') +
  #ylab('type of record (LDR/06)') +
  theme_bw() +
  theme(
    axis.text.x = element_text(
      angle = 45, 
      hjust = 0,
      vjust = 0,
    ),
    axis.text.y = element_text(
      angle = 45,
    ),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    legend.position = "none",
    plot.margin = unit(c(0,2,2,0), "cm")
  ) +
  scale_x_discrete(position = "top")

g

print(
  g,
  vp = viewport(
    width = unit(0.5, "npc"),
    height = unit(0.5, "npc"), 
    angle = -45
  )
)

