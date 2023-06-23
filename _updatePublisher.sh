#!/bin/bash
pubsource=https://github.com/HL7/fhir-ig-publisher/releases/latest/download/
publisher_jar=publisher.jar
dlurl=$pubsource$publisher_jar

input_cache_path=$PWD/input-cache/

scriptdlroot=https://raw.githubusercontent.com/HL7/ig-publisher-scripts/main
update_bat_url=$scriptdlroot/_updatePublisher.bat
gen_bat_url=$scriptdlroot/_genonce.bat
gencont_bat_url=$scriptdlroot/_gencontinuous.bat
gencont_sh_url=$scriptdlroot/_gencontinuous.sh
gen_sh_url=$scriptdlroot/_genonce.sh
update_sh_url=$scriptdlroot/_updatePublisher.sh

skipPrompts=false
FORCE=false

if ! type "curl" > /dev/null; then
	echo "ERROR: Script needs curl to download latest IG Publisher. Please install curl."
	exit 1
fi

while [ "$#" -gt 0 ]; do
    case $1 in
    -f|--force)  FORCE=true ;;
    -y|--yes)  skipPrompts=true ; FORCE=true ;;
    *)  echo "Unknown parameter passed: $1.  Exiting"; exit 1 ;;
    esac
    shift
done

echo "Checking internet connection"
curl -sSf tx.fhir.org > /dev/null

if [ $? -ne 0 ] ; then
  echo "Offline (or the terminology server is down), unable to update.  Exiting"
  exit 1
fi

if [ ! -d "$input_cache_path" ] ; then
  if [ $FORCE != true ]; then
    echo "$input_cache_path does not exist"
    message="create it?"
    read -r -p "$message" response
    else
    response=y
  fi
fi

if [[ $response =~ ^[yY].*$ ]] ; then
  mkdir ./input-cache
fi

publisher="$input_cache_path$publisher_jar"

if test -f "$publisher" ; then
	echo "IG Publisher FOUND in input-cache"
	jarlocation="$publisher"
	jarlocationname="Input Cache"
	upgrade=true
else
	publisher="../$publisher_jar"
	upgrade=true
	if test -f "$publisher"; then
		echo "IG Publisher FOUND in parent folder"
		jarlocation="$publisher"
		jarlocationname="Parent Folder"
		upgrade=true
	else
		echo "IG Publisher NOT FOUND in input-cache or parent folder"
		jarlocation=$input_cache_path$publisher_jar
		jarlocationname="Input Cache"
		upgrade=false
	fi
fi

if [[ $skipPrompts == false ]]; then

  if [[ $upgrade == true ]]; then
    message="Overwrite $jarlocation? (Y/N) "
  else
    echo Will place publisher jar here: "$jarlocation"
    message="Ok (enter 'y' or 'Y' to continue, any other key to cancel)?"
  fi
  read -r -p "$message" response
else
  response=y
fi
if [[ $skipPrompts == true ]] || [[ $response =~ ^[yY].*$ ]]; then

	echo "Downloading most recent publisher to $jarlocationname - it's ~100 MB, so this may take a bit"
	curl -L $dlurl -o "$jarlocation" --create-dirs
else
	echo cancelled publisher update
fi

if [[ $skipPrompts != true ]]; then
    message="Update scripts? (enter 'y' or 'Y' to continue, any other key to cancel)?"
    read -r -p "$message" response
  fi

if [[ $skipPrompts == true ]] || [[ $response =~ ^[yY].*$ ]]; then
  echo "Downloading most recent scripts "

  curl -L $update_bat_url -o /tmp/_updatePublisher.new
  cp /tmp/_updatePublisher.new _updatePublisher.bat
  rm /tmp/_updatePublisher.new

  curl -L $gen_bat_url -o /tmp/_genonce.new
  cp /tmp/_genonce.new _genonce.bat
  rm /tmp/_genonce.new

  curl -L $gencont_bat_url -o /tmp/_gencontinuous.new
  cp /tmp/_gencontinuous.new _gencontinuous.bat
  rm /tmp/_gencontinuous.new

  curl -L $gencont_sh_url -o /tmp/_gencontinuous.new
  cp /tmp/_gencontinuous.new _gencontinuous.sh
  rm /tmp/_gencontinuous.new

  curl -L $gen_sh_url -o /tmp/_genonce.new
  cp /tmp/_genonce.new _genonce.sh
  rm  /tmp/_genonce.new

  curl -L $update_sh_url -o /tmp/_updatePublisher.new
  cp /tmp/_updatePublisher.new _updatePublisher.sh
  rm /tmp/_updatePublisher.new
fi
