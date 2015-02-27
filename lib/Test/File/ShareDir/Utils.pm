use 5.006;
use strict;
use warnings;

package Test::File::ShareDir::Utils;

our $VERSION = '1.001000';

our $AUTHORITY = 'cpan:KENTNL'; # AUTHORITY

# ABSTRACT: Simple utilities for File::ShareDir testing

use Exporter 5.57 qw(import);
use Carp qw( croak );

our @EXPORT_OK = qw( with_dist_dir with_module_dir extract_dashes );

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
  my $dist_object = Test::File::ShareDir::Object::Dist->new( extract_dashes( 'dists', $config ) );
  $dist_object->install_all_dists();
  $dist_object->register();
  my $guard = Scope::Guard->new( _mk_clearer($dist_object) );    ## no critic (Variables::ProhibitUnusedVarsStricter)
  return $code->();
}
























sub with_module_dir {
  my ( $config, $code ) = @_;
  if ( 'CODE' ne ( ref $code || q{} ) ) {
    croak( 'CodeRef expected at end of with_module_dir(), ' . ( ref $code || qq{scalar="$code"} ) . ' found' );
  }

  require Test::File::ShareDir::Object::Module;
  require Scope::Guard;

  my $module_object = Test::File::ShareDir::Object::Module->new( extract_dashes( 'modules', $config ) );
    
  $module_object->install_all_modules();
  $module_object->register();
  my $guard = Scope::Guard->new( _mk_clearer($module_object) );  ## no critic (Variables::ProhibitUnusedVarsStricter)

  return $code->();
}





















sub extract_dashes {
  my ( $undashed_to, $source ) = @_;
  if ( not ref $source or 'HASH' ne ref $source ) {
    return croak(q[Must pass a hashref]);
  }
  my %input_config = %{$source};
  my $params       = {};
  for my $key ( keys %input_config ) {
    next unless $key =~ /\A-(.*)\z/msx;
    $params->{$1} = delete $input_config{$key};
  }
  $params->{$undashed_to} = {} if not exists $params->{$undashed_to};
  for my $key ( keys %input_config ) {
    $params->{$undashed_to}->{$key} = $input_config{$key};
  }
  return $params;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test::File::ShareDir::Utils - Simple utilities for File::ShareDir testing

=head1 VERSION

version 1.001000

=head1 SYNOPSIS

  use Test::File::ShareDir::Utils qw( with_module_dir );
  use File::ShareDir qw( module_dir );

  with_module_dir({ "Module::Name" => "share/Module-Name"}, sub {

    module_dir("Module::Name") # resolves to a sharedir containing share/Module-Name's contents.

  });

  module_dir("Module::Name") # resolves to system sharedir if it exists.

=export with_dist_dir

Sets up a C<ShareDir> environment with limited context.

  # with_dist_dir(\%config, \&sub);
  with_dist_dir( { 'Dist-Name' => 'share/' } => sub {

      # File::ShareDir resolves to a copy of share/ in this context.

  } );

C<%config> can contain anything L<Test::File::ShareDir::Dist> accepts.

=over 4

=item C<-root>: Defaults to C<$CWD>

=item C<I<$distName>>: Declare C<$distName>'s C<ShareDir>.

=back

=export with_module_dir

Sets up a C<ShareDir> environment with limited context.

  # with_module_dir(\%config, \&sub);
  with_module_dir( { 'Module::Name' => 'share/' } => sub {

      # File::ShareDir resolves to a copy of share/ in this context.

  } );

C<%config> can contain anything L<Test::File::ShareDir::Module> accepts.

=over 4

=item C<-root>: Defaults to C<$CWD>

=item C<I<$moduleName>>: Declare C<$moduleName>'s C<ShareDir>.

=back

=export extract_dashes

A utility that helps tranform:

  -opt_a => bar
  -opt_b => baz
  NameA  => NameAValue
  NameB  => NameBValue

Into

  opt_a => bar
  opt_b => baz
  modules => {
    NameA => NameAValue
    NameB => NameBValue
  }

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
