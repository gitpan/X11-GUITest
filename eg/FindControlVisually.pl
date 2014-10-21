#!/usr/bin/perl
#-----------------------------------------------------------------------------#
# X11::GUITest ($Id: FindControlVisually.pl,v 1.2 2011/01/07 02:24:54 ctrondlp Exp $)
# Notes: Example of script to locate a widget/control visually using an
#        image baseline. 
#-----------------------------------------------------------------------------#

## Pragmas/Directives/Diagnostics ##
use strict;
use warnings;

## Imports (use [MODULE] qw/[IMPORTLIST]/;) ##
use File::Temp qw/:POSIX/;
use Image::SubImageFind qw/FindSubImage/;
use X11::GUITest qw/
	MoveMouseAbs
	ClickMouseButton
	:CONST
/;

## Constants (sub [CONSTANT]() { [VALUE]; }) ##

## Variables (my [SIGIL][VARIABLE] = [INITIALVALUE];) ##

## Core ##
print "$0 : Script Start\n";

print "Locating the control...\n";
# Find the control on-screen using baseline image to compare to
my ($x, $y) = FindScreenObject('/test/but_superscript.png');
if ($x > 0 || $y > 0) {
	print "Found at $x X $y\n";
	#MoveMouseAbs $x, $y;
	#ClickMouseButton M_LEFT;
} else {
	print "Not found\n";
}

print "$0 : Script End (Success)\n";

## Subroutines ##
sub FindScreenObject {
	my $baseline = shift;
	my $maxwait = shift || 30;

	if (!-e $baseline) {
		die("Baseline $baseline image does not exist");
	}

    my $scrfile = GetScreenshot();
	for (my $i = 1; $i <= $maxwait; $i++) {
		# Results may vary, depending on baseline quality and detail, etc.
	    my ($x, $y) = FindSubImage($scrfile, $baseline);
	    if ($x > 0 || $y > 0) {
	    	unlink $scrfile;
			return ($x, $y);
	    }
    	sleep(1);
	}
	unlink $scrfile;
	return (-1,-1);
}

sub GetScreenshot {
	my $file = tmpnam();
	my $cmd = `xwd -root | convert xwd:- $file`;
	return $file;
}
