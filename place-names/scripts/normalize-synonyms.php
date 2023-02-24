<?php

$in = fopen('../data_internal/place-synonyms.csv', "r");
$out = fopen('../data_internal/place-synonyms-normalized.csv', 'w');
fputcsv($out, ['original','normalized']);

$synonyms = 0;
$cities = 0;
while (($line = fgets($in)) != false) {
  if (preg_match('/^#/', $line))
    continue;
  $cities++;
  $line = trim($line);
  $values = explode('=', $line, 2);
  $normalized = $values[0];
  $originals = explode('|', $values[1]);
  foreach ($originals as $i => $value) {
    if ($value != '') {
      $synonyms++;
      $csv = array2csv([$value, $normalized]);
      $csv = str_replace('\\"', '""', $csv);
      fwrite($out, $csv);
      # fwrite($out, sprintf("%s\t%s\n", $value, $normalized));
      # fputcsv($out, );
    } else {
      echo "normalized ($i): ", $normalized, "\n";
    }
  }
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