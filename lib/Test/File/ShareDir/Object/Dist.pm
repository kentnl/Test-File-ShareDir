use 5.006;    # pragmas
use strict;
use warnings;

package Test::File::ShareDir::Object::Dist;

our $VERSION = '1.001003';

# ABSTRACT: Object Oriented ShareDir creation for distributions

# AUTHORITY

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Test::File::ShareDir::Object::Dist",
    "interface":"class",
    "inherits":"Class::Tiny::Object"
}

=end MetaPOD::JSON

=cut

use Class::Tiny {
  inc => sub {
    require Test::File::ShareDir::Object::Inc;
    return Test::File::ShareDir::Object::Inc->new();
  },
  dists => sub {
    return {};
  },
  root => sub {
    require Path::Tiny;
    return Path::Tiny::path(q[./])->absolute;
  },
};

use Carp qw( carp );

=attr C<inc>

A C<Test::File::ShareDir::Object::Inc> object.

=attr C<dists>

A hash of :

    Dist-Name => "relative/path"

=attr C<root>

The origin all paths's are relative to.

( Defaults to C<cwd> )

=cut

sub __rcopy { require File::Copy::Recursive; goto \&File::Copy::Recursive::rcopy; }

=method C<dist_names>

    my @names = $instance->dist_names();

Returns the names of all distributions listed in the C<dists> set.

=cut

sub dist_names {
  my ($self) = @_;
  return keys %{ $self->dists };
}

=method C<dist_share_target_dir>

    my $dir = $instance->dist_share_target_dir("Dist-Name");

Returns the path where the C<ShareDir> will be created for C<Dist-Name>

=cut

sub dist_share_target_dir {
  my ( $self, $distname ) = @_;
  return $self->inc->dist_tempdir->child($distname);
}

=method C<dist_share_source_dir>

    my $dir = $instance->dist_share_source_dir("Dist-Name");

Returns the path where the C<ShareDir> will be B<COPIED> I<FROM> for C<Dist-Name>

=cut

sub dist_share_source_dir {
  my ( $self, $distname ) = @_;
  require Path::Tiny;
  return Path::Tiny::path( $self->dists->{$distname} )->absolute( $self->root );
}

=method C<install_dist>

    $instance->install_dist("Dist-Name");

Installs C<Dist-Name>'s C<ShareDir>

=cut

sub install_dist {
  my ( $self, $distname ) = @_;
  my $source = $self->dist_share_source_dir($distname);
  my $target = $self->dist_share_target_dir($distname);
  return __rcopy( $source, $target );
}

=method C<install_all_dists>

    $instance->install_all_dists();

Installs all C<dist_names>

=cut

sub install_all_dists {
  my ($self) = @_;
  for my $dist ( $self->dist_names ) {
    $self->install_dist($dist);
  }
  return;
}

=method C<add_to_inc>

B<DEPRECATED:> Use C<register> instead.

=cut

sub add_to_inc {
  my ($self) = @_;
  carp 'add_to_inc deprecated since 1.001000, use register';
  return $self->register;
}

=method C<register>

    $instance->register();

Adds the C<Tempdir> C<ShareDir> (  C<inc> ) to the global C<@INC>

I<Since 1.001000>

=cut

sub register {
  my ($self) = @_;
  $self->inc->register;
  return;
}

=method C<clear>

    $instance->clear();

Removes the C<Tempdir> C<ShareDir> ( C<inc> ) from the global C<@INC>

I<Since 1.001000>

=cut

sub clear {
  my ($self) = @_;
  $self->inc->clear;
  return;
}

1;

=head1 SYNOPSIS

    use Test::File::ShareDir::Object::Dist;

    my $dir = Test::File::ShareDir::Object::Dist->new(
        root    => "some/path",
        dists => {
            "Hello-Nurse" => "share/HN"
        },
    );

    $dir->install_all_dists;
    $dir->add_to_inc;

=cut
