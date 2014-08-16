use 5.006;    # pragmas
use strict;
use warnings;

package Test::File::ShareDir::Object::Module;

our $VERSION = '1.000006';

# ABSTRACT: Object Oriented ShareDir creation for modules

# AUTHORITY

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Test::File::ShareDir::Object::Module",
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
  modules => sub {
    return {};
  },
  root => sub {
    require Path::Tiny;
    return Path::Tiny::path(q[./])->absolute;
  },
};

=attr C<inc>

A C<Test::File::ShareDir::Object::Inc> object.

=attr C<modules>

A hash of :

    Module::Name => "relative/path"

=attr C<root>

The origin all paths's are relative to.

( Defaults to C<cwd> )

=cut

sub __rcopy { require File::Copy::Recursive; goto \&File::Copy::Recursive::rcopy; }

=method C<module_names>

    my @names = $instance->module_names();

Returns the names of all modules listed in the C<modules> set.

=cut

sub module_names {
  my ( $self, ) = @_;
  return keys %{ $self->modules };
}

=method C<module_share_target_dir>

    my $dir = $instance->module_share_target_dir("Module::Name");

Returns the path where the C<ShareDir> will be created for C<Module::Name>

=cut

sub module_share_target_dir {
  my ( $self, $module ) = @_;

  $module =~ s/::/-/msxg;

  return $self->inc->module_tempdir->child($module);
}

=method C<module_share_source_dir>

    my $dir = $instance->module_share_source_dir("Module::Name");

Returns the path where the C<ShareDir> will be B<COPIED> I<FROM> for C<Module::Name>

=cut

sub module_share_source_dir {
  my ( $self, $module ) = @_;
  require Path::Tiny;
  return Path::Tiny::path( $self->modules->{$module} )->absolute( $self->root );
}

=method C<install_module>

    $instance->install_module("Module::Name");

Installs C<Module::Name>'s C<ShareDir>

=cut

sub install_module {
  my ( $self, $module ) = @_;
  my $source = $self->module_share_source_dir($module);
  my $target = $self->module_share_target_dir($module);
  return __rcopy( $source, $target );
}

=method C<install_all_modules>

    $instance->install_all_modules();

Installs all C<module_names>.

=cut

sub install_all_modules {
  my ($self) = @_;
  for my $module ( $self->module_names ) {
    $self->install_module($module);
  }
  return;
}

=method C<add_to_inc>

    $instance->add_to_inc();

Adds the C<Tempdir> C<ShareDir> ( C<inc> ) to the global C<@INC>.

=cut

sub add_to_inc {
  my ($self) = @_;
  $self->inc->add_to_inc;
  return;
}

1;

=head1 SYNOPSIS

    use Test::File::ShareDir::Object::Module;

    my $dir = Test::File::ShareDir::Object::Module->new(
        root    => "some/path",
        modules => {
            "Hello::Nurse" => "share/HN"
        },
    );

    $dir->install_all_modules;
    $dir->add_to_inc;

=cut
