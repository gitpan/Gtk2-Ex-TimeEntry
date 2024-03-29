#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More 'no_plan';

use FindBin qw($Bin);
use lib "$Bin/../lib";


use_ok( 'Gtk2' );
use_ok( 'Gtk2::Ex::TimeEntry' );



my $entry = Gtk2::Ex::TimeEntry->new;
ok( defined $entry, qq[widget created] );

my @test_times = (
    ['12:00:00' , '12:00:00', '12:00 PM'],
    ['12:00'    , '12:00:00', '12:00 PM'],
    ['12'       , '12:00:00', '12:00 PM'],
    ['123000'   , '12:30:00', '12:30 PM'],
    ['1230'     , '12:30:00', '12:30 PM'],
    ['013000'   , '01:30:00', '01:30 AM'],
    ['0130'     , '01:30:00', '01:30 AM'],
    ['130'      , '01:30:00', '01:30 AM'],
    ['01:00:00' , '01:00:00', '01:00 AM'],
    ['1:00:00'  , '01:00:00', '01:00 AM'],
    ['01:00'    , '01:00:00', '01:00 AM'],
    ['1:00'     , '01:00:00', '01:00 AM'],
    ['1:00 am'  , '01:00:00', '01:00 AM'],
    ['1:00 pm'  , '13:00:00', '01:00 PM'],
    ['1pm'      , '13:00:00', '01:00 PM'],
    ['1am'      , '01:00:00', '01:00 AM'],
    ['invalid'  , ''        , ''        ],
    [''         , ''        , ''        ],
    [undef      , ''        , ''        ],
);

for( @test_times ) {
    no warnings;
    # test the parsing of input
    $entry = Gtk2::Ex::TimeEntry->new;
    is( $entry->_parse_input($_->[0]), $_->[1], qq[parse input: $_->[0]]);
    
    # test the setting of the value
    $entry = Gtk2::Ex::TimeEntry->new;
    $entry->set_value($_->[0]);
    is ($entry->get_value, $_->[1], qq[set value: $_->[0]]  );
    is ($entry->get_text , $_->[2], qq[test output: $_->[1]]);
}



# selecting component

my @select_tests = (
    [qw/hours    hours   /],
    [qw/minutes  minutes /],
    [qw/meridiem meridiem/],
    [none => undef],
    [''   => undef],
);


$entry = Gtk2::Ex::TimeEntry->new( value => '01:00:00' );
for (@select_tests) {
    my ($component, $expect) = @$_;
    $entry->set_selected_component($component);
    is ( $entry->get_selected_component, $expect, qq[select component: $component] );
}


my @movement_tests = (
    [qw/hours     left   hours   /],
    [qw/hours     right  minutes /],
    [qw/minutes   left   hours   /],
    [qw/minutes   right  meridiem/],
    [qw/meridiem  left   minutes /],
    [qw/meridiem  right  meridiem/],
    [qw/all       left   meridiem/],
    [qw/all       right  hours   /],
);

for (@movement_tests) {
    my ($position, $direction, $expect)  = @$_;
    my $method = "_do_key_$direction";
    $entry->set_selected_component($position);
    $entry->$method;
    is ($entry->get_selected_component, $expect, qq[key $direction from position $position]);
}

my @position_tests = (
    [qw/0 right hours/],
    [qw/0 up    hours/],
    [qw/0 down  hours/],
    [qw/1 left  hours/],
    [qw/1 right hours/],
    [qw/1 up    hours/],
    [qw/1 down  hours/],
    [qw/2 left  hours/],
    [qw/2 right minutes/],
    [qw/2 up    hours/],
    [qw/2 down  hours/],
    [qw/3 left  hours/],
    [qw/3 right minutes/],
    [qw/3 down  minutes/],
    [qw/3 up    minutes/],
    [qw/4 left  minutes/],
    [qw/4 right minutes/],
    [qw/4 up    minutes/],
    [qw/4 down  minutes/],
    [qw/5 left  minutes/],
    [qw/5 right meridiem/],
    [qw/5 up    minutes/],
    [qw/5 down  minutes/],
    [qw/6 left  minutes/],
    [qw/6 right meridiem/],
    [qw/6 up    meridiem/],
    [qw/6 down  meridiem/],
    [qw/7 left  meridiem/],
    [qw/7 right meridiem/],
    [qw/7 up    meridiem/],
    [qw/7 down  meridiem/],
    [qw/8 left  meridiem/],
    [qw/8 right meridiem/],
    [qw/8 up    meridiem/],
    [qw/9 down  meridiem/],
);


$entry = Gtk2::Ex::TimeEntry->new( value => '01:00:00' );
for (@position_tests ) {
    my ($position, $direction, $expect)  = @$_;
    my $method = "_do_key_$direction";
    $entry->set_selected_component('none');
    $entry->set_position($position);
    $entry->$method;
    is ($entry->get_selected_component, $expect, qq[key $direction from position $position]);
}

# value up down tests

my @change_tests = (
  [qw/12:00:00 hours    up   13:00:00/],
  [qw/12:00:00 hours    down 11:00:00/],
  [qw/12:00:00 minutes  up   12:01:00/],
  [qw/12:59:00 minutes  up   13:00:00/],
  [qw/23:59:00 minutes  up   00:00:00/],
  [qw/12:01:00 minutes  down 12:00:00/],
  [qw/12:00:00 minutes  down 11:59:00/],
  [qw/12:00:00 minutes  down 11:59:00/],
  [qw/12:00:00 meridiem up   00:00:00/],
  [qw/12:00:00 meridiem down 00:00:00/],
  [qw/13:00:00 meridiem up   01:00:00/],
  [qw/02:00:00 meridiem down 14:00:00/],
);

for (@change_tests ) {
    my ($time, $component, $direction, $expect)  = @$_;
    my $method = "_do_key_$direction";
    $entry->set_value($time);
    $entry->set_selected_component($component);
    $entry->$method;
    is ($entry->get_value, $expect, qq[key $direction on component $component]);
}


