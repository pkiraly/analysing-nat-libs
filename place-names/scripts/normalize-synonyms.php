<?php

$in = fopen('../data_internal/place-synonyms.csv', "r");
$out = fopen('../data_internal/place-synonyms-normalized.csv', 'w');
fputcsv($out, ['original','normalized', 'factor']);

$synonyms = 0;
$cities = 0;
$normalized_cities = [];
$prev_is_multi = false;
while (($line = fgets($in)) != false) {
  if ($line == "# multi\n")
    $prev_is_multi = true;
  if ($line == '' || $line == "\n" || preg_match('/^#/', $line))
    continue;
  $cities++;
  $line = trim($line);
  $values = explode('=', $line, 2);
  $normalized = $values[0];
  if (isset($normalized_cities[$normalized]) && !$prev_is_multi) 
    printf("%s= is duplicated\n", $normalized);
  $normalized_cities[$normalized] = true;
  $normalized = explode('|', $normalized);
  $originals = explode('|', $values[1]);
  $uniques = [];
  foreach ($originals as $i => $value) {
    if ($value != '') {
      if (isset($uniques[$value])) {
        printf("%s| is duplication for %s\n", $value, $normalized);
      } else {
        $uniques[$value] = true;
        $synonyms++;
        $factor = 1 / count($normalized);
        foreach ($normalized as $normalized_city) {
          $csv = array2csv([$value, $normalized_city, $factor]);
          $csv = str_replace('\\"', '""', $csv);
          fwrite($out, $csv);
        }
      }
    } else {
      echo "normalized ($i): ", json_encode($normalized), "\n";
      echo $line, "\n";
    }
  }
  $prev_is_multi = false;
}

fclose($in);
fclose($out);
echo "normalization is DONE: $cities cities, $synonyms synonyms\n";

function array2csv($fields, $delimiter = ",", $enclosure = '"', $escape_char = "\\") {
  $buffer = fopen('php://temp', 'r+');
  fputcsv($buffer, $fields, $delimiter, $enclosure, $escape_char);
  rewind($buffer);
  $csv = fgets($buffer);
  fclose($buffer);
  return $csv;
}