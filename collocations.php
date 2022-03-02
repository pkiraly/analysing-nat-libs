<?php

$catalogues = [
  'bnpl', 'bayern', 'ddb', 'dnb', 'kbr', 'libris', 'lnb', 'loc', 'mek', 'nfi', 'onb', 'uva', 'K10plus'
];

$fields = [];
$fields[] = $argv[1];
$fields[] = $argv[2];

// $fields = ['leader07_bibliographicLevel_ss', 'leader06_typeOfRecord_ss'];
// leader05_recordStatus_ss
// leader06_typeOfRecord_ss
// leader07_bibliographicLevel_ss
// 040d_AdminMetadata_modifyingAgency_ss

collocateCatalogues($catalogues, $fields);

/// functions

function collocateCatalogues($catalogues, $fields) {
  echo str_putcsv(['catalogue', $fields[0], $fields[1], 'count']), "\n";
  foreach ($catalogues as $catalogue) {
  	collocateFields($catalogue, $fields);
  }
}

function collocateFields($catalogue, $fields) {
  $params = 'q=*:*&start=0&rows=0&wt=json&q.op=AND&json.nl=map&facet=on&facet.limit=100&facet.mincount=1';
  foreach ($fields as $field) {
    $params .= '&facet.field=' . $field;
  }

  $response = search($catalogue, $params);

  $f1_values = $response->facets->{$fields[0]};
  foreach ($f1_values as $value1 => $count1) {
    $response = search($catalogue, $params . '&fq=' . $fields[0] . ':' . urlencode('"' . $value1 . '"'));
    foreach ($response->facets->{$fields[1]} as $value2 => $count2) {
      echo str_putcsv([$catalogue, $value1, $value2, $count2]), "\n";
    }
  }
}

function search($catalogue, $params) {
  $url = 'http://localhost:8983/solr/' . $catalogue . '/select?' . $params;
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
