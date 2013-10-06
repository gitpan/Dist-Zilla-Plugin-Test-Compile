use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.04

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'examples/dist.ini',
    'lib/Dist/Zilla/Plugin/Test/Compile.pm',
    'lib/Dist/Zilla/Plugin/Test/Compile/Conflicts.pm'
);

notabs_ok($_) foreach @files;
done_testing;
