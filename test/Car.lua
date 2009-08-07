
require 'Coat.Role'

role 'Breakable'

has( 'is_broken', { is = 'rw', isa = 'boolean' } )

method( '_break' , function (self)
    print "I broke"
    self:is_broken(true)
end )

class 'Car'
with 'Breakable'

has( 'engine', { is = 'ro', isa = 'Engine' } )

