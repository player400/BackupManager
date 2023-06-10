#!/bin/bash

# Name		   : Auto-Backup Manager Execution Module
# Author           : Mateusz Nurczyński (mnurczynski4@gmail.com)
# Created On       : 2023-05-11
# Last Modified On : 2023-05-11
# Version          : 1.1
#
# Description      : This is the Execution Module of the Auto-Backup Manager. This script creates the backups based on the list provided in .rc file as listed in ./backup-config.rc. 
# 	 	     This script should be started automatically on boot in order to work properly (see systemd documentation).
# 		     List blueprint:
#		     NUMBER=<number of backups>
#		     LIST=(<first backup name> <first backup update period in days> <first backup original file directory> <first backup last update date in YYYY-MM-DD format> <second backup name> ... )
#		     For easy modification of the backup list and restoring the backups see the Auto-Backup Manager Editor Module. 
#
# Copyright	   : Software is hereby released under MIT license. For details see opensource.org. Copy of the licence attached below.
#		     Copyright Mateusz Nurczyński 2023.
#		     Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:"	 
#		     The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#		     THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO #EVENT 	SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS #IN THE SOFTWARE.

while getopts hvl OPT; do
	case $OPT in
		"h") echo "This is the Execution Module of the Auto-Backup Manager. This script creates the backups based on the list provided in .rc file as listed in ./backup-config.rc. "
		     echo "This script should be started automatically on boot in order to work properly (see systemd documentation)."
		     echo "List blueprint:"
		     echo "NUMBER=<number of backups>"
		     echo "LIST=(<first backup name> <first backup update period in days> <first backup original file directory> <first backup last update date in YYYY-MM-DD format> <second backup name> ... )"
		     echo "For easy modification of the backup list and restoring the backups see the Auto-Backup Manager Editor Module."
		     exit;;
		"v") echo "This is version 1.1 of the Auto-Backup Execution Module by Mateusz Nurczyński, student of the Faculty Of Electronics, Telecommunications and Infomatics at Gdańsk University of Technology"
		     exit;;
		"l") echo "Software is hereby released under MIT license. For details see opensource.org. Copy of the licence attached below."
		     echo "Copyright Mateusz Nurczyński 2023."
		     echo "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:"
		     echo "The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software."
		     echo "THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
		     echo "Contact: mnurczynski4@gmail.com."
		     exit;;
	esac
done

. backup_config.rc

while :
do
	. $LIST_LOCATION
	ITER=0
	while [[ $ITER -lt $(($NUMBER*4)) ]]; do
		NAME=${LIST[$ITER]}
		PERIOD=${LIST[$(($ITER+1))]}
		BACKUP_PATH=${LIST[$(($ITER+2))]}
		LAST_BACKUP_DATE=${LIST[$(($ITER+3))]}
		DESIRED_BACKUP_DATE=$(date '+%Y-%m-%d' -d "-$PERIOD days")
		if [[ $DESIRED_BACKUP_DATE > $LAST_BACKUP_DATE ]]; then
			ARGUMENT=$BACKUP_PATH
			ARGUMENT+=" "
			ARGUMENT+=$BACKUP_LOCATION
			ARGUMENT+=$NAME
			echo $ARGUMENT
			cp $ARGUMENT
			LIST[$(($ITER+3))]=$(date '+%Y-%m-%d')
		fi
		ITER=$(($ITER+4))
	done
	echo "NUMBER=$NUMBER" > $LIST_LOCATION
	echo "LIST=(${LIST[*]})" >> $LIST_LOCATION
	sleep 1h
done
