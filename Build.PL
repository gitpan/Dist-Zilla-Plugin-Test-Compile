
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "common tests to check syntax of your modules",
  "dist_author" => [
    "Jerome Quelin"
  ],
  "dist_name" => "Dist-Zilla-Plugin-Test-Compile",
  "dist_version" => "2.003",
  "license" => "perl",
  "module_name" => "Dist::Zilla::Plugin::Test::Compile",
  "recommends" => {
    "Test::Script" => "1.05"
  },
  "recursive_test_files" => 1,
  "requires" => {
    "Data::Section" => 0,
    "Dist::Zilla::File::InMemory" => 0,
    "Dist::Zilla::Role::FileGatherer" => 0,
    "Moose" => 0,
    "Moose::Util::TypeConstraints" => 0,
    "namespace::autoclean" => 0,
    "perl" => "5.008",
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => [],
  "test_requires" => {
    "Cwd" => 0,
    "Dist::Zilla::Tester" => 0,
    "File::Find" => 0,
    "File::Temp" => 0,
    "Path::Class" => 0,
    "Test::More" => "0.94"
  }
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  my $tr = delete $module_build_args{test_requires};
  my $br = $module_build_args{build_requires};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
