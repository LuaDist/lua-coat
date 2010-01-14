#!/usr/bin/env lua

require 'Coat.Role'

role 'Breakable'

has.is_broken = { is = 'rw', isa = 'boolean' }

function method:_break ()
    self:is_broken(true)
end

role 'Breakdancer'

function method:_break ()
    self:is_broken(true)
    print "break dance"
end

class 'FragileDancer'
with( 'Breakable', {
                alias = { _break = 'break_bone' },
                excludes = '_break',
      },
      'Breakdancer', {
                alias = { _break = 'break_dance' },
                excludes = '_break',
      } )

function method:_break ()
    print "I broke"
end


require 'Test.More'

plan(6)

man = FragileDancer.new()
ok( man:isa 'FragileDancer', "FragileDancer" )
ok( man:does 'Breakable' )
ok( man:does 'Breakdancer' )
ok( man.break_bone )
ok( man.break_dance )
ok( man._break )

