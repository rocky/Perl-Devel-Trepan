# -*- coding: utf-8 -*-
# Copyright (C) 2011-2012, 2014, 2018 Rocky Bernstein <rocky@cpan.org>
use warnings; no warnings 'redefine'; no warnings 'once'; use types;

package Devel::Trepan::CmdProcessor::Command::Info::Functions;

use if !@ISA, Devel::Trepan::CmdProcessor::Command::Subcmd::Core;

use rlib '../../../../..';

unless (@ISA) {
    eval <<"EOE";
    use constant MAX_ARGS => 1;  # Need at most this many - undef -> unlimited.
EOE
}

use strict;
our (@ISA, @SUBCMD_VARS);
# Values inherited from parent
use vars @Devel::Trepan::CmdProcessor::Command::Subcmd::SUBCMD_VARS;

## FIXME: do automatically.
our $CMD = "info functions";

@ISA = qw(Devel::Trepan::CmdProcessor::Command::Subcmd);
=pod

=head2 Synopsis:

=cut
our $HELP = <<'HELP';
=pod

B<info functions> [I<regexp>]

Give functions names or those matching I<regexp>. If no regular
expresion is given, list all functions.
=cut
HELP

our $SHORT_HELP = 'All function names, or those matching REGEXP';
our $MIN_ABBREV = length('fu');

sub complete($self, $prefix)
{
    Devel::Trepan::Complete::complete_subs($prefix);
}

sub run($self, $args)
{
    my $proc = $self->{proc};
    my $regexp = undef;

    if (@$args == 3) {
        $regexp = $args->[2];
    }

    my @functions = keys %DB::sub;
    @functions = grep /$regexp/, @functions if defined $regexp;
    if (scalar @functions) {
        my %FILES = ();
        for my $function (sort @functions) {
            my $file_range = $DB::sub{$function};
            if ($file_range =~ /^(.+):(\d+-\d+)/) {
                my ($filename, $range) = ($1, $2);
                $FILES{$filename} ||= [];
                push @{$FILES{$filename}}, [$function, $range];
            } else {
                $FILES{$file_range} ||= [];
                push @{$FILES{$file_range}}, [$function];
            }
        }
        # FIXME: make output more like gdb's.
        for my $filename (sort keys %FILES) {
            $proc->section($filename);
            for my $entry (@{$FILES{$filename}}) {
                $proc->msg("\t" . join(' is at ', @$entry));
            }
        }
    } else {
	my @fns = Devel::Trepan::Complete::complete_builtins($regexp);
	if (@fns) {
            for my $entry (@fns) {
                $proc->msg($entry . ' is a built-in function');
            }
	} else {
	    $proc->msg("No matching functions");
	}
    }
}

unless (caller) {
    require Devel::Trepan::CmdProcessor;
    my $proc = Devel::Trepan::CmdProcessor->new;
    my $parent = Devel::Trepan::CmdProcessor::Command::Info->new($proc, 'info');
    my $cmd = __PACKAGE__->new($parent, 'return');
    print $cmd->{help}, "\n";
    print "min args: ", $cmd->MIN_ARGS, ", max_args: ", $cmd->MAX_ARGS, "\n";
    # Demo it.
    # require_relative '../../mock'
    # my($dbgr, $parent_cmd) = MockDebugger::setup('show');
    # $cmd = __PACKAGE__->new(parent_cmd);
    # $cmd->run(@$cmd->prefix);
}

# Suppress a "used-once" warning;
$HELP || scalar @SUBCMD_VARS;
