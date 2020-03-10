#!/bin/bash

set -e

file="$1"


# get file name https://stackoverflow.com/a/965072/1320237
filename="${file%.*}"

# black and white http://www.imagemagick.org/discourse-server/viewtopic.php?p=36135&sid=d797e339237b68bf303f7950c0f17031#p36135
convert "$file" -threshold 20% "$filename-bin.png"
