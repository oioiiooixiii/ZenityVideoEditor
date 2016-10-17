#!/bin/bash

# 'Set video trim points' module for simple Zenity/FFmpeg video editor
# ver. 0.1 - 1st March 2016
# source: http://oioiiooixiii.blogspot.com

### VARIABLES ##################################################################

startPoint="00:00:00.00" # Desired HMS start-point of video
startSeconds="0" # Used for internal calculation
endPoint="00:00:00.00" # Desired HMS end-point of video
endSeconds="0" # Used for internal calculation
timestampFile="/dev/shm/numbers.text" # Location of FFplay stdout

### FUNCTIONS ##################################################################

function readSeconds() 
{
   echo "$(grep -E '[0-9]{2}' $timestampFile | tail -1)"
}

function getTimestamp() 
{
   seconds="$1"
   mSeconds="${seconds#*.}"
   seconds="${seconds%.*}"

   hours="$(( seconds / 3600 ))"
   minutes="$(( ( seconds / 60 ) % 60 ))"
   seconds="$(( seconds % 60 ))"

   printf "%02d:%02d:%02d.%02d" "$hours" "$minutes" "$seconds" "$mSeconds"
}

function checkTimes()
{
   # Compare values after removing decimal char
   (( $(sed 's/\.//' <<< $startSeconds) \
   <= $(sed 's/\.//' <<< $endSeconds) )) \
   && echo "OK"
}

function showTrimDialog()
{
   while [ "${PIPESTATUS[0]}" != "1" ]
   do
      selection="$(zenity --list \
               --width=220 --height=184 \
               --title="Trim Video" \
               --text="⇨ [ $startPoint ⟷ $endPoint ] ⇦" \
               --column="Select Option" \
                  "Start Point  ⇨ [" \
                  "End Point  ] ⇦" \
                  "Finished")"
    
      case "$selection" in
         "Start Point  ⇨ [" )
            startSeconds="$(readSeconds)"
            startPoint="$(getTimestamp $startSeconds)" ;;
         "End Point  ] ⇦" )    
            endSeconds="$(readSeconds)"
            endPoint="$(getTimestamp $endSeconds)" ;;
         "Finished" )    
            [ "$(checkTimes)" == "OK" ] \
            && echo "$startPoint $endPoint" \
            && exit 1 \
            || zenity \
               --warning \
               --text="There is a problem with the selected times" ;;
      esac
   done 
}

### BEGIN ######################################################################

showTrimDialog

### NOTES ######################################################################
