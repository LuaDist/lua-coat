#!/usr/bin/env lua

require 'Coat'

class 'Car'

has.engine = { is = 'ro', isa = 'string', lazy_build = true }
has._size = { is = 'ro', lazy_build = true }

function method._build_engine ()
    return "Engine"
end

function method._build__size ()
    return 1
end

class 'SpecialCar'
extends 'Car'

function override._build_engine ()
    return "SpecialEngine"
end

require 'Test.More'

plan(9)

car = Car.new()
ok( car:isa 'Car', "Car" )
is( car:engine(), 'Engine' )
ok( car.clear_engine )
is( car:_size(), 1 )
ok( car._clear_size )

car = SpecialCar.new()
ok( car:isa 'SpecialCar', "SpecialCar" )
ok( car:isa 'Car' )
is( car:engine(), 'SpecialEngine' )
ok( car.clear_engine )

