package Alien::Build::Plugin::Fetch::Git;

use strict;
use warnings;
use 5.008001;
use Alien::Util qw( version_cmp );
use Alien::Build::Plugin;
use URI;
use URI::file;
use URI::git;
use Path::Tiny qw( path );
use File::Temp qw( tempdir );
use File::chdir;
use Capture::Tiny qw( capture_merged capture_stdout );

# ABSTRACT: Alien::Build plugin to fetch from git
# VERSION

=head1 SYNOPSIS

 use alienfile;
 
 meta->prop->{start_url} = 'git://example.git/foo.git#v0.01';
 plugin 'Fetch::Git';

=head1 DESCRIPTION

This plugin provides a fetch capability for C<git> in L<Alien::Build>.
You can specify a tag or branch with the fragment part of the URL.
Most of the time you won't be using this plugin directly, but will
instead be using L<Alien::git> or L<Alien::Build::Plugin::Download::Git>.

=head1 SEE ALSO

=over 4

=item L<Alien::Build>

=item L<Alien::Build::Git>

=item L<Alien::Builg::Plugin::Download::Git>

=back

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

      if($url =~ /^[a-zA-Z0-9]+:/ && !( $url =~ /^[A-Z]:/i && $^O eq 'MSWin32' ))
      {
        $url = URI->new($url);
      }
      else
      {
        my $tmp = URI::file->new_abs(".");
        if($^O eq 'MSWin32')
        {
          $tmp->host('');
        }
        else
        {
          $tmp->host('localhost');
        }
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
        if(can_branch_clone())
        {
          $build->system('%{git}', 'clone', '--depth' => 1, '--branch', "$tag", "$url");
        }
        else
        {
          $build->system('%{git}', 'clone', "$url");
        }
        die "command failed" if $?;
        my($dir) = path(".")->absolute->children;

        if(can_branch_clone())
        {
          # do nothing
        }
        else
        {
          # mildly prefer the -C version as it will handle spaces in $dir.
          if(can_minus_c())
          {
            $build->system('%{git}', -C => "$dir", 'checkout', $tag);
          }
          else
          {
            $build->system("cd $dir ; %{git} checkout $tag");
          }
          die "command failed" if $?;
        }
        return {
          type     => 'file',
          filename => $dir->basename,
          path     => $dir->stringify,
          protocol => $url->scheme,
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
          protocol => $url->scheme,
        };
      }
    },
  );
}


my $can_minus_c;
sub can_minus_c
{
  unless(defined $can_minus_c)
  {
    require Alien::git;
    my $tmp = path(tempdir( CLEANUP => 1));
    my(undef, $ret) = capture_merged {
      system(Alien::git->exe, -C => $tmp, 'init');
      $?;
    };
    $can_minus_c = !! $? == 0 && -d $tmp->child('.git');
    $tmp->remove_tree;
  }

  $can_minus_c;
}

my $can_branch_clone;
sub can_branch_clone
{
  unless(defined $can_branch_clone)
  {
    require Alien::git;
    if(version_cmp(Alien::git->version, "1.8.3.5") >= 0)
    {
      $can_branch_clone = 1;
    }
    else
    {
      $can_branch_clone = 0;
    }
  }

  $can_branch_clone;
}

1;
