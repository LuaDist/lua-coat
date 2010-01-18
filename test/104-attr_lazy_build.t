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

plan(6)

car = Car.new()
ok( car:isa 'Car', "Car" )
is( car.engine, 'Engine' )
is( car._size, 1 )

car = SpecialCar.new()
ok( car:isa 'SpecialCar', "SpecialCar" )
ok( car:isa 'Car' )
is( car.engine, 'SpecialEngine' )

