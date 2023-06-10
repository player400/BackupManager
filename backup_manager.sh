#!/bin/bash

# Name		   : Auto-Backup Manager Editor Module
# Author           : Mateusz Nurczyński (mnurczynski4@gmail.com)
# Created On       : 2023-05-12
# Last Modified On : 2023-05-12
# Version          : 1.1
#
# Description      : This is the Editor Module of the Auto-Backup Manager. CAUTION - this script only does the backup once and edits the Backup List (the file listed in ./backup_config.rc). 
#		   : In order for the Manager to work properly the Execution Module (backup.sh) needs to be installed in the same folder as this script and be auto-started by the system on boot.
#
# Cop# Copyright	   : Software is hereby released under MIT license. For details see opensource.org. Copy of the licence attached below.
#		     Copyright Mateusz Nurczyński 2023.
#		     Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:"	 
#		     The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#		     THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO #EVENT 	SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS #IN THE SOFTWARE.

. backup_config.rc

while getopts hvl OPT; do
	case $OPT in
		"h") echo "This is the Editor Module of the Auto-Backup Manager. CAUTION - this script only does the backup once and edits the Backup List (the file listed in ./backup_config.rc). "
		     echo "In order to use this script start it without options - it is equipped with intuitive Zenity GuI"
		     echo "In order for the Manager to work properly the Execution Module (backup.sh) needs to be installed in the same folder as this script and be auto-started by the system on boot."
		     echo "NOTE: both Execution and Editor modules need to be in the same folder, together with a copy of backup_config.rc file (where you can modifiy backup location)."
		     exit;;
		"v") echo "This is version 1.1 of the Auto-Backup Editor Module by Mateusz Nurczyński, student of the Faculty Of Electronics, Telecommunications and Infomatics at Gdańsk University of Technology"
		     exit;;
		"l") echo "Software is hereby released under MIT license. For details see opensource.org. Copy of the licence attached below."
		     echo "Copyright Mateusz Nurczyński 2023."
		     echo "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without 			limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:"
		     echo "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software."
		     echo "THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
		     echo "Contact: mnurczynski4@gmail.com."
		     exit;;
	esac
done

STARTING_MENU=("Create new backup" "Manage existing backups")
OFFSET_OF_PICKED_BACKUP=-1

manage(){
	EDIT_MENU=("Restore" "Delete")
	COMMAND=$(zenity --list --column=MENU "${EDIT_MENU[@]}" --height 320)
	case $COMMAND in
		"Restore")
			ARGUMENT=""
			ARGUMENT+=$BACKUP_LOCATION
			ARGUMENT+=${LIST[$OFFSET_OF_PICKED_BACKUP]}
			ARGUMENT+="/"
			FILENAME="$(basename -- ${LIST[$(($OFFSET_OF_PICKED_BACKUP+2))]} )"
			ARGUMENT+=$FILENAME
			cat $ARGUMENT > ${LIST[$(($OFFSET_OF_PICKED_BACKUP+2))]};;
		"Delete") 	
			ARGUMENT=""
			ARGUMENT+=$BACKUP_LOCATION
			ARGUMENT+=${LIST[$OFFSET_OF_PICKED_BACKUP]}
			rm -r $ARGUMENT
			NEW_LIST=()
			ITER=0
			while [[ $ITER -lt $OFFSET_OF_PICKED_BACKUP ]]; do
				NEW_LIST+=( ${LIST[$ITER]} )
				ITER=$(($ITER+1))
			done
			ITER=$(($ITER+4))
			while [[ $ITER -lt $NUMBER ]]; do
				NEW_LIST+=( ${LIST[$ITER]} )
				ITER=$(($ITER+1))
			done
			LIST=("${NEW_LIST[@]}")
			NUMBER=$(($NUMBER-1));;
	esac
}

create(){
NEW_NAME=$(zenity --entry --text "What name should your backup have?")
if [ -z $NEW_NAME ]; then
	return
fi
NEW_PERIOD=`zenity --scale --text="How often (in days) would you like to backup the file?"  --min-value=1  --max-value=30 --value=7`
echo $NEW_PERIOD
if [ -z $NEW_PERIOD ]; then
	return
fi
NEW_PERIOD=$(($NEW_PERIOD-1))
FILE=$(zenity --file-selection --title="What file would you like to backup? Keep in mind that the file needs to stay in the same directory or the backups won't work.")
case $? in
         0)
         	ARGUMENT=$FILE
		ARGUMENT+=" "
		LOCATION=$BACKUP_LOCATION
		LOCATION+=$NEW_NAME
		mkdir -p $LOCATION
		ARGUMENT+=$BACKUP_LOCATION
		ARGUMENT+=$NEW_NAME
		echo $ARGUMENT
		cp $ARGUMENT
                LIST+=("$NEW_NAME")
                LIST+=("$NEW_PERIOD")
                LIST+=("$FILE")
                LIST+=("$(date '+%Y-%m-%d')")
                NUMBER=$(($NUMBER+1));;
         1)
                zenity --error --text "No file selected! New backup cancelled";;
        -1)
                zenity --error --text "Unexpected error! New backup cancelled";;
esac
}

while :
do
	EXISTING_BACKUPS=()
	. $LIST_LOCATION
	ITER=0
	while [[ $ITER -lt  $(($NUMBER*4)) ]]; do
		EXISTING_BACKUPS+=( "${LIST[$ITER]}" )
		ITER=$(($ITER+4))
	done
	COMMAND=$(zenity --list --column=MENU "${STARTING_MENU[@]}" --height 320)
	case $COMMAND in
		"Create new backup") create;;
		"Manage existing backups") 	
			NAME=""
			NAME=$(zenity --list --column=MENU "${EXISTING_BACKUPS[@]}" --height 320)
			ITER=0
			while [[ $ITER -lt  $NUMBER ]]; do
				if [ "${EXISTING_BACKUPS[$ITER]}" = "$NAME" ]; then
					OFFSET_OF_PICKED_BACKUP=$(($ITER*4))
					break
    				fi
				ITER=$(($ITER+1))
			done
			if [ $OFFSET_OF_PICKED_BACKUP -ne -1 ]; then
				manage
    			fi;;
		*) exit;;
	esac
	echo "NUMBER=$NUMBER" > $LIST_LOCATION
	echo "LIST=(${LIST[*]})" >> $LIST_LOCATION
done
