#!/bin/bash

# SETUP.sh
# script that ships with dotfu repo to add af and afrec to .bashrc file
# author: jotey
# date: 18 April 2017

#  #  #  #  #  #  #  #  #  #  #  CHANGELOG  #  #  #  #  #  #  #  #  #  #  #
# ---- when ---- | -- who -- | -- what -- |
# ----------------------------------------------------------------------------
#  18 Apr 2017   |  jotey    | started this changelog! 
# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------

# # # USAGE FROM TEMPLATE # # #

USAGE_MESSAGE="[This script takes no args]"
ARGMIN=0
ARGMAX=0

usage () {
	printf "usage: %s $USAGE_MESSAGE \n" $0 >&2
	exit
}

#usage test for $ARGMIN
if [ $# -lt $ARGMIN ]; then
	usage
fi

#usage test for $ARGMIN
if [ $# -gt $ARGMAX ]; then
	usage
fi

# # # FUNCTIONS # # #

# # # VARIABLES # # #
# tip: relative paths are your enemy! #
# logpath=/absolute/path/to/relevant/dir

# # # MAIN PROGRAM # #
cd /$USER && ls dotfu >/dev/null && echo "...dotfu repo found, continuing"

grep -q "af(){"
if [ $? -eq 0 ]; then
	echo "af function already installed, quitting
	exit
else
	echo ...testing to see if /$USER/.bashrc is under RCS control...
	# TK
	echo ...installing af function
	cat << EOF >> /$USER/.bashrc
af(){
	repo=/$USER/dotfu
	if [ "$1" = "-v" ]; then
		dirs="${@:2}"
		for i in $dirs; do
			echo sourcing files in ${i} ...
			for j in $repo/$i/*; do
				echo sourcing $j
				source $j
			done
		done   
	else    #non-verbose   
		dirs=$*
		for i in $dirs; do
			for j in $repo/$i/*; do
				source $j
			done
		done
	fi
}
EOF

# Section for afrec
# echo these are the dotfu categories
# echo type in, with spaces, the ones you would like to source via afrec
# echo or leave blank to accept generic recommendation (math screen rcs)
# that functionality...
# add the afrec function to .bashrc
fi

