#!/usr/bin/perl

use warnings;

BEGIN { $| = 1; print "1..16\n"; }
END {print "not ok 1\n" unless $loaded;}
use X11::GUITest qw/
	:ALL
	:CONST
/;
$loaded = 1;
print "ok 1\n";

# Used for testing below
my $BadWinTitle = 'BadWindowNameNotToBeFound';
my $BadWinId = '898989899';
my @Windows = ();

# FindWindowLike
print "not " unless FindWindowLike(".*");
print "not " unless not FindWindowLike($BadWinTitle);
print "ok 2\n";

# WaitWindowLike
print "not " unless WaitWindowLike(".*");
print "not " unless not WaitWindowLike($BadWinTitle, undef, 1);
print "ok 3\n";

# WaitWindowViewable
print "not " unless WaitWindowViewable(".*");
print "not " unless not WaitWindowViewable($BadWinTitle, undef, 1);
print "ok 4\n";

# ClickWindow

# StartApp
# RunApp
# SetEventSendDelay
# GetEventSendDelay
# SetKeySendDelay
# GetKeySendDelay

# GetWindowName
my $WinName = '';
foreach my $win (FindWindowLike(".*")) {
	$WinName = GetWindowName($win);
	if (defined($WinName)) {
		last;
	}
}
print "not " unless defined($WinName);
print "ok 5\n";

# GetRootWindow
print "not " unless GetRootWindow();
print "ok 6\n";

# GetChildWindows
print "not " unless GetChildWindows(GetRootWindow());
print "ok 7\n";

# MoveMouseAbs
print "not " unless MoveMouseAbs(2, 2);
print "not " unless MoveMouseAbs(1, 1);
print "ok 8\n";

# ClickMouseButton

# SendKeys

# IsWindow
print "not " unless IsWindow(GetRootWindow());
print "not " unless not IsWindow($BadWinId);
print "ok 9\n";

# IsWindowViewable
@Windows = WaitWindowViewable(".*");
print "not " unless IsWindowViewable($Windows[0]);
print "not " unless not IsWindowViewable($BadWinId);
print "ok 10\n";

# MoveWindow
# ResizeWindow
# IconifyWindow
# UnIconifyWindow
# Raise Window
# LowerWindow

# GetInputFocus
print "not " unless GetInputFocus();
print "ok 11\n";

# SetInputFocus

# GetWindowPos
my ($x, $y, $width, $height) = GetWindowPos(GetInputFocus());
print "not " unless (defined($x) and defined($y) and
					 defined($width) and defined($height));
print "ok 12\n";

# GetScreenRes
print "not " unless GetScreenRes();
print "ok 13\n";

# GetScreenDepth
print "not " unless GetScreenDepth();
print "ok 14\n";

# GetMousePos
print "not " unless GetMousePos();
print "ok 15\n";

# IsChild
foreach my $win ( GetChildWindows(GetRootWindow()) ) {
	if (!IsChild(GetRootWindow(), $win)) {
		print "not ";
		last;
	}
}
print "ok 16\n";

# IsKeyPressed
# IsMouseButtonPressed
# QuoteStringForSendKeys
