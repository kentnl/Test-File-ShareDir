use 5.006;    # pragmas
use strict;
use warnings;

package Test::File::ShareDir::TempDirObject;

our $VERSION = '1.000006';

# ABSTRACT: Internal Object to make code simpler.

# AUTHORITY

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Test::File::ShareDir::TempDirObject",
    "interface":"class"
}

=end MetaPOD::JSON

=cut

use Path::Tiny qw(path);
use Carp qw(confess);
## no critic (Subroutines::RequireArgUnpacking)

=method new

Creates a new instance of this object.

=cut

sub new {
  my ( $class, $config ) = @_;

  confess('Need -share => for Test::File::ShareDir') unless exists $config->{-share};

  my $realconfig = {
    root => path(q{./})->absolute,    #->resolve->absolute,
  };

  $realconfig->{root} = path( delete $config->{-root} )->absolute if exists $config->{-root};

  require Test::File::ShareDir::Object::Inc;
  require Test::File::ShareDir::Object::Module;
  require Test::File::ShareDir::Object::Dist;

  $realconfig->{inc} = Test::File::ShareDir::Object::Inc->new();

  $realconfig->{modules} = Test::File::ShareDir::Object::Module->new(
    inc     => $realconfig->{inc},
    modules => ( delete $config->{-share}->{-module} || {} ),
    root    => $realconfig->{root},
  );

  $realconfig->{dists} = Test::File::ShareDir::Object::Dist->new(
    inc   => $realconfig->{inc},
    dists => ( delete $config->{-share}->{-dist} || {} ),
    root  => $realconfig->{root},
  );

  confess( 'Unsupported -share types : ' . join q{ }, keys %{ $config->{-share} } ) if keys %{ $config->{-share} };

  delete $config->{-share};

  confess( 'Unsupported parameter to import() : ' . join q{ }, keys %{$config} ) if keys %{$config};

  return bless $realconfig, $class;
}

my @cache;

sub _tempdir {
  my ($self) = shift;
  return $self->{inc}->tempdir;
}

sub _module_tempdir {
  my ($self) = shift;
  return $self->{inc}->module_tempdir;
}

sub _dist_tempdir {
  my ($self) = shift;
  return $self->{inc}->dist_tempdir;
}

sub _root {
  my ($self) = shift;
  return $self->{root};
}

sub _modules { return shift->{modules}->modules }

sub _dists { return shift->{dists}->dists }

sub _module_names {
  my ($self) = shift;
  return $self->{modules}->module_names;
}

sub _dist_names {
  my ($self) = shift;
  return $self->{dists}->dist_names;
}

sub _module_share_target_dir {
  my ( $self, $modname ) = @_;
  return $self->{modules}->module_share_target_dir($modname);
}

sub _dist_share_target_dir {
  my ( $self, $distname ) = @_;
  return $self->{dists}->dist_share_target_dir($distname);
}

sub _module_share_source_dir {
  my ( $self, $module ) = @_;
  return $self->{modules}->module_share_source_dir($module);
}

sub _dist_share_source_dir {
  my ( $self, $dist ) = @_;
  return $self->{dists}->dist_share_source_dir($dist);
}

sub _install_module {
  my ( $self, $module ) = @_;
  $self->{modules}->install_module($module);
}

sub _install_dist {
  my ( $self, $dist ) = @_;
  $self->{dists}->install_dist($dist);
}

1;

=head1 SYNOPSIS

    my $object = $class->new({
        -root => 'foo', # optional
        -share => {
            -module => {
                'baz' => 'dir',
            },
            -dist => {
                'Task-baz' => 'otherdir',
            },
        },
    });

    # installs a sharedir for 'baz' by copying 'foo/dir'
    $object->_install_module('baz');

    # installs a shardir for distribution 'Task-baz' by copying 'foo/otherdir'
    $object->_install_dist('Task-baz');

    # add to @INC
    unshift @INC, $object->_tempdir->stringify;

=cut
