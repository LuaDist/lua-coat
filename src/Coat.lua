
--
-- lua-Coat : <http://lua-coat.luaforge.net/>
--

local basic_error = error
local getmetatable = getmetatable
local pairs = pairs
local pcall = pcall
local rawget = rawget
local require = require
local setfenv = setfenv
local setmetatable = setmetatable
local tostring = tostring
local basic_type = type
local _G = _G
local debug = require 'debug'
local package = require 'package'
local string = require 'string'
local table = require 'table'

module 'Coat'

local Meta = require 'Coat.Meta.Class'

function type (obj)
    local t = basic_type(obj)
    if t == 'table' then
        pcall(function ()
                t = obj._CLASS or t
              end)
    end
    return t
end

function error (msg)
    local lvl = 1
    while true do
        local t = debug.getinfo(lvl,'S')
        if not t.short_src:find '/Coat' then break end
        lvl = lvl + 1
    end
    basic_error(msg, lvl)
end

local function argerror (caller, narg, extramsg)
    error("bad argument #" .. tostring(narg) .. " to "
          .. caller .. " (" .. extramsg .. ")")
end

local function typerror (caller, narg, arg, tname)
    argerror(caller, narg, tname .. " expected, got " .. type(arg))
end

function checktype (caller, narg, arg, tname)
    if basic_type(arg) ~= tname then
        typerror(caller, narg, arg, tname)
    end
end
local checktype = checktype

function findtable (fname)
    local i = 1
    local t = _G
    for w in fname:gmatch "(%w+)%." do
        i = i + w:len() + 1
        t[w] = t[w] or {}
        t = t[w]
    end
    local name = fname:sub(i)
    t[name] = t[name] or {}
    return t[name]
end

function can (obj, name)
    checktype('can', 2, name, 'string')
    return basic_type(obj[name]) == 'function'
end

function isa (obj, t)
    if basic_type(t) == 'table' and t._NAME then
        t = t._NAME
    end
    if basic_type(t) ~= 'string' then
        argerror('isa', 2, "string or Object/Class expected")
    end

    local function walk (types)
        for i = 1, #types do
            local v = types[i]
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

    local tobj = basic_type(obj)
    if (tobj == 'table' or tobj == 'userdata') and obj._ISA then
        return walk(obj._ISA)
    else
        return basic_type(obj) == t
    end
end

function does (obj, r)
    if basic_type(r) == 'table' and r._NAME then
        r = r._NAME
    end
    if basic_type(r) ~= 'string' then
        argerror('does', 2, "string or Role expected")
    end

    local function walk (roles)
        for _, v in pairs(roles) do
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

    local tobj = basic_type(obj)
    if (tobj == 'table' or tobj == 'userdata') and obj._DOES then
        return walk(obj._DOES)
    else
        return false
    end
end

function dump (obj, label)
    label = label or 'obj'
    local seen = {}

    local function keys_sorted (t)
        local sorted = {}
        for k in pairs(t) do
            table.insert(sorted, k)
        end
        table.sort(sorted, function (a, b)
                          local r, cmp = pcall(function () return a < b end)
                          if r == nil then
                              return tostring(a) < tostring(b)
                          else
                              return cmp
                          end
                      end)
        return sorted
    end -- keys_sorted

    local function _dump (obj, indent, ref)
        local tobj = basic_type(obj)
        if tobj == 'string' then
            return string.format('%q', obj)
        elseif tobj == 'table' then
            if seen[obj] then
                return seen[obj]
            end
            seen[obj] = ref
            local indent2 = indent .. "  "
            local lines = {}
            local str
            if obj._NAME then
                str = obj._CLASS .. " {"
                local sorted = keys_sorted(obj._VALUES)
                for i = 1, #sorted do
                    local k = sorted[i]
                    local v = rawget(obj._VALUES, k)
                    local line = indent2 .. k .. " = "
                                         .. _dump(v, indent2, ref .. '.' .. k) .. ",\n"
                    table.insert(lines, line)
                end
            else
                str = "{"
                local sorted = keys_sorted(obj)
                for i = 1, #sorted do
                    local k = sorted[i]
                    local v = rawget(obj, k)
                    local kr = "[" .. _dump(k, indent2) .. "]"
                    local line = indent2 .. kr .. " = "
                                         .. _dump(v, indent2, ref .. kr) .. ",\n"
                    table.insert(lines, line)
                end
            end
            if #lines > 0 then
                str = str .. "\n" .. table.concat(lines) .. indent
            end
            return str .. "}"
        else
            return tostring(obj)
        end
    end -- _dump

    return label .. " = " .. _dump(obj, '', label)
end

