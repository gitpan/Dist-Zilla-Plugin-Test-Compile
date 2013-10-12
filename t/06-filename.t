use strict;
use warnings FATAL => 'all';

use Test::More;
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';
use Test::DZil;
use Path::Tiny;
use Cwd;
use Config;

my $tzil = Builder->from_config(
    { dist_root => 't/does-not-exist' },
    {
        add_files => {
            'source/dist.ini' => simple_ini(
                [ GatherDir => ],
                [ MakeMaker => ],
                [ ExecDir => ],
                [ 'Test::Compile' => { fail_on_warning => 'none', filename => 'xt/author/foo.t' } ],
            ),
            path(qw(source lib Foo.pm)) => "package Foo;\n1;\n",
        },
    },
);

$tzil->build;

my $build_dir = $tzil->tempdir->subdir('build');
ok(!-e path($build_dir, 't', '00-compile.t'), 'default test not created');
my $file = path($build_dir, 'xt', 'author', 'foo.t');
ok(-e $file, 'test created using new name');

my $cwd = getcwd;
my $files_tested;
subtest 'run the generated test' => sub
{
    chdir $build_dir;
    system($^X, 'Makefile.PL');
    system($Config{make});

    do $file;
    warn $@ if $@;

    $files_tested = Test::Builder->new->current_test;
};

is($files_tested, 1, 'correct number of files were tested');

chdir $cwd;

done_testing;
