#!/usr/bin/env lua

require 'Coat'

class 'Engine'

function method._break ()
    _G.seen = "I broke"
end

class 'Car'
has.engine = { is = 'rw', isa = 'Engine', handles = { '_break' } }

require 'Test.More'

plan(4)

_G.seen = ''

car = Car.new{ engine = Engine.new() }
ok( car:isa 'Car', "isa Car" )
ok( car.engine:isa 'Engine' )
ok( car:can '_break', "can _break" )
car:_break()
is( _G.seen, "I broke" )

