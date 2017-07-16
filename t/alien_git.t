use Test2::V0 -no_srand => 1;
use Test::Alien;
use Alien::git;

alien_ok 'Alien::git';

isnt( Alien::git->version, 'unknown', 'version is not unknown' );

my $exe = Alien::git->exe;

my $run = run_ok([$exe, '--version'])
  ->success;

if(Alien::git->version eq 'unknown')
{
  $run->diag;
}
else
{
  $run->note;
}

done_testing
