# -*- coding: utf-8 -*-
# Copyright (C) 2011, 2018 Rocky Bernstein <rockyb@rubyforge.net>
use strict; use warnings; no warnings 'redefine';
use English qw( -no_match_vars );
use rlib '../..';

use Class::Struct;
use strict;
use types;

struct WatchPoint => {
    id          => '$', # watchpoint number
    enabled     => '$', # True if watchpoint is enabled
    hits        => '$', # How many times watch was hit
    expr        => '$', # what Perl expression to evaluate
    old_value   => '$', # Previous value
    current_val => '$', # Current value. Set only when != old value
};

package WatchPoint;
sub inspect($self)
{
    sprintf("watchpoint %d, expr %s, old_value: %s, current_value %s",
            $self->id, $self->expr, $self->old_value // 'undef',
            $self->current_val // 'undef',
        );
};

package Devel::Trepan::WatchMgr;

sub new
{
    my ($class, $dbgr) = @_;
    my $self = {};
    $self->{dbgr} = $dbgr;
    bless $self, $class;
    $self->clear();
    $self;
}

sub clear($self)
{
    $self->{list} = [];
    $self->{next_id} = 1;
}

sub inspect($self)
{
    my str $str = '';
    for my $watchpoint ($self->list) {
        next unless defined $watchpoint;
        $str .= $watchpoint->inspect . "\n";
    }
    $str;
}

sub list($self)
{
    return @{$self->{list}};

}

# Remove all breakpoints that we have recorded
sub DESTROY($self) {
    for my $id ($self->list) {
        $self->delete_by_object($id) if defined($id);
    }
    $self->{clear};
}

sub find($self, $index)
{
    for my $object ($self->list) {
        next unless $object;
        return $object if $object->id eq $index;
    }
    return undef;
}

sub delete($self, $index)
{
    my $object = $self->find($index);
    if (defined ($object)) {
        $self->delete_by_object($object);
        return $object;
    } else {
        return undef;
    }
}

sub delete_by_object($self, $delete_object)
{
    my @list = $self->list;
    my $i = 0;
    for my $candidate (@list) {
        next unless defined $candidate;
        if ($candidate eq $delete_object) {
            splice @list, $i, 1;
            $self->{list} = \@list;
            return $delete_object;
        }
    }
    return undef;
}

sub add($self, $expr)
{
    my $watchpoint = WatchPoint->new(
        id       => $self->{next_id}++,
        enabled => 1,
        hits    => 0,
        expr    => $expr,
        );

    push @{$self->{list}}, $watchpoint;
    return $watchpoint;
}

sub compact($self)
{
    my @new_list = ();
    for my $watchpoint ($self->list) {
        next unless defined $watchpoint;
        push @new_list, $watchpoint;
    }
    $self->{list} = \@new_list;
    return $self->{list};
}

sub is_empty($self)
{
    $self->compact();
    return scalar(0 == $self->list);
}

sub max($self)
{
    my $max = 0;
    for my $watchpoint ($self->list) {
        $max = $watchpoint->id if $watchpoint->id > $max;
    }
    return $max;
}

sub size($self)
{
    $self->compact();
    return scalar $self->list;
}

sub reset($self)
{
    for my $id ($self->list) {
        $self->{dbgr}->delete_object($id);
     }
    $self->{list} = [];
}


unless (caller) {

    eval <<'EOE';
    sub wp_status($$)
    {
        my ($watchpoints, $i) = @_;
        printf "list size: %s\n", $watchpoints->size();
        printf "max: %d\n", $watchpoints->max() // -1;
        print $watchpoints->inspect();
        print "--- ${i} ---\n";
    }
EOE

    my $watchpoints = Devel::Trepan::WatchMgr->new('bogus');
wp_status($watchpoints, 0);

my $watchpoint1 = $watchpoints->add('1+2');
wp_status($watchpoints, 1);
$watchpoints->add('3*4');
wp_status($watchpoints, 2);

$watchpoints->delete_by_object($watchpoint1);
wp_status($watchpoints, 3);

$watchpoints->add('3*4+5');
wp_status($watchpoints, 4);

$watchpoints->delete(2);
wp_status($watchpoints, 5);

}

1;
