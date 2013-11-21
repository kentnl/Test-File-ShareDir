use strict;
use warnings;

package Test::File::ShareDir::Module;

# ABSTRACT: Simplified C<module> oriented C<ShareDir> tester

use File::ShareDir 1.00 qw();

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Test::File::ShareDir::Module",
    "interface":"exporter"
}

=end MetaPOD::JSON


=head1 SYNOPSIS

    use Test::File::ShareDir::Module {
        -root => "some/root/path",
        "Module::Foo" => "share/ModuleFoo",
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

  require Test::File::ShareDir::Object::Module;

  my $params = {};
  for my $key ( keys %input_config ) {
    next unless $key =~ /\A-(.*)\z/msx;
    $params->{$1} = delete $input_config{$key};
  }
  $params->{modules} = {} if not exists $params->{modules};
  for my $key ( keys %input_config ) {
    $params->{modules}->{$key} = $input_config{$key};
  }

  my $object = Test::File::ShareDir::Object::Module->new($params);
  $object->install_all_modules();
  $object->add_to_inc();

  return 1;
}

1;
