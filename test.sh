#!/bin/bash

NAME='schedulePlus'
VDATE='2022-07-06_23'
VERSION='0.2.3.1'

#ZIPP=$NAME.zip
GITdoc='https://neandr.github.io/'$NAME
jUserData=data/jPrefs.user.json


  bw=$'\033[1m'                  # bold
  br=$'\033[1;38;5;196m'         # bold red
  ba=$'\033[1;38;5;16;48;5;15m'  # bold black on white
  bg=$'\033[1;38;5;28;48;5;7m'   # bold green on white
  bb=$'\033[1;38;5;21;48;5;7m'   # bold blue on white
  e0=$'\033[0m'                  # reset/normal


H="
    SYNOPSIS
      $SH [ARGUMENT]

    DESCRIPTION
      '$NAME' ist verfügbar auf Github als ZIP, ebenso das Setup-Script 'schedulePlusSetup.sh'

      Dieses Setup-Script 'schedulePlusSetup.sh' unterstützt das Abrufen des $NAME.zip
      sowie das Laden erforderlicher Libraries aus dem Netz. Die gesamte $NAME Installation
      wird installiert und einsatzfähig gemacht.

      Der Abruf des Setup-Scripts 'schedulePlusSetup.sh' erfogt mit:
         $ba cd ~  &&  wget https://neandr.github.io/schedulePlus/schedulePlusSetup.*     $e0
         $ba unzip -p $NAME.zip schedulePlusSetup.sh > schedulePlusSetup.sh       $e0

      Für das abgerufene ZIP lässt sich die SHA-256 Prüfsumme kontrollieren,
      bei der Installation (siehe Argument '-Z') werden die ZIP Prüfsummen
      der GIT Datei und die der abgerufenen angegeben.

      Die ZIP-Datei und dieses Skript '$SH' werden im einem übergeordneten
      Verzeichnis '$NAME' gespeichert und ausgeführt, d.h. der Verzeichnisbaum sieht so aus:

       ../pi/                     oder ein anderes übergeordnetes Verzeichnis
         |__schedulePlus3.zip     ev. weitere Versionen
         |__schedulePlus3Setup.sh
         |
         |__schedulePlus3/        hier ist der '$NAME' Code nach der Installation
                                  gespeichert und wird dort ausgeführt
"

A="
    ARGUMENT
      no argument        Zeigt Version/Datum und momentanes Verzeichnis
      '--help'           Prompt dieses 'Help' Textes

      '-Z'               Auswahl einer lokalen ZIP Datei, Default ist ($NAME.zip)
      '-l' '--libs'      Laden der Python/bash Bibliotheken (Python, Bottle, jp etc)
      '-i' '--install'   Installation der '$NAME' Funktionen
      '-c' '--configure' Konfigurieren des '$NAME' Systems

    Dokumentation   Siehe $GITdoc
"

echo -e "$ba ___ $NAME Setup       #$VERSION  $VDATE ___ $e0"

  rm *.txt 2>/dev/null


  xDIR="$(pwd)"
  baseDIR="$(dirname $xDIR)"
  currentDIR="$(basename $xDIR)"

  echo "        xDIR: " $xDIR        #  /home/pi
  echo "     baseDIR: " $baseDIR     #  /home
  echo "  currentDIR: " $currentDIR  #  pi
  echo -e


#-----------------------------------------

