use strict;
use warnings;

package Test::File::ShareDir;
BEGIN {
  $Test::File::ShareDir::VERSION = '0.1.0';
}

# ABSTRACT: Create a Fake ShareDir for your modules for testing.



use File::Temp qw( tempdir );
use Path::Class qw( dir );
use File::Copy::Recursive qw( rcopy );
use File::ShareDir 1.00 qw();

sub import {
  my ( $class, %config ) = @_;

  if ( not exists $config{-root} ) {
    require Carp;
    Carp::confess('Need -root => for Test::File::ShareDir');
  }

  if ( not exists $config{-share} ) {
    require Carp;
    Carp::confess('Need -share for Test::File::ShareDir');
  }

  my $rootdir = dir( $config{-root} );
  my $modules = {};

  if ( exists $config{-share}->{-module} ) {
    $modules = delete $config{-share}->{-module};
  }

  if ( keys %{ $config{-share} } ) {
    require Carp;
    Carp::confess( 'Unsupported -share types : ' . join q{ }, keys %{ $config{-share} } );
  }

  my $tempdir = dir( tempdir( CLEANUP => 1 ) );
  my $module_share_dir_root = $tempdir->subdir('auto/share/module');
  $module_share_dir_root->mkpath();

  for my $module ( keys %{$modules} ) {
    my $sourcedir = $rootdir->subdir( $modules->{$module} );
    my $targetdir = $module_share_dir_root->subdir( _module_subdir($module) );

    #print "Copy $sourcedir to $targetdir\n";
    rcopy( $sourcedir, $targetdir );
  }

  unshift @INC, $tempdir->stringify;

  return 1;
}

# this is replicated from File::ShareDir
# but code is copied to prevent breakages when the private method
# one-day vanishes.
sub _module_subdir {
  my $modname = shift;
  ## no critic ( RegularExpressions )
  $modname =~ s/::/-/g;
  return $modname;
}

1;

__END__
=pod

=head1 NAME

Test::File::ShareDir - Create a Fake ShareDir for your modules for testing.

=head1 VERSION

version 0.1.0

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

=head1 DESCRIPTION

At present, this module only has support for creating test-worth 'module' sharedirs, and then
these are 'new' style sharedirs and are NOT compatible with old File::ShareDirs.

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

