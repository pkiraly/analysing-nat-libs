<?php

// uva
$catalogues = [ // 'bayern', 'uva'
  // 'bnpl', 'bayern', 'ddb', 'loc', 'nfi', 'onb', 'uva', 'libris'
  'uva'
];
$fields = ['650a_Topic_topicalTerm_ss', '008all07_GeneralInformation_date1_ss'];
$filters = [
 // '6502_Topic_sourceOfHeading_ss:"yso/fin"&scheme=yso/fin'
  '6502_Topic_sourceOfHeading_ss:"Faceted application of subject terminology (Dublin, Ohio: OCLC)"'
];

// leader05_recordStatus_ss
// leader06_typeOfRecord_ss
// leader07_bibliographicLevel_ss
// 040d_AdminMetadata_modifyingAgency_ss

collocateCatalogues($catalogues, $fields);

/// functions

function collocateCatalogues($catalogues, $fields) {
  echo str_putcsv(['rank', 'term', 'date', 'count']), "\n";
  foreach ($catalogues as $catalogue) {
    collocateFields($catalogue, $fields);
  }
}

function collocateFields($catalogue, $fields) {
  $params = 'q=*:*&start=0&rows=0&wt=json&q.op=AND&json.nl=map&facet=on&facet.mincount=1';
  foreach ($fields as $field) {
    $params .= '&facet.field=' . $field;
  }
  if (isset($filters)) {
    foreach ($fielters as $filter)
      $params += '&fq=' . $filter;
  }

  $response = search($catalogue, $params . '&facet.limit=25');

  $f1_values = $response->facets->{$fields[0]};
  $i = 0;
  foreach ($f1_values as $term => $count1) {
    $response = search($catalogue, $params . '&fq=' . $fields[0] . ':' . urlencode('"' . $term . '"') . '&facet.limit=1000&facet.sort=index');
    foreach ($response->facets->{$fields[1]} as $value2 => $count2) {
      echo str_putcsv([$i, $term, $value2, $count2]), "\n";
    }
    $i++;
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
