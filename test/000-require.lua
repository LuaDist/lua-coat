#!/usr/bin/env lua

require 'lunity'
module( 'TestRequire', lunity )

function test_require ()
    local m = require 'Coat'
    assertType( m, 'table' )
    assertEqual( m, Coat )
    assertEqual( m, package.loaded.Coat )
    assertNotNil( m._COPYRIGHT:match 'Perrad' )
    assertNotNil( Coat._DESCRIPTION:match 'Lua' )
    assertType( m._VERSION, 'string' )
    assertNotNil( m._VERSION:match '^%d%.%d$' )
end


runTests{ useANSI = false }