#  Select a schedulePlus ZIP on GIT for download
#   - no unzipping  .. see  zip_2_dir
#  Download only if not locally present
#  Downloaded ZIP will be SHA checked
#  Name of downloaded ZIP stored in ZIPP
#
function zip_from_git()         # --Z
{
   echo -e "$bb ... Download a 'schedulePlus' ZIP from GIT .......... $e0"

   wget  https://api.github.com/repos/neandr/schedulePlus/contents 2>/dev/null
   mv contents git1.txt

   Z=$(cat git1.txt |  sed -n '/"path": "docs",/{n;p;}' | sed -e 's/"sha":/ /;s/,//' | xargs )
   X="https://api.github.com/repos/neandr/schedulePlus/git/trees/"$Z
   wget $X 2>/dev/null  # saves to a file named $Z

   mv $Z git2.txt
   cat git2.txt | egrep zip.sha | sed -e 's/"path"://g;s/[,"]//g;s/.sha//g' > zips_on_git.txt

   n=0
   zips=();

   while IFS= read -r line; do
      line0=$(echo $line | xargs )
      echo "       $n : [$line0]"
      ((n=n+1))
      zips+=("$line0")
   done < zips_on_git.txt

   read -n 1 -p "      $ba Auswahl der ZIP Datei auf GIT ?   $e0" No ;

   if [[ $No == ?(-)+([0-9]) && ${zips[$No]} ]] ; then
         ZIPP=$(echo ${zips[$No]} | tr -d ' ')
   else
      echo -e "\n$br NO ZIP selected. Terminating! $e0"
      exit 1
   fi

   echo -e  "\n$bb ---  ZIP für die Installation:  '$ZIPP' $e0"


   if [ -f $ZIPP ] ; then
     echo -e " *** $ba $ZIPP already exists! $e0"
   else

      #echo "  ZIPP:  "$ZIPP
      #echo " GITdoc: "$GITdoc
      #echo "  >>"$GITdoc/$ZIPP"<<"

      wget $GITdoc/$ZIPP 2>/dev/null
   fi
   shatest
}

function shatest()
{
   echo -e " !!!  SHA256 Check für  '$ZIPP'"

   s1=$(cat $ZIPP | sha256sum | head -c 64)
   s2=$(wget -qO- $GITdoc/$ZIPP.sha)
   echo -e "    abgerufene Datei  : $s1"
   echo -e "    Prüfsumme auf GIT : $s2"
   if [[ ! $s1 == $s2 ]] ; then
      echo "$br  ZIP Fehler! Checksum nicht übereinstimmend! $e0"
      exit 1
   fi
}


#  Find all 'schedulePlus*.zip' to select one, name to => ZIPP
#  With no selection => clear ZIPP variable
#
function zip_list_local ()            # --L
{
   echo "$bb  Local '$NAME' ZIP Versions! $e0"

   ls -1 $NAME*.zip >xx.txt

   n=0
   zips=();

   while IFS= read -r line; do
      line0=$(echo $line | xargs )
      echo "       $n : [$line0]"
      ((n=n+1))
      zips+=("$line0")
   done < xx.txt
   rm xx.txt

   read -n 1 -p "$ba  Select $NAME ZIP version for installation   $e0" No ;

   if [[ $No == ?(-)+([0-9]) && ${zips[$No]} ]] ; then
         ZIPP=$(echo ${zips[$No]} | tr -d ' ')
   else
      echo -e "\n$br  NO ZIP selected. Terminating! $e0"
      ZIPP=""
      exit 1
   fi

   echo -e  "\n$bb  ---  $NAME ZIP version selected! $e0 '$ZIPP' "
}


# UNZIP a local held ZIP -- name of ZIP in variable ZIPP
#
# With update installation
# ask how to handle 'data/'  .. hold or overwrite ???

function unzip_2_dir()          #  --U
{
   zip_list_local

   if [[ $ZIPP == "" ]] ; then
      echo -e "$br 'ZIP' not defined! $e0"
      exit 999
   fi

   if [ -d $xDIR/$NAME/  ]  ; then
      echo -e      "$br  !!! --- Installation directory $ba'$xDIR/$NAME/'  $e0"
      echo -e      "$br  !!! --- already exists!                    $e0"
      echo -e      "$br  ??? How to handle user '/data' ?           $e0"
      echo -e      "$bb    N    No Update - hold user data          $e0"
      echo -e      "$bb    U    Update - overwrites with ZIP data   $e0"
      echo -e      "$bb  other  Terminate - do nothing              $e0"

      read -n 1 -p "$br  ??? --- Select   N/U ? $e0" Qa ;
      echo -e  "\n"

      if [[ $Qa == 'U'  ]] ; then   # Update completely
          rm -R $xDIR/$NAME/
          echo -e "$ba  --- unzipp '$ZIPP' to  directory $e0"
          unzip -o $ZIPP -d $xDIR/$NAME/ -x schedulePlusSetup.sh

      elif [[ $Qa == 'N'  ]] ; then  #
          echo -e "$ba   --- Hold $xDIR/$NAME/ and /data   $e0"
          unzip -o $ZIPP -d $xDIR/$NAME/ -x "data/*" schedulePlusSetup.sh
      else
         echo -e "NO selection ..."
         exit 99
      fi

      exit 0

   else
      echo -e "$ba  ---  New installation -- all ZIP data will be installed $e0"
      unzip -o $ZIPP -d $xDIR/$NAME/
   fi

 exit 0
}


