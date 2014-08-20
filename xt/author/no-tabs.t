use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.09

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'examples/dist.ini',
    'lib/Dist/Zilla/Plugin/Test/Compile.pm',
    't/00-compile.t',
    't/00-report-prereqs.dd',
    't/00-report-prereqs.t',
    't/01-basic.t',
    't/02-warnings.t',
    't/03-taint.t',
    't/04-bash.t',
    't/05-prereqs.t',
    't/06-filename.t',
    't/07-prereqs-phase.t',
    't/08-xt_mode.t',
    't/09-extra-files.t',
    't/10-shebang-w.t',
    't/11-shebang-C.t',
    't/12-shebang-comment.t',
    't/13-shebang-dashes.t',
    't/14-extratests.t',
    't/zzz-check-breaks.t',
    'xt/author/no-tabs.t',
    'xt/author/pod-spell.t',
    'xt/release/changes_has_content.t',
    'xt/release/clean-namespaces.t',
    'xt/release/cpan-changes.t',
    'xt/release/distmeta.t',
    'xt/release/eol.t',
    'xt/release/kwalitee.t',
    'xt/release/minimum-version.t',
    'xt/release/mojibake.t',
    'xt/release/pod-coverage.t',
    'xt/release/pod-no404s.t',
    'xt/release/pod-syntax.t',
    'xt/release/portability.t'
);

notabs_ok($_) foreach @files;
done_testing;
