--
-- lua-Coat : <http://github.com/fperrad/lua-Coat/>
--

require 'Coat'

module(..., package.seeall)

local basic_type = Coat.basic_type
local checktype = Coat.checktype

function subtype (name, parent, validator, msg)
    checktype('subtype', 1, name, 'string')
    checktype('subtype', 2, parent, 'string')
    checktype('subtype', 3, validator, 'function')
    checktype('subtype', 4, msg or '', 'string')
    if _TC[name] then
        error( "Duplicate definition of type " .. name )
    end
    _TC[name] = {
        parent = parent,
        validator = validator,
        message = msg,
    }
end
_G.subtype = subtype

function as (parent, ...) -- sugar
    if ... then
        error "too many arguments to as"
    end
    return parent
end
_G.as = as

function where (validator, ...) -- sugar
    if ... then
        error "too many arguments to where"
    end
    return validator
end
_G.where = where

function message (msg, ...) -- sugar
    if ... then
        error "too many arguments to message"
    end
    return msg
end
_G.message = message

function enum (name, ...)
    checktype('enum', 1, name, 'string')
    local t = ...
    if basic_type(t) ~= 'table' then
        t = {...}
    end
    if #t < 1 then
        error "You must have at least two values to enumerate through"
    end
    for i, v in ipairs(t) do
        checktype('enum', 1+i, v, 'string')
    end
    if _TC[name] then
        error( "Duplicate definition of type " .. name )
    end
    local u = table.concat(t, '|')
    _TC[name] = {
        parent = 'string',
        validator = function (val)
                        return u:find(val)
                    end,
    }
end
_G.enum = enum

--
-- Copyright (c) 2009 Francois Perrad
--
-- This library is licensed under the terms of the MIT license, like Lua itself.
--
