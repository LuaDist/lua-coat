#!/usr/bin/env lua

require 'Coat.Role'

role 'Breakable'

function method._break ()
    _G.seen = "I broke"
end

class 'Engine'
with 'Breakable'

class 'Car'
has.engine = { is = 'rw', does = 'Breakable', handles = Breakable }

require 'Test.More'

plan(6)

_G.seen = ''

car = Car.new{ engine = Engine.new() }
ok( car:isa 'Car', "isa Car" )
ok( car.engine:isa 'Engine' )
ok( car.engine:does 'Breakable' )
ok( car:does 'Breakable', "does Breakable" )
ok( car:can '_break', "can _break" )
car:_break()
is( _G.seen, "I broke" )

