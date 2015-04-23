use 5.008001;
use strict;
use warnings;

package suggested;
# ABSTRACT: Load suggested modules on demand when available

require recommended;

our @ISA     = qw/recommended/;
our $VERSION = '0.004';

1;

=head1 SYNOPSIS

    use suggested 'Foo::Bar', {
        'Bar::Baz' => '1.23',
        'Wibble'   => '0.14',
    };

    if ( suggested->has( 'Foo::Bar' ) ) {
        # do something with Foo::Bar
    }

=head1 DESCRIPTION

This works just like L<recommended>, but a suggestion is less strong than a
recommendation.  This is provided for self-documentation purposes.

=cut

# vim: ts=4 sts=4 sw=4 et:
