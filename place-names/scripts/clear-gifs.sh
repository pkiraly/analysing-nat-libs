#!/usr/bin/env bash

REGIONS="Germany France Italy Iberia Benelux British-Isles"

for REGION in $REGIONS; do
  echo $REGION
  if [[ -f $REGION-map.gif ]]; then
    rm $REGION-map.gif
  fi
  rm $REGION-map-*.jpg
done

