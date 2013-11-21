use strict;
use warnings;

package Test::File::ShareDir::Object::Inc;

use Class::Tiny {
  tempdir => sub {
    require Path::Tiny;
    require File::Temp;
    my $dir = Path::Tiny::path( File::Temp::tempdir( CLEANUP => 1 ) );
    return $dir->absolute;
  },
  module_tempdir => sub {
    my ($self) = @_;
    my $dir = $self->tempdir->child('auto/share/module');
    $dir->mkpath();
    return $dir->absolute;
  },
  dist_tempdir => sub {
    my ($self) = @_;
    my $dir = $self->tempdir->child('auto/share/dist');
    $dir->mkpath();
    return $dir->absolute;
  },
};

sub add_to_inc {
  my ($self) = @_;
  unshift @INC, $self->tempdir->stringify;
  return;
}

1;