function new (class, args)
    args = args or {}

    for _, r in pairs(class._ROLE) do -- check roles
        for _, v in pairs(r._EXCL) do
            if class:does(v) then
                error("Role " .. r._NAME .. " excludes role " .. v)
            end
        end
        for _, v in pairs(r._REQ) do
            if not class[v] then
                error("Role " .. r._NAME .. " requires method " .. v)
            end
        end
    end

    local obj = {
        _CLASS = class._NAME,
        _VALUES = {}
    }
    local mt = {}
    setmetatable(obj, mt)
    class._INIT(obj, args)
    mt.__index = function (o, k)
        local getter = '_get_' .. k
        if class[getter] then
            return class[getter](o)
        else
            return class[k]
        end
    end
    mt.__newindex = function (o, k, v)
        local setter = '_set_' .. k
        if class[setter] then
            class[setter](o, v)
        else
            error("Cannot set '" .. k .. "' (unknown)")
        end
    end
    if class.BUILD then
        class.BUILD(obj, args)
    end
    return obj
end

function instance (class, args)
    class._INSTANCE = class._INSTANCE or new(class, args)
    return class._INSTANCE
end

function __gc (class, obj)
    if class.DEMOLISH then
        class.DEMOLISH(obj)
    end
end

local function attr_default (options, obj)
    local builder = options.builder
    if builder then
        local func = obj[builder]
        if not func then
            error("method " .. builder .. " not found in " .. obj._CLASS)
        end
        return func(obj)
    else
        local default = options.default
        if basic_type(default) == 'function' then
            return default(obj)
        else
            return default
        end
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
                local mapping = Types and Types.coercion_map(options.isa)
                if not mapping then
                    error("Coercion is not available for type " .. options.isa)
                end
                local coerce = mapping[type(val)]
                if coerce then
                    val = coerce(val)
                end
            end

            local function check_isa (tname)
                local tc = Types and Types.find_type_constraint(tname)
                if tc then
                    check_isa(tc.parent)
                    if not tc.validator(val) then
                        local msg = tc.message
                        if msg == nil then
                            error("Value for attribute '" .. name
                                  .. "' does not validate type constraint '"
                                  .. tname .. "'")
                        else
                            error(string.format(msg, val))
                        end
                    end
                else
                    if not isa(val, tname) then
                        error("Invalid type for attribute '" .. name
                              .. "' (got " .. type(val)
                              .. ", expected " .. tname ..")")
                    end
                end
            end -- check_isa

            check_isa(options.isa)
        end

        if options.does then
            local role = options.does
            if not does(val, role) then
                error("Value for attribute '" .. name
                      .. "' does not consume role '" .. role .. "'")
            end
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
        else
            val = validate(k, opts, obj._VALUES[k])
        end
    end

    local m = getmetatable(obj)
    for k, v in pairs(class._MT) do
        if not m[k] then
            m[k] = v
        end
    end

    for i = 1, #class._PARENT do
        local p = class._PARENT[i]
        p._INIT(obj, args)
    end
end

