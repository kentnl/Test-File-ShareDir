use 5.006;    # pragmas
use strict;
use warnings;

package Test::File::ShareDir::Dist;

our $VERSION = '1.000006';

# ABSTRACT: Simplified dist oriented ShareDir tester

our $AUTHORITY = 'cpan:KENTNL'; # AUTHORITY

use File::ShareDir 1.00 qw();












sub import {
  my ( undef, $arg ) = @_;

  if ( not ref $arg or 'HASH' ne ref $arg ) {
    require Carp;
    return Carp::croak q[Must pass a hashref];
  }

  my %input_config = %{$arg};

  require Test::File::ShareDir::Object::Dist;

  my $params = {};
  my $clearer;
  $clearer = delete $input_config{-clearer} if exists $input_config{-clearer};

  for my $key ( keys %input_config ) {
    next unless $key =~ /\A-(.*)\z/msx;
    $params->{$1} = delete $input_config{$key};
  }
  $params->{dists} = {} if not exists $params->{dists};
  for my $key ( keys %input_config ) {
    $params->{dists}->{$key} = $input_config{$key};
  }

  my $dist_object = Test::File::ShareDir::Object::Dist->new($params);
  $dist_object->install_all_dists();
  $dist_object->register();
  if ($clearer) {
    ${$clearer} = sub { $dist_object->clear };
  }
  return 1;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test::File::ShareDir::Dist - Simplified dist oriented ShareDir tester

=head1 VERSION

version 1.000006

=head1 SYNOPSIS

    use Test::File::ShareDir::Dist {
      '-root'                 => 'some/root/path',    # optional
      '-clearer'              => \$clearer,           # optional
      'Dist-Zilla-Plugin-Foo' => 'share/DZPF',
    };

C<-root> is optional, and defaults to C<cwd>. ( See L<Test::File::ShareDir/-root> )

B<NOTE:> There's a bug prior to 5.18 with C<< use Foo { -key => } >>, so for backwards compatibility, make sure you either quote
the key: C<< use Foo { '-key' => } >>, or make it the non-first key.

I<Since 1.001000:>

C<-clearer> is optional, and if set, will be vivified to a C<CodeRef>. ( See L<Test::File::ShareDir/-clearer> )

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Test::File::ShareDir::Dist",
    "interface":"exporter"
}


=end MetaPOD::JSON

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
