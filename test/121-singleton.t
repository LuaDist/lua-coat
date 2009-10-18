#!/usr/bin/env lua

require 'Coat'

singleton 'Foo'

has.var = { is = 'rw', isa = 'number' }

require 'Test.More'

plan(6)

foo = Foo.instance{ var = 4 }
ok( foo:isa 'Foo', "Foo" )
is( foo:var(), 4 )

bar = Foo.instance()
ok( bar:isa 'Foo' )
is( foo, bar )

baz = Foo()
ok( baz:isa 'Foo' )
is( foo, baz )

