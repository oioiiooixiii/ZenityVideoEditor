#!/bin/bash

# 'Display video' module for simple Zenity/FFmpeg video editor
# ver. 0.1 - 1st March 2016
# source: http://oioiiooixiii.blogspot.com

### VARIABLES ####################################################

filename="$1"
timestampFile="/dev/shm/numbers.text" # Location of FFplay stdout
ffplayPID="" # Process ID of FFplay child-process

### FUNCTIONS ####################################################

function videoLength() 
{
   ffprobe "$1" 2>&1 | \
   grep Duration | \
   awk -F: '{ print ($2 * 3600) + ($3 * 60) + $4 }' | \
   cut -d '.' -f 1
}

function displayVideo() 
{
   ffplay \
      -i "$1" \
      -vf  "$ancillary,\
            $timecode,\
            $pictureType,\
            $progressBar" \
      -an \
      2>&1 | stdbuf -oL awk '{print $1}' > "$timestampFile" &
      # NB1: 'stdbuf' used to remove file I/O buffer lag
      
   #ffplayPID="$!" 
   echo "$!" # Return PID value of ffplay instance
}

### FILTERS ######################################################

progressBar=\
"\
   pad=iw:ih+36:\
      color=gray,\
   drawtext=fontfile=/usr/share/fonts/truetype/freefont/FreeSans.ttf:\
      fontsize=50:\
      fontcolor=black@.4:\
      y=h-36:x=t*(640/$(videoLength $filename))-6:\
      text='I'\
"
timecode=\
"\
   drawtext=fontfile=/usr/share/fonts/truetype/freefont/FreeSans.ttf:\
      fontsize=50:\
      fontcolor=white:\
      x=(w-tw)/2: y=h-(2*lh):\
      box=1:\
      boxcolor=0x00000000@0.6:\
      text='%{pts\:hms}'\
"
pictureType=\
"\
   drawtext=fontfile=/usr/share/fonts/truetype/freefont/FreeSans.ttf:\
      fontsize=50:\
      fontcolor=white:\
      x=(w-tw)/1.25: y=h-(2*lh):\
      box=1:\
      boxcolor=0x00000000@0.6:\
      text='%{pict_type}'\
"

ancillary=\
"\
   scale=640:-2,\
   showinfo\
"

### BEGIN ##########################################################

displayVideo "$filename"

### NOTES ##########################################################

#NB1: https://www.gnu.org/software/coreutils/manual/html_node/stdbuf-invocation.html
