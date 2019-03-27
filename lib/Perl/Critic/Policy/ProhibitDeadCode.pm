package Perl::Critic::Policy::ProhibitDeadCode;
use 5.008001;
use strict;
use warnings;
our $VERSION = '0.01';

use Readonly;
use Perl::Critic::Utils qw{ :severities :classification :ppi };

use base 'Perl::Critic::Policy';

Readonly::Scalar my $DESC => q{Code that cannot logically ever be executed};
Readonly::Scalar my $EXPL => q{Code must be logically reachable to execute};

sub supported_parameters { return() }
sub default_severity     { return $SEVERITY_HIGH }
sub default_themes       { return qw( bugs ) }
sub applies_to           { return 'PPI::Token::Word' }

sub violates {
    my ($self, $start_word) = @_;

    # Is this statement terminating?
    return if $start_word->content() ne 'exit';

    # Is this statement optional?
    my $is_optional = 0;
    my $word = $start_word->snext_sibling();
    while ($word) {
        if (
            $word->isa('PPI::Token::Word') and
            $word->content() =~ m{^(?:if|unless)$}
        ) {
            $is_optional = 1;
            last;
        }

        $word = $word->snext_sibling();
    }
    return if $is_optional;

    # Are there more statements?
    my $start_statement = $start_word->parent();
    my $next_statement = $start_statement->snext_sibling();
    return if !$next_statement;

    # Lets see if any of them are run-time statements as compile-time
    # statements are a-ok.
    my $found_run_time_statements = 0;
    while ($next_statement) {
        my $statement = $next_statement;
        $next_statement = $statement->snext_sibling();

        next if _is_named_sub( $statement );

        $found_run_time_statements = 1;
        last;
    }
    return if !$found_run_time_statements;

    # So, we found a non-optional terminating statement followed
    # by run-time statements, aka Dead Code.
    return $self->violation( $DESC, $EXPL, $start_word );
}

sub _is_named_sub {
    my ($statement) = @_;

    my $sub_word = $statement->schild(0);
    return 0 if !$sub_word;
    return 0 if !$sub_word->isa('PPI::Token::Word');
    return 0 if !$sub_word->content() eq 'sub';

    my $name_word = $sub_word->snext_sibling();
    return 0 if !$name_word;
    return 0 if !$name_word->isa('PPI::Token::Word');

    my $block = $name_word->snext_sibling();
    return 0 if !$block;
    return 0 if !$block->isa('PPI::Structure::Block');

    my $nothing = $block->snext_sibling();
    return 0 if $nothing;

    return 1;
}

1;
__END__

=encoding utf-8

=head1 NAME

Perl::Critic::Policy::ProhibitDeadCode - Detect code which will never
be executed.

=head1 DESCRIPTION

...

=head1 SUPPORT

Please submit bugs and feature requests to the
Perl-Critic-Policy-ProhibitDeadCode GitHub issue tracker:

L<https://github.com/bluefeet/Perl-Critic-Policy-ProhibitDeadCode/issues>

=head1 AUTHORS

    Aran Clary Deltac <bluefeet@gmail.com>

=head1 ACKNOWLEDGEMENTS

Thanks to L<ZipRecruiter|https://www.ziprecruiter.com/>
for encouraging their employees to contribute back to the open
source ecosystem.  Without their dedication to quality software
development this distribution would not exist.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

