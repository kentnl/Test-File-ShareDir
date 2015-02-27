use 5.006;
use strict;
use warnings;

package Test::File::ShareDir::Utils;

our $VERSION = '1.001000';

use Exporter 5.57 qw(import);
use Carp qw( croak );

our @EXPORT_OK = qw( with_dist_dir with_module_dir );

# This code is just to make sure any guard objects
# are not lexically visible to the sub they contain creating a self reference.
sub _mk_clearer {
  my ($clearee) = @_;
  return sub { $clearee->clear };
}

sub with_dist_dir {
  my ( $config, $code ) = @_;
  if ( 'CODE' ne ( ref $code || q{} ) ) {
    croak( 'CodeRef expected at end of with_dist_dir(), ' . ( ref $code || qq{scalar="$code"} ) . ' found' );
  }
  require Test::File::ShareDir::Object::Dist;
  require Scope::Guard;
  my $dist_object = Test::File::ShareDir::Object::Dist->_new_from_import($config);
  $dist_object->install_all_dists();
  $dist_object->register();
  my $guard = Scope::Guard->new( _mk_clearer($dist_object) );
  return $code->();
}

sub with_module_dir {
  my ( $config, $code ) = @_;
  if ( 'CODE' ne ( ref $code || q{} ) ) {
    croak( 'CodeRef expected at end of with_module_dir(), ' . ( ref $code || qq{scalar="$code"} ) . ' found' );
  }
  require Test::File::ShareDir::Object::Module;
  require Scope::Guard;
  my $module_object = Test::File::ShareDir::Object::Module->_new_from_import($config);
  $module_object->install_all_modules();
  $module_object->register();
  my $guard = Scope::Guard->new( _mk_clearer($module_object) );
  return $code->();
}

__END__

=pod

=encoding UTF-8

=head1 NAME

Test::File::ShareDir::Utils

=head1 VERSION

version 1.001000

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
