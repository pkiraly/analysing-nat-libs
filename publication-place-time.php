<?php

$catalogue = $argv[1];

// uva
$catalogues = [ // 'bayern', 'uva'
  // 'bnpl', 'bayern', 'ddb', 'loc', 'nfi', 'onb', 'uva', 'libris'
  'bnpl'
];

$fields = [
  '008all07_GeneralInformation_date1_ss',
  '260a_Publication_place_ss',
];

$filters = [
  'type_ss:%22Books%22',
  'leader06_typeOfRecord_ss:%22Language%20material%22'
];

// leader05_recordStatus_ss
// leader06_typeOfRecord_ss
// leader07_bibliographicLevel_ss
// 040d_AdminMetadata_modifyingAgency_ss

echo str_putcsv(['date', 'term', 'count']), "\n";
collocateFields($catalogue, $fields);

# collocateCatalogues($catalogues, $fields);

/// functions

function collocateCatalogues($catalogues, $fields) {
  echo str_putcsv(['rank', 'date', 'term', 'count']), "\n";
  foreach ($catalogues as $catalogue) {
    collocateFields($catalogue, $fields);
  }
}

function collocateFields($catalogue, $fields) {
  global $filters;

  $params = 'q=*:*&start=0&rows=0&wt=json&q.op=AND&json.nl=map&facet=on&facet.mincount=1';
  foreach ($fields as $field) {
    $params .= '&facet.field=' . $field;
  }
  if (isset($filters)) {
    foreach ($filters as $filter) {
      $params .= '&fq=' . $filter;
    }
  }

  $response = search($catalogue, $params . '&facet.limit=100000', true);

  $f1_values = $response->facets->{$fields[0]};
  $i = 0;
  foreach ($f1_values as $term => $count1) {
    $response = search($catalogue, $params . '&fq=' . $fields[0] . ':' . urlencode('"' . $term . '"') . '&facet.limit=100000&facet.sort=index');
    foreach ($response->facets->{$fields[1]} as $value2 => $count2) {
      echo str_putcsv([$term, $value2, $count2]), "\n";
    }
    $i++;
  }
}

function search($catalogue, $params, $debugUrl = false) {
  $url = 'http://localhost:8983/solr/' . $catalogue . '/select?' . $params;
  if ($debugUrl)
    fwrite(STDERR, "hello $url\n");

  $solrResponse = json_decode(file_get_contents($url));
  $response = (object)[
    'numFound' => $solrResponse->response->numFound,
    'docs' => $solrResponse->response->docs,
    'facets' => (isset($solrResponse->facet_counts) ? $solrResponse->facet_counts->facet_fields : []),
    'params' => $solrResponse->responseHeader->params,
  ];

  return $response;
}

function str_putcsv(array $input, $delimiter = ',', $enclosure = '"') {
  $fp = fopen('php://temp', 'r+b');

  fputcsv($fp, $input, $delimiter, $enclosure);
  rewind($fp);
  $data = rtrim(stream_get_contents($fp), "\n");
  fclose($fp);
  return $data;
}
