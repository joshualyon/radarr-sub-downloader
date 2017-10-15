#!/bin/bash

declare MY_DIR=`dirname $0`
declare LOG_FILE=$MY_DIR/../sub-downloader.log
declare WANTED_FILE=$MY_DIR/../wanted/subs.wanted

function remove {
  if [[ -f $1 ]]; then
    rm $1
  fi
}

function cleanLog {
  remove $LOG_FILE
}

function cleanWanted {
  remove $WANTED_FILE
}

function assert {
  echo "assert $1"
  if $1; then
    echo "o Done"
  else
    echo "x Failed"
    exit 1
  fi
}

function printHelpTest {
  echo "----- Print help test -----"
  cleanLog
  $MY_DIR/../sub-downloader.sh
  assert "test -f $LOG_FILE"
}

function uncompleteArgsTest {
  echo "----- Uncomplete args test -----"
  cleanLog
  $MY_DIR/../sub-downloader.sh -l
  assert "test $? -eq 1"
  assert "test ! -f $LOG_FILE"
}

function doDownloadLang {
  echo "----- Simple download test -----"
  export radarr_movie_title="Gifted"
  export radarr_moviefile_path="./movie/Gifted_(2017)_Bluray-1080p.mkv"
  export radarr_moviefile_relativepath="Gifted_(2017)_Bluray-1080p.mkv"
  export radarr_moviefile_scenename="Gifted.2017.1080p.BluRay.DTS.x264-NCmt"
  export radarr_moviefile_sourcepath="./movie/sub/vSDmuX6pu9Rqo.mkv"
  export radarr_moviefile_sourcefolder="./movie/sub"
  export radarr_movie_path="./movie"
  export radarr_movie_imdbid="tt4481414"


  cleanLog
  $MY_DIR/../sub-downloader.sh -l es,en
  assert "test -f $LOG_FILE"
  assert "test -f ./movie/Gifted_(2017)_Bluray-1080p.es.srt"
  assert "test -f ./movie/Gifted_(2017)_Bluray-1080p.en.srt"
  rm ./movie/Gift*.srt
}

function addToWantedTest {
  echo "----- Add to wanted test -----"
  export radarr_movie_title="Gifted"
  export radarr_moviefile_path="./movie/Gifted (2017) Bluray-1080p.mkv"
  export radarr_moviefile_relativepath="Gifted (2017) Bluray-1080p.mkv"
  export radarr_moviefile_scenename="Gifted.2017.1080p.BluRay.DTS.x264-NCmt"
  export radarr_moviefile_sourcepath="./movie/sub/vSDmuX6pu9Rqo.mkv"
  export radarr_moviefile_sourcefolder="./movie/sub"
  export radarr_movie_path="./movie"
  export radarr_movie_imdbid="tt4481414"



  cleanLog
  cleanWanted
  $MY_DIR/../sub-downloader.sh -l es
  assert "test ! -f ./movie/Gifted (2017) Bluray-1080p.es.srt"  
  assert "test \"$(cat ${WANTED_FILE})\" == \"./Gifted (2017):Gifted.2017.1080p.BluRay.DTS.x264-NCmt:Gifted:en\""
}

printHelpTest
uncompleteArgsTest
doDownloadLang
# addToWantedTest

