package Alien::Build::Plugin::Download::Git;

use strict;
use warnings;
use 5.008001;
use Alien::Build::Plugin;
use Alien::Build::Plugin::Fetch::Git;
use Alien::Build::Plugin::Prefer::SortVersions;
use PerlX::Maybe qw( maybe );

# ABSTRACT: Alien::Build plugin to download from git
# VERSION

has filter => undef;
has version => undef;

sub init
{
  my($self, $meta) = @_;
  
  $meta->add_requires('configure' => 'Alien::Build::Plugin::Download::Git' => 0);
  $meta->add_requires('configure' => 'Alien::Build::Plugin::Fetch::Git' => 0);
  $meta->add_requires('configure' => 'Alien::Build::Plugin::Prefer::SortVersions' => 0);

  my $fetch = Alien::Build::Plugin::Fetch::Git->new;
  $fetch->init($meta);
  
  my $prefer = Alien::Build::Plugin::Prefer::SortVersions->new(
    maybe filter  => $self->filter,
    maybe version => $self->version,
  );
  
  $prefer->init($meta);
}

1;
