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

  my ( $guard, $clearer );
  $guard   = delete $input_config{-guard}   if exists $input_config{-guard};
  $clearer = delete $input_config{-clearer} if exists $input_config{-clearer};

  my $dist_object = Test::File::ShareDir::Object::Dist->_new_from_import( \%input_config );
  $dist_object->install_all_dists();
  $dist_object->register();
  if ($guard) {
    require Scope::Guard;
    ${$guard} = Scope::Guard->new( _mk_clearer($dist_object) );
  }
  if ($clearer) {
    ${$clearer} = _mk_clearer($dist_object);
  }
  return 1;
}

## Hack: This prevents self-referencing memory leaks
## under debuggers.
sub _mk_clearer {
  my ($dist_object) = @_;
  return sub { $dist_object->clear() };
}
1;

=head1 SYNOPSIS

    use Test::File::ShareDir::Dist {
      '-root'                 => 'some/root/path',    # optional
      '-clearer'              => \$clearer,           # optional
      'Dist-Zilla-Plugin-Foo' => 'share/DZPF',
    };

C<-root> is optional, and defaults to C<cwd>. ( See L<Test::File::ShareDir/-root> )

B<NOTE:> There's a bug prior to 5.18 with C<< use Foo { -key => } >>, so for backwards compatibility, make sure you either quote
the key: C<< use Foo { '-key' => } >>, or make it the non-first key.

I<Since 1.001000:> C<-clearer> is optional, and if set, will be vivified to a C<CodeRef>. ( See L<Test::File::ShareDir/-clearer> )

B<EXPERIMENTAL> I<Since 1.001000:> C<-guard> is optional, and if set, will be vivified to a C<Scope::Guard>. ( See L<Test::File::ShareDir/-guard> for B<EXPERIMENTAL> details )

=cut