function has (class, name, options)
    checktype('has', 1, name, 'string')
    options = options or {}
    checktype('has', 2, options, 'table')

    if class[name] then
        error("Overwrite definition of method " .. name)
    end
    if options[1] == '+' then
        inherited = class._ATTR[name]
        if inherited == nil then
            error("Cannot overload unknown attribute " .. name)
        end
        local t = {}
        for k, v in pairs(inherited) do
            t[k] = v
        end
        for k, v in pairs(options) do
            if k == 'is' and t[k] == 'ro' then
                break
            end
            t[k] = v
        end
        options = t
    elseif class._ATTR[name] ~= nil then
        error("Duplicate definition of attribute " .. name)
    end

    if options.reset and options.required then
        error "The reset option is incompatible with required option"
    end
    if options.inject then
        options.lazy_build = true
    end
    if options.lazy_build then
        options.lazy = true
        options.builder = '_build_' .. name
        options.reset = true
    end
    if options.trigger and basic_type(options.trigger) ~= 'function' then
        error "The trigger option requires a function"
    end
    if options.default and options.builder then
        error "The options default and builder are not compatible"
    end
    if options.lazy and options.default == nil and options.builder == nil then
        error "The lazy option implies the builder or default option"
    end
    if options.builder and basic_type(options.builder) ~= 'string' then
        error "The builder option requires a string (method name)"
    end
    class._ATTR[name] = options

    if options.is then
        class['_set_' .. name] = function (obj, val)
            local t = rawget(obj, '_VALUES')
            if options.is == 'ro'
               and (options.lazy or t[name] ~= nil)
               and (not options.reset or val ~= nil) then
                error("Cannot set a read-only attribute ("
                      .. name .. ")")
            end
            val = validate(name, options, val)
            t[name] = val
            local trigger = options.trigger
            if trigger then
                trigger(obj, val)
            end
            return val
        end

        class['_get_' .. name] = function (obj)
            local t = rawget(obj, '_VALUES')
            if options.lazy and t[name] == nil then
                local val = attr_default(options, obj)
                val = validate(name, options, val)
                t[name] = val
            end
            return t[name]
        end
    end

    if options.inject then
        if not options.does then
            error "The inject option requires a does option"
        end
        class[options.builder] = function (obj)
            local impl = Meta.class(obj._CLASS)._BINDING[options.does]
            if not impl then
                error("No binding found for " .. options.does .. " in class " .. obj._CLASS)
            end
            return impl()
        end
    end

    if options.handles then
        if basic_type(options.handles) == 'table' and not options.handles._NAME then
            for k, v in pairs(options.handles) do
                local meth = k
                if basic_type(meth) == 'number' then
                    meth = v
                end
                if class[meth] then
                    error("Duplicate definition of method " .. meth)
                end
                class[meth] = function (obj, ...)
                    local attr = rawget(obj, '_VALUES')[name]
                    local func = attr[v]
                    if func == nil then
                        error("Cannot delegate " .. meth .. " from "
                              .. name .. " (" .. v .. ")")
                    end
                    return func(attr, ...)
                end -- delegate
            end
        else
            local role
            if basic_type(options.handles) == 'string' then
                role = require(options.handles)
            elseif options.handles._NAME then
                role = options.handles
            end
            if not role or role._INIT then
                error "The handles option requires a table or a Role"
            end
            if options.does ~= role._NAME then
                error "The handles option requires a does option with the same role"
            end
            for _, v in pairs(role._STORE) do
                if v[1] == 'method' then
                    local meth = v[2]
                    if class[meth] then
                        error("Duplicate definition of method " .. meth)
                    end
                    class[meth] = function (obj, ...)
                        local attr = rawget(obj, '_VALUES')[name]
                        local func = attr[meth]
                        if func == nil then
                            error("Cannot delegate " .. meth .. " from "
                                  .. name .. " (" .. meth .. ")")
                        end
                        return func(attr, ...)
                    end -- delegate
                end
            end
            table.insert(class._DOES, role._NAME)
        end
    end -- options.handles
end

function method (class, name, func)
    checktype('method', 1, name, 'string')
    checktype('method', 2, func, 'function')
    if class._ATTR[name] then
        error("Overwrite definition of attribute " .. name)
    end
    if class[name] then
        error("Duplicate definition of method " .. name)
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
        func(...)
        super(...)
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
        func(...)
    end
end

function memoize (class, name)
    checktype('memoize', 1, name, 'string')
    local func = class[name]
    if not func then
        error("Cannot memoize non-existent method "
              .. name .. " in class " .. class._NAME)
    end

    local cache = Meta._CACHE
    class[name] = function (...)
        local arg = {...}
        local key = name
        for i = 1, #arg do
            key = key .. '|' .. tostring(arg[i])
        end
        local result = cache[key]
        if result == nil then
            result = func(...)
            cache[key] =result
        end
        return result
    end
end

function bind (class, name, impl)
    checktype('bind', 1, name, 'string')
    local t = basic_type(impl)
    if t ~= 'function' then
        if t == 'string' then
            impl = require(impl)
        end
        if not impl._INIT then
            argerror('bind', 2, "function or string or Class expected")
        end
    end
    if class._BINDING[name] then
        error("Duplicate binding of " .. name)
    end
    class._BINDING[name] = impl
end

function extends(class, ...)
    local arg = {...}
    for i = 1, #arg do
        local v = arg[i]
        local parent
        if basic_type(v) == 'string' then
            parent = require(v)
        elseif v._NAME then
            parent = v
        end
        if not parent or not parent._INIT then
            argerror('extends', i, "string or Class expected")
        end

        if parent:isa(class) then
            error("Circular class structure between '"
                  .. class._NAME .."' and '" .. parent._NAME .. "'")
        end

        table.insert(class._PARENT, parent)
        table.insert(class._ISA, parent._ISA)
        table.insert(class._DOES, parent._DOES)
        for _, r in pairs(parent._ROLE) do
            table.insert(class._ROLE, r)
        end
    end

    local t = getmetatable(class)
    t.__index = function (t, k)
                    local function search (cl)
                        for i = 1, #cl._PARENT do
                            local p = cl._PARENT[i]
                            local v = rawget(p, k) or search(p)
                            if v then
                                return v
                            end
                        end
                    end -- search

                    v = search(class)
                    t[k] = v      -- save for next access
                    if v == nil then
                        v = _G[k]
                    end
                    return v
                end
    local a = getmetatable(class._ATTR)
    a.__index = function (t, k)
                    local function search (cl)
                        for i = 1, #cl._PARENT do
                            local p = cl._PARENT[i]
                            local v = rawget(p._ATTR, k) or search(p)
                            if v then
                                return v
                            end
                        end
                    end -- search

                    v = search(class)
                    t[k] = v      -- save for next access
                    return v
                end
