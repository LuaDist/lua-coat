
--
-- lua-Coat : <http://fperrad.github.com/lua-Coat/>
--

local basic_type = type
local setmetatable = setmetatable
local next = next

module 'Coat.Meta.Class'

local _classes = {}
function classes ()
    return _classes
end

function class (name)
    return _classes[name]
end

function has (class, name)
    return class._ATTR[name]
end

local reserved = {
    BUILD = true,
    can = true,
    does = true,
    dump = true,
    extends = true,
    instance = true,
    isa = true,
    memoize = true,
    new = true,
    type = true,
    with = true,
    _INIT = true,
    __gc = true,
}

function attributes (class)
    return next, class._ATTR, nil
end

function methods (class)
    local function getnext (t, k)
        local v
        repeat
            k, v = next(t, k)
            if not k then return nil end
        until not reserved[k]
          and basic_type(v) == 'function'
          and not k:match '^_get_' and not k:match '^_set_'
          and not k:match '^_build_'
        return k, v
    end
    return getnext, class, nil
end

function metamethods (class)
    local function getnext (mt, k)
        local v
        repeat
            k, v = next(mt, k)
            if not k then return nil end
        until k ~= '__index'
        return k, v
    end
    return getnext, class._MT, nil
end

function parents (class)
    local i = 0
    return  function ()
                i = i + 1
                local parent = class._PARENT[i]
                return parent and parent._NAME, parent
            end
end

function roles (class)
    local i = 0
    return  function ()
                i = i + 1
                local role = class._ROLE[i]
                return role and role._NAME, role
            end
end

_CACHE = {}
setmetatable(_CACHE, { __mode = 'v' })

--
-- Copyright (c) 2009-2010 Francois Perrad
--
-- This library is licensed under the terms of the MIT/X11 license,
-- like Lua itself.
--
