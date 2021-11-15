#!/bin/sh

# lindir2windir.sh
#		-	ln -s lindir2windir.sh windir2lindir.sh
#
# Super simple POSIX shell script to use in WSL for translating path names
# from one environment to the other.
#

# Grab the name of this program.
PROGRAM=`echo $0 | sed "s/.*\///"`

# If invoked as "windir2lindir.sh" then translate windows path name to linux.
# Otherwise, assume this is the linux to windows invocation.
WIN_MODE=0
if [ "$PROGRAM" = "windir2lindir.sh" ]; then
	WIN_MODE=1
fi

# We'll take as many directory names on the command line as you want.
for i in "$@"; do

	# Windows to Linux mode.
	if [ "$WIN_MODE" -eq "1" ]; then
		DRIVE=`echo $i | sed "s/^\([A-Z]\).*/\1/" | tr '[:upper:]' '[:lower:]'`
		PATH=`echo $i | sed "s/^[A-Z]://"	| sed "s/\\\\\\/\//g" | sed "s/\([^a-zA-Z0-9/]\)/\\\\\\\\\1/g"`
		echo "/mnt/$DRIVE$PATH"

	# Linux to Windows mode.
	else
		if [ `echo $i | grep '^.'` ]; then
			i=`realpath $i`
		fi
		if [ `echo $i | grep '/mnt/[a-z]/'` ]; then
			DRIVE=`echo $i | sed "s/^\/mnt\/\([a-z]\).*/\1/" | tr '[:lower:]' '[:upper:]'`
			PATH=`echo $i | sed "s/^\/mnt\/[a-z]//" | sed "s/\\\\\\\\\([^a-zA-Z0-9/]\)/\1/g"`
			echo "$DRIVE:$PATH"
		fi
	fi
done

