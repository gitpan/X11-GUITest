#!/usr/bin/perl
# X11::GUITest ($Id: Makefile.PL,v 1.22 2011/01/09 19:50:14 ctrondlp Exp $)

use strict;
use warnings;
use ExtUtils::MakeMaker;

# Disable Automated Testing in certain cases
if (defined $ENV{'AUTOMATED_TESTING'} && $ENV{'AUTOMATED_TESTING'}) {
	if (!defined($ENV{'DISPLAY'}) || not length($ENV{'DISPLAY'})) {
		exit(0);
	}
}

# Write core documentation and the POD that Makefile uses.
WriteDocumentation();

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	'NAME' => 'X11::GUITest',
	($] ge '5.005') ? (
		'AUTHOR' => 'Dennis K. Paulsen <ctrondlp@cpan.org>',
		'ABSTRACT' => 'Collection of functions for X11 GUI testing/interaction.',
	) : (),
	'VERSION_FROM' => 'GUITest.pm', # Finds $VERSION
	($] lt '5.008') ? (
		'INST_MAN3DIR' => './blib/man3',
		'MAN3EXT' => '3pm'
	) : (),
	'MAN3PODS' => (-r 'X11-GUITest.POD~') ? {'X11-GUITest.POD~' => '$(INST_MAN3DIR)/X11::GUITest.$(MAN3EXT)'} : {},
	'LIBS'  => ['-L/usr/X11R6/lib -L/usr/X/lib -lXtst -lXext -lX11'], # e.g., '-lm'
	# To work around an incompatibility between the XTest and the Xinerama
	# (X server) extensions, use "-DX11_GUITEST_USING_XINERAMA".
	'DEFINE' => '-DNDEBUG -DX11_GUITEST_ALT_L_FALLBACK_META_L', # e.g., '-DHAVE_SOMETHING'
	'INC'   => '-I/usr/X11R6/include -I/usr/X/include', # e.g., '-I/usr/include/other'
	'clean' => {FILES => 'X11-GUITest.POD~'},
	'CCFLAGS' => '-Wall',
	'OBJECT' => 'GUITest$(OBJ_EXT) KeyUtil$(OBJ_EXT)',
	'OPTIMIZE' => '-O2'
);


# Subroutine: WriteDocumentation 
# Description: This function is implemented to combine the
#			   files containing POD, generate the documentation
#			   in HTML/plain-text formats, and support the
#			   Makefile's MAN3 transformation/installation.
sub WriteDocumentation {
	my $podfile = 'X11-GUITest.POD~';
	
	# Combine POD containing files into one.  Don't love
	# the system() calls, but acceptable as short-term.
	system("cat GUITest.pm >$podfile");
	system("cat GUITest.xs >>$podfile");

	# Check POD
	if ( system("podchecker $podfile &>/dev/null") != 0 ) {
		print "POD validation failed!  Documentation will not be written.\n";
		return(0);	
	}
	
	# Generate Text and HTML documents
	print "Writing documentation for X11::GUITest\n";
	system("pod2text $podfile docs/X11-GUITest.txt");
	system("pod2html --infile=$podfile --outfile=docs/X11-GUITest.html");

	# If symlink subroutine is supported, create the README link
	if ( eval {symlink('', ''); 1} ) {
		symlink('docs/X11-GUITest.txt', 'README');
	}

	# Clean up misc. files.  Leaving X11-GUITest.POD~ around for
	# Makefile use
	unlink <pod*.x??>;
	unlink <pod*.tmp>;
	
	return(1);	
}

