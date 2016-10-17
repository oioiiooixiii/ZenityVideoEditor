#!/bin/bash

# 'Save file' module for simple Zenity/FFmpeg video editor
# ver. 0.1 - 1st March 2016
# source: http://oioiiooixiii.blogspot.com

### VARIABLES ##########################################################

### FUNCTIONS ##########################################################

function getOutputFilename()
{
   # Check for $2 and $3 for better formatting
   [ ! -z "$2" ] && times="_$2--$3_"
   
   zenity \
      --entry \
      --title="Save file" \
      --text="Save file as" \
      --width=480 \
      --entry-text="EDIT_${times}_$1"
}

function runFFmpeg()
{   
   arguments=()
   # $1: Input filename
   [ ! -z "$1" ] && arguments+=(-i "$1")
   # $2: Output filename
   # $3: Start time
   [ ! -z "$3" ] && arguments+=(-ss "$3")
   # $4: End time
   [ ! -z "$4" ] && arguments+=(-to "$4")
   # $5: Filters
   # $6: Force cut on non-keyframes
   [ ! -z "$2" ] && arguments+=(-c copy -copyinkf "$2")
   
   ffmpeg \
      "${arguments[@]}" \
      -y \
      2>&1 \
      | zenity \
         --text-info \
         --width=480 \
         --height=300

   # --auto-scroll in newer zenity installs
}

### BEGIN ##############################################################

outputFilename="$(getOutputFilename $1 $2 $3)"
[ "${PIPESTATUS[0]}" != "1" ] && runFFmpeg "$1" "$outputFilename" "$2" "$3" 

### NOTES ##############################################################

#NB1: https://www.ffmpeg.org/ffmpeg-formats.html#Options-10

#one runFFmpeg function, -non break frams etc added to "ffmpeg arguments" string

#function runFFmpegNonKeyframes()
#{
 #  # NB1: '-break_non_keyframes 1' Deliberate break on non-keyframes, even if it introduces errors
  # ffmpeg -ss "$startpoint" -i "$inputName" -to "$endPoint" -break_non_keyframes 1 -c copy "$(getOutputFilename)"
#}


# Transform BASH arguments to FFmpeg arguments 
#
#[ -z "$1" ] && zenity \
#                  --warning \
 #                 --text="Interal Error: Input filename not set."\
 #           && exit 1 || inputName="-i $1"
#[ -z "$2" ] && startPoint="-ss $2"
#[ -z "$3" ] && endPoint="-to $3"
#[ -z "$4" ] && forceCut="true"
#[ -z "$5" ] && filters="-vf \"$5\""
