package Perl::Critic::Policy::Catalyst::ProhibitUnreachableCode;
use 5.008001;
use strict;
use warnings;
our $VERSION = '0.01';

use Readonly;

use Perl::Critic::Utils qw{ :severities :data_conversion :classification };
use base 'Perl::Critic::Policy';

Readonly::Array my @CONDITIONALS => qw( if unless foreach while until for );
Readonly::Hash  my %CONDITIONALS => hashify( @CONDITIONALS );

Readonly::Array my @OPERATORS => qw( && || // and or err ? );
Readonly::Hash  my %OPERATORS => hashify( @OPERATORS );

#-----------------------------------------------------------------------------

Readonly::Scalar my $DESC => q{Unreachable code};
Readonly::Scalar my $EXPL => q{Consider removing it};

#-----------------------------------------------------------------------------

sub supported_parameters { return ()                 }
sub default_severity     { return $SEVERITY_HIGH     }
sub default_themes       { return qw( core bugs certrec )    }
sub applies_to           { return 'PPI::Token::Word' }

#-----------------------------------------------------------------------------

sub violates {
    my ( $self, $elem, undef ) = @_;

    my $statement = $elem->statement();
    return if not $statement;

    # We check to see if this is an interesting token before calling
    # is_method_call().  This weeds out most candidate tokens and
    # prevents us from having to make an expensive function call.

    return if $elem ne 'detach';

    my $prev = $elem->sprevious_sibling();
    return if !$prev;
    return if $prev ne '->';
    return if !$prev->isa('PPI::Token::Operator');

    $prev = $prev->sprevious_sibling();
    return if !$prev;
    return if $prev ne '$c';
    return if !$prev->isa('PPI::Token::Symbol');

    return if not is_method_call($elem);

    # Scan the enclosing statement for conditional keywords or logical
    # operators.  If any are found, then this the following statements
    # could _potentially_ be executed, so this policy is satisfied.

    # NOTE: When the first operand in an boolean expression is
    # C<croak> or C<die>, etc., the second operand is technically
    # unreachable.  But this policy doesn't catch that situation.

    for my $child ( $statement->schildren() ) {
        return if $child->isa('PPI::Token::Operator') && exists $OPERATORS{$child};
        return if $child->isa('PPI::Token::Word') && exists $CONDITIONALS{$child};
    }

    return $self->_gather_violations($statement);
}

sub _gather_violations {
    my ($self, $statement) = @_;

    # If we get here, then the statement contained an unconditional
    # die or exit or return.  Then all the subsequent sibling
    # statements are unreachable, except for those that have labels,
    # which could be reached from anywhere using C<goto>.  Subroutine
    # declarations are also exempt for the same reason.  "use" and
    # "our" statements are exempt because they happen at compile time.

    my @violations = ();
    while ( $statement = $statement->snext_sibling() ) {
        my @children = $statement->schildren();
        last if @children && $children[0]->isa('PPI::Token::Label');
        next if $statement->isa('PPI::Statement::Sub');
        next if $statement->isa('PPI::Statement::End');
        next if $statement->isa('PPI::Statement::Data');
        next if $statement->isa('PPI::Statement::Package');

        next if $statement->isa('PPI::Statement::Include') &&
            $statement->type() ne 'require';

        next if $statement->isa('PPI::Statement::Variable') &&
            $statement->type() eq 'our';

        push @violations, $self->violation( $DESC, $EXPL, $statement );
    }

    return @violations;
}

1;
__END__

=encoding utf-8

=head1 NAME

Perl::Critic::Policy::Catalyst::ProhibitUnreachableCode -
Detect code which will never be executed.

=head1 DESCRIPTION

...

=head1 SUPPORT

Please submit bugs and feature requests to the
Perl-Critic-Policy-Catalyst-ProhibitUnreachableCode GitHub issue tracker:

L<https://github.com/bluefeet/Perl-Critic-Policy-Catalyst-ProhibitUnreachableCode/issues>

=head1 AUTHORS

    Aran Clary Deltac <bluefeet@gmail.com>
    Peter Guzis <pguzis@cpan.org>

This module is a fork of
L<Perl::Critic::Policy::ControlStructures::ProhibitUnreachableCode>
and modified to fit.

=head1 ACKNOWLEDGEMENTS

Thanks to L<ZipRecruiter|https://www.ziprecruiter.com/>
for encouraging their employees to contribute back to the open
source ecosystem.  Without their dedication to quality software
development this distribution would not exist.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab shiftround :
