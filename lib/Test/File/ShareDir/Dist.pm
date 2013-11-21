use strict;
use warnings;

package Test::File::ShareDir::Dist;

# ABSTRACT: Simplified C<dist> oriented C<ShareDir> tester

use File::ShareDir 1.00 qw();

=head1 SYNOPSIS

    use Test::File::ShareDir::Dist {
        -root => "some/root/path",
        "Dist-Zilla-Plugin-Foo" => "share/DZPF",
    };

C<-root> is optional, and defaults to C<cwd>

=cut

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
