use strict;
use warnings;

package Test::File::ShareDir::Dist;
BEGIN {
  $Test::File::ShareDir::Dist::AUTHORITY = 'cpan:KENTNL';
}
{
  $Test::File::ShareDir::Dist::VERSION = '0.4.1';
}

# ABSTRACT: Simplified C<dist> oriented C<ShareDir> tester

use File::ShareDir 1.00 qw();


sub import {
  my ( $class, $arg ) = @_;

  if ( not ref $arg or not ref $arg eq 'HASH' ) {
    require Carp;
    return Carp::croak q[Must pass a hashref];
  }

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

version 0.4.1

=head1 SYNOPSIS

    use Test::File::ShareDir::Dist {
        '-root' => 'some/root/path',
        'Dist-Zilla-Plugin-Foo' => 'share/DZPF',
    };

C<-root> is optional, and defaults to C<cwd>

B<NOTE:> There's a bug prior to 5.18 with C<< use Foo { -key => } >>, so for backwards compatibility, make sure you either quote the key: C<< use Foo { '-key' => } >>, or make it the non-first key.

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Test::File::ShareDir::Dist",
    "interface":"exporter"
}


=end MetaPOD::JSON

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
