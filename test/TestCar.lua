#!/usr/bin/env lua

require 'Car'
require 'lunity'
module( 'TestCar', lunity )

function test_Car ()
    local car = Car.new()
    assertTrue( car:isa 'Car' )
    assertTrue( car:does 'Breakable' )
    assertNil( car:is_broken() )
    car:_break()
    assertTrue( car:is_broken() )
end

runTests{ useANSI = false }
