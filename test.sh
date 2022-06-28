#!/bin/bash
GITdoc='https://neandr.github.io/schedulePlus'

NAME='schedulePlus'
VDATE='2022-06-25_1632'
VERSION='3.2'

ZIPP=$NAME.zip

echo "$T"

    xDIR="$(pwd)"
    baseDIR="$(dirname $xDIR)"
    currentDIR="$(basename $xDIR)"

    echo "        xDIR: " $xDIR        #  /home/pi
    echo "     baseDIR: " $baseDIR     #  /home
    echo "  currentDIR: " $currentDIR  #  pi
    #echo " Default ZIP: " $ZIPP        #  $NAME
    echo -e

    echo -e "System Check ..."
    port=$(sed 's/, "/\n/g' $xDIR/data/jPrefs.json | egrep "port" | tr -d '":a-zA-Z ,')
    addr=$(echo $(hostname -I) | awk '{print $ 1;}')
    echo -e "System Check ... addr: $addr  port:$port  \n\n"


#==============================================

    # Check not to operate on '$NAME' directory,
    # should work on it's parent directory!
    if [[ $currentDIR == '$NAME' ]] ; then
       echo -e "\n!!! ---  Current dir is '$NAME'"
       echo -e   "!!! ---  Script should not be excecuted here!\n"
       exit 1
    fi

  while (( "$#" )); do
   case "$1" in

    -t|--test)
      echo "$T"; exit 0
    ;;

    -s|--system)
     port=$(sed 's/, "/\n/g' $xDIR/data/jPrefs.json | egrep "port" | tr -d '":a-zA-Z ,')
     addr=$(echo $(hostname -I) | awk '{print $ 1;}')
     echo "System Check  addr: $addr  port:$port"
     exit 0
     ;;

    --help)
       echo "$H$A"; exit 0
       ;;


    -l|--libs)
       echo "  ... Bibliotheken laden (Python, Bottle etc ..) ";
       cmd=LibsLoad; shift 1
       ;;

    -i|--install)
       zipdocs
       echo "  ... System installieren mit $ZIPP"
       cmd=SystemInstall; shift 1
       ;;

    -c|--configure)
       echo "  ... System konfigurieren";
       #zipdocs
       cmd=SystemConfigure; shift 1
       #SystemConfigure; shift 1
       ;;

    -a|--all)
       echo "  ... Alles ausführen";
       zipdocs
       LibsLoad
       SystemInstall
       SystemConfigure
       exit 0
       ;;

    --Z)
       zipdocs
       exit 0
       ;;
    *)
       echo "$A"; exit 0
       ;;

   esac
  done
  echo "  ... Aufruf '$cmd' mit ZIP '$ZIPP'"
  $cmd
  rm wget.log 2>/dev/null
  exit 0
