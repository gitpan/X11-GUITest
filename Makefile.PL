#!/usr/bin/perl

use strict;
use warnings;

use ExtUtils::MakeMaker;


# If executable, call MakeDocs.sh to ensure GUITest.POD is
# created to use for man3 page generation.
if (-x 'MakeDocs.sh') {
	system('./MakeDocs.sh');
}

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	'NAME' => 'X11::GUITest',
	($] ge '5.005') ? (
		'AUTHOR' => 'Dennis K. Paulsen',
		'ABSTRACT' => 'Collection of functions for X11 GUI testing/interaction.',
	) : (),
	'VERSION_FROM' => 'GUITest.pm', # Finds $VERSION
	'MAN3PODS' => (-r 'GUITest.POD') ? {'GUITest.POD' => '$(INST_MAN3DIR)/X11::GUITest.$(MAN3EXT)'} : {},
	'LIBS'  => ['-L/usr/X11R6/lib -lX11 -lXtst'], # e.g., '-lm'
	'DEFINE' => '-DNDEBUG', # e.g., '-DHAVE_SOMETHING'
	'INC'   => '-I/usr/X11R6/include', # e.g., '-I/usr/include/other'
	'clean' => {FILES => 'GUITest.POD'},
	#'CCFLAGS' => '-Werror', 
	#'OPTIMIZE' => '-Od'
);
