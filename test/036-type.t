#!/usr/bin/env lua

require 'Coat'

class 'A'
has.a = { is = 'rw', isa = 'A' }

class 'B'
extends 'A'
has.b = { is = 'rw', isa = 'B' }

class 'C'
extends 'B'
has.c = { is = 'rw', isa = 'C' }

require 'Test.More'

plan(18)

foo = A()
foo.a = A()
is( foo.a:type(), 'A', "A" )
foo.a = B()
is( foo.a:type(), 'B' )
foo.a = C()
is( foo.a:type(), 'C' )

foo = B()
foo.a = A()
is( foo.a:type(), 'A', "B" )
foo.a = B()
is( foo.a:type(), 'B' )
foo.a = C()
is( foo.a:type(), 'C' )
error_like([[local foo = B(); foo.b = A()]],
           "^[^:]+:%d+: Invalid type for attribute 'b' %(got A, expected B%)")
foo.b = B()
is( foo.b:type(), 'B' )
foo.b = C()
is( foo.b:type(), 'C' )

foo = C()
foo.a = A()
is( foo.a:type(), 'A', "C" )
foo.a = B()
is( foo.a:type(), 'B' )
foo.a = C()
is( foo.a:type(), 'C' )
error_like([[local foo = C(); foo.b = A()]],
           "^[^:]+:%d+: Invalid type for attribute 'b' %(got A, expected B%)")
foo.b = B()
is( foo.b:type(), 'B' )
foo.b = C()
is( foo.b:type(), 'C' )
error_like([[local foo = C(); foo.c = A()]],
           "^[^:]+:%d+: Invalid type for attribute 'c' %(got A, expected C%)")
error_like([[local foo = C(); foo.c = B()]],
           "^[^:]+:%d+: Invalid type for attribute 'c' %(got B, expected C%)")
foo.c = C()
is( foo.c:type(), 'C' )