function install_py ()
{
   echo "$ba  ... install_it  $WHAT  $e0"
   INSTALL_STAT=`sudo pip3 install $WHAT`
   IS_STAT=$(( ! $(grep -iq 'satisfied:' <<< "$INSTALL_STAT"; echo $?) ))
   echo "  ...     status  '$IS_STAT' \n INSTALL_STAT:  >>$INSTALL_STAT<< "
}

function install_Py ()        # --P
{
   echo "$ba  ... Install python3-pip ... $e0"
   sudo apt-get install python3-pip

   WHAT='apscheduler'
   install_py $WHAT

   WHAT='bottle'
   install_py $WHAT

   WHAT='python-dateutil'
   install_py $WHAT
}

# **********************************************

# Edit jPrefs.user.json  with 'nano' editor
#  .. needs $NAME .zip already unzipped!
#
function edit_userjprefs ()          # --J
{
   if [ ! -f '$NAME/$jUserData' ] ; then
      nano $NAME/$jUserData
      cat $NAME/$jUserData
   else
      echo -e "$br   ... Edit Failed!  '$NAME/$jUserData' missing ! $e0"
      exit 99
   fi
}

# ---------------------------------------------
function SystemInstall ()
{
   exit 1
}


#==============================================

   # Check not to operate on '$NAME' directory,
   # should work on it's parent directory!

   if [[ $currentDIR == $NAME ]] ; then
      echo -e "\n$br   !!! ---  Current dir is '$NAME'"
      echo -e      "   !!! ---  Run this script in parent directory!$e0\n"
      exit 1
   fi

   # -------------------


   while (( "$#" )); do
      case "$1" in

         --help)
          echo "$H$A"; exit 0
          ;;


         --L)
            zip_list_local
         exit 0
         ;;

         --Z)
            zip_from_git
         exit 0
         ;;


         --U)
            echo "$bb  ... $NAME App Unzip to local directory $e0"
            unzip_2_dir
         exit 0
         ;;


         --P|--install_Py)
            echo "----------------------"
            echo "$bb  ... $NAME - Python Libs install    $e0"
            install_Libs
         exit 0
         ;;


         --J|edit_userjprefs)
            echo -e "\n$ba   ... Edit.. '$NAME/$jUserData'   $e0"
            edit_userjprefs
         exit 0
         ;;


         --S|--system)
         port=$(sed 's/, "/\n/g' $xDIR/$NAME/data/jPrefs.json | egrep "port" | tr -d '":a-zA-Z ,')
         addr=$(echo $(hostname -I) | awk '{print $ 1;}')
         echo "$ba System Check  addr: $bb$addr$ba  port: $bb$port$e0"
         exit 0
         ;;


         # -----------------------------------------------


         -s|--SystemInstall)
            echo "$bb  ... $NAME app installation $e0"
            zip_list_local


            exit 0
         ;;


         # -----------------------------------------------


         -i|--install)

          echo "  ... System installieren mit $ZIPP"
          ###cmd=SystemInstall; shift 1
          ;;

         -c|--configure)
          echo "  ... System konfigurieren";

          cmd=SystemConfigure; shift 1
          #SystemConfigure; shift 1
          ;;

         -a|--all)
          echo "  ... Alles ausführen";


          ###SystemInstall

          exit 0
          ;;


         *)
          echo "$A"; exit 0
          ;;

         esac
         done

  echo "  ... Aufruf '$cmd' mit ZIP '$ZIPP'"
  $cmd
  exit 0
