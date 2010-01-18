#!/usr/bin/env lua

require 'Coat'

class 'MyItem'

has.name = { is = 'rw', isa = 'string' }

class 'MyItem3D'

extends( 'Point3D', MyItem )

require 'Test.More'

plan(14)

point2d = Point.new{ x = 2, y = 4}
is( point2d:type(), 'Point', "Point" )
ok( point2d:isa 'Point' )
nok( Coat.Meta.Class.has( Point, 'z' ) )

point3d = Point3D.new{ x = 1, y = 3, z = 1}
is( point3d:type(), 'Point3D', "Point3D" )
ok( point3d:isa 'Point3D' )
ok( Coat.Meta.Class.has( Point3D, 'z' ) )

item = MyItem3D.new{ name = 'foo', x = 4, z = 3 }
is( item:type(), 'MyItem3D', "MyItem3D" )
ok( item:isa 'MyItem3D' )
ok( item:isa 'Point3D' )
ok( item:isa 'MyItem' )
is( item.x, 4 )
is( item.y, 0 )
is( item.z, 3 )
is( item.name, 'foo' )

