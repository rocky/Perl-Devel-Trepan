#!/usr/bin/env perl
#  Copyright (C) 2011-2015,2017,2019 Rocky Bernstein <rocky@cpan.org>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;
use Module::Build;
use Config;
use File::Basename;
use File::Spec;

my $lib = File::Spec->catfile(dirname(__FILE__), 'lib');
unshift @INC, $lib;
require Devel::Trepan::Version;

my $release_status = ($Devel::Trepan::Version::VERSION =~ /_/) ?
    'testing' : 'stable';
# print "$Devel::Trepan::Version::VERSION $release_status\n";

my $builder = Module::Build->new(
    module_name         => 'Devel::Trepan',
    add_to_cleanup      => [ 'Devel-Trepan-*', 'tmp*', '*.got'  ],
    create_makefile_pl  => 'passthrough',
    dist_abstract       =>
    'Modular Perl Debugger (akin to Python "Trepanning" Debuggers).',
    dist_author         => 'Rocky Bernstein <rocky@cpan.org>',
    dist_version_from   => 'lib/Devel/Trepan/Version.pm',
    license             => 'gpl',
    needs_compiler      => 0,
    release_status      => $release_status,

    meta_merge => {
        resources => {
            bugtracker  => 'https://github.com/rocky/Perl-Devel-Trepan/issues',
            repository  => {
		type => 'git',
		url => 'git://github.com/rocky/Perl-Devel-Trepan.git',
		web => 'http://github.com/rocky/Perl-Devel-Trepan',
	    }
        }
    },

    configure_requires  => {
        'Module::Build' => '0.4211',

    },
    build_requires => {
        'rlib'                    => '0.02',
    },

    no_index   => {
	'package'                           => ['SelfLoader', 'DB', 'Carp']
    },

    recommends => {
        'B::CodeLines'                      => 1.1,
        'Data::Printer'                     => 0,
        'Data::Dumper::Concise'             => 0,
        'Devel::Trepan::Deparse'            => '2.1.0',
        'Devel::Trepan::Disassemble'        => '2.0.2',
        'Devel::Trepan::Shell'              => '1.4.1',
        'Eval::WithLexicals'                => 0,
        'Pod::Text::Color'                  => '2.06',

        # 1.33 has tilde completion, and removes unhelpful
        # filename suffix classifiers, @, =, and *
        'Term::ReadLine::Perl5'             => '1.33',
    },

    requires => {
        'perl'                              => '5.008008',
        'Array::Columnize'                  => '1.04',
        # 'Capture::Tiny'                     => 0,
        'Data::Dumper'                      => 0,
        'Devel::Callsite'                   => 0.08,
	'File::HomeDir'                     => 0.54,
        'Getopt::Long'                      => '2.36',
        'Digest::SHA'                       => 0,
        'Marpa::R2'                         => 4.000,
        'PadWalker'                         => 0,
        'Pod::Find'                         => 1.63,
        'Pod::Text'                         => 3.13,
        'Scalar::Util'                      => 0,
        'Syntax::Highlight::Perl::Improved' => 1.01,
        'rlib'                              => '0.02',
        'version'                           => 0,
    },

    sign                => ($ENV{PERL_MB_NOSIGN} ? 0 : 1),

    test_requires => {
        'Test::More'                        => '0.81',
	'Time::HiRes'                       => '1.9721',
        'rlib'                              => '0.02',
    },

    );

$builder->create_build_script();
