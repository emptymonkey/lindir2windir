#!/bin/sh

export PATH="/bin:/usr/bin:/usr/local/bin"

# sh has a builtin echo that always translates control characters.
# That means that in the case of 'C:\one\two\foo\bar' the "\t" in "\two" 
# is treated as a tab character. This results in "C:\one	wo\foo\bar".
# This is not what we want.
ECHO=`which echo`" -E"

# lindir2windir.sh
#		-	ln -s lindir2windir.sh windir2lindir.sh
#
# Super simple POSIX shell script to use in WSL for translating path names
# from one environment to the other.
#

# Grab the name of this program.
PROGRAM=`$ECHO $0 | sed "s/.*\///"`

# If invoked as "windir2lindir.sh" then translate windows path name to linux.
# Otherwise, assume this is the linux to windows invocation.
WIN_MODE=0
if [ "$PROGRAM" = "windir2lindir.sh" ]; then
	WIN_MODE=1
fi

# We'll take as many directory names on the command line as you want.
for i in "$@"; do

	# Windows to Linux mode.
	if [ $WIN_MODE -eq 1 ]; then
		DRIVE=`$ECHO $i | sed "s/^\([A-Z]\).*/\1/" | tr '[:upper:]' '[:lower:]'`
		NEW_PATH=`$ECHO $i | sed "s/^[A-Z]://"	| sed "s/\\\\\\/\//g" | sed "s/\([^a-zA-Z0-9/.]\)/\\\\\\\\\1/g"`
		$ECHO "/mnt/$DRIVE$NEW_PATH"

	# Linux to Windows mode.
	else
		ABSOLUTE_PATH=`$ECHO $i | tr -d '\\\\'`
		ABSOLUTE_PATH=`realpath "$ABSOLUTE_PATH"`
		$ECHO "$ABSOLUTE_PATH | egrep '/mnt/[a-z]/'" 1>/dev/null
		if [ $? -eq 0 ]; then
			DRIVE=`$ECHO $ABSOLUTE_PATH | sed "s/^\/mnt\/\([a-z]\).*/\1/" | tr '[:lower:]' '[:upper:]'`
			NEW_PATH=`$ECHO $ABSOLUTE_PATH | sed "s/^\/mnt\/[a-z]//" | tr '/' '\\\\'`
			if [ -z "$NEW_PATH" ]; then
				NEW_PATH="\\"
			fi
			$ECHO "$DRIVE:$NEW_PATH"
		fi
	fi
done

