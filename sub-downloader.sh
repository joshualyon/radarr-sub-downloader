#!/bin/bash
set -e
echo `dirname $0`
declare LOG_FILE=`dirname $0`/sub-downloader.log
declare WANTED_FILE=`dirname $0`/wanted/subs.wanted
declare CACHE_DIR=`dirname $0`/cache/

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
declare SCENE_NAME=${radarr_moviefile_scenename}
declare MOVIE_DIR=${radarr_movie_path}
declare MOVIE_NAME=${radarr_movie_title}
# Movie_Title #	Title of the movie
# MovieFile_Path # Full path to the movie file
# MovieFile_RelativePath #	Path to the movie file relative to the movie' path
# MovieFile_SceneName #	Original release name
# MovieFile_SourcePath #	Full path to the episode file that was imported
# MovieFile_SourceFolder #	Full path to the folder the episode file was imported from
# Movie_Path #	Full path to the movie
# Movie_ImdbId #	IMDB ID for the movie
# ------
doLog "Movie_Title: ${radarr_movie_title}"
doLog "MovieFile_Path: ${radarr_moviefile_path}"
doLog "MovieFile_RelativePath: ${radarr_moviefile_relativepath}"
doLog "MovieFile_SceneName: ${radarr_moviefile_scenename}"
doLog "MovieFile_SourcePath: ${radarr_moviefile_sourcepath}"
doLog "MovieFile_SourceFolder: ${radarr_moviefile_sourcefolder}"
doLog "Movie_Path: ${radarr_movie_path}"
doLog "Movie_ImdbId: ${radarr_movie_imdbid}" 
# ----

if [[ -z $MOVIE_PATH ]]; then
  doLog "radarr_moviefile_path environment variable not found"
  exit 1
fi

doLog "Looking for subtitles for: ${MOVIE_NAME}"

doLog "Executing subliminal"
doLog "subliminal --cache-dir ${CACHE_DIR} download -d ${MOVIE_DIR} ${LANGUAGES} ${SCENE_NAME}.mkv"
subliminal --cache-dir ${CACHE_DIR} download -d ${MOVIE_DIR} ${LANGUAGES} "${SCENE_NAME}.mkv" >> $LOG_FILE 2>&1
  
# Look for not found subtitles
declare LANG_ARRAY=($(echo ${LANGUAGES} | sed "s/-l //g"))

for LANG in "${LANG_ARRAY[@]}"; do
  SUB_FILE_SRC="${MOVIE_DIR}/${SCENE_NAME}.${LANG}.srt"
  SUB_FILE_DST=$(echo $MOVIE_PATH | sed "s/...$/${LANG}\.srt/g")
  mv $SUB_FILE_SRC $SUB_FILE_DST
  if [[ ! -f $SUB_FILE_SRC ]]; then
    doLog "Subtitle ${SUB_FILE_SRC} not found, adding it to wanted"
    echo $MOVIE_DIR:$SCENE_NAME:$MOVIE_NAME:$LANG >> ${WANTED_FILE}
  fi
done
