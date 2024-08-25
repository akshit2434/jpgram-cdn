#!/usr/bin/bash

PWD="$(pwd)"
RED='\033[1;31m'
NC='\033[0m'

if [ "$( basename $PWD )" != "jpgram-cdn" ];
then
  printf "${RED}ERROR${NC}: run this script in root directory of jpgram-cdn repo.\n" >&2 
  exit 1
fi

source secrets.env

if [ -z "${JPGRAM_IG_ID}" ] || [ -z "${JPGRAM_IG_PSWD}" ];
then
  printf "${RED}ERROR${NC}: JPGRAM_IG_ID or JPGRAM_IG_PSWD env are not provided.\n" >&2 
  exit 1
fi

mkdir -p images && cd images 

printf "Caching images... (this will take a few minutes)\n(To check instaloader output enter 'tail -f images/instaloader.log' in a seperate terminal)\n"
python3 -m instaloader +../clubs.txt --fast-update --no-videos --no-metadata-json --login $JPGRAM_IG_ID --password $JPGRAM_IG_PSWD 2> instaloader.log >&2

if [ $? -ne 0 ]
then
  printf "${RED}ERROR${NC}: Cache Updation was unsuccessful. Any changes were not commited and left as it is. Check instaloader.log for furthur details.\n" >&2 
  exit 1
fi

cd ..
git add .
git commit -m "chore: update image cache ($( date +%Y-%m-%d ))"
