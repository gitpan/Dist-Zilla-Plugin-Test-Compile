use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::CheckDeps 0.008

use Test::More 0.94;
use Test::CheckDeps 0.007;

check_dependencies('classic');

if (0) {
    BAIL_OUT("Missing dependencies") if !Test::More->builder->is_passing;
}

done_testing;

