use strict;
use warnings;

package Test::File::ShareDir;

# ABSTRACT: Create a Fake ShareDir for your modules for testing.

=head1 SYNOPSIS

    use Test::More;

    use FindBin;

    use Test::File::ShareDir
        -root => "$FindBin::Bin/../",
        -share => {
            -module => { 'My::Module' => 'share/MyModule' }
            -dist   => { 'My-Dist'    => 'share/somefolder' }
        };

    use My::Module;

    use File::ShareDir qw( module_dir dist_dir );

    module_dir( 'My::Module' ) # dir with files from $dist/share/MyModule

    dist_dir( 'My-Dist' ) # dir with files from $dist/share/somefolder

=cut

=head1 DESCRIPTION

This module only has support for creating 'new' style sharedirs and are NOT compatible with old File::ShareDirs.

For this reason, unless you have File::ShareDir 1.00 or later installed, this module will not be usable by you.

=cut

use File::ShareDir 1.00 qw();

sub import {
  my ( $class, %input_config ) = @_;

  require Test::File::ShareDir::TempDirObject;

  my $object = Test::File::ShareDir::TempDirObject->new( \%input_config );

  for my $module ( $object->_module_names ) {
    $object->_install_module($module);
  }

  for my $dist ( $object->_dist_names ) {
    $object->_install_dist($dist);
  }

  unshift @INC, $object->_tempdir->stringify;

  return 1;
}

1;
