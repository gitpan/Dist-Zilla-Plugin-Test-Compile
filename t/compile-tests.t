#!perl
#
# This file is part of Dist-Zilla-Plugin-Test-Compile
#
# This software is copyright (c) 2009 by Jerome Quelin.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#

use strict;
use warnings;

use Dist::Zilla::Tester;
use Path::Class;
use Cwd;
use Test::More tests => 2;

my @warned;
local $SIG{__WARN__} = sub {
  push @warned, $_[0];
  warn $_[0];
};

# build fake dist
my $tzil = Dist::Zilla::Tester->from_config({
    dist_root => dir(qw(t compile-tests)),
});
my $cwd = getcwd;
chdir $tzil->tempdir->subdir('source');
$tzil->build;

my $dir = $tzil->tempdir->subdir('build');
ok( -e file($dir, 't', '00-compile.t'), 'test created');

ok( (scalar grep { /\bCompileTests.+is deprecated/ } @warned), 'got deprecation warning' );

chdir $cwd;