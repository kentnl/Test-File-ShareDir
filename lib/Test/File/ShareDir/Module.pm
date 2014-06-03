use 5.006;    # pragmas
use strict;
use warnings;

package Test::File::ShareDir::Module;

# ABSTRACT: Simplified module oriented ShareDir tester

# AUTHORITY

use File::ShareDir 1.00 qw();

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Test::File::ShareDir::Module",
    "interface":"exporter"
}

=end MetaPOD::JSON


=head1 SYNOPSIS

    use Test::File::ShareDir::Module {
        '-root' => "some/root/path",
        'Module::Foo' => "share/ModuleFoo",
    };

C<-root> is optional, and defaults to C<cwd>


B<NOTE:> There's a bug prior to 5.18 with C<< use Foo { -key => } >>, so for backwards compatibility, make sure you either quote
the key: C<< use Foo { '-key' => } >>, or make it the non-first key.

=cut

my @cache;

sub import {
  my ( undef, $arg ) = @_;

  if ( not ref $arg or 'HASH' ne ref $arg ) {
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

  my $module_object = Test::File::ShareDir::Object::Module->new($params);
  $module_object->install_all_modules();
  $module_object->add_to_inc();

  push @cache, $module_object;    # Prevent tempdir being reaped

  return 1;
}

END {
  undef $_ for @cache;
}

1;
