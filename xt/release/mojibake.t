#!perl
#
# This file is part of Dist-Zilla-Plugin-Test-Compile
#
# This software is copyright (c) 2009 by Jérôme Quelin.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#

use strict;
use warnings qw(all);

use Test::More;

## no critic (ProhibitStringyEval, RequireCheckingReturnValueOfEval)
eval q(use Test::Mojibake);
plan skip_all => q(Test::Mojibake required for source encoding testing) if $@;

all_files_encoding_ok();
