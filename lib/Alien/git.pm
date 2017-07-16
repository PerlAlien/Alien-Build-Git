package Alien::git;

use strict;
use warnings;
use 5.008001;
use Capture::Tiny qw( capture );
use File::Which qw( which );

# ABSTRACT: Find system git
# VERSION

sub cflags {''}
sub libs   {''}
sub dynamic_libs {}
sub install_type { 'system' }

# IF you are reading the documentation and wondering
# why it says that you need to add bin_dir to your
# PATH, and you are looking at the source here and seeing
# that it just returns an empty list, and wondering
# why?  It is because in the future Alien::git MAY
# support share installs, at which point your code will
# break if you are NOT adding bin_dir to your PATH.
sub bin_dir {()}

sub exe { scalar which $ENV{ALIEN_GIT} || 'git' }

sub version
{
  my($out) = capture {
    system(
      __PACKAGE__->exe,
      '--version',
    );
  };
  
  $out =~ /git version ([0-9\.]+)/
    ? $1
    : 'unknown';
}

sub alien_helper
{
  return {
    git => __PACKAGE__->exe,
  }
}

1;
