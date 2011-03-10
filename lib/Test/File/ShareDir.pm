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
        };

    use My::Module;

    use File::ShareDir qw( module_dir );

    module_dir( 'My::Module' ) # dir with files from $dist/share/MyModule

=cut

=head1 DESCRIPTION

At present, this module only has support for creating test-worth 'module' sharedirs, and then
these are 'new' style sharedirs and are NOT compatible with old File::ShareDirs.

=cut


use File::ShareDir 1.00 qw();

sub import {
  my ( $class, %input_config ) = @_;

  require Test::File::ShareDir::TempDirObject;

  my $object = Test::File::ShareDir::TempDirObject->new( \%input_config );

  for my $module ( $object->_module_names ){
      $object->_install_module( $module );
  }

  unshift @INC, $object->_tempdir->stringify;

  return 1;
}

1;
