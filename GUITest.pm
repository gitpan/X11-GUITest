# X11::GUITest ($Id: GUITest.pm,v 1.37 2003/12/13 17:37:04 ctrondlp Exp $) 
#  
# Copyright (c) 2003-2004  Dennis K. Paulsen, All Rights Reserved.
# Email: ctrondlp@users.sourceforge.net
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
#

=head1 NAME

X11::GUITest - Provides GUI testing/interaction facilities.

Developed by Dennis K. Paulsen

=head1 VERSION

0.19

Please consult 'docs/Changes' for the list of changes between
module revisions.

=head1 DESCRIPTION

This Perl package is intended to facilitate the testing of GUI applications
by means of user emulation.  It can be used to test/interact with GUI
applications; which have been built upon the X library or toolkits
(i.e., GTK+, Xt, Qt, Motif, etc.) that "wrap" the X library's functionality.

=head1 DEPENDENCIES

An X server with the XTest extensions enabled.  This seems to be the
norm.  If it is not enabled, it usually can be by modifying the X
server configuration (i.e., XF86Config).

Also, the standard DISPLAY environment variable is utilized to determine
the host, display, and screen to work with.  By default it is usually set
to ":0.0" for the localhost.  However, by altering this variable one can
interact with applications under a remote host's X server.  To change this 
from a terminal window, one can utilize the following basic syntax: 
export DISPLAY=<hostname-or-ipaddress>:<display>.<screen>  Please note that
under most circumstances, xhost will need to be executed properly on the remote
host as well.

=head1 INSTALLATION

  perl Makefile.PL
  make
  make test
  make install

=head1 SYNOPSIS

For additional examples, please look under the 'eg/'
sub-directory from the installation folder.

  use X11::GUITest qw/
    StartApp
    WaitWindowViewable
    SendKeys
  /;

  # Start gedit application
  StartApp('gedit');

  # Wait for application window to come up and become viewable. 
  my ($GEditWinId) = WaitWindowViewable('gedit');
  if (!$GEditWinId) {
    die("Couldn't find gedit window in time!");
  }

  # Send text to it
  SendKeys("Hello, how are you?\n");

  # Close Application (Alt-f, q).
  SendKeys('%(f)q');

  # Handle gedit's Question window if it comes up when closing.  Wait
  # at most 5 seconds for it.
  if (WaitWindowViewable('Question', undef, 5)) {
    # DoN't Save (Alt-n)
    SendKeys('%(n)');
  }

=cut

package X11::GUITest;

use strict;
use warnings;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

require Exporter;
require DynaLoader;
#require AutoLoader;

