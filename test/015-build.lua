#!/usr/bin/env lua

require 'Coat'

class 'Foo'

has( 'var', { isa = 'number', default = 1 } )

function BUILD (self)
    self:var(2)
end

require 'lunity'
module( 'TestBuild', lunity )

function test_Foo ()
    local foo = Foo.new{ var = 4 }
    assertTrue( foo:isa 'Foo' )
    assertEqual( foo:var(), 2 )
end

function test_FooDefault ()
    local foo = Foo.new()
    assertTrue( foo:isa 'Foo' )
    assertEqual( foo:var(), 2 )
end


runTests{ useANSI = false }