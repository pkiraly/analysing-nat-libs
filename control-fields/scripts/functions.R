if (!("tidyverse" %in% (.packages()))) {
  library(tidyverse)
}

setLanguage <- function(df_normalized, language, fieldA, fieldB) {
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
    txt_title <- paste(fieldA$title_en, fieldB$title_en, sep = ' vs.\n')
    txt_subtitle <- 'in national libraries'
    txt_xlab <- fieldB$lab_en
    txt_ylab <- fieldA$lab_en
  }
  return(list(df=df_language, 'txt_title'=txt_title, 'txt_subtitle'=txt_subtitle,
              'txt_xlab'=txt_xlab, 'txt_ylab'=txt_ylab))
}

createImage <- function(params) {
  print(names(params$df))
  # view(params$df)
  g <- params$df %>% 
    ggplot(aes(x = x, y = reorder(y, desc(y)))) +
    geom_point(aes(size = percentage, colour = count)) +
    labs(title = params$txt_title, #subtitle = params$txt_subtitle
    ) +
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
    scale_size(range = c(0, 6), breaks=seq(0, params$max_count, 100)) +
    scale_x_discrete(position = "top") +
    facet_wrap(vars(title))
  print(g)
  return(g)
}

runAll <- function(.prefix, codeA, codeB) {
  # source('control-fields/scripts/codes.R')

  libs <- libraries %>% 
    filter(is_national == TRUE) %>% 
    select(catalogue) %>% 
    unlist(use.names = FALSE)
  
  collocations_count <- counts %>% 
    filter(id == .prefix) %>% 
    select(catalogue, count, percentage)

  params <- comparisions %>% filter(prefix == .prefix)
  a <- params$a
  b <- params$b
  
  codeA <- codeA %>% rename(hungarianA = hungarian, englishA = english)
  codeB <- codeB %>% rename(hungarianB = hungarian, englishB = english)
  fieldA <- fields %>% filter(solr == a) %>% select(-solr)
  fieldB <- fields %>% filter(solr == b) %>% select(-solr)
  
  df <- read_csv(sprintf('control-fields/data_raw/%s.csv', .prefix), show_col_types = FALSE)
  
  df_renamed <- df %>% 
    rename(a = a, b = b) %>% 
    mutate(
      a = ifelse(nchar(a) <= 1 | is.na(a), '[invalid]', a),
      b = ifelse(nchar(b) <= 1 | is.na(b), '[invalid]', b)
    ) #%>% 
    # filter(catalogue == 'onb')
  
  nr_replacement <- replacement %>% filter(prefix == .prefix) %>% nrow()
  if (nr_replacement == 1) {
    repl <- replacement %>% filter(prefix == .prefix) %>% select(replacement) %>% 
      unlist(use.names = FALSE)

    df_renamed <- df_renamed %>% 
      mutate(b = gsub(repl, '', b)) %>% 
      mutate(b = gsub('Phonodisc, phonowire, etc.', 'Phonodisc phonowire etc.', b)) %>% 
      mutate(b = gsub('Humor, satires, etc.', 'Humor satires etc.', b)) %>% 

      separate(b, into = c('e', 'f', 'g', 'h'), sep = ', ') %>% 
      pivot_longer(c('e', 'f', 'g', 'h'), names_to = 'x', values_to = 'b') %>% 
      filter(!is.na(b)) %>% 
      select(-x) %>%
      mutate(
        a = ifelse(nchar(a) <= 1 | is.na(a), '[invalid]', a),
        b = ifelse(nchar(b) <= 1 | is.na(b), '[invalid]', b)
      ) %>% 
      mutate(b = gsub('Phonodisc phonowire etc.', 'Phonodisc, phonowire, etc.', b)) %>% 
      mutate(b = gsub('Humor satires etc.', 'Humor, satires, etc.', b)) %>% 
      group_by(catalogue, a, b) %>% 
      summarise(count = sum(count), .groups = 'drop') %>% 
      ungroup()
  }
  normalizedFile <- sprintf('control-fields/data_raw/%s-normalized.csv', .prefix)
  if (file.exists(normalizedFile)) {
    df_renamed <- read_csv(normalizedFile)
  } else {
    As <- codeA %>% select(solr) %>% unlist(use.names = FALSE)
    Bs <- codeB %>% select(solr) %>% unlist(use.names = FALSE)
    for (A in As) {
      for (B in Bs) {
        for (cat in libs) {
          if (df_renamed %>% filter(catalogue == cat && a == A && b == B) %>% nrow() == 0) {
            df_renamed <- df_renamed %>% 
              add_row(catalogue = cat, a = A, b = B, count = NA)
          }
        }
      }
    }
    write_csv(df_renamed, normalizedFile)
  }

  max_count <- max(df$count)
  
  df_normalized <- df_renamed %>% 
    left_join(libraries, by = c('catalogue' = 'catalogue')) %>% 
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
  
  cat_filled <- df_normalized %>% 
    select(catalogue) %>% 
    distinct() %>% 
    unlist(use.names = FALSE)

  all_represented <- TRUE
  if (length(libs) != length(cat_filled)) {
    all_represented <- FALSE
    missing_libs <- setdiff(libs, cat_filled)
    print(paste('missing_libs:', paste(missing_libs, collapse = ', ')))
  }

  languages <- c('english', 'hungarian')
  # languages <- c('hungarian')
  for (language in languages) {

    lib2 <- libraries %>% 
      filter(is_national == TRUE) %>% 
      left_join(collocations_count, by = c('catalogue' = 'catalogue')) %>% 
      select(language, count, percentage) %>% 
      rename(coll_count = count) %>%
      rename(l = language) %>%
      mutate(title = sprintf(
        "%s\n%s %s (%.1f%%)", l, 
        str_replace_all(scales::label_comma()(coll_count), ',', ' '),
        ifelse(language == 'hungarian', 'rekord', 'records'),
        percentage
      ))

    titles <- lib2$title

    imgParams <- setLanguage(df_normalized, language, fieldA, fieldB)
    imgParams$max_count <- max_count

    if (all_represented == FALSE) {
      for (lib in missing_libs) {
        name <- libraries %>% filter(catalogue == lib) %>% 
          select(language) %>% 
          unlist(use.names = FALSE)
        row <- imgParams$df %>% 
          head(n=1) %>% 
          mutate(count = NA, library = name) 
        imgParams$df <- imgParams$df %>% union(row)
      }
      if (language == 'hungarian') {
        .levels <- libraries$hungarian
      } else {
        .levels <- libraries$english
      }
      imgParams$df$library <- factor(imgParams$df$library, levels=.levels)
    }

    imgParams$df <- imgParams$df %>% 
      left_join(lib2, by = c('library' = 'l')) %>%
      select(-c(library)) %>% 
      mutate(percentage = count/coll_count)
    imgParams$df$title <- factor(imgParams$df$title, levels=titles)

    # collocations_count

    yVals_fct <- imgParams$df %>% select(y) %>% distinct() %>% unlist(use.names = FALSE)
    yVals <- as.character(yVals_fct)
    y <- length(yVals)

    xVals_fct <- imgParams$df %>% select(x) %>% distinct() %>% unlist(use.names = FALSE)
    xVals <- as.character(xVals_fct)
    x <- length(xVals)

    ymarg <- max(nchar(xVals), na.rm = TRUE)
    xmarg <- max(nchar(yVals), na.rm = TRUE)

    if (x > 20) {
      x <- 20
    }

    g <- createImage(imgParams)
    dir <- sprintf('control-fields/img/%s', language)
    if (!dir.exists(dir)) {
      dir.create(dir)
    }
    filename <- sprintf('%s/%s-nat.jpg', dir, .prefix)
    .width <- (x * 100) + (10 * xmarg) + 100
    if (.width < 1100) {
      print(sprintf('extra low width: %d', .width))
      .width <- 1100
    }
    .height <- (y * 100) + (10 * round(sqrt(ymarg^2 / 2))) + 100
    if (.height > 2000) {
      print(sprintf('extra height: %d', .height))
      .height <- 2000
    }

    #print(sprintf('x=%d, y=%d, xmarg=%d, ymarg=%d -> width=%d, height=%d',
    #              x, y, xmarg, ymarg, .width, .height))
    print(filename)
    ggsave(filename, g, device = 'jpeg', scale = 1,
           width = .width, height = .height, units = "px", dpi = 150) # 1300, 1500
  }
}

