use strict;
use warnings;

package Test::File::ShareDir;
BEGIN {
  $Test::File::ShareDir::VERSION = '0.2.1';
}

# ABSTRACT: Create a Fake ShareDir for your modules for testing.





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

__END__
=pod

=head1 NAME

Test::File::ShareDir - Create a Fake ShareDir for your modules for testing.

=head1 VERSION

version 0.2.1

=head1 SYNOPSIS

    use Test::More;

    # use FindBin; optional

    use Test::File::ShareDir
        # -root => "$FindBin::Bin/../" # optional,
        -share => {
            -module => { 'My::Module' => 'share/MyModule' }
            -dist   => { 'My-Dist'    => 'share/somefolder' }
        };

    use My::Module;

    use File::ShareDir qw( module_dir dist_dir );

    module_dir( 'My::Module' ) # dir with files from $dist/share/MyModule

    dist_dir( 'My-Dist' ) # dir with files from $dist/share/somefolder

=head1 DESCRIPTION

This module only has support for creating 'new' style sharedirs and are NOT compatible with old File::ShareDirs.

For this reason, unless you have File::ShareDir 1.00 or later installed, this module will not be usable by you.

=head1 IMPORTING

=head2 -root

This parameter is the prefix the other paths are relative to.

If this parameter is not specified, it defaults to the Current Working Directory ( CWD ).

In versions prior to C<0.3.0>, this value was mandatory.

The rationale behind using CWD as the default value is as follows.

=over 4

=item * Most users of this module are likely to be using it to test distributions

=item * Most users of this module will be using it in C<$project/t/> to load files from C<$project/share/>

=item * Most CPAN tools run tests with CWD = $project

=back

Therefor, defaulting to CWD is a reasonably sane default for most people, but where it is not it can
still be overridden.

  -root => "$FindBin::Bin/../" # resolves to project root from t/ regardless of Cwd.

=head2 -share

This parameter is mandatory, and contains a hashref containing the data that explains what directories you want shared.

  -share =>  { ..... }

=head3 -module

C<-module> contains a hashref mapping Module names to path names for module_dir style sharedirs.

  -share => {
    -module => { 'My::Module' => 'share/mymodule/', }
  }

  ...

  module_dir('My::Module')

Notedly, it is a hashref, which means there is a limitation of one sharedir per module. This is simply because having more than one sharedir per module makes no sense at all.

=head3 -dist

C<-dist> contains a hashref mapping Distribution names to path names for dist_dir style sharedirs. The same limitation applied to C<-module> applies here.

  -share => {
    -dist => { 'My-Dist' => 'share/mydist' }
  }
  ...
  dist_dir('My-Dist')

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

