normalizePlaceNames <- function(prefix) {
  col_types <- ifelse(prefix == 'bnpt', "cci", "icci")
  df <- read_csv(sprintf('%s-place-time.csv', prefix), col_types=col_types)
  print(names(df))

  print('remove rank')
  if ('rank' %in% names(df)) {
    df <- df %>%
      select(-rank)
  }
  
  print('fix date')
  df_date <- df %>% 
    filter(grepl('^\\d+$', date)) %>% 
    mutate(date = as.integer(date)) %>% 
    filter(date >= 1500 & date <= 2022)
  
  print('replace 1')
  df_name <- df_date %>% 
    mutate(term2 = str_replace(term, ' ?[\\.;:,] ?$', '')) %>% 
    mutate(term2 = str_replace(term2, ' \\[etc\\.?\\]$', '')) %>%
    mutate(term2 = str_replace(term2, '^\\[(.*?)\\]$', '\\1')) %>% 
    mutate(term2 = str_replace(term2, '^\\((.+)\\)$', '\\1')) %>%
    mutate(term2 = str_replace(term2, '^\\[', '')) %>% 
    mutate(term2 = str_replace(term2, '^\\s+', '')) %>% 
    mutate(term2 = str_replace(term2, '^\\(', '')) %>% 
    mutate(term2 = str_replace(term2, ' ?\\[\\?\\]$', '')) %>% 
    mutate(term2 = str_replace(term2, '^,$', '')) %>% 
    mutate(term2 = str_replace(term2, 'ü', 'ü')) %>% # ANSEL code to UTF-8
    mutate(term2 = str_replace(term2, 'ö', 'ö')) %>% # ANSEL code to UTF-8
    mutate(term2 = str_replace(term2, '^A ', '')) %>%
    mutate(term2 = str_replace(term2, '^À ', '')) %>%
    mutate(term2 = str_replace(term2, '^(W |w )', '')) %>%
    mutate(term2 = str_replace(term2, "^(t' ?|T'|t'|Te |Tot |In |'t |te | |à |à |À |Zu |tot |En |a |t |T |'T |á |Á |Á |I |Em |em )", '')) %>%
    mutate(term2 = str_replace(term2, "^(Gedruckt (tot |t'|zu )|Getruckt zu |Getr\\. zu |Getrukt zu |Getruckt zü |Getruckt zů |Ghedruct (tot |t')|Gedrukt te )", '')) %>%
    mutate(term2 = str_replace(term2, "^(Prentätty |Prentättu |Prentattu |Prentat i |Präntätty |Prändätty |Prändäty |Prändätty |Prändätyt |Präntätyd )", '')) %>%
    mutate(term2 = str_replace(term2, "^(Omtryckt i |Tryckt (j|på|i) |Tryckt uthi |Tryckte i |Trykkt i |Trykt i |Tryckt)", '')) %>%
    mutate(term2 = str_replace(term2, "^Se vend (a|à) ", '')) %>%
    mutate(term2 = str_replace(term2, "^Imprimé en (la ville de )?", '')) %>%
    mutate(term2 = str_replace(term2, "^(Imprinted at |Imprimé à |Imprim. à |Gedruckt (te|in|ter|zur) |Impressvm et finitvm |Impressum |Impressvm |Reimpressvm |Impressa |Reimpressa |Typis impressa |Imprimé à |Réimprimé à |Sur l'imprimé à |Imprimé a |Recvsa |Recusa |Excussum |Excvsvm |Excvsae |Excvsa |Excvssvm |Excusa |Impr\\. |Exc\\. |Impressus |Imprimebatur |Imprimebat |Impresso em |Impresso en |Impresse |Impresa en |Impressae uero |Impr\\[e\\]ssum |Impresso in )", '')) %>%
    mutate(term2 = str_replace(term2, " (impressit|impressum|impressa|prändätty|recusa)$", '')) %>%
    
    mutate(term2 = str_replace(term2, "^(S\\.l\\.?|S.L.|s\\.l\\.|Place of publication not identified|Miejsce nieznane.*|miejsce nieznane|Miejsce niezane|Kustannuspaikka tuntematon|S. l|S\\.I\\.|s. l.)$", 'S. l.')) %>%
    mutate(term2 = str_replace(term2, "^et se trouve (a|à) ", '')) %>%
    mutate(term2 = str_replace(term2, "^Verteutscht und gedruckt zu ", '')) %>%
    mutate(term2 = str_replace(term2, "^(Prostant|Venundantur|Veneunt) ", '')) %>%
    mutate(term2 = str_replace(term2, "^(label: ) ", '')) %>%
    mutate(term2 = str_replace(term2, "^\\s+", '')) %>%
    mutate(term2 = str_replace(term2, " (etc|ecc|usw)\\.?$", '')) %>%
    mutate(term2 = str_replace(term2, " ?\\[( ?etc|ecc|usw)  ?\\.?\\]$", '')) %>%
    mutate(term2 = str_replace(term2, "[,:\\?]$", '')) %>%

    mutate(term2 = str_replace(term2, ",? (MA\\.|Ma\\.?|Mas\\.?|Mass\\.?|Massachusetts|Massachesetts)(,? U\\.?S\\.?A)?$", ', MA')) %>%
    mutate(term2 = str_replace(term2, ",? (\\(Mass\\.?\\)|\\[Mass\\.?\\]|Mass\\.?)(,? U\\.?S\\.?A)?$", ', MA')) %>%

    mutate(term2 = str_replace(term2, ", (Md\\.?|M\\.?D\\.|Maryland)(,? U\\.?S\\.?A)?$", ', MD')) %>%
    mutate(term2 = str_replace(term2, ",? \\[Md.\\]$", ', MD')) %>%

    mutate(term2 = str_replace(term2, ",? (Oh\\.?|OH\\.|Ohion|Ohio|OHIO|\\[Ohio\\]|\\(Ohio\\)|\\[OH\\])(,? U\\.?S\\.?A)?$", ', OH')) %>%
    mutate(term2 = str_replace(term2, ", (I(ll?|LL?)\\.?|Illinois)(,? U\\.?S\\.?A)?$", ', IL')) %>%
    mutate(term2 = str_replace(term2, ", (Pa\\.?)(,? U\\.?S\\.?A)?$", ', PA')) %>%
    mutate(term2 = str_replace(term2, ", (CA\\.|Ca\\.?|Cal\\.?|Calif\\.?\\]?|California|Califórnia)(,? U\\.?S\\.?A)?$", ', CA')) %>%
    mutate(term2 = str_replace(term2, ", (Ct\\.?|CT\\.|Conn\\.?|Connecticut)(,? U\\.?S\\.?A)?$", ', CT')) %>%
    mutate(term2 = str_replace(term2, ", (VA\\.|Va\\.?|Virginia)(,? U\\.?S\\.?A)?$", ', VA')) %>%
    mutate(term2 = str_replace(term2, ", (Mn\\.?|MN\\.Minn\\.?|Minnesota)(,? U\\.?S\\.?A)?$", ', MN')) %>%
    mutate(term2 = str_replace(term2, ", ((Wa|Wash|\\[WA\\])\\.?|WA\\.|Washington)(,? U\\.?S\\.?A)?$", ', WA')) %>%
    mutate(term2 = str_replace(term2, ", ((Or|Ore|Oreg)\\.?|OR\\.|Oregon)(,? U\\.?S\\.?A)?$", ', OR')) %>%
    mutate(term2 = str_replace(term2, ", ((Ok|Okl|Okla|Oklah)\\.?|OK\\.|Oklahoma)(,? U\\.?S\\.?A)?$", ', OK')) %>%
    mutate(term2 = str_replace(term2, ", ((Nv|Nev)\\.?|NV\\.|Nevada)(,? U\\.?S\\.?A)?$", ', NV')) %>%
    mutate(term2 = str_replace(term2, ", (LA\\.|La\\.?|Lou\\.?|Louisiana)(,? U\\.?S\\.?A)?$", ', LA')) %>%
    mutate(term2 = str_replace(term2, ", (TX\\.|Tx\\.?|Tex\\.?|Texas)(,? U\\.?S\\.?A)?$", ', TX')) %>%
    mutate(term2 = str_replace(term2, ", (NJ\\.|Nj\\.?|N\\. ?J\\.?|New Jersey)(,? U\\.?S\\.?A)?$", ', NJ')) %>%
    mutate(term2 = str_replace(term2, ", (NY\\.|Ny\\.?|N\\. ?Y\\.?|New York)(,? U\\.?S\\.?A)?$", ', NY')) %>%
    mutate(term2 = str_replace(term2, ", (FL\\.|Fl\\.?|F\\.L\\.?|Fla\\.?|Flo\\.?|Flor\\.?|Florida|Floryda)(,? U\\.?S\\.?A)?$", ', FL')) %>%
    mutate(term2 = str_replace(term2, ", (TN\\.|Tn\\.?|Tenn\\.?|Tennessee)(,? U\\.?S\\.?A)?$", ', TN')) %>%
    mutate(term2 = str_replace(term2, ", (CO\\.|Co\\.?|Col\\.?|Colo\\.?|Kol\\.|Colorado)(,? U\\.?S\\.?A)?$", ', CO')) %>%
    mutate(term2 = str_replace(term2, ", (UT\\.|Ut\\.?|Utah)(,? U\\.?S\\.?A)?$", ', UT')) %>%
    mutate(term2 = str_replace(term2, ",? (MI\\.|Mi\\.?|Mich\\.?|Michigan|\\[(Mich.\\|MI)])(,? U\\.?S\\.?A)?$", ', UT')) %>%
    mutate(term2 = str_replace(term2, ", ?(MI\\.|Mi\\.?|Mich\\.?|Michigan|\\[(Mich.\\|MI)])(,? U\\.?S\\.?A)?$", ', UT')) %>%
    mutate(term2 = str_replace(term2, ", (RI\\.|R\\. ?I\\.?|Rhode Island)(,? U\\.?S\\.?A)?$", ', RI')) %>%
    mutate(term2 = str_replace(term2, ", (IN\\.|I\\. ?N\\.?|In\\.?|Ind\\.?|Indiana)(,? U\\.?S\\.?A)?$", ', IN')) %>%
    mutate(term2 = str_replace(term2, ", (NC\\.|N\\. ?C\\.?|Nc\\.?|North Carolin[ea])(,? U\\.?S\\.?A)?$", ', NC')) %>%
    mutate(term2 = str_replace(term2, ", (IA\\.|I\\. ?A\\.?|Iowa)(,? U\\.?S\\.?A)?$", ', IA')) %>%
    mutate(term2 = str_replace(term2, ", (NH\\.|N\\. ?N\\.?|New Hampshire)(,? U\\.?S\\.?A)?$", ', NH')) %>%
    mutate(term2 = str_replace(term2, ", (NM\\.|N\\. ?M\\.?|New Mexico|\\(New Mexico\\))(,? U\\.?S\\.?A)?$", ', NM')) %>%
    mutate(term2 = str_replace(term2, ",? (LA\\.|L\\. ?A\\.?)(,? U\\.?S\\.?A)?$", ', LA')) %>%
    mutate(term2 = str_replace(term2, ",? (HI\\.|H\\. ?I\\.?|Hawaii|Hawai'i|Hawaiʿi|Hawaï)(,? U\\.?S\\.?A)?$", ', HI')) %>%
    mutate(term2 = str_replace(term2, ",? (AZ\\.|A\\. ?Z\\.?|Ari\\.?|Ariz\\.?|Arizona)(,? U\\.?S\\.?A)?$", ', AZ')) %>%
    mutate(term2 = str_replace(term2, ",? (MN\\.|MIN\\.?|M\\. ?N\\.?|Min\\.?|Minn\\.?|Minnes\\.?|Minnesota|\\(Minnesota\\)|\\[Minnesota\\])(,? U\\.?S\\.?A)?$", ', MN')) %>%
    mutate(term2 = str_replace(term2, " , ", ', '))

  print('cities')
  df_cities <- df_name %>% 
    mutate(term2 = str_replace(term2, "^(den Haag.*|Den Haag.+|'s Graven.+|.*[Gg]ravenhage)$", 'Den Haag')) %>%
    mutate(term2 = str_replace(term2, "^(Amstelredam.*|Amsterdam.+|Amsteldam.*|Amstelaedam.*|Amstelædami.*)$", 'Amsterdam')) %>%
    mutate(term2 = str_replace(term2, "^(Antverpiæ.*|Antwerpen.+)$", 'Antwerpen')) %>%
    mutate(term2 = str_replace(term2, "^(Athēnais.+|Athēna:.*)$", 'Athens')) %>%
    mutate(term2 = str_replace(term2, "^(Basileae.*|Basileæ.*|Basel etc.*)$", 'Basel')) %>%
    mutate(term2 = str_replace(term2, "^(Frankfurt/M.*|Frankfurt a. Main.*)$", 'Frankfurt am Main')) %>%
    mutate(term2 = str_replace(term2, "^(Groningen.+)$", 'Groningen')) %>%
    mutate(term2 = str_replace(term2, "^(Halle .*)$", 'Halle')) %>%
    mutate(term2 = str_replace(term2, "^(Lugduni.*|L[vu]gd\\. Batav.+|Leiden.+)$", 'Leiden')) %>%
    mutate(term2 = str_replace(term2, "^(Leipzig.+)$", 'Leipzig')) %>%
    mutate(term2 = str_replace(term2, "^(London.+|Londini.*)$", 'London')) %>%
    mutate(term2 = str_replace(term2, "^(Moskva.+)$", 'Moskva')) %>%
    mutate(term2 = str_replace(term2, "^(New York.*)$", 'New York')) %>%
    mutate(term2 = str_replace(term2, "^(Paris.*)$", 'Paris')) %>%
    mutate(term2 = str_replace(term2, "^(Leningrad.*||S.-Peterburg'')$", 'Sankt-Peterburg')) %>%
    mutate(term2 = str_replace(term2, "^(Trajecti ad Rhen.*|Utrecht.+)$", 'Utrecht')) %>%
    mutate(term2 = str_replace(term2, "^(Venet.+|.*\\[Venezia\\])$", 'Venezia')) %>%
    mutate(term2 = str_replace(term2, "^Alphen (aan den?|a.d.|a/d) R(ĳ|ij)n$", 'Alphen aan den Rijn')) %>%
    mutate(term2 = str_replace(term2, "^(Freiburg i.+)$", 'Freiburg')) %>%
    mutate(term2 = str_replace(term2, "^(Hildburghausen.+)$", 'Hildburghausen')) %>%
    mutate(term2 = str_replace(term2, "^(Oxford.+)$", 'Oxford')) %>%
    mutate(term2 = str_replace(term2, "^.*\\[Thessaloníki\\]$", 'Thessalonikē')) %>%
    mutate(term2 = str_replace(term2, "^(Wittenberg.+)$", 'Wittenberg')) %>%
    mutate(term2 = str_replace(term2, "^(.*Berlin.*)$", 'Berlin')) %>%
    mutate(term2 = str_replace(term2, "^(Lemberg ?.*)$", "L'vìv")) %>%
    mutate(term2 = str_replace(term2, "^(Königsberg.*)$", "Kaliningrad")) %>%
    mutate(term2 = str_replace(term2, "^(Stettin.*|Szczecin.+)$", "Szczecin")) %>%
    mutate(term2 = str_replace(term2, "^(Danzig.*)$", "Gdańsk")) %>%
    mutate(term2 = str_replace(term2, "^(Regensburg.+)$", "Regensburg")) %>%
    mutate(term2 = str_replace(term2, "^(Kattowitz.*)$", "Katowice")) %>%
    mutate(term2 = str_replace(term2, "^(Lublin.+)$", "Lublin")) %>%
    mutate(term2 = str_replace(term2, "^(Częstochowa.+)$", "Częstochowa")) %>%
    mutate(term2 = str_replace(term2, "^(Hämeenlinna.+)$", 'Hämeenlinna')) %>% 
    mutate(term2 = str_replace(term2, "^(Helsinki.+|Gel'singfors.*)$", 'Helsinki')) %>% 
    mutate(term2 = str_replace(term2, "^(Åbo,? .+|Turku .+|.*\\[Turku\\].*)$", 'Turku')) %>%
    mutate(term2 = str_replace(term2, " [etc\\.?]: Cambridge University [Pp]ress$", '')) %>%
    mutate(term2 = str_replace(term2, "^(Cambridge \\[Eng.\\]|Cambridge University Press)$", 'Cambridge')) %>%
    mutate(term2 = str_replace(term2, "^(Äänekoski,? .+)$", 'Äänekoski')) %>%
    mutate(term2 = str_replace(term2, "^(Yerevan.+)$", 'Jerevan')) %>%
    mutate(term2 = str_replace(term2, "^(Beyrouth.*)$", 'Beirut')) %>%
    
    mutate(term2 = str_replace(term2, "^(Rostochi.*)$", 'Rostock')) 
  
  print('replace 2')

  synonyms <- read_csv('data_internal/place-synonyms-normalized.csv', show_col_types = FALSE)

  df_name2 <- df_cities %>%
   left_join(synonyms, by = c('term2' = 'original')) %>% 
    mutate(normalized = ifelse(is.na(normalized), term2, normalized))

  outputFile <- sprintf('%s-place-time-normalized.csv', prefix)
  print(paste('save into', outputFile))
  write_csv(df_name2, outputFile)
}
