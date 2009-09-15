#!/usr/bin/env lua

require 'Coat'

class 'Foo'
has.x = { is = 'rw', isa = 'number' }
has.s = { is = 'rw', isa = 'string' }
has.c = { is = 'rw', isa = 'function' }
has.subobject = { is = 'rw', isa = 'Bar' }

class 'Bar'
has.x = { is = 'rw' }

class 'Baz'

require 'Test.More'

plan(8)

_G.foo = Foo.new()
foo:x(43)
is( foo:x(), 43 )
foo:s "text"
is( foo:s(), "text" )
foo:c( function () return 3 end )
is( foo:c()(), 3 )
foo:subobject(Bar.new())
ok( foo:subobject():isa 'Bar' )

error_like([[foo:x "text"]],
           "^[^:]+:%d+: Invalid type for attribute 'x' %(got string, expected number%)")

error_like([[foo:s(2)]],
           "^[^:]+:%d+: Invalid type for attribute 's' %(got number, expected string%)")

error_like([[foo:c(2)]],
           "^[^:]+:%d+: Invalid type for attribute 'c' %(got number, expected function%)")

error_like([[foo:subobject(Baz.new())]],
           "^[^:]+:%d+: Invalid type for attribute 'subobject' %(got Baz, expected Bar%)")

