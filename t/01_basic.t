
use strict;
use warnings;

use Test::More 0.96;
use Test::Fatal;
use FindBin;
use Test::File::ShareDir
  -root  => "$FindBin::Bin/../",
  -share => { -module => { 'Example' => 't/tshare', } };

use lib "$FindBin::Bin/../t/tlib";

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

done_testing;
