#!/bin/sh

# Check POD
podchecker GUITest.pm GUITest.xs &>/dev/null
if [ $? -ne 0 ] 
then
	echo "POD validation failed!  Documentation will not be written."
	exit 1
fi

# Combine the POD in the correct order.
cat GUITest.pm >GUITest.POD
cat GUITest.xs >>GUITest.POD

# Generate Documents
echo 'Writing Documentation for X11::GUITest' 
pod2text GUITest.POD docs/X11-GUITest.txt
pod2html --infile=GUITest.POD --outfile=docs/X11-GUITest.html

# Make symlink for README
ln -fs docs/X11-GUITest.txt README

# Clean Up.  Leaving GUITest.POD around for Makefile to use
rm -f pod*.x??

