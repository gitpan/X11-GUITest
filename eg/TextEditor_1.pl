#!/usr/bin/perl
#----------------------------------------------------------------------#
# VCS $Id: TextEditor_1.pl,v 1.1 2003/03/31 01:22:23 ctrondlp Exp $
# Notes: Example of interaction with gedit (Text Editor).  Tested with
# 		 version 2.0.2 of the editor application using the English
#		 language.
#----------------------------------------------------------------------#

## Pragmas/Directives/Diagnostics ##
use strict;
use warnings;

## Imports (use [MODULE] qw/[IMPORTLIST]/;) ##
use X11::GUITest qw/
	StartApp
	WaitWindowClose
	WaitWindowViewable
	SendKeys
	ClickWindow
	GetWindowName
/;

## Constants (sub [CONSTANT]() { [VALUE]; }) ##

## Variables (my [SIGIL][VARIABLE] = [INITIALVALUE];) ##
my $GEMainWin = 0;
my $GEAboutWin = 0;


## Core ##

# Start the text editor
StartApp('gedit');
# Wait for it to appear. RegEx: .* = zero or more of any character
( ($GEMainWin) = WaitWindowViewable('Untitled.*gedit') ) or die('Unable to find editor window!');

# Send some text to the editor (TEXT x NUM TIMES)
SendKeys("Hello, how are you today?\n" x 2) or die('Unable to send text to editor!');

# Ensure the window changes its name to include the
# 'modified' word since we sent it text above.
(GetWindowName($GEMainWin) =~ /modified/i) or die('Editor did not switch its title as expected!');

# Open about box (Alt-h, a) and wait for it
SendKeys('%(h)a');
( ($GEAboutWin) = WaitWindowViewable('About gedit') ) or die('Unable to find about box!');

# We could use an easier method (SendKeys) to close the
# about box, but we're going to show usage of ClickWindow
# with hard-coded offsets (Ewww!) instead.  The position
# offsets below allow the OK button of the about box to
# be clicked.
ClickWindow($GEAboutWin, 260, 260) or die('Unable to tell about box to close!');

# To be safe, ensure about box is closed before we continue
WaitWindowClose($GEAboutWin);

# Now close the editor using menu short-cuts
SendKeys('%(f)q');

# Wait for confirmation window to appear
WaitWindowViewable('Question') or die('Unable to find confirmation (Question) window!');

# Select DoN't Save
SendKeys('%(n)') or die('Unable to select Don\'t Save button!');

# Ensure main window gets closed
WaitWindowClose($GEMainWin) or die('The editor window did not close!');


## Subroutines ##
