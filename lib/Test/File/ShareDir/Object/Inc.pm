use 5.006;    # pragmas
use strict;
use warnings;

package Test::File::ShareDir::Object::Inc;

our $VERSION = '1.001003';

# ABSTRACT: Shared tempdir object code to inject into @INC

# AUTHORITY

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Test::File::ShareDir::Object::Inc",
    "interface":"class",
    "inherits":"Class::Tiny::Object"
}

=end MetaPOD::JSON

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
use Carp qw( carp );

=attr C<tempdir>

A path to a C<tempdir> of some description.

=attr C<module_tempdir>

The C<module> C<ShareDir> base directory within the C<tempdir>

=attr C<dist_tempdir>

The C<dist> C<ShareDir> base directory within the C<tempdir>

=method C<add_to_inc>

B<DEPRECATED:> Use C<register> instead.

=cut

sub add_to_inc {
  my ($self) = @_;
  carp 'add_to_inc deprecated sice 1.001000, use register instead';
  return $self->register;
}

=method C<register>

    $instance->register;

Allows this C<Inc> to be used.

Presently, this injects the associated C<tempdir> into C<@INC>

I<Since 1.001000>

=cut

sub register {
  my ($self) = @_;
  unshift @INC, $self->tempdir->stringify;
  return;
}

=method C<clear>

    $instance->clear();

Prevents this C<Inc> from being used.

Presently, this removes the C<tempdir> from C<@INC>

I<Since 1.001000>

=cut

sub clear {
  my ($self) = @_;
  ## no critic (Variables::RequireLocalizedPunctuationVars)
  @INC = grep { ref or $_ ne $self->tempdir->stringify } @INC;
  return;
}

1;

=head1 SYNOPSIS

    use Test::File::ShareDir::Object::Inc;

    my $inc = Test::File::ShareDir::Object::Inc->new();

    $inc->tempdir() # add files to here

    $inc->module_tempdir() # or here

    $inc->dist_tempdir() # or here

    $inc->add_to_inc;

=head1 DESCRIPTION

This class doesn't do very much on its own.

It simply exists to facilitate C<tempdir> creation,
and the injection of those C<tempdir>'s into C<@INC>

=cut
