use 5.006;    # pragmas
use strict;
use warnings;

package Test::File::ShareDir::Object::Inc;

our $VERSION = '1.000003';

# ABSTRACT: Shared tempdir object code to inject into @INC

our $AUTHORITY = 'cpan:KENTNL'; # AUTHORITY




































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





















sub add_to_inc {
  my ($self) = @_;
  unshift @INC, $self->tempdir->stringify;
  return;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test::File::ShareDir::Object::Inc - Shared tempdir object code to inject into @INC

=head1 VERSION

version 1.000003

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

=head1 METHODS

=head2 C<add_to_inc>

    $instance->add_to_inc;

Injects C<tempdir> into C<@INC>

=head1 ATTRIBUTES

=head2 C<tempdir>

A path to a C<tempdir> of some description.

=head2 C<module_tempdir>

The C<module> C<ShareDir> base directory within the C<tempdir>

=head2 C<dist_tempdir>

The C<dist> C<ShareDir> base directory within the C<tempdir>

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Test::File::ShareDir::Object::Inc",
    "interface":"class",
    "inherits":"Class::Tiny::Object"
}


=end MetaPOD::JSON

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
