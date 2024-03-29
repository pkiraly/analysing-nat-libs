<?php
define('LN', "\n");

// $catalogue = $argv[1];

$catalogues = [
  // 'bnpl', 'bayern', 'ddb', 'dnb', 'kbr', 'libris', 'lnb', 'loc', 'mek', 'nfi', 'onb', 'uva', 'K10plus', 'nli', 'firenze',
  // 'bl', 'nkp', 'kb',
  'oszk'
];

$fields = [];
$fields[] = $argv[1];
$fields[] = $argv[2];
$id = $argv[3];

// $fields = ['leader07_bibliographicLevel_ss', 'leader06_typeOfRecord_ss'];
// leader05_recordStatus_ss
// leader06_typeOfRecord_ss
// leader07_bibliographicLevel_ss
// 040d_AdminMetadata_modifyingAgency_ss

collocateCatalogues($catalogues, $fields, $id);

/// functions

function collocateCatalogues($catalogues, $fields, $id) {
  echo str_putcsv(['id', 'catalogue', 'count']), "\n";
  foreach ($catalogues as $catalogue) {
  	collocateFields($catalogue, $fields, $id);
  }
}

function collocateFields($catalogue, $fields, $id) {
  $response = search($catalogue, 'q='.urlencode('*:*').'&start=0&rows=0&wt=json&q.op=AND&json.nl=map');
  $total = $response->numFound;

  $q = [];
  foreach ($fields as $field) {
    $q[] = sprintf('%s:*', $field, '*');
  }

  $params = 'q=' . urlencode(join(' AND ', $q)) . '&start=0&rows=0&wt=json&q.op=AND&json.nl=map';

  $response = search($catalogue, $params);
  $percentage = $response->numFound == 0 ? 0 : sprintf("%.2f", $response->numFound * 100 / $total);
  echo str_putcsv([$id, $catalogue, $response->numFound, $percentage]), LN;
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
