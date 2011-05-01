#!/usr/bin/perl
# X11::GUITest ($Id: Makefile.PL,v 1.25 2011/04/29 02:08:27 ctrondlp Exp $)

use strict;
use warnings;
use ExtUtils::MakeMaker;


# Optional building of additional doc formats.
if (defined($ARGV[0]) && $ARGV[0] eq 'docs') {
	BuildDocumentation();
}

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
	'MAN3PODS' => {'GUITest.pm' => '$(INST_MAN3DIR)/X11::GUITest.$(MAN3EXT)'},
	'LIBS'  => ['-L/usr/X11R6/lib -L/usr/X/lib -lXtst -lXext -lX11'], # e.g., '-lm'
	# To work around an incompatibility between the XTest and the Xinerama
	# (X server) extensions, use "-DX11_GUITEST_USING_XINERAMA".
	'DEFINE' => '-DNDEBUG -DX11_GUITEST_ALT_L_FALLBACK_META_L', # e.g., '-DHAVE_SOMETHING'
	'INC'   => '-I/usr/X11R6/include -I/usr/X/include', # e.g., '-I/usr/include/other'
	'CCFLAGS' => '-Wall',
	'OBJECT' => 'GUITest$(OBJ_EXT) KeyUtil$(OBJ_EXT)',
	'OPTIMIZE' => '-O2'
);


# Subroutine: BuildDocumentation 
# Description: This function is implemented to generate the
#			   documentation in HTML/plain-text formats. 
sub BuildDocumentation {
	my $podfile = 'GUITest.pm';

	# Check POD
	if ( system("podchecker $podfile &>/dev/null") != 0 ) {
		print "POD validation failed!  Documentation will not be written.\n";
		return(0);	
	}
	
	# Generate Text and HTML documents
	print "Writing documentation for X11::GUITest\n";
	system("pod2text $podfile docs/X11-GUITest.txt");
	system("pod2html --infile=$podfile --outfile=docs/X11-GUITest.html");
	system("cp -f docs/X11-GUITest.txt README");

	# Clean up misc. files.  Leaving X11-GUITest.POD~ around for
	# Makefile use
	unlink <pod*.x??>;
	unlink <pod*.tmp>;
	
	return(1);	
}

