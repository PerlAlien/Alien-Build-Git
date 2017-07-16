package Alien::Build::Plugin::Fetch::Git;

use strict;
use warnings;
use 5.008001;
use Alien::Build::Plugin;
use URI;
use URI::file;
use URI::git;
use Path::Tiny qw( path );
use File::Temp qw( tempdir );
use File::chdir;
use Capture::Tiny qw( capture_merged );

# ABSTRACT: Alien::Build plugin to fetch from git
# VERSION

=head1 SYNOPSIS

 use alienfile;
 
 meta->prop->{start_url} = 'git://
 plugin 'Fetch::Git';

=head1 DESCRIPTION

=cut

sub init
{
  my($self, $meta) = @_;
  
  $meta->add_requires('share' => 'Alien::git' => 0);
  
  $meta->register_hook(
    fetch => sub {
      my($build, $url) = @_;

      $url ||= $build->meta_prop->{start_url};
      die "no default URL provided!" unless defined $url;
      
      if($url =~ /^[a-zA-Z0-9]+:/)
      {
        $url = URI->new($url);
      }
      else
      {
        my $tmp = URI::file->new_abs(".");
        $tmp->host('localhost');
        if($url =~ s/#(.*)$//)
        {
          $tmp->fragment($1);
        }
        $tmp->path($url);
        $url = $tmp;
      }
      
      my $exe = Alien::git->exe;

      if(defined $url->fragment)
      {
        local $CWD = tempdir( CLEANUP => 1 );
        my($tag) = $url->fragment;
        $url->fragment(undef);
        $build->system('%{git}', 'clone', "$url");
        die "command failed" if $?;
        my($dir) = path(".")->absolute->children;
        $build->system('%{git}', -C => "$dir", 'checkout', $tag);
        die "command failed" if $?;
        return {
          type     => 'file',
          filename => $dir->basename,
          path     => $dir->stringify,
        };
      }
      else
      {
        $build->log("fetching tags from $url");
        my($output, $error) = capture_merged {
          $build->system('%{git}', 'ls-remote', '--tags', "$url");
          $?;
        };

        if($error)
        {
          print $output;
          die "command failed";
        }

        my @tags = sort
                   grep { defined $_ }
                   map { m{refs/tags/(.*)$} ? $1 : undef }
                   split /\n\r?/, $output;
        
        return {
          type => 'list',
          list => [
            map { 
              my $tag = $_;
              my $url = $url->clone;
              $url->fragment($tag);
              my %h = (
                filename => $tag,
                url      => "$url",
              );
              \%h;
            } @tags
          ],
        };
      }
    },
  );
}

1;
