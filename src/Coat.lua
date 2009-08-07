
--
-- lua-Coat : <http://github.com/fperrad/lua-Coat/>
--

module(..., package.seeall)

Meta = {}

basic_type = type
local basic_type = basic_type
local function object_type (obj)
    local t = basic_type(obj)
    if t == 'table' and obj._CLASS then
        return obj._CLASS
    else
        return t
    end
end
_G.type = object_type

local function argerror (caller, narg, extramsg)
    error("bad argument #" .. tostring(narg) .. " to "
          .. caller .. " (" .. extramsg .. ")")
end

local function typerror (caller, narg, arg, tname)
    argerror(caller, narg, tname .. " expected, got " .. object_type(arg))
end

function checktype (caller, narg, arg, tname)
    if basic_type(arg) ~= tname then
        typerror(caller, narg, arg, tname)
    end
end
local checktype = checktype

function isa (obj, t)
    if basic_type(t) == 'table' and t._NAME then
        t = t._NAME
    end
    if basic_type(t) ~= 'string' then
        argerror('isa', 2, "string or Object/Class expected")
    end

    local function walk (types)
        for i, v in ipairs(types) do
            if v == t then
                return true
            elseif basic_type(v) == 'table' then
                local result = walk(v)
                if result then
                    return result
                end
            end
        end
        return false
    end -- walk

    if basic_type(obj) == 'table' and obj._ISA then
        return walk(obj._ISA)
    else
        return basic_type(obj) == t
    end
end

function Coat.does (obj, r)
    if basic_type(r) == 'table' and r._NAME then
        r = r._NAME
    end
    if basic_type(r) ~= 'string' then
        argerror('does', 2, "string or Role expected")
    end

    local function walk (roles)
        for i, v in ipairs(roles) do
            if v == r then
                return true
            elseif basic_type(v) == 'table' then
                local result = walk(v)
                if result then
                    return result
                end
            end
        end
        return false
    end -- walk

    if basic_type(obj) == 'table' and obj._DOES then
        return walk(obj._DOES)
    else
        return false
    end
end

function new (class, args)
    args = args or {}
    local obj = {
        _CLASS = class._NAME, 
        _VALUES = {}
    }
    setmetatable(obj, {})
    class._INIT(obj, args)
    if class.BUILD then
        class.BUILD(obj, args)
    end
    return obj
end

function __gc (class, obj)
    if class.DEMOLISH then
        class.DEMOLISH(obj)
    end
end

local function attr_default (options, obj)
    local default = options.default
    if basic_type(default) == 'function' then
        return default(obj)
    else
        return default
    end
end

local function validate (name, options, val)
    if val == nil then
        if options.required and not options.lazy then
            error("Attribute '" .. name .. "' is required")
        end
    else
        if options.isa then
            if options.coerce then
                local mapping = Types and Types._COERCE[options.isa]
                if not mapping then
                    error( "Coercion is not available for type " .. options.isa)
                end
                local coerce = mapping[object_type(val)]
                if coerce then
                    val = coerce(val)
                end
            end

            local function check_isa (tname)
                local tc = Types and Types._TC[tname]
                if tc then
                    check_isa(tc.parent)
                    if not tc.validator(val) then
                        local msg = tc.message
                        if msg == nil then
                            error("Value for attribute '" .. name
                                  .. "' does not validate type constraint '"
                                  .. tname .. "'" )
                        else
                            error(string.format(msg, val))
                        end
                    end
                else
                    if not isa(val, tname) then
                        error( "Invalid type for attribute '" .. name .. "' (got "
                               .. object_type(val) .. ", expected " .. tname ..")" )
                    end
                end
            end -- check_isa

            check_isa(options.isa)
        end
    end
    return val
end

function _INIT (class, obj, args)
    for k, opts in pairs(class._ATTR) do
        if obj._VALUES[k] == nil then
            local val = args[k]
            if val ~= nil then
                if basic_type(val) == 'function' then
                    val = val(obj)
                end
            elseif not opts.lazy then
                val = attr_default(opts, obj)
            end
            val = validate(k, opts, val)
            obj._VALUES[k] = val
        end
    end

    local m = getmetatable(obj)
    for k, v in pairs(class._MT) do
        if not m[k] then
            m[k] = v
        end
    end

    for i, p in ipairs(class._PARENT) do
        p._INIT(obj, args)
    end
end

function Meta.has (class, name)
    return class._ATTR[name]
end

function has (class, name, options)
    checktype('has', 1, name, 'string')
    options = options or {}
    checktype('has', 2, options, 'table')

    if name:sub(1, 1) == '+' then
        name = name:sub(2)
        inherited = class._ATTR[name]
        if inherited == nil then
            error( "Cannot overload unknown attribute " .. name )
        end
        local t = {}
        for k, v in pairs(inherited) do
            t[k] = v
        end
        for k, v in pairs(options) do
            t[k] = v
        end
        options = t
    elseif class._ATTR[name] ~= nil then
        error( "Duplicate definition of attribute " .. name )
    end
    if options.trigger and basic_type(options.trigger) ~= 'function' then
        error "The trigger option requires a function"
    end
    if options.lazy and options.default == nil then
        error "The lazy option implies the default option"
    end
    class._ATTR[name] = options

    class[name] = function (obj, val)
        if val ~= nil then
            -- setter
            if options.is == 'ro' then
                error("Cannot set a read-only attribute ("
                      .. name .. ")")
            else
                val = validate(name, options, val)
                obj._VALUES[name] = val
                if options.trigger then
                    options.trigger(obj, val)
                end
                return val
            end
        end
        -- getter
        if options.lazy and obj._VALUES[name] == nil then
            local val = attr_default(options, obj)
            val = validate(name, options, val)
            obj._VALUES[name] = val
        end
        return obj._VALUES[name]
    end

    if options.handles then
        for k, v in pairs(options.handles) do
            class[k] = function (obj, ...)
                local d = obj._VALUES[name]
                if d[v] == nil then
                    error( "Cannot delegate " .. k .. " from "
                           .. name .. " (" .. v .. ")" )
                end
                return d[v](d, ...)
            end
        end
    end

    if options.clearer then
        if options.required then
            error "The clearer option is incompatible with required option"
        end
        if basic_type(options.clearer) ~= 'string' then
            error "The clearer option requires a string"
        end
        class[options.clearer] = function (obj)
            obj._VALUES[name] = nil
        end
    end
