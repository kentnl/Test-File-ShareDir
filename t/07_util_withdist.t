
use strict;
use warnings;

use Test::More 0.96;
use Test::Fatal;
use FindBin;

use Test::File::ShareDir::Utils qw(with_dist_dir);
use lib "$FindBin::Bin/07_files/lib";
use Example;
use File::ShareDir qw( dist_dir dist_file );

with_dist_dir(
  { Example => 't/07_files/share' } => sub {
    is(
      exception {
        note dist_dir('Example');
      },
      undef,
      'dist_dir doesn\'t bail as it finds the dir'
    );

    is(
      exception {
        note dist_file( 'Example', 'afile' );
      },
      undef,
      'dist_file doesn\'t bail as it finds the file'
    );
  },
);

isnt(
  exception {
    note dist_dir('Example');
  },
  undef,
  'dist_dir bails after clear'
);

# Note: This code warns, its a bug in File::ShareDir
# dist_file( 'x', 'y' )
#  -> _dist_dir_new('x') -> Returns undef
#  -> File::Spec->catfile( undef, 'afile' )  # warns about undef in subroutine entry.
isnt(
  exception {
    note dist_file( 'Example', 'afile' );
  },
  undef,
  'dist_file bails after clear'
);

done_testing;