@ISA = qw(Exporter DynaLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw(
    
);

@EXPORT_OK = qw(
	ClickMouseButton
	ClickWindow
	FindWindowLike
	GetChildWindows
	GetEventSendDelay
	GetInputFocus
	GetKeySendDelay
	GetMousePos
	GetParentWindow
	GetRootWindow
	GetScreenDepth
	GetScreenRes
	GetWindowFromPoint
	GetWindowName
	GetWindowPos
	IconifyWindow
	IsChild
	IsKeyPressed
	IsMouseButtonPressed
	IsWindow
	IsWindowViewable
	LowerWindow
	MoveMouseAbs
	MoveWindow
	PressKey
	PressMouseButton
	PressReleaseKey
	QuoteStringForSendKeys
	RaiseWindow
	ReleaseKey
	ReleaseMouseButton
	ResizeWindow
	RunApp
	SendKeys
	SetEventSendDelay
	SetInputFocus
	SetKeySendDelay
	SetWindowName
	StartApp
	UnIconifyWindow
	WaitWindowClose
	WaitWindowLike
	WaitWindowViewable
);

# Tags (:ALL, etc.)
%EXPORT_TAGS = (
	'ALL' => \@EXPORT_OK,
	'CONST' => [qw(DEF_WAIT M_LEFT M_MIDDLE M_RIGHT M_BTN1 M_BTN2 M_BTN3 M_BTN4 M_BTN5)],
);

Exporter::export_ok_tags(keys %EXPORT_TAGS);

$VERSION = '0.19';

# Module Constants 
sub DEF_WAIT() { 10; }
# Mouse Buttons
sub M_BTN1() { 1; }
sub M_BTN2() { 2; }
sub M_BTN3() { 3; }
sub M_BTN4() { 4; }
sub M_BTN5() { 5; }
sub M_LEFT() { M_BTN1; }
sub M_MIDDLE() { M_BTN2; }
sub M_RIGHT() { M_BTN3; }

# Module Variables


bootstrap X11::GUITest $VERSION;

=head1 FUNCTIONS

Parameters enclosed within [] are optional.  

If there are multiple optional parameters available for a function
and you would like to specify the last one, for example, you can
utilize undef for those parameters you don't specify.

REGEX in the documentation below denotes an item that is treated as 
a regular expression.  For example, the regex "^OK$" would look for
an exact match for the word OK.


=over 8

=item FindWindowLike TITLEREGEX [, WINDOWIDSTARTUNDER]

Finds the window Ids of the windows matching the specified title regex.  
Optionally one can specify the window to start under; which would allow
one to constrain the search to child windows of that window.

An array of window Ids is returned for the matches found.  An empty
array is returned if no matches were found.

  my @WindowIds = FindWindowLike('gedit');
  # Only worry about first window found
  my ($WindowId) = FindWindowLike('gedit');

=back

=cut

sub FindWindowLike {
	my $titlerx = shift;
	my $start = shift || GetRootWindow();
	my $winname = '';
	my @wins = ();

	# Match the starting window???
	$winname = GetWindowName($start) || '';
	if ($winname =~ /$titlerx/i) {
		push @wins, $start;
	}
	
	# Match a child window?
	foreach my $child (GetChildWindows($start)) {
		my $winname = GetWindowName($child) || '';
		if ($winname =~ /$titlerx/i) {
			push @wins, $child;
		}
	}
	return(@wins);
}


=over 8

=item WaitWindowLike TITLEREGEX [, WINDOWIDSTARTUNDER] [, MAXWAITINSECONDS]

Waits for a window to come up that matches the specified title regex.  
Optionally one can specify the window to start under; which would allow
one to constrain the search to child windows of that window.  

One can optionally specify an alternative wait amount in seconds.  A
window will keep being looked for that matches the specified title regex
until this amount of time has been reached.  The default amount is defined
in the DEF_WAIT constant available through the :CONST export tag.

If a window is going to be manipulated by input, WaitWindowViewable is the
more robust solution to utilize.

An array of window Ids is returned for the matches found.  An empty
array is returned if no matches were found.

  my @WindowIds = WaitWindowLike('gedit');
  # Only worry about first window found
  my ($WindowId) = WaitWindowLike('gedit');

  WaitWindowLike('gedit') or die("gedit window not found!");

=back

=cut

sub WaitWindowLike {
	my $titlerx = shift;
	my $start = shift || GetRootWindow();
	my $wait = shift || DEF_WAIT;
	my @wins = ();

	# For each second we $wait, look for window title
	# twice (2 lookups * 500ms = ~1 second).
	for (my $i = 0; $i < ($wait * 2); $i++) {
		my @wins = FindWindowLike($titlerx, $start);
		if (@wins) {
			return(@wins);
		}
		# Wait 500 ms in order not to bog down the system.  If one 
		# changes this, the ($wait * 2) above will want to be changed
		# in order to represent seconds correctly.
		select(undef, undef, undef, 0.50);
	}	
	# Nothing
	return(@wins);
}


=over 8

=item WaitWindowViewable TITLEREGEX [, WINDOWIDSTARTUNDER] [, MAXWAITINSECONDS]

Similar to WaitWindow, but only recognizes windows that are viewable.  When GUI
applications are started, their window isn't necessarily viewable yet, let alone
available for input, so this function is very useful.

Likewise, this function will only return an array of the matching window Ids for
those windows that are viewable.  An empty array is returned if no matches were
found.

=back

=cut

sub WaitWindowViewable {
	my $titlerx = shift;
	my $start = shift || GetRootWindow();
	my $wait = shift || DEF_WAIT;
	my @wins = ();

	# For each second we $wait, look for window title
	# twice (2 lookups * 500ms = ~1 second).
	for (my $i = 0; $i < ($wait * 2); $i++) {
		# Find windows, but recognize only those that are viewable
		foreach my $win (FindWindowLike($titlerx, $start)) {
			if (IsWindowViewable($win)) {
				push @wins, $win;
			}
		}
		if (@wins) {
			return(@wins);
		}
		# Wait 500 ms in order not to bog down the system.  If one 
		# changes this, the ($wait * 2) above will want to be changed
		# in order to represent seconds correctly.
		select(undef, undef, undef, 0.50);
	}	
	# Nothing
	return(@wins);
}


=over 8

=item WaitWindowClose WINDOWID [, MAXWAITINSECONDS]

Waits for the specified window to close.

One can optionally specify an alternative wait amount in seconds. The
window will keep being checked to see if it has closed until this amount
of time has been reached.  The default amount is defined in the DEF_WAIT
constant available through the :CONST export tag.

zero is returned if window is not gone, non-zero if it is gone.

=back

=cut

sub WaitWindowClose {
	my $win = shift;
	my $wait = shift || DEF_WAIT;

	# For each second we $wait, check window Id 
	# twice (2 lookups * 500ms = ~1 second).
	for (my $i = 0; $i < ($wait * 2); $i++) {
		if (not IsWindow($win)) {
			# Success, window isn't recognized
			return(1);
		}
		# Wait 500 ms in order not to bog down the system.  If one 
		# changes this, the ($wait * 2) above will want to be changed
		# in order to represent seconds correctly.
		select(undef, undef, undef, 0.50);
	}
	# Failure
	return(0);
}


=over 8

=item ClickWindow WINDOWID [, X Offset] [, Y Offset] [, Button]

Clicks on the specified window with the mouse.

Optionally one can specify the X offset and Y offset.  By default,
the top left corner of the window is clicked on, with these two
parameters one can specify a different position to be clicked on.

One can also specify an alternative button.  The default button is
M_LEFT, but M_MIDDLE and M_RIGHT may be specified too.  Also,
you could use the logical Id for the button: M_BTN1, M_BTN2, M_BTN3,
M_BTN4, M_BTN5.  These are all available through the :CONST export
tag.

zero is returned on failure, non-zero for success

=back

=cut

sub ClickWindow {
	my $win = shift;
	my $x_offset = shift || 0;
	my $y_offset = shift || 0;
	my $button = shift || M_LEFT;

	my ($x, $y) = GetWindowPos($win);
	if (!defined($x) or !defined($y)) {
		return(0);
	}
	if (!MoveMouseAbs($x + $x_offset, $y + $y_offset)) {
		return(0);
	}
	if (!ClickMouseButton($button)) {
		return(0);
	}
	return(1);
}


=over 8

=item GetWindowFromPoint X, Y 

Returns the window that is at the specified point.

zero is returned if there are no matches (i.e., off screen).

=back

=cut

sub GetWindowFromPoint {
	my $x = shift;
	my $y = shift;
	my $lastmatch = 0;

	# Note: Windows are returned in current stacking order, therefore
	# the last match should be the top-most window.	
	foreach my $win ( GetChildWindows(GetRootWindow()) ) {
		my ($w_x1, $w_y1, $w_w, $w_h) = GetWindowPos($win);
		my $w_x2 = ($w_x1 + $w_w);
		my $w_y2 = ($w_y1 + $w_h);
		# Is window position invalid?
		if ($w_x1 < 0 || $w_y1 < 0) {
			next;
		}
		# Does window match our point?
		if ($x >= $w_x1 && $x <= $w_x2 && $y >= $w_y1 && $y <= $w_y2) {
			$lastmatch = $win;
		}
	}
	return($lastmatch);
}


=over 8

=item IsChild PARENTWINDOWID, WINDOWID

Determines if the specified window is a child of the
specified parent.

zero is returned for false, non-zero for true.

=back

=cut

sub IsChild {
	my $parent = shift;
	my $win = shift;

	foreach my $child ( GetChildWindows($parent) ) {
		if ($child == $win && $child != $parent) {
			return(1);
		}
	}
	return(0);
}


=over 8

=item QuoteStringForSendKeys STRING

Quotes {} characters in the specified string that would be interpreted
as having special meaning if sent to SendKeys directly.  This function
would be useful if you had a text file in which you wanted to use each
line of the file as input to the SendKeys function, but didn't want
any special interpretation of the characters in the file.

Returns the quoted string, undef is returned on error.

  # Quote  ~, %, etc.  as  {~}, {%}, etc for literal use in SendKeys. 
  SendKeys( QuoteStringForSendKeys('Hello: ~%^(){}+') );

=back

=cut

sub QuoteStringForSendKeys {
	my $str = shift or return(undef);

	# Quote {} special characters (^, %, (, {, etc.)
	$str =~ s/(\^|\%|\+|\~|\(|\)|\{|\})/\{$1\}/gm;
	
	return($str);
}


=over 8

=item StartApp COMMANDLINE

Uses the shell to execute a program.  A primative method is used
to detach from the shell, so this function returns as soon as the
program is called.  Useful for starting GUI applications and then
going on to work with them.

zero is returned on failure, non-zero for success

  StartApp('gedit');

=back

=cut

sub StartApp {
	my $cmdline = shift;

	# Add ampersand if not present to detach program from shell, allowing
	# this function to return before application is finished running.
	# RegExp: [&][zero or more whitespace][anchor, nothing to follow whitespace]
	if ($cmdline !~ /\&\s*$/) {
		$cmdline .= ' &'; 
	}
	local $! = 0;
	system($cmdline);

	# Limited to catching specific problems due to detachment from shell
	return( (length($!) == 0) );
}


=over 8

=item RunApp COMMANDLINE

Uses the shell to execute a program until its completion.

Return value will be application specific, however -1 is returned
to indicate a failure in starting the program.

  RunApp('/work/myapp');

=back

=cut

sub RunApp {
	my $cmdline = shift;
	return( system($cmdline) );
}


=over 8

=item ClickMouseButton BUTTON

Clicks the specified mouse button.  Available mouse buttons
are: M_LEFT, M_MIDDLE, M_RIGHT.  Also, you could use the logical
Id for the button: M_BTN1, M_BTN2, M_BTN3, M_BTN4, M_BTN5.  These
are all available through the :CONST export tag.

zero is returned on failure, non-zero for success.

=back

=cut

sub ClickMouseButton {
	my $button = shift;

	if (!PressMouseButton($button) ||
		!ReleaseMouseButton($button)) {
		return(0);
	}
	return(1);
}

# Subroutine: INIT
# Description: Used to initialize the underlying mechanisms
#			   that this package utilizes. 
# Note: Perl idiom not to return values for this subroutine.
sub INIT {
	InitGUITest();
}

# Subroutine: END
# Description: Used to deinitialize the underlying mechanisms
#			   that this package utilizes.
# Note: Perl idiom not to return values for this subroutine.
sub END {
	DeInitGUITest();
}

=over 8

=item <Documentation Continued...>

=back

=cut

# Autoload methods go after __END__, and are processed by the autosplit program.

# Return success
1;
__END__
