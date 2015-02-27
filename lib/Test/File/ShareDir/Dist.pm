use 5.006;    # pragmas
use strict;
use warnings;

package Test::File::ShareDir::Dist;

our $VERSION = '1.000006';

# ABSTRACT: Simplified dist oriented ShareDir tester

# AUTHORITY

use File::ShareDir 1.00 qw();

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Test::File::ShareDir::Dist",
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

  require Test::File::ShareDir::Object::Dist;

  my $dist_object = Test::File::ShareDir::Object::Dist->_new_from_import( \%input_config );
  $dist_object->install_all_dists();
  $dist_object->register();
  return 1;
}

1;

=head1 SYNOPSIS

    use Test::File::ShareDir::Dist {
        '-root' => 'some/root/path',
        'Dist-Zilla-Plugin-Foo' => 'share/DZPF',
    };

C<-root> is optional, and defaults to C<cwd>

B<NOTE:> There's a bug prior to 5.18 with C<< use Foo { -key => } >>, so for backwards compatibility, make sure you either quote
the key: C<< use Foo { '-key' => } >>, or make it the non-first key.

=cut