end

function method (class, name, func)
    checktype('method', 1, name, 'string')
    checktype('method', 2, func, 'function')
    if class[name] then
        error( "Duplicate definition of method " .. name )
    end
    class[name] = func
end

function overload (class, name, func)
    checktype('overload', 1, name, 'string')
    checktype('overload', 2, func, 'function')
    class._MT[name] = func
end

function override (class, name, func)
    checktype('override', 1, name, 'string')
    checktype('override', 2, func, 'function')
    if not class[name] then
        error("Cannot override non-existent method "
              .. name .. " in class " .. class._NAME)
    end
    class[name] = func
end

function before (class, name, func)
    checktype('before', 1, name, 'string')
    checktype('before', 2, func, 'function')
    local super = class[name]
    if not super then
        error("Cannot before non-existent method "
              .. name .. " in class " .. class._NAME)
    end

    class[name] = function (...)
        local result = func(...)
        super(...)
        return result
    end
end

function around (class, name, func)
    checktype('around', 1, name, 'string')
    checktype('around', 2, func, 'function')
    local super = class[name]
    if not super then
        error("Cannot around non-existent method "
              .. name .. " in class " .. class._NAME)
    end

    class[name] = function (obj, ...)
        return func(obj, super,  ...)
    end
end

function after (class, name, func)
    checktype('after', 1, name, 'string')
    checktype('after', 2, func, 'function')
    local super = class[name]
    if not super then
        error("Cannot after non-existent method "
              .. name .. " in class " .. class._NAME)
    end

    class[name] = function (...)
        super(...)
        return func(...)
    end
end

function extends(class, ...)
    for i, v in ipairs{...} do
        local p
        if basic_type(v) == 'string' then
            p = require(v)
        elseif v._NAME then
            p = v
        end
        if not p or not p._INIT then
            argerror('extends', i, "string or Class expected")
        end

        if p:isa(class) then
            error("Circular class structure between '"
                  .. class._NAME .."' and '" .. p._NAME .. "'")
        end

        table.insert(class._PARENT, p)
        table.insert(class._ISA, p._ISA)
        table.insert(class._DOES, p._DOES)
    end

    local t = getmetatable(class)
    t.__index = function (t, k) 
                    local function search ()
                        for i, p in ipairs(class._PARENT) do
                            local v = p[k]
                            if v then 
                                return v
                            end
                        end
                    end -- search

                    local v = rawget(t, k) or search()
                    t[k] = v      -- save for next access
                    return v
                end
    local a = getmetatable(class._ATTR)
    a.__index = function (t, k) 
                    local function search ()
                        for i, p in ipairs(class._PARENT) do
                            local v = p._ATTR[k]
                            if v then 
                                return v
                            end
                        end
                    end -- search

                    local v = rawget(t, k) or search()
                    t[k] = v      -- save for next access
                    return v
                end
end

function Coat.with (class, ...)
    for i, v in ipairs{...} do
        local r
        if basic_type(v) == 'string' then
            r = require(v)
        elseif v._NAME then
            r = v
        end
        if not r or r._INIT then
            argerror('with', i, "string or Role expected")
        end

        table.insert(class._DOES, r._NAME)
        for i, v in ipairs(r._STORE) do
            local k = table.remove(v, 1)
            Coat[k](class, unpack(v))
        end
    end
end

local classes = {}
function Meta.classes ()
    return classes
end

function Meta.class (name)
    return classes[name]
end

function _G.class (modname)
    checktype('class', 1, modname, 'string')
    if _G[modname] then
        error("name conflict for module '" .. modname .. "'")
    end

    local M = {}
    _G[modname] = M
    package.loaded[modname] = M
    setmetatable(M, {
        __index = _G,
        __call  = function (t, ...)
                      return t.new(...)
                  end,
    })
    setfenv(2, M)
    M._NAME = modname
    M._M = M
    M._ISA = { modname }
    M._PARENT = {}
    M._DOES = {}
    M._MT = { __index = M }
    M._ATTR = {}
    setmetatable(M._ATTR, {})
    M.isa = isa
    M.does = does
    M.new = function (...) return new(M, ...) end
    M.__gc = function (...) return __gc(M, ...) end
    M._INIT = function (...) return _INIT(M, ...) end
    M.has = function (...) return has(M, ...) end
    M.method = function (...) return method(M, ...) end
    M.overload = function (...) return overload(M, ...) end
    M.override = function (...) return override(M, ...) end
    M.before = function (...) return before(M, ...) end
    M.around = function (...) return around(M, ...) end
    M.after = function (...) return after(M, ...) end
    M.extends = function (...) return extends(M, ...) end
    M.with = function (...) return with(M, ...) end
    classes[modname] = M
end

_VERSION = "0.1.0"
_DESCRIPTION = "lua-Coat : Yet Another Lua Object-Oriented Model"
_COPYRIGHT = "Copyright (c) 2009 Francois Perrad"
--
-- This library is licensed under the terms of the MIT/X11 license, like Lua itself.
--
