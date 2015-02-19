
use strict;
use warnings;

use Test::More 0.96;
use Test::Fatal;
use FindBin;

{
  my $guard;
  use Test::File::ShareDir
    -root  => "$FindBin::Bin/02_files",
    -share => { -dist => { 'Example-Dist' => 'share', } },
    -guard => \$guard;

  use File::ShareDir qw( dist_dir dist_file );

  is(
    exception {
      note dist_dir('Example-Dist');
    },
    undef,
    'dist_dir doesn\'t bail as it finds the dir'
  );

  is(
    exception {
      note dist_file( 'Example-Dist', 'afile' );
    },
    undef,
    'dist_file doesn\'t bail as it finds the file'
  );

}

# Guard Clear

isnt(
  exception {
    note dist_dir('Example-Dist');
  },
  undef,
  'dist_dir bails after clearing'
);

# Note: This code warns, its a bug in File::ShareDir
# dist_file( 'x', 'y' )
#  -> _dist_dir_new('x') -> Returns undef
#  -> File::Spec->catfile( undef, 'afile' )  # warns about undef in subroutine entry.
isnt(
  exception {
    note dist_file( 'Example-Dist', 'afile' );
  },
  undef,
  'dist_file bails after clearing'
);

done_testing;
