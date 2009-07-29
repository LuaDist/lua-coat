#!/usr/bin/env lua

require 'Coat'

class 'MyItem'

has( 'name', { isa = 'string' } )

class 'MyItem3D'

extends( 'Point3D', MyItem )

require 'lunity'
module( 'TestExtends', lunity )

function test_Point ()
    local point2d = Point.new{ x = 2, y = 4}
    assertType( point2d, 'Point' )
    assertTrue( point2d:isa 'Point' )
    assertNil( point2d.z )
end

function test_Point3D ()
    local point3d = Point3D.new{ x = 1, y = 3, z = 1}
    assertType( point3d, 'Point3D' )
    assertTrue( point3d:isa 'Point3D' )
    assertInvokable( point3d.z )
end

function test_MyItem3D ()
    local item = MyItem3D.new{ name = 'foo', x = 4, z = 3 }
    assertType( item, 'MyItem3D' )
    assertTrue( item:isa 'MyItem3D' )
    assertTrue( item:isa 'Point3D' )
    assertTrue( item:isa 'MyItem' )
    assertInvokable( item.x )
    assertInvokable( item.y )
    assertInvokable( item.z )
    assertInvokable( item.name )
    assertEqual( type(item.x), 'function' )
    assertEqual( type(item.y), 'function' )
    assertEqual( type(item.z), 'function' )
    assertEqual( type(item.name), 'function' )
end


runTests{ useANSI = false }
