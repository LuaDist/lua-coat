#!/usr/bin/env lua

require 'Coat'

class 'Foo'

has 'baz'
has( 'bar', { 
    is = 'rw',
    trigger = function (self, value)
                  self:baz(value)
              end,
} )

require 'lunity'
module( 'TestTriggers', lunity )

function test_Foo ()
    local foo = Foo.new{ baz = 42 }
    assertTrue( foo:isa 'Foo' )
    assertEqual( foo:baz(), 42 )
    foo:bar( 33 )
    assertEqual( foo:bar(), 33 )
    assertEqual( foo:baz(), 33 )
end

function test_BadTrigger ()
--    Foo.has( 'badtrig', { isa = 'number', trigger = 2 } )
    assertErrors( Foo.has, 'badtrig', { isa = 'number', trigger = 2 } )
end

runTests{ useANSI = false }