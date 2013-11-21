use strict;
use warnings;

package Test::File::ShareDir::Module;
BEGIN {
  $Test::File::ShareDir::Module::AUTHORITY = 'cpan:KENTNL';
}
{
  $Test::File::ShareDir::Module::VERSION = '0.3.4';
}

use File::ShareDir 1.00 qw();


sub import {
  my ( $class, $arg ) = @_;

  die "Must pass a hashref" if not ref $arg;
  die "Must pass a hashref" if not ref $arg eq 'HASH';

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

__END__

=pod

=encoding UTF-8

=head1 NAME

Test::File::ShareDir::Module

=head1 VERSION

version 0.3.4

=head1 SYNOPSIS

    use Test::File::ShareDir::Module {
        -root => "some/root/path",
        "Module::Foo" => "share/ModuleFoo",
    };

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
