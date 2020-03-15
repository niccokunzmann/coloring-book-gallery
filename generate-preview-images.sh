#!/bin/bash
#
# This file generates the preview images from the png source.
#
# To use it, install ImageMagick, best after Version 7.0.9.2
# Verify it using
#
#    convert --version
#
# https://github.com/ImageMagick/ImageMagick/pull/1270#issuecomment-578502743
#
# From https://github.com/ImageMagick/ImageMagick/blob/master/Install-unix.txt
#
#    git clone https://github.com/ImageMagick/ImageMagick.git
#    cd ImageMagick
#    ./configure
#    make
#    make install
#
# Configuration of the preview images:
# 
# The width of the preview images
thumbnailMaximumWidth=(100 150 200 300)
# The height multiplied with the width, so the images do not get too big
maxHeightMultiplier=2

export SOURCE_DATE_EPOCH=2020-03-15

set -e
cd "`dirname \"$0\"`"
convert --version

# constraints:
#  - do not scale up images
#  - if maxHeight is reached, scale accordingly

find images -iname '*.png' | while read -r image; do
  resolution="`identify \"$image\" | grep -oE '[0-9]+x[0-9]+' | head -n1`"
  widthHeight=(${resolution//x/ }) # from https://stackoverflow.com/a/5257398/1320237
  width="${widthHeight[0]}"
  height="${widthHeight[1]}"
  echo "converting $image"
  printedMessage1="false"
#  printedMessageNewer="false"
  for maxWidth in ${thumbnailMaximumWidth[*]}; do
    maxHeight="$(( $maxWidth * $maxHeightMultiplier ))"
    newHeight="$(( $height * $maxWidth / $width ))"
    if [ "$newHeight" -ge "$maxHeight" ]; then
      if [ "$printedMessage1" == "false" ]; then
        echo "    Image is $maxHeightMultiplier times higher then wide. $newHeight > $maxHeight"
        printedMessage1="true"
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
    path="${image##images/}"
    outputFile="thumbs/$maxWidth/$path"
    # only update if the file is newer
    # see https://superuser.com/a/188247/164164
#    if  [ -f "$outputFile" ] && [ "$image" -nt "$outputFile" ]; then
#      if [ "$printedMessageNewer" == "false" ]; then
#        echo "    Skipping some preview images because they are newer than the source image."
#        printedMessageNewer="true"
#      fi
#    else
      echo "    -> $outputFile at ${userShownWidth}x$userShownHeight"
      mkdir -p "`dirname \"$outputFile\"`"
      convert "$image" -resize "${newWidth}x$newHeight" "$outputFile"
#    fi
  done
done


