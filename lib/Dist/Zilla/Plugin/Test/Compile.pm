#
# This file is part of Dist-Zilla-Plugin-Test-Compile
#
# This software is copyright (c) 2009 by Jerome Quelin.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
use 5.008;
use strict;
use warnings;

package Dist::Zilla::Plugin::Test::Compile;
{
  $Dist::Zilla::Plugin::Test::Compile::VERSION = '2.008'; # TRIAL
}
# ABSTRACT: common tests to check syntax of your modules

use Moose;
use Data::Section -setup;
with (
    'Dist::Zilla::Role::FileGatherer',
    'Dist::Zilla::Role::FileFinderUser' => {
        method          => 'found_module_files',
        finder_arg_names => [ 'module_finder' ],
        default_finders => [ ':InstallModules' ],
    },
    'Dist::Zilla::Role::FileFinderUser' => {
        method          => 'found_script_files',
        finder_arg_names => [ 'script_finder' ],
        default_finders => [ ':ExecFiles' ],
    },
    'Dist::Zilla::Role::PrereqSource',
);

use Moose::Util::TypeConstraints;

# -- attributes

has fake_home     => ( is=>'ro', isa=>'Bool', default=>0 );
has skip          => ( is=>'ro', predicate=>'has_skip' ); # skiplist - a regex
has needs_display => ( is=>'ro', isa=>'Bool', default=>0 );
has fail_on_warning => ( is=>'ro', isa=>enum([qw(none author all)]), default=>'author' );
has bail_out_on_fail => ( is=>'ro', isa=>'Bool', default=>0 );

has _test_more_version => (
    is => 'ro', isa => 'Str',
    init_arg => undef,
    lazy => 1,
    default => sub { shift->bail_out_on_fail ? '0.94' : '0.88' },
);

# note that these two attributes could conceivably be settable via dist.ini,
# to avoid us using filefinders at all.
has _module_filenames  => (
    isa => 'ArrayRef[Str]',
    traits => ['Array'],
    handles => { _module_filenames => 'elements' },
    lazy => 1,
    default => sub { [ map { $_->name } @{shift->found_module_files} ] },
);
has _script_filenames => (
    isa => 'ArrayRef[Str]',
    traits => ['Array'],
    handles => { _script_filenames => 'elements' },
    lazy => 1,
    default => sub { [ map { $_->name } @{shift->found_script_files} ] },
);

sub register_prereqs
{
    my $self = shift;
    $self->zilla->register_prereqs(
        {
            type  => 'requires',
            phase => 'test',
        },
        'Test::More' => $self->_test_more_version,
        $self->fake_home ? ( 'File::Temp' => '0' ) : (),
        $self->_script_filenames ? ( 'Test::Script' => '1.05' ) : (),
    );
}

