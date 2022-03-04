if (!("tidyverse" %in% (.packages()))) {
  library(tidyverse)
}

runAll <- function(.prefix, codeA, codeB) {
  params <- comparisions %>% filter(prefix == .prefix)
  a <- params$a
  b <- params$b
  
  codeA <- codeA %>% rename(hungarianA = hungarian, englishA = english)
  codeB <- codeB %>% rename(hungarianB = hungarian, englishB = english)
  fieldA <- fields %>% filter(solr == a) %>% select(-solr)
  fieldB <- fields %>% filter(solr == b) %>% select(-solr)
  
  df <- read_csv(sprintf('control-fields/data_raw/%s.csv', .prefix))
  max_count <- max(df$count)
  
  df_normalized <- df %>% 
    rename(a = a, b = b) %>% 
    mutate(
      a = ifelse(nchar(a) == 1 | is.na(a), '[invalid]', a),
      b = ifelse(nchar(b) == 1 | is.na(b), '[invalid]', b)
    ) %>% 
    left_join(libraries) %>% 
    left_join(codeA, by = c('a' = 'solr')) %>% 
    left_join(codeB, by = c('b' = 'solr')) %>% 
    mutate(
      catalogue = factor(catalogue, levels=libraries$catalogue),
      hungarian = factor(hungarian, levels=libraries$hungarian),
      english = factor(english, levels=libraries$english),
      hungarianA = factor(hungarianA, levels=codeA$hungarianA),
      englishA = factor(englishA, levels=codeA$englishA),
      hungarianB = factor(hungarianB, levels=codeB$hungarianB),
      englishB = factor(englishB, levels=codeB$englishB)
    ) %>% 
    filter(is_national == TRUE)

  print(paste('df_normalized: ', dim(df_normalized)))
  
  languages <- c('english', 'hungarian')
  for (language in languages) {
    imgParams <- setLanguage(df_normalized, language)
    g <- createImage(imgParams)
    
    filename <- sprintf('control-fields/img/%s-nat.%s.jpg', .prefix, language)
    ggsave(filename, g, device = 'jpeg', scale = 1,
           width = 1300, height = 1500, units = "px", dpi = 150)
  }
}

setLanguage <- function(df_normalized, language) {
  if (language == 'hungarian') {
    df_language <- df_normalized %>% 
      mutate(x = hungarianB, y = hungarianA, library = hungarian) %>% 
      select(x, y, count, library)
    txt_title <- paste(fieldA$title_hu, fieldB$title_hu, sep = ' és ')
    txt_subtitle <- 'nemzeti könyvtárakban'
    txt_xlab <- fieldB$lab_hu
    txt_ylab <- fieldA$lab_hu
  } else if (language == 'english') {
    df_language <- df_normalized %>% 
      mutate(x = englishB, y = englishA, library = english) %>% 
      select(x, y, count, library)
    txt_title <- paste(fieldA$title_en, fieldB$title_en, sep = ' vs. ')
    txt_subtitle <- 'in national libraries'
    txt_xlab <- fieldB$lab_en
    txt_ylab <- fieldA$lab_en
  }
  return(list(df=df_language, 'txt_title'=txt_title, 'txt_subtitle'=txt_subtitle,
                              'txt_xlab'=txt_xlab, 'txt_ylab'=txt_ylab))
}

createImage <- function(params) {

  print(paste('df: ', dim(params$df)))
  
  g <- params$df %>% 
    ggplot(aes(x = x, y = reorder(y, desc(y)))) +
    geom_point(aes(size = count), colour = 'red') +
    labs(title = params$txt_title, subtitle = params$txt_subtitle) +
    xlab(params$txt_xlab) +
    ylab(params$txt_ylab) +
    theme_bw() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 0, vjust = 0),
      # axis.text.y = element_text(angle = 45),
      # axis.title.x = element_blank(),
      # axis.title.y = element_blank(),
      # title = element_blank(),
      legend.position = "none",
      plot.margin = unit(c(0.2,2,0.2,0.2), "cm")
    ) +
    scale_size(range = c(0, 6), breaks=seq(0, max_count, 100)) +
    scale_x_discrete(position = "top") +
    facet_wrap(vars(library))
  return(g)
}