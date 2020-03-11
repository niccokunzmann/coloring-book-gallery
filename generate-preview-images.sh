#!/bin/bash
#
# This file generates the preview images from the png source.
#
# The width of the preview images
thumbnailMaximumWidth=(100 150 200 300)
# The height multiplied with the width, so the images do not get too big
maxHeightMultiplier=2

set -e
cd "`dirname \"$0\"`"

# constraints:
#  - do not scale up images
#  - if maxHeight is reached, scale accordingly

find images -iname '*.png' | while read -r image; do
  resolution="`identify \"$image\" | grep -oE '[0-9]+x[0-9]+' | head -n1`"
  widthHeight=(${resolution//x/ }) # from https://stackoverflow.com/a/5257398/1320237
  width="${widthHeight[0]}"
  height="${widthHeight[1]}"
  echo "converting $image"
  printed="false"
  for maxWidth in ${thumbnailMaximumWidth[*]}; do
    maxHeight="$(( $maxWidth * $maxHeightMultiplier ))"
    newHeight="$(( $height * $maxWidth / $width ))"
    if [ "$newHeight" -ge "$maxHeight" ]; then
      if [ "$printed" == "false" ]; then
        echo "    Image is $maxHeightMultiplier times higher then wide. $newHeight > $maxHeight"
        printed="true"
      fi
      userShownWidth="$(( $width * $maxHeight / $height ))"
      userShownHeight="$maxHeight"
      newWidth=""
      newHeight="$maxHeight"
    else
      userShownWidth="$maxWidth"
      userShownHeight="$newHeight"
      newWidth="$maxWidth"
      newHeight=""
    fi
    # create the new file name, see https://stackoverflow.com/a/965072/1320237
    filename=$(basename -- "$image")
    extension="${filename##*.}"
    filename="${filename%.*}"
    path="${image##images/}"
    path="`dirname \"$path\"`"
    outputFile="thumbs/$path/$filename-$maxWidth.$extension"
    echo "    -> $outputFile at ${userShownWidth}x$userShownHeight"
    mkdir -p "`dirname \"$outputFile\"`"
    convert "$image" -resize "${newWidth}x$newHeight" "$outputFile"
  done
done


