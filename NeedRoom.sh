#!/usr/bin/env bash

#================================================================
# Made by Rin -- rin.mancuso@gmail.com

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License at <http://www.gnu.org/licenses/> for
# more details.




#================================================================
# Settings


# Generic
NAME=NeedRoom
VERSION=0.9
DEBUG=false


# Script settings
REFRESH_TIME=1



# Paint with all the colors of the wind
STOP="$(tput sgr0)"
CLOSE="$(tput sgr0 ; tput bold)"
RED="$(tput bold ; tput setaf 1)"
GREEN="$(tput bold ; tput setaf 2)"
YELLOW="$(tput bold ; tput setaf 3)"
BLUE="$(tput bold ; tput setaf 4)"
PINK="$(tput bold ; tput setaf 5)"
CYAN="$(tput bold ; tput setaf 6)"
WHITE="$(tput bold ; tput setaf 7)"
REDALERT=`echo -ne '\033[5;31m'`



#================================================================
# Initialization


# Need help ?
if [ "$1" == "--help" ] || [ "$1" == "-h" ]
then
echo "$CLOSE $NAME - Dynamic workspaces just like in Gnome-shell$STOP
 V.$VERSION by$YELLOW Rin (@rin_mancuso on Twitter) -- rin.mancuso@gmail.com $STOP
Script to adjust the number of workspaces dynamically to fit your needs (Ironically, it doesn't works on Gnome-shell). Make sure you have wmctrl installed before, and simply run this in a terminal. You can exit and bring everything back to normal with a ctrl+c
(Warning, on old hardware it can be pretty cpu intensive. Default settings are fine)." ; exit
fi


# Say hello nicely
echo "$GREEN * Hello ! Have a nice day ! :)$STOP"


# Check if wmctrl is installed
if $(hash wmctrl)
then echo " * wmctrl detected ! Proceeding..."
else echo "$RED * no wmctrl detected on this system. Install it, it's worth it$STOP" && exit
fi


# Get number of already existing workspaces
NB_WORKSPACES=$(wmctrl -d |tail -1 | cut -d ' ' -f 1)


# Add 1 to have the total count since we start from 0
NB_WORKSPACES=$((NB_WORKSPACES + 1))
echo " * Detected $NB_WORKSPACES virtual desktop(s)"


# If user ctrl+c, put everything back to how it was
trap "wmctrl -n $NB_WORKSPACES ; echo '$BLUE * Ctrl+c ! Putting back everything like it was before$CLOSE'  ; exit 0" INT


# Warn for the refresh time
echo " * Number of workspaces is refreshed each $REFRESH_TIME seconds"






#================================================================
# LOOP


# Repeat each REFRESH_TIME
while sleep $REFRESH_TIME
do

    # Warn for each loop
    echo ; echo "$CLOSE * NEW LOOP $STOP"


    # Get a list of workspaces with something on it. Basically list windows, strip workspace ID 
    NOT_EMPTY="$(while read line ;
                    do set $line ; echo "$2"
                    done <<< "$(wmctrl -l)" | sort -u)"


    # There is always something on desktop "-1" : the "on all workspaces"-stuff (docks, panels, etc). We don't need it
    NOT_EMPTY=${NOT_EMPTY//"-1"}
    echo " ID of used workspaces : ${NOT_EMPTY//[$'\r\n']}"


    # Get current workspace. Basically display workspaces, get the two columns, get the line with the "*", strip out the workspace
    CURRENT_WORKSPACE=$(wmctrl -d | cut -d ' ' -f 1,3 | grep '*' | cut -d ' ' -f 1)
    echo " Current workspace : $CURRENT_WORKSPACE (Labelled as desktop $((CURRENT_WORKSPACE + 1)) )"


    # Check the number of used workspaces. And if user is on a non-empty workspace
    # We don't disturb the user by removing a workspace when he/she is on it
    USED_WORKSPACES=0
    user_on_used_workspace=false
    for ws in $NOT_EMPTY
    do
		USED_WORKSPACES=$((USED_WORKSPACES + 1))
		LAST_WORKSPACE=$ws
		if [ $ws == $CURRENT_WORKSPACE ]
                    then user_on_used_workspace=true
               fi
    done
   echo " Last used workspace : $LAST_WORKSPACE (Labelled as desktop $(( LAST_WORKSPACE + 1)) )"
   echo " Number of workspaces : $NB_WORKSPACES, used workspaces : $USED_WORKSPACES + 1 empty"
 
    # If there is a mismatch in used workspaces vs the total count
    if  [ $((USED_WORKSPACES + 1)) != $NB_WORKSPACES ] #&& [ $user_on_used_workspace == "true" ]
    then

            # Then we will correct this by changing to used workspaces and adding one
            # Warn that we do stuff
            echo "$YELLOW Mismatch !$STOP We need $USED_WORKSPACES but have $((NB_WORKSPACES))... Adjusting dynamically..."

	    # Remove all unused workspaces by setting new count to used workspaces
	    NB_WORKSPACES=$USED_WORKSPACES
	    [ ! "$DEBUG" == true ] && wmctrl -n $NB_WORKSPACES

    else
            # Everything's alright
            echo " No need for a new virtual desktop, nothing to do here"

    fi



# If last used workspace is last workspace
if [ $(( LAST_WORKSPACE + 2)) -gt $NB_WORKSPACES ]
then
	    # Adding last empty workspace (after removing everything. Or else we would end with just removing the last workspace)
	    NB_WORKSPACES=$(( NB_WORKSPACES + 1))
	    echo "$YELLOW Last workspace not empty !$STOP Setting the new count of workspaces, now we have $NB_WORKSPACES"
	    [ ! "$DEBUG" == true ] && wmctrl -n $NB_WORKSPACES
fi


# End of big loop
done



#================================================================
#================================================================
