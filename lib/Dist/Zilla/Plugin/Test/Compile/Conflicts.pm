#
# This file is part of Dist-Zilla-Plugin-Test-Compile
#
# This software is copyright (c) 2009 by Jerome Quelin.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
package # hide from PAUSE
    Dist::Zilla::Plugin::Test::Compile::Conflicts;

use strict;
use warnings;

use Dist::CheckConflicts
    -dist      => 'Dist::Zilla::Plugin::Test::Compile',
    -conflicts => {
        'Test::Kwalitee::Extra' => 'v0.0.8',
    },

;

1;

# ABSTRACT: Provide information on conflicts for Dist::Zilla::Plugin::Test::Compile
