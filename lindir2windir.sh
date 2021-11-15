#!/bin/sh

export PATH="/bin:/usr/bin:/usr/local/bin"

# lindir2windir.sh
#		-	ln -s lindir2windir.sh windir2lindir.sh
#
# Super simple POSIX shell script to use in WSL for translating path names
# from one environment to the other.
#

usage() {
	echo "Usage: $0 [-e] [-h]" 1>&2
	echo "  -e:  Escape mode. All [^a-zA-Z0-9] characters are escaped."
	echo "  -h:  This message."
	exit 1
}

ESCAPE=0
while getopts "eh" o; do
	case "${o}" in
		e)
			ESCAPE=1
			;;
		h)
			usage
			;;
		*)
			usage
			;;
	esac
done
shift $((OPTIND-1))

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

	# XXX If we don't reset the path every loop, then shit breaks. WTActualF?!
	export PATH="/bin:/usr/bin:/usr/local/bin"

	# Windows to Linux mode.
	if [ $WIN_MODE -eq 1 ]; then
		DRIVE=`echo $i | sed "s/^\([A-Z]\).*/\1/" | tr '[:upper:]' '[:lower:]'`
		PATH=`echo $i | sed "s/^[A-Z]://"	| sed "s/\\\\\\/\//g" | sed "s/\([^a-zA-Z0-9/.]\)/\\\\\\\\\1/g"`
		echo "/mnt/$DRIVE$PATH"

	# Linux to Windows mode.
	else
		ABSOLUTE_PATH=$i
		echo "$ABSOLUTE_PATH | egrep '^\.'" 1>/dev/null
		if [ $? -eq 0 ]; then
			ABSOLUTE_PATH=`realpath "$ABSOLUTE_PATH"`
		fi
		echo "$ABSOLUTE_PATH | egrep '/mnt/[a-z]/'" 1>/dev/null
		if [ $? -eq 0 ]; then
			DRIVE=`echo $ABSOLUTE_PATH | sed "s/^\/mnt\/\([a-z]\).*/\1/" | tr '[:lower:]' '[:upper:]'`
			PATH=`echo $ABSOLUTE_PATH | sed "s/^\/mnt\/[a-z]//" | sed "s/\//\\\\\\\\/g"`
			if [ $ESCAPE -eq 1 ]; then
				PATH=`echo $PATH | sed "s/\([^a-zA-Z0-9/\\]\)/\\\\\\\\\1/g"`
			fi
			if [ -z "$PATH" ]; then
				PATH="\\\\"
			fi
			echo "$DRIVE:$PATH"
		fi
	fi
done

