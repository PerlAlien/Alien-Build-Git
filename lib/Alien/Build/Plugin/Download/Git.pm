package Alien::Build::Plugin::Download::Git;

use strict;
use warnings;
use 5.008001;
use Alien::Build::Plugin;
use Alien::Build::Plugin::Fetch::Git;
use Alien::Build::Plugin::Prefer::SortVersions;
use Alien::Build::Plugin::Extract::Directory;
use PerlX::Maybe qw( maybe );

# ABSTRACT: Alien::Build plugin to download from git
# VERSION

has filter => undef;
has version => undef;

sub init
{
  my($self, $meta) = @_;
  
  $meta->add_requires('configure' => 'Alien::Build::Plugin::Download::Git'        => '0.01');
  $meta->add_requires('configure' => 'Alien::Build::Plugin::Fetch::Git'           => '0.01');
  $meta->add_requires('configure' => 'Alien::Build::Plugin::Prefer::SortVersions' => '0.65');
  $meta->add_requires('configure' => 'Alien::Build::Plugin::Extract::Directory'   => '0.65');

  my $fetch = Alien::Build::Plugin::Fetch::Git->new;
  $fetch->init($meta);
  
  my $prefer = Alien::Build::Plugin::Prefer::SortVersions->new(
    maybe filter  => $self->filter,
    maybe version => $self->version,
  );
  
  $prefer->init($meta);
  
  my $extract = Alien::Build::Plugin::Extract::Directory->new;
  $extract->init($meta);

}

1;
