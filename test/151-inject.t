#!/usr/bin/env lua

require 'Coat'
require 'Coat.Role'

role 'Log'

abstract 'Service'
has.logger = { is = 'ro', does = 'Log', inject = true }

class 'Logger'
with 'Log'

class 'ServiceImpl1'
extends 'Service'
bind.Log = 'Logger'

class 'ServiceImpl2'
extends 'Service'
bind.Log = Logger

class 'ServiceImpl3'
extends 'Service'
bind.Log = function ()
    return Logger.new{}
end


require 'Test.More'

plan(12)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 151.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

foo = ServiceImpl1()
ok( foo:isa 'ServiceImpl1', "ServiceImpl1" )
ok( foo:isa 'Service' )
ok( foo.logger:isa 'Logger' )
ok( foo.logger:does 'Log' )

foo = ServiceImpl2()
ok( foo:isa 'ServiceImpl2', "ServiceImpl2" )
ok( foo:isa 'Service' )
ok( foo.logger:isa 'Logger' )
ok( foo.logger:does 'Log' )

foo = ServiceImpl3()
ok( foo:isa 'ServiceImpl3', "ServiceImpl3" )
ok( foo:isa 'Service' )
ok( foo.logger:isa 'Logger' )
ok( foo.logger:does 'Log' )

