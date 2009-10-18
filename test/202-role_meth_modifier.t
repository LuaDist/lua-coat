#!/usr/bin/env lua

require 'Coat.Role'

role 'Breakable'

has.is_broken = { is = 'rw', isa = 'boolean' }

method._break = function (self)
    self:is_broken(true)
end

class 'Car'
with 'Breakable'

has.engine = { is = 'ro', isa = 'Engine' }

after._break = function (self)
    _G.seen = "I broke"
end

require 'Test.More'

plan(5)

_G.seen = ''

car = Car.new()
ok( car:isa 'Car', "Car" )
ok( car:does 'Breakable' )
is( car:is_broken(), nil )
car:_break()
ok( car:is_broken() )
is( _G.seen, "I broke" )

