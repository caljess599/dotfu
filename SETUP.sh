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
#  19 Apr 2017   |  jotey    | first deployment, afrec generic only, no rcs 
# ----------------------------------------------------------------------------
#  19 Apr 2017   |  jotey    | added RCS functionality
# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------

# # # USAGE FROM TEMPLATE # # #

USAGE_MESSAGE="[name of alternative file (default is ~/.bashrc)]"
ARGMIN=0
ARGMAX=1

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
isrcs(){
	# accept a file name
	givenname=$1
	# where it is
	pathtofile=$(dirname $1)
	# what it's called
	basename=$(basename $1)
	# preserve check on its existence
	if [ ! -e $1 ]; then
		echo "No such file exists"
		return 2
	else
		if
			[ -e ${pathtofile}/RCS/${basename},v ]; then
			return 1
		else
			return 0
		fi
	fi
}

addaf(){
	cat << 'EOF' >> $BDIR/$BASHRC

# af function for dotfu repo
# usage: af [-v] <dotfu folder> [...]
# -v flag produces verbose output
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

# generic afrec options, with verbose option
# use eval $(afrec) to load
afrec(){
	echo af -v math megaraid screen rcs
}
EOF
}

# # # VARIABLES # # #
# tip: relative paths are your enemy! #

# if alternative file name provided, use it
if [ $# -gt $ARGMIN ]; then
	BASHRC=$1
else
	BASHRC=".bashrc"
fi

# # # MAIN PROGRAM # #
PDIR=$(pwd)
if [ ${PDIR##*\/} != dotfu ]; then
	echo "Please run this script from dotfu directory"
	exit
fi

BDIR=${PDIR%*\/dotfu}
echo ... using $BDIR for $BASHRC path ...

# see if function exists, uncommented
EXIST=$(grep -q "^af(){" $BDIR/${BASHRC}; echo $?) 

# may not need to install
if [ $EXIST -eq 2 ]; then
	echo "$BDIR/$BASHRC does not exist, quitting"
elif [ $EXIST -eq 0 ]; then
	echo "The af function already present in $BDIR/$BASHRC, quitting"
	exit
else
	echo ... testing to see if $BDIR/$BASHRC is under RCS control ...
	CONTROL=$(isrcs $BDIR/$BASHRC; echo $?)
	if [ $CONTROL -eq 2 ]; then
		exit
	elif [ $CONTROL -eq 1 ]; then
		echo ... yes, file is under RCS ...
		echo ... unlocking $BDIR/$BASHRC ...
	        co -l $BDIR/$BASHRC
	       	echo ... installing af function to $BDIR/$BASHRC...
		addaf
		echo ... re-locking file ...
		ci -u -m'inserted af and afrec functions for dotfu repo' $BDIR/$BASHRC 
	else
		echo ... this file is not under RCS, continuing ...
		echo ... installing af function to $BDIR/$BASHRC ...
		addaf
	
	fi
	echo ... IF THIS IS A PERSONAL BOX, you will need to adjust the repo path ...
	echo ... afrec installed with default options: math megaraid screen rcs ...
	echo ... feel free to edit based on the needs of this box ...
fi
