#!/usr/bin/env lua

require 'Coat'

class 'One'
has.one = { isa = 'number', is = 'rw', default = 1 }

class 'Two'
extends 'One'
has.two = { isa = 'number', is = 'rw', default = 2 }

class 'Three'
extends 'Two'
has.three = { isa = 'number', is = 'rw', default = 3 }

class 'Four'
extends 'Three'
has.four = { isa = 'number', is = 'rw', default = 4 }


require 'Test.More'

plan(8)

foo = Four.new()
is( foo:one(), 1, "attr" )
is( foo:two(), 2 )
is( foo:three(), 3 )
is( foo:four(), 4 )

ok( foo:isa 'One', "isa" )
ok( foo:isa 'Two' )
ok( foo:isa 'Three' )
ok( foo:isa 'Four' )

