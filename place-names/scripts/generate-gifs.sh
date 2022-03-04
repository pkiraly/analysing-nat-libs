#!/usr/bin/env bash

SCALE=1200
REGIONS="Germany France Italy Iberia Benelux British-Isles"

for REGION in $REGIONS; do
  echo $REGION
  if [[ -f $REGION-map.gif ]]; then
    rm $REGION-map.gif
  fi
  ffmpeg -framerate 0.5 -pattern_type glob -i "$REGION-map-*.jpg" -r 15 -vf scale=$SCALE:-1 $REGION-map.gif
done
