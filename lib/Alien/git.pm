package Alien::git;

use strict;
use warnings;
use 5.008001;

# ABSTRACT: Find system git
# VERSION

sub cflags {''}
sub libs   {''}
sub bin_dir {()}
sub dynamic_libs {}

sub alien_helper
{
  return {
    git => $ENV{ALIEN_GIT} || 'git',
  }
}

1;
