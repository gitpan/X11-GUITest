#!/usr/bin/perl
# X11::GUITest ($Id: test.t,v 1.21 2004/02/14 15:08:50 ctrondlp Exp $)
# Note: Functions that might be intrusive are not checked

BEGIN {
	# Is X running? 
	if (length $ENV{'DISPLAY'}) {
		# It should be, so plan on running the tests.
		$| = 1; print "1..23\n";
	} else {
		warn "X11::GUITest - X Windows not running or DISPLAY not set.\n"; 
		exit(0);
	} 
}
END {
	print "not ok 1\n" unless $loaded;
}
use X11::GUITest qw/
	:ALL
/;
$loaded = 1;
print "ok 1\n";

use strict;
use warnings;

# Used for testing below
my $BadWinTitle = 'BadWindowNameNotToBeFound';
my $BadWinId = '898989899';
my @Windows = ();


# FindWindowLike
print "not " unless FindWindowLike(".*");
print "not " unless not FindWindowLike($BadWinTitle);
print "ok 2\n";

# WaitWindowClose
print "not " unless WaitWindowClose($BadWinId);
print "ok 3\n";

# WaitWindowLike
print "not " unless WaitWindowLike(".*");
print "not " unless not WaitWindowLike($BadWinTitle, undef, 1);
print "ok 4\n";

# WaitWindowViewable
print "not " unless WaitWindowViewable(".*");
print "not " unless not WaitWindowViewable($BadWinTitle, undef, 1);
print "ok 5\n";

# ClickWindow
# StartApp
# RunApp
# SetEventSendDelay
# GetEventSendDelay
# SetKeySendDelay
# GetKeySendDelay

# GetWindowName
my $WinName = ''; 
# Note: Only worry about windows that have a name
# RegExp: ".+" = one or more characters
foreach my $win (FindWindowLike(".+")) {
	# If call fails, WinName will be set to undef
	$WinName = GetWindowName($win);
	if (not defined($WinName)) {
		last;
	}
}
print "not " unless defined($WinName);
print "ok 6\n";

# SetWindowName

# GetRootWindow
print "not " unless GetRootWindow();
print "ok 7\n";

# GetChildWindows
print "not " unless GetChildWindows(GetRootWindow());
print "ok 8\n";

# MoveMouseAbs
print "not " unless MoveMouseAbs(2, 2);
print "not " unless MoveMouseAbs(1, 1);
print "ok 9\n";

# ClickMouseButton

# SendKeys

# IsWindow
print "not " unless IsWindow(GetRootWindow());
print "not " unless not IsWindow($BadWinId);
print "ok 10\n";

# IsWindowViewable
@Windows = WaitWindowViewable(".*");
print "not " unless IsWindowViewable($Windows[0]);
print "not " unless not IsWindowViewable($BadWinId);
print "ok 11\n";

# MoveWindow
# ResizeWindow
# IconifyWindow
# UnIconifyWindow
# Raise Window
# LowerWindow

# SetInputFocus

# GetInputFocus
print "not " unless GetInputFocus();
print "ok 12\n";

# GetWindowPos
my ($x, $y, $width, $height) = GetWindowPos(GetRootWindow());
print "not " unless (defined($x) and defined($y) and
					 defined($width) and defined($height));
print "ok 13\n";

# GetScreenRes
print "not " unless GetScreenRes();
print "ok 14\n";

# GetScreenDepth
print "not " unless GetScreenDepth();
print "ok 15\n";

# GetMousePos
print "not " unless GetMousePos();
print "ok 16\n";

# IsChild
print "not " unless ( @Windows = GetChildWindows(GetRootWindow()) );
# Note: Limiting check to a certain number of windows (10)
foreach my $win ( splice(@Windows, 0, 10) ) {
	if (!IsChild(GetRootWindow(), $win)) {
		print "not ";
		last;
	}
}
print "ok 17\n";

# IsKeyPressed
# IsMouseButtonPressed

# QuoteStringForSendKeys
print "not " unless defined( QuoteStringForSendKeys('~!@#$%^&*()_+') );
print "ok 18\n";
print "not " unless not defined ( QuoteStringForSendKeys(undef) );
print "ok 19\n";

# GetParentWindow
print "not " unless not GetParentWindow(GetRootWindow());
print "ok 20\n";
print "not " unless GetParentWindow($Windows[0]);
print "ok 21\n";

# GetWindowFromPoint
# Note: Using invalid window position of (-1500 x -1500) for testing. 
print "not " unless not GetWindowFromPoint(-1500, -1500);
print "ok 22\n";
print "not " unless GetWindowFromPoint(0, 0);
print "ok 23\n";

# PressKey
# ReleaseKey
# PressReleaseKey
# PressMouseButton
# ReleaseMouseButton

