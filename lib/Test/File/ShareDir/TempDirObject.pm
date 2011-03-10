use strict;
use warnings;

package Test::File::ShareDir::TempDirObject;
BEGIN {
  $Test::File::ShareDir::TempDirObject::VERSION = '0.1.1';
}

# ABSTRACT: Internal Object to make code simpler.


## no critic (Subroutines::RequireArgUnpacking)
sub __dir     { require Path::Class::Dir;      return Path::Class::Dir->new(@_); }
sub __tempdir { require File::Temp;            goto \&File::Temp::tempdir; }
sub __rcopy   { require File::Copy::Recursive; goto \&File::Copy::Recursive::rcopy; }
sub __confess { require Carp;                  goto \&Carp::confess; }


sub new {
  my ( $class, $config ) = @_;

  __confess('Need -root => for Test::File::ShareDir')  unless exists $config->{-root};
  __confess('Need -share => for Test::File::ShareDir') unless exists $config->{-share};

  my $realconfig = {
    root    => __dir( $config->{-root} ),    #->resolve->absolute,
    modules => {},
  };

  $realconfig->{modules} = delete $config->{-share}->{-module} if exists $config->{-share}->{-module};

  __confess( 'Unsupported -share types : ' . join q{ }, keys %{ $config->{-share} } ) if keys %{ $config->{-share} };

  delete $config->{-root};
  delete $config->{-share};

  __confess( 'Unsupported parameter to import() : ' . join q{ }, keys %{$config} ) if keys %{$config};

  return bless $realconfig, $class;
}

sub _tempdir {
  my ($self) = shift;
  return $self->{tempdir} if exists $self->{tempdir};
  $self->{tempdir} = __dir( __tempdir( CLEANUP => 1 ) );
  return $self->{tempdir};
}

sub _module_tempdir {
  my ($self) = shift;
  return $self->{module_tempdir} if exists $self->{module_tempdir};
  $self->{module_tempdir} = $self->_tempdir->subdir('auto/share/module');
  $self->{module_tempdir}->mkpath();
  return $self->{module_tempdir};
}

sub _root {
  my ($self) = shift;
  return $self->{root};
}

sub _modules { return shift->{modules}; }

sub _module_names {
  my ($self) = shift;
  return keys %{ $self->_modules };
}

sub _module_share_target_dir {
  my ( $self, $modname ) = @_;

  ## no critic (RegularExpressions)
  $modname =~ s/::/-/g;

  return $self->_module_tempdir->subdir($modname);
}

sub _module_share_source_dir {
  my ( $self, $module ) = @_;
  return $self->_root->subdir( $self->_modules->{$module} );
}

sub _install_module {
  my ( $self, $module ) = @_;
  return __rcopy( $self->_module_share_source_dir($module), $self->_module_share_target_dir($module) );
}

1;

__END__
=pod

=head1 NAME

Test::File::ShareDir::TempDirObject - Internal Object to make code simpler.

=head1 VERSION

version 0.1.1

=head1 SYNOPSIS

    my $object = $class->new({
        -root => 'foo',
        -share => {
            -module => {
                'baz' => 'dir',
            }
        }
    });

    # installs a sharedir for 'baz' by copying 'foo/dir'
    $object->_install_module('baz');

    # add to @INC
    unshift @INC, $object->_tempdir->stringify;

=head1 METHODS

=head2 new

Creates a new instance of this object.

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

