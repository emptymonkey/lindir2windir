#!/bin/sh

# lindir2windir.sh
#		-	ln -s lindir2windir.sh windir2lindir.sh
#
# Super simple POSIX shell script to use in WSL for translating path names
# from one environment to the other.
#

# At one point, far below, the script suddenly couldn't find sed anymore
# even though it had used it half a dozen times up to that point.
# Full path fixed it. Obviously I have more to learn about environment
# mangling.
SED=`which sed`
TR=`which tr`
ECHO=`which echo`
REALPATH=`which realpath`
GREP=`which grep`

if [ -z $SED -o -z $TR -o -z $ECHO -o -z $REALPATH ]; then
	echo "How am I even here?!"
	exit 1
fi

usage() {
	$ECHO "Usage: $0 [-e] [-h]" 1>&2
	$ECHO "\t-e:\tEscape mode. All [^a-zA-Z0-9] characters are escaped."
	$ECHO "\t-h:\tThis message."
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
PROGRAM=`$ECHO $0 | $SED "s/.*\///"`

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
		DRIVE=`$ECHO $i | $SED "s/^\([A-Z]\).*/\1/" | $TR '[:upper:]' '[:lower:]'`
		PATH=`$ECHO $i | $SED "s/^[A-Z]://"	| $SED "s/\\\\\\/\//g" | $SED "s/\([^a-zA-Z0-9/]\)/\\\\\\\\\1/g"`
		$ECHO "/mnt/$DRIVE$PATH"

	# Linux to Windows mode.
else
	$ECHO $i | $GREP '^\.' 1>/dev/null
	if [ $? -eq 0 ]; then
		i=`$REALPATH "$i"`
	fi
	$ECHO $i | $GREP '/mnt/[a-z]/' 1>/dev/null
	if [ $? -eq 0 ]; then
		DRIVE=`$ECHO $i | $SED "s/^\/mnt\/\([a-z]\).*/\1/" | $TR '[:lower:]' '[:upper:]'`
		PATH=`$ECHO $i | $SED "s/^\/mnt\/[a-z]//"`
		if [ $ESCAPE -eq 1 ]; then
			PATH=`$ECHO $PATH | $SED "s/\([^a-zA-Z0-9/]\)/\\\\\\\\\1/g"`
		fi
		$ECHO "$DRIVE:$PATH"
	fi
	fi
done

