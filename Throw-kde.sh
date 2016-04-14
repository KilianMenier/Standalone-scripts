#!/bin/bash

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
# Configuration

VERSION="1.0.0"
NAME="Throw"
ICON="yakuake"

Left_Separator='['
Right_Separator=']'





#================================================================
# Time to do some code ;)

function Throw() # Firstly intended as function in Bash configuration file
{

if [ -z "$1" ]	# If you don't gave dices to throw
then		# Then explain how it works

	echo -e "$0: \"Throw 2D6 1D4\""
	echo -e "--> Same as throwing 2 dices of 6 and 1 of 4 =)\n"


else		# Else, okay, user is not a noob

	if [  "$1" = "--in-a-pipe" ]		# If option invoked
	then					# Then
		shift  && no_nice_output="noes"		# No nice output
		Left_Separator=''			# No left separator
		Right_Separator=''			# No right separator
	fi					# End of if option

	
	
	
	while [ ! -z "$1" ]			#So long as there are dices and they match pattern of dice
	do


		[ -z "$no_nice_output" ] && echo -n "$1: "			#Echo dice it is

		
		if [[ ! $1 = *D* ]] && [[ ! $1 = *d* ]]				# if it's not a dice
		then								# Then
			[ -z "$no_nice_output" ] && echo -n " ...Nah"			# Signal it
			err_code=$(( ${err_code:-0} + 1 ))				# +1 in error code
			
			
		else								# Else, be nice

			if [[ $1 = *D* ]]
			then
			  how_much_thrown=${1%%D*}
			  number_of_faces=${1##*D}
			
			elif [[ $1 = *d* ]] 
			then
			  how_much_thrown=${1%%d*}
			  number_of_faces=${1##*d}
			fi
			
			
			for i in $(seq 1 "$how_much_thrown" )			# For each dice to be thrown
			do							# do
				result=$[($RANDOM % $number_of_faces) + 1]		# Throw the dice
				echo -n "$Left_Separator$result$Right_Separator"	# Display it.
				echo -n ' '						# let a space
			done							# done
			
			
		fi							# End pattern-test
		shift ; [ -z "$no_nice_output" ] && echo		# Next dices, and new line.


	done													
	echo && return ${err_code:-0}		# Nothing went wrong =D



fi		#End of test if params

 } #End function Throw

 
 
 

#================================================================
# Run

if $(hash kdialog)
then echo " Kdialog installed ! Proceeding..."
else echo " You'll need kdialog installed in order to use this. Sorry."
fi







DICES="$( \
kdialog \
	--title "$NAME" \
	--icon "$ICON" \
	--inputbox " What kind and how much dices do you want to throw ? =)
(Numer of dices + D + number of sides)" "2D6 1D4" )"


kdialog \
	--title "$NAME" \
	--icon "$ICON" \
	--msgbox "Dice results : 
$(Throw $DICES)		   "
