
use strict;
use warnings;

package Test::File::ShareDir::Object::Dist;
BEGIN {
  $Test::File::ShareDir::Object::Dist::AUTHORITY = 'cpan:KENTNL';
}
{
  $Test::File::ShareDir::Object::Dist::VERSION = '0.3.4';
}

use Class::Tiny {
  inc => sub {
    require Test::File::ShareDir::Object::Inc;
    return Test::File::ShareDir::Object::Inc->new();
  },
  dists => sub {
    return {};
  },
  root => sub {
    require Path::Tiny;
    return Path::Tiny::path('./')->absolute;
  },
};

sub __rcopy { require File::Copy::Recursive; goto \&File::Copy::Recursive::rcopy; }

sub dist_names {
  return keys %{ $_[0]->dists };
}

sub dist_share_target_dir {
  my ( $self, $distname ) = @_;
  return $self->inc->dist_tempdir->child($distname);
}

sub dist_share_source_dir {
  my ( $self, $distname ) = @_;
  require Path::Tiny;
  return Path::Tiny::path( $self->dists->{$distname} )->absolute( $self->root );
}

sub install_dist {
  my ( $self, $distname ) = @_;
  my $source = $self->dist_share_source_dir($distname);
  my $target = $self->dist_share_target_dir($distname);
  return __rcopy( $source, $target );
}

sub install_all_dists {
  my ($self) = @_;
  for my $dist ( $self->dist_names ) {
    $self->install_dist($dist);
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

Test::File::ShareDir::Object::Dist

=head1 VERSION

version 0.3.4

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
