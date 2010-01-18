#!/usr/bin/env lua

require 'Coat'

class 'Foo'

has.attr = { is = 'rw' }

require 'Test.More'

plan(4)

foo = Foo.new()
is( foo.attr, nil )
foo.attr = 2
is( foo.attr, 2 )
foo.attr = false
is( foo.attr, false )
foo.attr = nil
is( foo.attr, nil )

