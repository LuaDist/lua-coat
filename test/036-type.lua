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


require 'lunity'
module( 'TestTypes', lunity )

function test_A ()
    local foo = A()
    assertEqual( foo:a(A()):type(), 'A' )
    assertEqual( foo:a(B()):type(), 'B' )
    assertEqual( foo:a(C()):type(), 'C' )
end

function test_B ()
    local foo = B()
    assertEqual( foo:a(A()):type(), 'A' )
    assertEqual( foo:a(B()):type(), 'B' )
    assertEqual( foo:a(C()):type(), 'C' )
    assertErrors( foo.b, foo, A() ) -- foo:b(A())
    assertEqual( foo:b(B()):type(), 'B' )
    assertEqual( foo:b(C()):type(), 'C' )
end

function test_C ()
    local foo = C()
    assertEqual( foo:a(A()):type(), 'A' )
    assertEqual( foo:a(B()):type(), 'B' )
    assertEqual( foo:a(C()):type(), 'C' )
    assertErrors( foo.b, foo, A() ) -- foo:b(A())
    assertEqual( foo:b(B()):type(), 'B' )
    assertEqual( foo:b(C()):type(), 'C' )
    assertErrors( foo.c, foo, A() ) -- foo:c(A())
    assertErrors( foo.c, foo, B() ) -- foo:c(B())
    assertEqual( foo:c(C()):type(), 'C' )
end


runTests{ useANSI = false }
