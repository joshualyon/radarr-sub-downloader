#!/bin/bash

declare WANTED_FILE=`dirname $0`/subs.wanted

declare MISSED=""
echo "###### Process started at: $(date) ######"

while IFS=':' read -a line; do
  MOVIE_DIR=${line[0]}
  SCENE_NAME=${line[1]}
  MOVIE_NAME=${line[2]}
  LANG=${line[3]}
  echo "subliminal download -d $MOVIE_DIR -l $LANG $SCENE_NAME"
  subliminal download -d $MOVIE_DIE -l $LANG "$SCENE_NAME"
  if [[ ! -f "$MOVIE_DIR\$SCENE_NAME.$LANG.srt ]]; then
    IFS=''
    MISSED="$MOVIE_DIR:$SCENE_NAME:$MOVIE_NAME:$LANG\n$MISSED"
    echo "Subtitle still not available"
  else
    echo "Great! we have found $MOVIE_NAME"
    echo "Renaming from $SCENE_NAME to $MOVIE_NAME"
    mv "$MOVIE_DIR\$SCENE_NAME.$LANG.srt" "$MOVIE_DIR\$MOVIE_NAME.$LANG.srt"
  fi
done < "$WANTED_FILE"

echo "Saving not found subtitles"
echo -en $MISSED > $WANTED_FILE
