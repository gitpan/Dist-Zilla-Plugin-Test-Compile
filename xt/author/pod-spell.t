use strict;
use warnings;
use Test::More;

# generated by Dist::Zilla::Plugin::Test::PodSpelling 2.006000
eval "use Test::Spelling 0.12; use Pod::Wordlist::hanekomu; 1" or die $@;


add_stopwords(<DATA>);
all_pod_files_spelling_ok( qw( bin lib  ) );
__DATA__
Jerome
Quelin
Ahmad
Zawawi
azawawi
Chris
Weyl
cweyl
Graham
Knop
haarg
Harley
Pig
harleypig
jquelin
Jesse
Luehrs
doy
Karen
Etheridge
ether
Kent
Fredric
kentfredric
Marcel
Gruenauer
hanekomu
Olivier
Mengu�
dolmen
Peter
Shangov
pshangov
Randy
Stauner
randy
Ricardo
SIGNES
rjbs
fayland
lib
Dist
Zilla
Plugin
Test
Compile
Conflicts
CompileTests
