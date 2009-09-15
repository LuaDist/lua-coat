#!/usr/bin/env lua

require 'MyApp'

require 'Test.More'

plan(6)

bar = MyApp.Bar.new()
ok( bar:isa 'MyApp.Bar', "MyApp.Bar" )

foo = MyApp.Bar.Foo.new()
ok( foo:isa 'MyApp.Bar.Foo', "MyApp.Bar.Foo" )
is( foo:bar( 'bar' ), 'bar' )

baz = MyApp.Baz.new()
ok( baz:isa 'MyApp.Baz', "MyApp.Baz" )

foo = MyApp.Baz.Foo.new()
ok( foo:isa 'MyApp.Baz.Foo', "MyApp.Baz.Foo" )
is( foo:baz( 'baz' ), 'baz' )

