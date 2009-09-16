#!/usr/bin/env lua

require 'Car'
require 'Test.More'

plan(6)

car = Car.new()
ok( car:isa 'Car', "isa" )
ok( car:does 'Breakable', "does" )
is( car:is_broken(), nil )
ok( car:can '_break', "can" )
is( car:_break(), "I broke" )
is( car:is_broken(), true )
