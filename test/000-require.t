#!/usr/bin/env lua

require 'Test.More'

plan(9)

require_ok 'Coat'
local m = require 'Coat'
type_ok( m, 'table' )
is( m, Coat )
is( m, package.loaded.Coat )
like( m._COPYRIGHT, 'Perrad', "_COPYRIGHT" )
like( Coat._DESCRIPTION, 'Lua', "_DESCRIPTION" )
type_ok( m._VERSION, 'string', "_VERSION" )
like( m._VERSION, '^%d%.%d%.%d$' )

is( Coat.math, nil, "check ns pollution" )

