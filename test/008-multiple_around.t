#!/usr/bin/env lua

require 'Coat'

class 'Parent'

method.orig = function (self, ...)
    local val = ...
    table.insert( _G.seen, 'orig : ' .. val )
    return 1
end

class 'Child'
extends 'Parent'

around.orig = function (self, func, ...)
    local val = ...
    table.insert( _G.seen, 'around 1 before : ' .. val)
    local result = func(self, ...)
    table.insert( _G.seen, 'around 1 after' )
    return result + 1
end

around.orig = function (self, func, ...)
    local val = ...
    table.insert( _G.seen, 'around 2 before : ' .. val)
    local result = func(self, ...)
    table.insert( _G.seen, 'around 2 after' )
    return result + 1
end

require 'Test.More'

plan(8)

p = Parent.new()
ok( p:isa 'Parent', "Simple" )
ok( p.orig )
_G.seen = {}
p:orig 'val'
eq_array( _G.seen, { 'orig : val' } )

c = Child.new()
ok( c:isa 'Child', "MultipleAround" )
ok( c:isa 'Parent' )
ok( c.orig )
_G.seen = {}
is( c:orig 'val', 3 )
eq_array( _G.seen, {
        'around 2 before : val',
                'around 1 before : val',
                        'orig : val',
                'around 1 after',
        'around 2 after',
} )

