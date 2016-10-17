#!/bin/bash 

# Simple FFmpeg video editor, with Zenity interface, and modular extensibility
# ver. 0.1 - 1st March 2016
# source: http://oioiiooixiii.blogspot.com

### VARIABLES ##################################################################

startPoint="" # Desired HMS start-point of video
endPoint="" # Desired HMS end-point of video
displayTimes="false" # Disable trim times display in main menu
timestampFile="/dev/shm/numbers.text" # Location of FFplay stdout - see NB1

file="" # Full URI of input video file
filename="" # Trimmed filename, used for displaying and processing
ffplayPID="" # Process ID of FFplay child-process

### FUNCTIONS ##################################################################

function finish() # Clean-up commands called when exiting program
{
   echo "Killing...$(( ffplayPID-1 ))"
   [ ! -z "$ffplayPID" ] && kill "$(( ffplayPID-1 ))" # issue with PID value
   rm "$timestampFile"
   #exit
}
trap finish EXIT

function getVideoFilename() # Request location of video input file
{
   badFileName="true"
   while [ "$badFileName" == "true" ]
   do
      file="$(zenity --file-selection)"
      [ "${PIPESTATUS[0]}" == "1" ] && exit 1 # If zenity cancle button clicked
      [ "$(ffprobe "$file" 2>&1 | grep 'Stream #0:0')" == "" ] \
      && zenity --error --text="Problem with video choice" \
      || badFileName="false"
   done
   # To do: sanitise filenames (spaces etc.)
   filename="${file##*/}" 
}

function displayVideo() # Initialise FFplay window with videoModule.sh
{
   echo "display video..."
   ffplayPID="$(. videoModule.sh $filename)"
   echo " PID is $ffplayPID"
}

function setTrimTimes() # Parse trim times returned from trimModule.sh
{
   [ "$1" != "00:00:00.00 00:00:00.00" ] \
   && startPoint="$(awk '{print $1}' <<< $1)" \
   && endPoint="$(awk '{print $2}' <<< $1)" \
   && displayTimes="true" \
   || displayTimes="false"
}

function getStatus() # Generate informational text for display in Zenity
{
   text="Video file: $filename"
   [ "$displayTimes" == "true" ] \
   && text="$text\nTrim times: ⇨ [ $startPoint ⟷ $endPoint] ⇦"
   echo "$text"
}

function showMainDialog() # Parent Zenity dialog menu
{
   while [ "${PIPESTATUS[0]}" != "1" ]
   do
      echo "${PIPESTATUS[0]}"
      echo "$?"
      selection="$(zenity --list \
               --width=300 --height=300 \
               --title="Zenity+FFmpeg Video Editor" \
               --text="$(getStatus)" \
               --column="Select Option" \
                  "Trim Video" \
                  "*Future video option" \
                  "*Future video option" \
                  "*Future video option" \
                  "Save video")"
    
      case "$selection" in
         "Trim Video" )
            setTrimTimes "$(. trimModule.sh )"
            echo ;; # echo to 'reset' exit code to 0 - see NB2
         "Save video" )
            . saveModule.sh "$filename" "$startPoint" "$endPoint"
            echo ;; # echo to 'reset' exit code to 0 - see NB2
      esac
   done 
}

### BEGIN ######################################################################

getVideoFilename
displayVideo
showMainDialog
#finish

### NOTES ######################################################################

#NB1: May be better to pass this URI as an argument to each module instance
#NB2: Multiple solutions to this e.g. give modules their own internal exit codes
