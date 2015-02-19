use 5.006;    # pragmas
use strict;
use warnings;

package Test::File::ShareDir::Module;

our $VERSION = '1.001000';

# ABSTRACT: Simplified module oriented ShareDir tester

our $AUTHORITY = 'cpan:KENTNL'; # AUTHORITY

use File::ShareDir 1.00 qw();












sub import {
  my ( undef, $arg ) = @_;

  if ( not ref $arg or 'HASH' ne ref $arg ) {
    require Carp;
    return Carp::croak q[Must pass a hashref];
  }

  my %input_config = %{$arg};

  require Test::File::ShareDir::Object::Module;

  my $params = {};
  my $guard;
  $guard = delete $input_config{-guard} if exists $input_config{-guard};

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
  $module_object->register();
  if ($guard) {
    require Scope::Guard;
    ${$guard} = Scope::Guard->new( sub { $module_object->clear() } );
  }
  return 1;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test::File::ShareDir::Module - Simplified module oriented ShareDir tester

=head1 VERSION

version 1.001000

=head1 SYNOPSIS

    use Test::File::ShareDir::Module {
      '-root'       => "some/root/path",
      '-guard'      => \$guard,           # optional
      'Module::Foo' => "share/ModuleFoo",
    };

C<-root> is optional, and defaults to C<cwd>. ( See L<Test::File::ShareDir/-root> )

B<NOTE:> There's a bug prior to 5.18 with C<< use Foo { -key => } >>, so for backwards compatibility, make sure you either quote
the key: C<< use Foo { '-key' => } >>, or make it the non-first key.

I<Since 1.001000:>

C<-guard> is optional, and if set, will be vivified to a C<Scope::Guard>. ( See L<Test::File::ShareDir/-guard> )

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Test::File::ShareDir::Module",
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
