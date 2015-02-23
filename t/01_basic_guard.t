
use strict;
use warnings;

use Test::More 0.96 ( $INC{"Devel/Cover.pm"} ? ( skip_all => "Guard broken under Devel::Cover" ) : () );
use Test::Fatal qw( exception );
use FindBin;

{
  my $guard;

  use Test::File::ShareDir
    -root  => "$FindBin::Bin/01_files",
    -share => { -module => { 'Example' => 'share', } },
    -guard => \$guard;

  use lib "$FindBin::Bin/01_files/lib";

  use Example;

  use File::ShareDir qw( module_dir module_file );

  is(
    exception {
      note module_dir('Example');
    },
    undef,
    'module_dir doesn\'t bail as it finds the dir'
  );

  is(
    exception {
      note module_file( 'Example', 'afile' );
    },
    undef,
    'module_file doesn\'t bail as it finds the file'
  );

}

# Guard Clear

isnt(
  exception {
    note module_dir('Example');
  },
  undef,
  'module_dir fails as file is no longer in @INC'
);

isnt(
  exception {
    note module_file( 'Example', 'afile' );
  },
  undef,
  'module_file fails as file is no longer in @INC'
);

done_testing;
