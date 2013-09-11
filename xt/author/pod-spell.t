use strict;
use warnings;
use Test::More;

# generated by Dist::Zilla::Plugin::Test::PodSpelling 2.006001
use Test::Spelling 0.12;
use Pod::Wordlist;


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
