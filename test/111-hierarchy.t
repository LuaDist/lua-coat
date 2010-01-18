#!/usr/bin/env lua

require 'Test.More'

plan(7)

if not require_ok 'MyApp' then
    skip_rest "no lib"
    os.exit()
end

bar = MyApp.Bar.new()
ok( bar:isa 'MyApp.Bar', "MyApp.Bar" )

foo = MyApp.Bar.Foo.new()
ok( foo:isa 'MyApp.Bar.Foo', "MyApp.Bar.Foo" )
foo.bar = 'bar'
is( foo.bar, 'bar' )

baz = MyApp.Baz.new()
ok( baz:isa 'MyApp.Baz', "MyApp.Baz" )

foo = MyApp.Baz.Foo.new()
ok( foo:isa 'MyApp.Baz.Foo', "MyApp.Baz.Foo" )
foo.baz = 'baz'
is( foo.baz, 'baz' )

