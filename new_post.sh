#!/bin/bash


DATE=`date '+%Y-%m-%d'`
DATETIME=`date '+%Y-%m-%d %H:%M:%S -0300'`
POST_TITLE=$1

FILENAME="${DATE}${POST_TITLE}.md"
FILE_PATH="./_posts/"${FILENAME}

echo -en "---\nlayout: post\ntitle: ${POST_TITLE}\ndate: ${DATETIME}\ncategories: []\ntags: []\n---\n" > "${FILE_PATH}"