sub gather_files {

    my ( $self , ) = @_;

    my @module_filenames = $self->_module_filenames;
    @module_filenames = grep {
        (my $module = $_) =~ s{^lib/}{};
        $module=~ s{[/\\]}{::}g;
        $module=~ s/\.pm$//;
        my $skip = $self->skip;
        $module !~ m/$skip/
    } @module_filenames if $self->skip;

    my $module_files = join("\n", @module_filenames);
    my $script_files = join("\n", $self->_script_filenames);

    my $home = ( $self->fake_home )
        ? join("\n", '# fake home for cpan-testers',
                     'require File::Temp;',
                     'local $ENV{HOME} = File::Temp::tempdir( CLEANUP => 1 );',
              )
        : '# no fake home requested';

    # Skip all tests if you need a display for this test and $ENV{DISPLAY} is not set
    my $needs_display = '';
    if ( $self->needs_display ) {
        $needs_display = <<'CODE';
BEGIN {
    if( not $ENV{DISPLAY} and not $^O eq 'MSWin32' ) {
        plan skip_all => 'Needs DISPLAY';
        exit 0;
    }
}
CODE
    }

    my $bail_out = $self->bail_out_on_fail
        ? 'BAIL_OUT("Compilation problems") if !Test::More->builder->is_passing;'
        : '';

    my $fail_on_warning = $self->fail_on_warning ne 'none'
        ? q{is(scalar(@warnings), 0, 'no warnings found');}
        : '';
    $fail_on_warning = 'if ($ENV{AUTHOR_TESTING}) { ' . $fail_on_warning . ' }'
        if $self->fail_on_warning eq 'author';

    my $test_more_version = $self->_test_more_version;
    my $plugin_version = $self->VERSION;


    require Dist::Zilla::File::InMemory;

    # TODO: we could instead use the TextTemplate role to munge this.
    for my $file (qw( t/00-compile.t )){
        my $content = ${$self->section_data($file)};
        $content =~ s/COMPILETESTS_TESTMORE_VERSION/$test_more_version/g;
        $content =~ s/PLUGIN_VERSION/$plugin_version/g;
        $content =~ s/COMPILETESTS_MODULE_FILES/$module_files/g;
        $content =~ s/COMPILETESTS_SCRIPT_FILES/$script_files/g;
        $content =~ s/COMPILETESTS_FAKE_HOME/$home/;
        $content =~ s/COMPILETESTS_NEEDS_DISPLAY/$needs_display/;
        $content =~ s/COMPILETESTS_BAIL_OUT_ON_FAIL/$bail_out/;
        $content =~ s/COMPILETESTS_FAIL_ON_WARNING/$fail_on_warning/;
        $content =~ s/ +$//gm;

        $self->add_file( Dist::Zilla::File::InMemory->new(
            name => $file,
            content => $content,
        ));
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=pod

=encoding utf-8

=for :stopwords Jerome Quelin Ahmad Luehrs Karen Etheridge Kent Fredric Marcel Gruenauer
Olivier Mengu� Randy M. Stauner Ricardo SIGNES fayland Zawawi Chris Weyl
Harley Pig Jesse

=head1 NAME

Dist::Zilla::Plugin::Test::Compile - common tests to check syntax of your modules

=head1 VERSION

version 2.008

=head1 SYNOPSIS

In your dist.ini:

    [Test::Compile]
    skip      = Test$
    fake_home = 1
    needs_display = 1
    fail_on_warning = author
    bail_out_on_fail = 1

=head1 DESCRIPTION

This is an extension of L<Dist::Zilla::Plugin::InlineFiles>, providing
the following files:

=over 4

=item * F<t/00-compile.t> - a standard test to check syntax of bundled modules

This test will find all modules and scripts in your dist, and try to
compile them one by one. This means it's a bit slower than loading them
all at once, but it will catch more errors.

We currently only check F<bin/>, F<script/> and F<scripts/> for scripts.

=back

This plugin accepts the following options:

=over 4

=item * skip: a regex to skip compile test for modules matching it. The
match is done against the module name (C<Foo::Bar>), not the file path
(F<lib/Foo/Bar.pm>).

=item * fake_home: a boolean to indicate whether to fake C<< $ENV{HOME} >>.
This may be needed if your module unilateraly creates stuff in homedir:
indeed, some cpantesters will smoke test your dist with a read-only home
directory. Default to false.

=item * needs_display: a boolean to indicate whether to skip the compile test
on non-Win32 systems when C<< $ENV{DISPLAY} >> is not set. Defaults to false.

=item * fail_on_warning: a string to indicate when to add a test for
warnings during compilation checks. Possible values are:

=over 4

=item * none: do not check for warnings

=item * author: check for warnings only when AUTHOR_TESTING is set
(default, and recommended)

=item * all: always test for warnings (not recommended, as this can prevent
installation of modules when upstream dependencies exhibit warnings in a new
Perl release)

=item * module_finder

This is the name of a L<FileFinder|Dist::Zilla::Role::FileFinder> for finding
modules to check.  The default value is C<:InstallModules>; this option can be
used more than once.

Other pre-defined finders are listed in
L<FileFinder|Dist::Zilla::Role::FileFinderUser/default_finders>.
You can define your own with the
L<Dist::Zilla::Plugin::FileFinder::ByName|[FileFinder::ByName]> plugin.

=item * script_finder

Just like C<module_finder>, but for finding scripts.  The default value is
C<:ExecFiles> (you can use the L<Dist::Zilla::Plugin::ExecDir> plugin to mark
those files as executables).

=back

=item * bail_out_on_fail: a boolean to indicate whether the test will BAIL_OUT
of all subsequent tests when compilation failures are encountered. Defaults to false.

=back

=for Pod::Coverage::TrustPod register_prereqs
    gather_files

=head1 SEE ALSO

L<Test::NeedsDisplay>

You can also look for information on this module at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Dist-Zilla-Plugin-Test-Compile>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Dist-Zilla-Plugin-Test-Compile>

=item * Open bugs

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Dist-Zilla-Plugin-Test-Compile>

=item * Git repository

L<http://github.com/jquelin/dist-zilla-plugin-test-compile.git>.

=back

=head1 AUTHOR

Jerome Quelin

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Jerome Quelin.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 CONTRIBUTORS

=over 4

=item *

Ahmad M. Zawawi <azawawi@ubuntu.(none)>

=item *

Chris Weyl <cweyl@alumni.drew.edu>

=item *

Harley Pig <harleypig@gmail.com>

=item *

Jerome Quelin <jquelin@gmail.com>

=item *

Jesse Luehrs <doy@tozt.net>

=item *

Karen Etheridge <ether@cpan.org>

=item *

Kent Fredric <kentfredric@gmail.com>

=item *

Marcel Gruenauer <hanekomu@gmail.com>

=item *

Olivier Mengu� <dolmen@cpan.org>

=item *

Randy Stauner <randy@magnificent-tears.com>

=item *

Ricardo SIGNES <rjbs@cpan.org>

=item *

fayland <fayland@gmail.com>

=back

=cut

__DATA__
___[ t/00-compile.t ]___
use strict;
use warnings;

# This test was generated via Dist::Zilla::Plugin::Test::Compile PLUGIN_VERSION

use Test::More COMPILETESTS_TESTMORE_VERSION;

COMPILETESTS_NEEDS_DISPLAY

use File::Temp qw{ tempdir };
use Capture::Tiny qw{ capture };

my @module_files = qw(
COMPILETESTS_MODULE_FILES
);

my @scripts = qw(
COMPILETESTS_SCRIPT_FILES
);

{
    COMPILETESTS_FAKE_HOME

    my @warnings;
    for my $lib (sort @module_files)
    {
        my ($stdout, $stderr, $exit) = capture {
            system($^X, '-Ilib', '-e', qq{require qq[$lib]});
        };
        is($?, 0, "$lib loaded ok");
        warn $stderr if $stderr;
        push @warnings, $stderr if $stderr;
    }

    COMPILETESTS_FAIL_ON_WARNING

if (@scripts) {
    require Test::Script;
    Test::Script->VERSION('1.05');
    foreach my $file ( @scripts ) {
        my $script = $file;
        $script =~ s!.*/!!;
        Test::Script::script_compiles( $file, "$script script compiles" );
    }
}

    COMPILETESTS_BAIL_OUT_ON_FAIL
}

done_testing;
