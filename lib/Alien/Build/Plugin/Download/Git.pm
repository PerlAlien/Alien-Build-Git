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

=head1 SYNOPSIS

 use alienfile;
 
 meta->prop->{start_url} = 'http://example.com/project-foo.git';
 plugin 'Download::Git' =>(
   version => qr/^v([0-9\.]+)$/,
 );

=head1 DESCRIPTION

This plugin downloads projects using git and selects the appropriate tag for
building.  Typically you want to build using the most recent production tag,
not just whatever C<master> happens to be at the moment.

This plugin uses these plugins to do the heavy lifting:

=over 4

=item L<Alien::Build::Plugin::Fetch::Git>

=item L<Alien::Build::Plugin::Prefer::SortVersions>

=item L<ALien::Build::Plugin::Extract::Directory>

=back

=head1 PROPERTIES

=head2 filter

his is a regular expression that lets you filter out tags that you do not
want to consider downloading.  For example, if the tags included name such as

 v1.0.0
 v1.1.2
 old-feature-not-included
 something-else/entirely

You could specify a filter of C<qr/^v[0-9\.]+$/> to make sure only tags that
appeared to be a version number are included.

=head2 version

Regular expression to parse out the version from tags.  The regular expression
should store the result in C<$1>.

In the previous example you might use the regular expression C<qr/^v([0-9\.]+/>.

=head1 SEE ALSO

=over 4

=item L<Alien>

=item L<Alien::Build>

=item L<Alien::Build::Git>

=item L<Alien::git>

=back

=cut

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
