#!/usr/bin/env lua

require 'Coat'

class 'Person'

has.name = { is = 'rw', isa = 'string' }
has.force = { is = 'rw', isa = 'number', default = 1 }

function method:walk ()
    return self.name .. " walks\n"
end

class 'Soldier'

extends 'Person'

has.force = { '+', default = 3 }

function method:attack ()
    return self.force + math.random( 10 )
end

class 'General'

extends 'Soldier'

has.force = { '+', default = 5 }

require 'Test.More'

plan(28)

if os.getenv "GEN_PNG" and os.execute "dot -V" == 0 then
    local f = io.popen("dot -T png -o 007.png", 'w')
    f:write(require 'Coat.UML'.to_dot())
    f:close()
end

man = Person.new{ name = 'John' }
ok( man:isa 'Person', "Person" )
ok( man:isa(Person) )
ok( man:isa(man) )
ok( Coat.Meta.Class.has( Person, 'name' ) )
ok( Coat.Meta.Class.has( Person, 'force' ) )
is( man.force, 1 )
ok( man:walk() )

ok( Soldier:isa 'Soldier', "Class Soldier" )
ok( Soldier:isa 'Person' )
ok( Soldier:isa(Person) )
ok( Soldier:isa(man) )

soldier = Soldier.new{ name = 'Dude' }
ok( soldier:isa 'Soldier', "Soldier" )
ok( soldier:isa 'Person' )
ok( soldier:isa(Person) )
ok( soldier:isa(man) )
ok( Coat.Meta.Class.has( Soldier, 'name' ) )
ok( Coat.Meta.Class.has( Soldier, 'force' ) )
is( soldier.force, 3 )
ok( soldier:walk() )
ok( soldier:attack() )

general = General.new{ name = 'Smith' }
ok( general:isa 'General', "General" )
ok( general:isa 'Soldier' )
ok( general:isa 'Person' )
ok( Coat.Meta.Class.has( General, 'name' ) )
ok( Coat.Meta.Class.has( General, 'force' ) )
is( general.force, 5 )
ok( general:walk() )
ok( general:attack() )

