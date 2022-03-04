if (!("tidyverse" %in% (.packages()))) {
  library(tidyverse)
}

fields <- tribble(
  ~solr, ~lab_en, ~lab_hu, ~title_en, ~title_hu,
  #--|--|--|--
  'leader06_typeOfRecord_ss', 'type of record (leader/06)', 'rekordtípus (rekordfej/06)', 'Type of record', 'Rekordtípus',
  'leader07_bibliographicLevel_ss', 'bibliographic level (leader/07)', 'bibliográfiai szint (rekordfej/07)', 'Bibliographic level', 'Bibliográfiai szint',
  'leader17_encodingLevel_ss', 'encoding level (leader/17)', 'leírás szintje (rekordfej/17)', 'Encoding level', 'Leírás jellege (leírás szintje)',
)
  
libraries <- tribble(
  ~catalogue, ~is_national, ~hungarian, ~english,
  #--|--|--|--
  'loc', TRUE, 'Kongresszusi Könyvtár', 'Library of Congress',
  'dnb', TRUE, 'Német Nemzeti Könyvtár', 'German National Library',
  'onb', TRUE, 'Osztrák Nemzeti Könyvtár', 'Austrian National Library',
  'nfi', TRUE, 'Finn Nemzeti Könyvtár', 'Finish National Library',
  'libris', TRUE, 'Svéd Nemzeti Könyvtár', 'Swedish National Library',
  'bnpl', TRUE, 'Lengyel Nemzeti Könyvtár', 'Polish National Library',
  'lnb', TRUE, 'Lett Nemzeti Könyvtár', 'Latvian National Library',
  'kbr', TRUE, 'Belga Nemzeti Könyvtár', 'Belgian National Library',
  'uva', FALSE, 'Amsterdami Egyetem', 'Uni Amsterdam',
  'bayern', FALSE, 'B3Kat', 'B3Kat',
  'K10plus', FALSE, 'K10plus', 'K10plus', 
  'ddb', FALSE, 'Német Digitális Könyvtár', 'German Digital Library',
  'mek', FALSE, 'MEK', 'Hungarian Electronic Library'
)
# add gent, uva, bl

code_ldr06 <- tribble(
  ~solr, ~english, ~hungarian,
  #--|--|--
  'Language material', 'a – Language material', 'a – nyelvi anyag',
  # '', 'b – ', 'kéziratos nyelvi anyag',
  'Notated music', 'c – Notated music', 'c – nyomtatott zenemű',
  'Manuscript notated music', 'd – Manuscript notated music', 'd – kéziratos zenemű',
  'Cartographic material', 'e – Cartographic material', 'e – kartográfiai anyag',
  'Manuscript cartographic material', 'f – Manuscript cartographic material', 'f – kéziratos kartográfiai anyag',
  'Projected medium', 'g – Projected medium', 'g – audiovizuális anyag',
  'Nonmusical sound recording', 'i – Nonmusical sound recording', 'i – nem zenei hangzó anyag',
  'Musical sound recording', 'j – Musical sound recording', 'j – zenei hangzó anyag',
  'Two-dimensional nonprojectable graphic', 'k – Two-dimensional nonprojectable graphic', 'k – két dimenziós (nem kivetíthető) ábrázolások',
  # '', 'l – ', 'számítógépes anyag',
  'Computer file', 'm – Computer file', 'm – számítógép által kezelt állomány',
  # '', 'n – ', 'n – különleges oktató anyag',
  'Kit', 'o – Kit', 'o – vegyes dokumentum csomag, készlet',
  'Mixed materials', 'p – Mixed materials', 'p – vegyes anyag',
  'Three-dimensional artifact or naturally occurring object', 'r – Three-dimensional artifact or naturally occurring object', 'r – három dimenziós alkotások és természetes anyagok',
  'Manuscript language material', 't – Manuscript language material', 't – kéziratos nyelvi anyag',
  '[invalid]', '[invalid]', '[érvénytelen]'
)

code_ldr07 <- tribble(
  ~solr, ~english, ~hungarian,
  #--|--|--
  'Monographic component part', 'a – Monographic component part', 'a – analitikus, monográfiáé ',
  'Serial component part', 'b – Serial component part', 'b – analitikus, időszakié',
  'Collection', 'c – Collection', 'c – gyűjteményes',
  'Subunit', 'd – Subunit', 'd – alárendelt (kötet, részegység)',
  'Integrating resource', 'i – Integrating resource', 'i – integrált forrás',
  'Monograph/Item', 'm – Monograph/Item', 'm – monografikus mint egység',
  'Serial', 's – Serial', 's – összefoglaló (időszaki)',
  '[invalid]', '    [invalid]', '    [érvénytelen]'
)

code_ldr17 <- tribble(
  ~solr, ~english, ~hungarian,
  #--|--|--
  'Full level', '# – Full level', '# – teljes, autopsziával',
  'Full level, material not examined', '1 – Full level, material not examined', '1 – teljes, autopszia nélkül',
  'Less-than-full level, material not examined', '2 – Less-than-full level, material not examined', '2 – egyszerűsített, autopszia nélkül',
  'Abbreviated level', '3 – Abbreviated level', '3 – rövidített',
  'Core level', '4 – Core level', '4 – tömörített',
  'Partial (preliminary) level', '5 – Partial (preliminary) level', '5 – egyszerűsített, autopsziával',
  'Minimal level', '7 – Minimal level', '7 – minimális',
  'Prepublication level', '8 – Prepublication level', '8 – előzetes',
  'Unknown', 'u – Unknown', 'u – ismeretlen',
  'Not applicable', 'z – Not applicable', 'z – nincs',
  '[invalid]', '    [invalid]', '    [érvénytelen]'
)

code_00833 <- tribble(
  ~solr, ~hungarian, ~english,
  #--|--|--
  '', '0 - Not fiction (not further specified)', 'nem szépirodalmi mű',
  '', '1 - Fiction (not further specified)', 'szépirodalmi mű',
  '', '–', 'b dráma',
  '', '[nincs]', 'c esszé',
  '', 'd – Dramas', 'humoreszk, szatíra, karcolat',
  '', 'e – Essays', 'levél',
  '', 'f – Novels', 'elbeszélés',
  '', '[nincs]', 'g vers',
  '', 'h - Humor, satires, etc.', 'h szónoklat',
  '', '[nincs]', 'i mese',
  '', 'j - Short stories', 'j egyéb és vegyes',
  '', 'm - Mixed forms', '	–',
  '', 'p – Poetry', '	–',
  '', 's – Speeches', '–',
  '', 'u – Unknown', '–',
  '', '| - No attempt to code', '–',
  '[invalid]', '   [invalid]', '   [érvénytelen]'
)

comparisions <- tribble(
  ~prefix, ~a, ~b,
  #--|--|--
  'ldr06-ldr07', 'leader06_typeOfRecord_ss', 'leader07_bibliographicLevel_ss',
  'ldr06-ldr17', 'leader06_typeOfRecord_ss', 'leader17_encodingLevel_ss',
  'ldr07-ldr17', 'leader07_bibliographicLevel_ss', 'leader17_encodingLevel_ss',
)

configuration <- list(
  list(prefix = 'ldr06-ldr07', codeA = code_ldr06, codeB = code_ldr07),
  list(prefix = 'ldr06-ldr17', codeA = code_ldr06, codeB = code_ldr17),
  list(prefix = 'ldr07-ldr17', codeA = code_ldr07, codeB = code_ldr17)
)

