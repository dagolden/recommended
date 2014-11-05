use 5.008001;
use strict;
use warnings;

package recommended;
# ABSTRACT: Load a recommended module and don't die if it doesn't exist

use version;
use Carp            ();
use Module::Runtime ();

our $VERSION = '0.002';

# $MODULES{$type}{$caller}{$mod} = [$min_version, $satisfied]
my %MODULES;

# for testing and diagnostics
sub __modules { return \%MODULES }

sub import {
    my $class  = shift;
    my $caller = caller;
    for my $arg (@_) {
        my $type = ref $arg;
        if ( !$type ) {
            $MODULES{$class}{$caller}{$arg} = [ 0, undef ];
        }
        elsif ( $type eq 'HASH' ) {
            while ( my ( $mod, $ver ) = each %$arg ) {
                Carp::croak("module '$mod': '$ver' is not a valid version string")
                  if !version::is_lax($ver);
                $MODULES{$class}{$caller}{$mod} = [ $ver, undef ];
            }
        }
        else {
            Carp::croak("arguments to 'recommended' must be scalars or a hash ref");
        }
    }
}

sub has {
    my ( $class, $mod, $ver ) = @_;
    my $caller = caller;
    my $spec   = $MODULES{$class}{$caller}{$mod};

    return unless $spec;

    if ( defined $ver ) {
        Carp::croak("module '$mod': '$ver' is not a valid version string")
          if !version::is_lax($ver);
    }
    else {
        # shortcut if default already checked
        return $spec->[1] if defined $spec->[1];
        $ver = $spec->[0];
    }

    local $@;
    my $ok = eval { Module::Runtime::use_module( $mod, $ver ) };
    return $spec->[1] = $ok ? 1 : 0;
}

1;

=for Pod::Coverage has

=head1 SYNOPSIS

    use recommended 'Foo::Bar', {
        'Bar::Baz' => '1.23',
        'Wibble'   => '0.14',
    };

    if ( recommended->has( 'Foo::Bar' ) ) {
        # do something with Foo::Bar
    }

    # default version required
    if ( recommended->has( 'Wibble' ) ) {
        # do something with Wibble if >= version 0.14
    }

    # custom version required
    if ( recommended->has( 'Wibble', '0.10' ) ) {
        # do something with Wibble if >= version 0.10
    }

=head1 DESCRIPTION

This module tries to load recommended modules of particular minimum versions
and provides means to check if they are loaded.  It is a thin veneer around
L<Module::Runtime>.

The major benefit over using L<Module::Runtime> directly is that this allows
you to self-document your recommended modules at the top of your code, while
still loading them on demand elsewhere.

=head1 USAGE

=head2 import

    use recommended 'Foo::Bar', {
        'Bar::Baz' => '1.23',
        'Wibble'   => '0.14',
    };

Scalar import arguments are treated as module names with a minimum required
version of zero.  Hash references are treated as module/minimum-version pairs.
If you repeat, the later minimum version overwrites the earlier one.

The list of modules and versions are kept separate for each calling package.

=head2 has

    recommended->has( $module );
    recommended->has( $module, $alt_minimum_version );

The C<has> method takes a module name and optional alternative minimum version
requirement and returns true if the following conditions are met:

=for :list
* the module was recommended (via C<use recommended>)
* the module can be loaded
* the module meets the default or alternate minimum version

Otherwise, it returns false.

The module is loaded without invoking the module's C<import> method, as running
import on an optional module at runtime is just weird.

=head1 SEE ALSO

=for :list
* L<Module::Runtime>
* L<Test::Requires>

=cut

# vim: ts=4 sts=4 sw=4 et:
