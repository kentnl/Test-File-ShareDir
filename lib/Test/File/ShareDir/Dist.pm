use strict;
use warnings;

package Test::File::ShareDir::Dist;
BEGIN {
  $Test::File::ShareDir::Dist::AUTHORITY = 'cpan:KENTNL';
}
{
  $Test::File::ShareDir::Dist::VERSION = '0.3.4';
}

# ABSTRACT: Simplified C<dist> oriented C<ShareDir> tester

use File::ShareDir 1.00 qw();


sub import {
  my ( $class, $arg ) = @_;

  die "Must pass a hashref" if not ref $arg;
  die "Must pass a hashref" if not ref $arg eq 'HASH';

  my %input_config = %{$arg};

  require Test::File::ShareDir::Object::Dist;

  my $params = {};
  for my $key ( keys %input_config ) {
    next unless $key =~ /\A-(.*)\z/msx;
    $params->{$1} = delete $input_config{$key};
  }
  $params->{dists} = {} if not exists $params->{dists};
  for my $key ( keys %input_config ) {
    $params->{dists}->{$key} = $input_config{$key};
  }

  my $object = Test::File::ShareDir::Object::Dist->new($params);
  $object->install_all_dists();
  $object->add_to_inc();

  return 1;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test::File::ShareDir::Dist - Simplified C<dist> oriented C<ShareDir> tester

=head1 VERSION

version 0.3.4

=head1 SYNOPSIS

    use Test::File::ShareDir::Dist {
        -root => "some/root/path",
        "Dist-Zilla-Plugin-Foo" => "share/DZPF",
    };

C<-root> is optional, and defaults to C<cwd>

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
