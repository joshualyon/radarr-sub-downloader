#!/bin/bash
set -e
echo `dirname $0`
declare LOG_FILE=`dirname $0`/sub-downloader.log
declare WANTED_FILE=`dirname $0`/wanted/subs.wanted

# Radarr/Sonarr does not show the stdout as part of the log information displayed by the system,
# So the log information is stored on our own
function doLog {
  echo -e $1
  echo -e $1 >> $LOG_FILE
}

function printUsage {
  msg="Usage: sub-downloader.sh [options]\n\n
    -l, --languages <languages-list>:\n
    \t Specify a comma-separated list of languages to download.\n
    \t example: sub-downloader.sh -l es,en\n\n
    -h, --help: print this help"
  doLog "$msg"
  exit 1
}

if [[ $# -eq 0 ]]; then
  printUsage
fi

while [ "$1" != "" ]; do
  case $1 in
    "-l" | "--languages")
      shift
      declare LANGUAGES=$(echo "-l $1" | sed "s/,/ -l /g")
      ;;
    *)
      printUsage
      ;;
  esac
  shift
done

doLog "###### Process started at: $(date) ######"

declare MOVIE_PATH=${radarr_moviefile_path}
# MovieFile_Path # Full path to the movie file
# MovieFile_SceneName #	Original release name
# MovieFile_SourcePath #	Full path to the episode file that was imported
# MovieFile_SourceFolder #	Full path to the folder the episode file was imported from
# Movie_Path #	Full path to the movie
# Movie_ImdbId #	IMDB ID for the movie

if [[ -z $MOVIE_PATH ]]; then
  doLog "radarr_moviefile_path environment variable not found"
  exit 1
fi

doLog "Looking for subtitles for: ${MOVIE_PATH}"

doLog "Executing subliminal"
doLog "subliminal download ${LANGUAGES} ${MOVIE_PATH}"
subliminal download ${LANGUAGES} "${MOVIE_PATH}" >> $LOG_FILE 2>&1
  
# Look for not found subtitles
declare LANG_ARRAY=($(echo ${LANGUAGES} | sed "s/-l //g"))

for LANG in "${LANG_ARRAY[@]}"; do
  SUB_FILE=$(echo $MOVIE_PATH | sed "s/...$/${LANG}\.srt/g")
  if [[ ! -f $SUB_FILE ]]; then
    doLog "Subtitle ${SUB_FILE} not found, adding it to wanted"
    echo $MOVIE_PATH:$SUB_FILE >> ${WANTED_FILE}
  fi
done
