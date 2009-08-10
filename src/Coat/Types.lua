--
-- lua-Coat : <http://lua-coat.luaforge.net/>
--

require 'Coat'

module(..., package.seeall)

local basic_type = Coat.basic_type
local checktype = Coat.checktype

_TC = {}
_COERCE = {}

function _G.subtype (name, parent, validator, msg)
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

function _G.as (parent, ...) -- sugar
    if ... then
        error "too many arguments to as"
    end
    return parent
end

function _G.where (validator, ...) -- sugar
    if ... then
        error "too many arguments to where"
    end
    return validator
end

function _G.message (msg, ...) -- sugar
    if ... then
        error "too many arguments to message"
    end
    return msg
end

function _G.enum (name, ...)
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

function _G.coerce (name, ...)
    checktype('coerce', 1, name, 'string')
    if not _COERCE[name] then
        _COERCE[name] = {}
    end
    local t = {...}
    local i = 2
    while #t > 0 do
        local from = table.remove(t, 1)
        checktype('coerce', i, from, 'string')
        i = i + 1
        local via = table.remove(t, 1)
        checktype('coerce', i, via, 'function')
        i = i + 1
        _COERCE[name][from] = via
    end
end

function _G.from (name, ...) -- sugar
    if ... then
        error "too many arguments to from"
    end
    return name
end

function _G.via (func, ...) -- sugar
    if ... then
        error "too many arguments to via"
    end
    return func
end

--
-- Copyright (c) 2009 Francois Perrad
--
-- This library is licensed under the terms of the MIT/X11 license, like Lua itself.
--
