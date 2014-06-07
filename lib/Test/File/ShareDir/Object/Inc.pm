use 5.006;    # pragmas
use strict;
use warnings;

package Test::File::ShareDir::Object::Inc;

# ABSTRACT: Shared tempdir object code to inject into @INC

# AUTHORITY

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Test::File::ShareDir::Object::Inc",
    "interface":"class",
    "inherits":"Class::Tiny::Object"
}

=end MetaPOD::JSON

=head1 SYNOPSIS

    use Test::File::ShareDir::Object::Inc;

    my $inc = Test::File::ShareDir::Object::Inc->new();

    $inc->tempdir() # add files to here

    $inc->module_tempdir() # or here

    $inc->dist_tempdir() # or here

    $inc->add_to_inc;

=cut

=head1 DESCRIPTION

This class doesn't do very much on its own.

It simply exists to facilitate C<tempdir> creation,
and the injection of those C<tempdir>'s into C<@INC>

=cut

my @cache;

use Class::Tiny {
  tempdir => sub {
    require Path::Tiny;
    my $dir = Path::Tiny::tempdir( CLEANUP => 1 );
    push @cache, $dir;    # explicit keepalive
    return $dir;
  },
  module_tempdir => sub {
    my ($self) = @_;
    my $dir = $self->tempdir->child('auto/share/module');
    $dir->mkpath();
    return $dir->absolute;
  },
  dist_tempdir => sub {
    my ($self) = @_;
    my $dir = $self->tempdir->child('auto/share/dist');
    $dir->mkpath();
    return $dir->absolute;
  },
};

=attr C<tempdir>

A path to a C<tempdir> of some description.

=attr C<module_tempdir>

The C<module> C<ShareDir> base directory within the C<tempdir>

=attr C<dist_tempdir>

The C<dist> C<ShareDir> base directory within the C<tempdir>

=method C<add_to_inc>

    $instance->add_to_inc;

Injects C<tempdir> into C<@INC>

=cut

sub add_to_inc {
  my ($self) = @_;
  unshift @INC, $self->tempdir->stringify;
  return;
}

1;
