rm bnpl-abroad.gif
rm bnpl-home.gif

ffmpeg -framerate 0.5 -pattern_type glob -i 'bnpl-map-abroad-*.jpg' -r 15 -vf scale=800:-1 bnpl-abroad.gif
ffmpeg -framerate 0.5 -pattern_type glob -i 'bnpl-map-home-*.jpg' -r 15 -vf scale=800:-1 bnpl-home.gif
