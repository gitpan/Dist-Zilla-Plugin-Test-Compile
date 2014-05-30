use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::CheckBreaks 0.007

use Test::More;

SKIP: {
    eval 'require Moose::Conflicts; Moose::Conflicts->check_conflicts';
    skip('no Moose::Conflicts module found', 1) if not $INC{'Moose/Conflicts.pm'};

    diag $@ if $@;
    pass 'conflicts checked via Moose::Conflicts';
}

my $breaks = {
  "Test::Kwalitee::Extra" => "<= v0.0.8"
};

use CPAN::Meta::Requirements;
my $reqs = CPAN::Meta::Requirements->new;
$reqs->add_string_requirement($_, $breaks->{$_}) foreach keys %$breaks;

use CPAN::Meta::Check 0.007 'check_requirements';
our $result = check_requirements($reqs, 'conflicts');

if (my @breaks = sort grep { defined $result->{$_} } keys %$result)
{
    diag 'Breakages found with Dist-Zilla-Plugin-Test-Compile:';
    diag "$result->{$_}" for @breaks;
    diag "\n", 'You should now update these modules!';
}


done_testing;