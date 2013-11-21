
use strict;
use warnings;

package Test::File::ShareDir::Object::Module;
BEGIN {
  $Test::File::ShareDir::Object::Module::AUTHORITY = 'cpan:KENTNL';
}
{
  $Test::File::ShareDir::Object::Module::VERSION = '0.3.4';
}

use Class::Tiny {
  inc => sub {
    require Test::File::ShareDir::Object::Inc;
    return Test::File::ShareDir::Object::Inc->new();
  },
  modules => sub {
    return {};
  },
  root => sub {
    require Path::Tiny;
    return Path::Tiny::path('./')->absolute;
  },
};

sub __rcopy { require File::Copy::Recursive; goto \&File::Copy::Recursive::rcopy; }

sub module_names {
  return keys %{ $_[0]->modules };
}

sub module_share_target_dir {
  my ( $self, $module ) = @_;
  return $self->inc->module_tempdir->child($module);
}

sub module_share_source_dir {
  my ( $self, $module ) = @_;
  require Path::Tiny;
  return Path::Tiny::path( $self->modules->{$module} )->absolute( $self->root );
}

sub install_module {
  my ( $self, $module ) = @_;
  my $source = $self->module_share_source_dir($module);
  my $target = $self->module_share_target_dir($module);
  return __rcopy( $source, $target );
}

sub install_all_modules {
  my ($self) = @_;
  for my $module ( $self->module_names ) {
    $self->install_module($module);
  }
}

sub add_to_inc {
  my ($self) = @_;
  $self->inc->add_to_inc;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test::File::ShareDir::Object::Module

=head1 VERSION

version 0.3.4

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
