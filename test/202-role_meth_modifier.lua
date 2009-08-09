#!/usr/bin/env lua

require 'Coat.Role'

role 'Breakable'

has( 'is_broken', { is = 'rw', isa = 'boolean' } )

method( '_break' , function (self)
    self:is_broken(true)
end )

class 'Car'
with 'Breakable'

has( 'engine', { is = 'ro', isa = 'Engine' } )

before( '_break' , function (self)
    print "I broke"
end )


require 'lunity'
module( 'TestRoleMethModifier', lunity )

function test_Car ()
    local car = Car.new()
    assertTrue( car:isa 'Car' )
    assertTrue( car:does 'Breakable' )
    assertNil( car:is_broken() )
    car:_break()
    assertTrue( car:is_broken() )
end


runTests{ useANSI = false }
