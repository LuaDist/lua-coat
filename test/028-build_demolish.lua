#!/usr/bin/env lua

require 'Coat'

class 'A'

has( 'id', {
    is = 'ro',
    required = true,
    isa = 'number',
} )
has( 'buffer', {
    is = 'ro',
    default = function () return {} end,
} )

method( 'BUILD', function (self)
    table.insert( self:buffer(), "BUILD A" )
end )
method( 'DEMOLISH', function (self)
    _G.REG.A[self:id()] = self:buffer()
end )

class 'B'
extends 'A'

after( 'BUILD', function (self)
    table.insert( self:buffer(), "BUILD B" )
end )
before( 'DEMOLISH', function (self)
    _G.REG.B[self:id()] = self:buffer()
end )


require 'lunity'
module( 'TestBuildDemolish', lunity )

function setup ()
    _G.REG = {
        A = {},
        B = {},
    }
end

function test_A ()
    a = A{ id = 1 }
    assertTrue( a:isa 'A' )
    assertTableEquals( a:buffer(), { "BUILD A" } )
    a:__gc()  -- manual
    a = nil
--    collectgarbage 'collect'
    assertTableEquals( _G.REG.A[1], { "BUILD A" } )
end

function test_B ()
    b = B{ id = 2 }
    assertTrue( b:isa 'B' )
    assertTrue( b:isa 'A' )
    assertTableEquals( b:buffer(), { "BUILD A", "BUILD B" } )
    b:__gc()  -- manual
    b = nil
--    collectgarbage 'collect'
    assertTableEquals( _G.REG.B[2], { "BUILD A", "BUILD B" } )
    assertTableEquals( _G.REG.A[2], { "BUILD A", "BUILD B" } )
end


runTests{ useANSI = false }