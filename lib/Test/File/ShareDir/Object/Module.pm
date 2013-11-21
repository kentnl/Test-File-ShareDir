
use strict;
use warnings;

package Test::File::ShareDir::Object::Module;

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
    return Path::Tiny::path('./')->absolute;
  },
};

sub __rcopy { require File::Copy::Recursive; goto \&File::Copy::Recursive::rcopy; }

sub module_names {
  return keys %{ $_[0]->modules };
}

sub module_share_target_dir {
  my ( $self, $module ) = @_;
  return $self->inc->module_tempdir->child($module);
}

sub module_share_source_dir {
  my ( $self, $module ) = @_;
  require Path::Tiny;
  return Path::Tiny::path( $self->modules->{$module} )->absolute( $self->root );
}

sub install_module {
  my ( $self, $module ) = @_;
  my $source = $self->module_share_source_dir($module);
  my $target = $self->module_share_target_dir($module);
  return __rcopy( $source, $target );
}

sub install_all_modules {
  my ($self) = @_;
  for my $module ( $self->module_names ) {
    $self->install_module($module);
  }
}

sub add_to_inc {
  my ($self) = @_;
  $self->inc->add_to_inc;
}

1;
