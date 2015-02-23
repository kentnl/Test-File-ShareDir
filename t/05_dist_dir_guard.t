
use strict;
use warnings;

use Test::More 0.96 ( $INC{"Devel/Cover.pm"} ? ( skip_all => "Guard broken under Devel::Cover" ) : () );
use Test::Fatal;
use FindBin;

{
  my $guard;
  use Test::File::ShareDir::Dist {
    '-root'        => "$FindBin::Bin/05_files",
    '-guard'       => \$guard,
    'Example-Dist' => 'share'
  };

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
  'dist_dir bails after clear'
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
  'dist_file bails after clear'
);

done_testing;