end

function with (class, ...)
    local arg = {...}
    local role
    for i = 1, #arg do
        local v = arg[i]
        if role and basic_type(v) == 'table' then
            if v.alias then
                local alias = v.alias
                if basic_type(alias) ~= 'table' then
                    argerror('with-alias', i, "table expected")
                end
                for old, new in pairs(alias) do
                    if basic_type(old) ~= 'string' then
                        argerror('with-alias', i, "string expected")
                    end
                    if basic_type(new) ~= 'string' then
                        argerror('with-alias', i, "string expected")
                    end
                    class[new] = class[old]
                end
            end
            if v.excludes then
                local excludes = v.excludes
                if basic_type(excludes) == 'string' then
                    excludes = { excludes }
                end
                if basic_type(excludes) ~= 'table' then
                    argerror('with-excludes', i, "table or string expected")
                end
                for i, name in pairs(excludes) do
                    if basic_type(name) ~= 'string' then
                        argerror('with-excludes', i, "string expected")
                    end
                    class[name] = nil
                end
            end
            role = nil
        else
            if basic_type(v) == 'string' then
                role = require(v)
            elseif v._NAME then
                role = v
            end
            if not role or role._INIT then
                argerror('with', i, "string or Role expected")
            end

            table.insert(class._DOES, role._NAME)
            table.insert(class._ROLE, role)
            for _, v in pairs(role._STORE) do
                _G.Coat[v[1]](class, v[2], v[3])
            end
        end
    end
end

function module (modname, level)
    if basic_type(package.loaded[modname]) == 'table' then
        error("name conflict for module '" .. modname .. "'")
    end

    local M = findtable(modname)
    package.loaded[modname] = M
    M._NAME = modname
    M._M = M
    setfenv(level, M)
    return M
end

local function _class (modname)
    local M = module(modname, 4)
    setmetatable(M, {
        __index = _G,
        __call  = function (t, ...)
                      return t.new(...)
                  end,
    })
    M._ISA = { modname }
    M._PARENT = {}
    M._DOES = {}
    M._ROLE = {}
    M._MT = { __index = M }
    M._ATTR = setmetatable({}, {})
    M._BINDING = {}
    M.type = type
    M.can = can
    M.isa = isa
    M.does = does
    M.dump = dump
    M.new = function (...) return new(M, ...) end
    M.__gc = function (...) return __gc(M, ...) end
    M._INIT = function (...) return _INIT(M, ...) end
    M.has = setmetatable({}, { __newindex = function (t, k, v) has(M, k, v) end })
    M.method = setmetatable({}, { __newindex = function (t, k, v) method(M, k, v) end })
    M.overload = setmetatable({}, { __newindex = function (t, k, v) overload(M, k, v) end })
    M.override = setmetatable({}, { __newindex = function (t, k, v) override(M, k, v) end })
    M.before = setmetatable({}, { __newindex = function (t, k, v) before(M, k, v) end })
    M.around = setmetatable({}, { __newindex = function (t, k, v) around(M, k, v) end })
    M.after = setmetatable({}, { __newindex = function (t, k, v) after(M, k, v) end })
    M.bind = setmetatable({}, { __newindex = function (t, k, v) bind(M, k, v) end })
    M.extends = function (...) return extends(M, ...) end
    M.with = function (...) return with(M, ...) end
    M.memoize = function (name) return memoize(M, name) end
    local classes = Meta.classes()
    classes[modname] = M
    return M
end

function _G.class (modname)
    checktype('class', 1, modname, 'string')
    _class(modname)
end

function _G.singleton (modname)
    checktype('singleton', 1, modname, 'string')
    local M = _class(modname)
    M.instance = function (...) return instance(M, ...) end
    M.new = M.instance
end

function _G.abstract (modname)
    checktype('abstract', 1, modname, 'string')
    local M = _class(modname)
    M.new = function () error("Cannot instanciate an abstract class " .. modname) end
end

_VERSION = "0.8.3"
_DESCRIPTION = "lua-Coat : Yet Another Lua Object-Oriented Model"
_COPYRIGHT = "Copyright (c) 2009-2010 Francois Perrad"
--
-- This library is licensed under the terms of the MIT/X11 license,
-- like Lua itself.
--
