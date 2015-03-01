use 5.006;    # pragmas
use strict;
use warnings;

package Test::File::ShareDir::Module;

our $VERSION = '1.001002';

# ABSTRACT: Simplified module oriented ShareDir tester

# AUTHORITY

use File::ShareDir 1.00 qw();
use Test::File::ShareDir::Utils qw( extract_dashes );

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Test::File::ShareDir::Module",
    "interface":"exporter"
}

=end MetaPOD::JSON

=cut

sub import {
  my ( undef, $arg ) = @_;

  if ( not ref $arg or 'HASH' ne ref $arg ) {
    require Carp;
    return Carp::croak q[Must pass a hashref];
  }

  my %input_config = %{$arg};

  require Test::File::ShareDir::Object::Module;

  my $module_object = Test::File::ShareDir::Object::Module->new(extract_dashes('modules', \%input_config ));
  $module_object->install_all_modules();
  $module_object->register();
  return 1;
}

1;

=head1 SYNOPSIS

    use Test::File::ShareDir::Module {
        '-root' => "some/root/path",
        'Module::Foo' => "share/ModuleFoo",
    };

C<-root> is optional, and defaults to C<cwd>


B<NOTE:> There's a bug prior to 5.18 with C<< use Foo { -key => } >>, so for backwards compatibility, make sure you either quote
the key: C<< use Foo { '-key' => } >>, or make it the non-first key.

=cut
