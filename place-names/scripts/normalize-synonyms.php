<?php

$in = fopen('place-synonyms.csv', "r");
$out = fopen('place-synonyms-normalized.csv', 'w');
fputcsv($out, ['original','normalized']);

while (($line = fgets($in)) != false) {
  $values = str_getcsv($line, '=');
  $normalized = $values[0];
  $originals = explode('|', $values[1]);
  foreach ($originals as $value) {
    if ($value != '') {
      # fwrite($out, sprintf("%s\t%s\n", $value, $normalized));
      fputcsv($out, [$value, $normalized]);
    } else {
      echo 'normalized: ', $normalized, "\n";
    }
  }
}

fclose($in);
fclose($out);
echo "normalization is DONE\n";