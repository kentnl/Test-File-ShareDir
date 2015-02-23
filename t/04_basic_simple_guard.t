
use strict;
use warnings;

use Test::More 0.96 ( $INC{"Devel/Cover.pm"} ? ( skip_all => "Guard broken under Devel::Cover" ) : () );
use Test::Fatal;
use FindBin;

{
  my $guard;
  use Test::File::ShareDir::Module {
    '-root'  => "$FindBin::Bin/04_files",
    '-guard' => \$guard,
    Example  => 'share',
  };

  use lib "$FindBin::Bin/04_files/lib";

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
  'module_dir bails after inc reset'
);

isnt(
  exception {
    note module_file( 'Example', 'afile' );
  },
  undef,
  'module_file bails after inc reset'
);

done_testing;
