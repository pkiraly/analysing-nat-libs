if (!("tidyverse" %in% (.packages()))) {
  library(tidyverse)
}

fields <- tribble(
  ~solr, ~lab_en, ~lab_hu, ~title_en, ~title_hu,
  #--|--|--|--
  'leader06_typeOfRecord_ss', 'type of record (leader/06)', 'rekordtípus (rekordfej/06)', 'Type of record', 'Rekordtípus',
  'leader07_bibliographicLevel_ss', 'bibliographic level (leader/07)', 'bibliográfiai szint (rekordfej/07)', 'Bibliographic level', 'Bibliográfiai szint',
  'leader17_encodingLevel_ss', 'encoding level (leader/17)', 'leírás szintje (rekordfej/17)', 'Encoding level', 'Leírás jellege (leírás szintje)',
  '007common00_PhysicalDescription_categoryOfMaterial_ss', 'category of material (007/00)', 'dokumentumkategória (007/00)', 'Category of material', 'Dokumentumkategória',
  '007map01_PhysicalDescription_specificMaterialDesignation_ss', 'specific material designation (map, 007/01)', 'a dokumentum speciális megjelölése (térkép, 007/01)', 'Specific material designation (map)', 'A dokumentum speciális megjelölése (térkép)',
  '007text01_PhysicalDescription_specificMaterialDesignation_ss', 'specific material designation (text, 007/01)', 'a dokumentum speciális megjelölése (szöveg, 007/01)', 'Specific material designation (text)', 'A dokumentum speciális megjelölése (szöveg)',
  '008book18_GeneralInformation_illustrations_ss', 'illustration (books, 008/18–21)', 'illusztráltság (könyvek, 008/18–21)', 'Illustration (books)', 'Illusztráltság (könyvek)',
  '008book24_GeneralInformation_natureOfContents_ss', 'nature of contents (books, 008/24–27)', 'tartalmi jellemzők (könyvek, 008/24–27)', 'Nature of contents', 'Tartalmi jellemzők',
  '008book33_GeneralInformation_literaryForm_ss', 'literary form (books, 008/33)', 'műfaj (könyvek, 008/33)', 'Literary form', 'Műfaj',
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
  'bl', TRUE, 'Brit Nemzeti Könyvtár', 'British Library',
  'uva', FALSE, 'Amsterdami Egyetem', 'Uni Amsterdam',
  'gent', FALSE, 'Genti Egyetem', 'Uni Gent',
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

code_00700 <- tribble(
  ~solr, ~english, ~hungarian,
  #--|--|--
  'Map', 'a – Map', 'a – térkép',
  'Electronic resource', 'c – Electronic resource', 'c – elektronikus dokumentum',
  'Globe', 'd – Globe', 'd – glóbusz',
  'Tactile material', 'f – Tactile material', 'f – tapintással érzékelhető anyag ',
  'Projected graphic', 'g – Projected graphic', 'g – kivetíthető kép',
  'Microform', 'h – Microform', 'h – mikroforma',
  'Nonprojected graphic', 'k – Nonprojected graphic', 'k – nem kivetíthető grafika',
  'Motion picture', 'm – Motion picture', 'm – mozgókép',
  'Kit', 'o – Kit', 'o – vegyes dokumentum csomag, készlet',
  'Notated music', 'q – Notated music', 'q – lejegyzett zene',
  'Remote-sensing image', 'r – Remote-sensing image', 'r – távérzékeléssel készült kép',
  'Sound recording', 's – Sound recording', 's – hangfelvétel',
  'Text', 't – Text', 't – szöveg',
  'Videorecording', 'v – Videorecording', 'v – videofelvétel',
  'Unspecified', 'z – Unspecified', 'z – meghatározatlan',
  '[invalid]', '    [invalid]', '    [érvénytelen]'
)

code_007map01 <- tribble(
  ~solr, ~english, ~hungarian,
  #--|--|--
  'Atlas', 'd – Atlas', 'd – atlasz',
  'Diagram', 'g – Diagram', 'g – diagram',
  'Map', 'j – Map', 'j – térkép',
  'Profile', 'k – Profile', 'k – függőleges metszet',
  'Model', 'q – Model', 'q – modell',
  'Remote-sensing image', 'r – Remote-sensing image', 'r – távérzékeléses felvétel',
  'Section', 's – Section', 's – szelvény',
  'Unspecified', 'u – Unspecified', 'u – ismeretlen',
  'View', 'y – View', 'y – látkép',
  'Other', 'z – Other', 'z – egyéb',
  'No attempt to code', '| – No attempt to code', '| – kódolatlan',
  '[invalid]', '    [invalid]', '    [érvénytelen]'
)

code_007text01 <- tribble(
  ~solr, ~english, ~hungarian,
  #--|--|--
  'Regular print', 'a – Regular print', 'a – normál nyomtatás',
  'Large print', 'b – Large print', 'b – nagybetűs nyomtatás',
  'Braille', 'c – Braille', 'c – Braille-írás (vakírás)',
  'Loose-leaf', 'd – Loose-leaf', 'd – szabadlapos kötésben',
  'Unspecified', 'u – Unspecified', 'u – ismeretlen',
  'Other', 'z – Other', 'z – egyéb',
  'No attempt to code', '| – No attempt to code', '| – kódolatlan',
  '[invalid]', '    [invalid]', '    [érvénytelen]'
)

code_00818 <- tribble(
  ~solr, ~english, ~hungarian,
  #--|--|--
  'No illustrations', '# – No illustrations', '# – nem illusztrált',
  'Illustrations', 'a – Illustrations', 'a – illusztrált',
  'Maps', 'b – Maps', 'b – térkép',
  'Portraits', 'c – Portraits', 'c – arckép',
  'Charts', 'd – Charts', 'd – diagram, grafikon',
  'Plans', 'e – Plans', 'e – tervrajz',
  'Plates', 'f – Plates', 'f – táblázat',
  'Music', 'g – Music', 'g – kotta',
  'Facsimiles', 'h – Facsimiles', 'h – hasonmás',
  'Coats of arms', 'i – Coats of arms', 'i – címer',
  'Genealogical tables', 'j – Genealogical tables', 'j – családfa',
  'Forms', 'k – Forms', 'k – űrlap',
  'Samples', 'l – Samples', 'l – statisztikai mintagyűjtemény',
  'Phonodisc, phonowire, etc.', 'm – Phonodisc, phonowire, etc.', 'm – hanghordozó melléklet',
  'Photographs', 'o – Photographs', 'o – fénykép',
  'Illuminations', 'p – Illuminations', 'p – iniciálé',
  # r	színes illusztráció
  # s	művészi borító
  'No attempt to code', '| – No attempt to code', '| – kódolatlan',
  '[invalid]', '    [invalid]', '    [érvénytelen]'
)

code_00824 <- tribble(
  ~solr, ~english, ~hungarian,
  #--|--|--
  'No specified nature of contents', '# – No specified nature of contents', '# – meghatározatlan',
  'Abstracts/summaries', 'a – Abstracts/summaries', 'a – kivonat, összefoglaló',
  'Bibliographies', 'b – Bibliographies', 'b – bibliográfia',
  'Catalogs', 'c – Catalogs', 'c – katalógus',
  'Dictionaries', 'd – Dictionaries', 'd – szótár',
  'Encyclopedias', 'e – Encyclopedias', 'e – enciklopédia',
  'Handbooks', 'f – Handbooks', 'f – kézikönyv',
  'Legal articles', 'g – Legal articles', 'g – jogi cikk',
  'Indexes', 'i – Indexes', 'i – mutató',
  'Patent document', 'j – Patent document', 'j – szabadalmi dokumentum',
  'Discographies', 'k – Discographies', 'k – diszkográfia',
  'Legislation', 'l – Legislation', 'l – törvény',
  'Theses', 'm – Theses', 'm – tézis, disszertáció',
  'Surveys of literature in a subject area', 'n – Surveys of literature in a subject area', 'n – irodalomkutatás',
  'Reviews', 'o – Reviews', 'o – szemle',
  'Programmed texts', 'p – Programmed texts', 'p – programozott szöveg',
  'Filmographies', 'q – Filmographies', 'q – filmográfia',
  'Directories', 'r – Directories', 'r – címtár',
  'Statistics', 's – Statistics', 's – statisztika',
  'Technical reports', 't – Technical reports', 't – kutatási jelentés',
  'Standards/specifications', 'u – Standards/specifications', 'u – szabvány/specifikáció',
  'Legal cases and case notes', 'v – Legal cases and case notes', 'v – jogi esetek',
  'Law reports and digests', 'w – Law reports and digests', 'w – jogi elemzés, szemle',
  'Yearbooks', 'y – Yearbooks', 'y – évkönyv',
  'Treaties', 'z – Treaties', 'z – szerződés',
  'Offprints', '2 – Offprints', '2 – különlenyomat',
  'Calendars', '5 – Calendars', '5 – naptár',
  'Comics/graphic novels', '6 – Comics/graphic novels', '6 – képregény',
  'No attempt to code', '| - No attempt to code', '| – kódolatlan',
  '[invalid]', '    [invalid]', '    [érvénytelen]'
)

code_00833 <- tribble(
  ~solr, ~english, ~hungarian,
  #--|--|--
  'Not fiction (not further specified)', '0 - Not fiction (not further specified)', '0 - nem szépirodalmi mű',
  'Fiction (not further specified)', '1 - Fiction (not further specified)', '1 - szépirodalmi mű',
  'Dramas', 'd – Dramas', 'd – dráma', # humoreszk, szatíra, karcolat',
  'Essays', 'e – Essays', 'e – esszé',
  'Novels', 'f – Novels', 'f – regény',
  # '', '[nincs]', 'g vers',
  'Humor, satires, etc.', 'h - Humor, satires, etc.', 'h - humoreszk, szatíra, karcolat',#'h szónoklat',
  # '', '[nincs]', 'i mese',
  'Letters', 'i - Short stories', 'i - levél',
  'Short stories', 'j - Short stories', 'j - elbeszélés',
  'Mixed forms', 'm - Mixed forms', 'm - egyéb és vegyes',
  'Poetry', 'p – Poetry', 'p – vers',
  'Speeches', 's – Speeches', 's – beszédek',
  'Unknown', 'u – Unknown', 'u – ismeretlen',
  'No attempt to code', '| - No attempt to code', '| – kódolatlan',
  '[invalid]', '   [invalid]', '   [érvénytelen]'
)

comparisions <- tribble(
  ~prefix, ~a, ~b,
  #--|--|--
  'ldr06-ldr07', 'leader06_typeOfRecord_ss', 'leader07_bibliographicLevel_ss',
  'ldr06-ldr17', 'leader06_typeOfRecord_ss', 'leader17_encodingLevel_ss',
  'ldr07-ldr17', 'leader07_bibliographicLevel_ss', 'leader17_encodingLevel_ss',
  'ldr06-00700', 'leader06_typeOfRecord_ss', '007common00_PhysicalDescription_categoryOfMaterial_ss',
  'ldr07-00700', 'leader07_bibliographicLevel_ss', '007common00_PhysicalDescription_categoryOfMaterial_ss',
  'ldr17-00700', 'leader17_encodingLevel_ss', '007common00_PhysicalDescription_categoryOfMaterial_ss',
  'ldr06-007map01material', 'leader06_typeOfRecord_ss', '007map01_PhysicalDescription_specificMaterialDesignation_ss',
  'ldr06-007text01material', 'leader06_typeOfRecord_ss', '007text01_PhysicalDescription_specificMaterialDesignation_ss',
  '007map01material-008book18ill', '007map01_PhysicalDescription_specificMaterialDesignation_ss', '008book18_GeneralInformation_illustrations_ss',
  '007text01material-008book18ill', '007text01_PhysicalDescription_specificMaterialDesignation_ss', '008book18_GeneralInformation_illustrations_ss',
  '007text01material-008book24nature', '007text01_PhysicalDescription_specificMaterialDesignation_ss', '008book24_GeneralInformation_natureOfContents_ss',
  '007text01material-008book33lit', '007text01_PhysicalDescription_specificMaterialDesignation_ss', '008book33_GeneralInformation_literaryForm_ss',
)

configuration <- list(
  list(prefix = 'ldr06-ldr07', codeA = code_ldr06, codeB = code_ldr07),
  list(prefix = 'ldr06-ldr17', codeA = code_ldr06, codeB = code_ldr17),
  list(prefix = 'ldr07-ldr17', codeA = code_ldr07, codeB = code_ldr17),
  list(prefix = 'ldr06-00700', codeA = code_ldr06, codeB = code_00700),
  list(prefix = 'ldr07-00700', codeA = code_ldr07, codeB = code_00700),
  list(prefix = 'ldr17-00700', codeA = code_ldr17, codeB = code_00700),
  list(prefix = 'ldr06-007map01material', codeA = code_ldr06, codeB = code_007map01),
  list(prefix = 'ldr06-007text01material', codeA = code_ldr06, codeB = code_007text01),
  list(prefix = '007map01material-008book18ill', codeA = code_007map01, codeB = code_00818),
  list(prefix = '007text01material-008book18ill', codeA = code_007text01, codeB = code_00818),
  list(prefix = '007text01material-008book24nature', codeA = code_007text01, codeB = code_00824),
  list(prefix = '007text01material-008book33lit', codeA = code_007text01, codeB = code_00833)
)

replacement <- tribble(
  ~prefix, ~replacement,
  #--|--
  '007map01material-008book18ill', ', No illustrations',
  '007text01material-008book18ill', ', No illustrations',
  '007text01material-008book33lit', ', No illustrations',
  '007text01material-008book24nature', ', No specified nature of contents',
)
