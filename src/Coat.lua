
--
-- lua-Coat : <http://github.com/fperrad/lua-Coat/>
--

local basic_type = type
function type (obj)
    local t = basic_type(obj)
    if t == 'table' and obj._CLASS then
        return obj._CLASS
    else
        return t
    end
end -- type

local function argerror (caller, narg, extramsg)
    error("bad argument #" .. tostring(narg) .. " to "
          .. caller .. " (" .. extramsg .. ")")
end -- argerror

local function typerror (caller, narg, arg, tname)
    argerror(caller, narg, tname .. " expected, got " .. type(arg))
end -- typerror

local function checktype (caller, narg, arg, tname)
    if basic_type(arg) ~= tname then
        typerror(caller, narg, arg, tname)
    end
end -- checktype

function class (modname)
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
    M._ISA = {modname}

    local mt = {
        __index = M,
    }

    local attrs = {}

    M.isa = function (obj, t)
        if basic_type(t) == 'table' and t._NAME then
            t = t._NAME
        end
        if basic_type(t) ~= 'string' then
            argerror('isa', 2, "string or Object/Class expected")
        end

        local function walk_type (types)
            for i, v in ipairs(types) do
                if v == t then
                    return true
                elseif basic_type(v) == 'table' then
                    local result = walk_type(v)
                    if result then
                        return result
                    end
                end
            end
            return false
        end -- walk_type

        return walk_type(obj._ISA)
    end -- isa

    M.new = function (args)
        args = args or {}
        local obj = {
            _CLASS = M._NAME, 
            values = {}
        }
        setmetatable(obj, {})
        M._INIT(obj, args)
        if M.BUILD then
            M.BUILD(obj, args)
        end
        return obj
    end -- new

    local function validate (name, options, val)
        if val and options.isa and type(val) ~= options.isa then
            error("Invalid type for attribute '" .. name .. "' (got "
                  .. type(val) .. ", expected " .. options.isa ..")")
        end
        return val
    end

    M._INIT = function (obj, args)

        local function walk_type (types)

            local function init ()
                for k, v in pairs(attrs) do
                    if not obj.values[k] then
                        local val = args[k]
                        if val ~= nil then
                            if basic_type(val) == 'function' then
                                val = val(obj)
                            end
                        else
                            local default = v.default
                            if basic_type(default) == 'function' then
                                val = default(obj)
                            else
                                val = default
                            end
                        end

                        val = validate(k, v, val)
                        obj.values[k] = val
                    end
                end

                local m = getmetatable(obj)
                for k, v in pairs(mt) do
                    if not m[k] then
                        m[k] = v
                    end
                end
            end -- init

            for i, v in ipairs(types) do
                if basic_type(v) == 'string' then
                    if v == M._NAME then
                        init()
                    else
                        package.loaded[v]._INIT(obj, args)
                    end
                else
                    walk_type(v)
                end
            end
        end -- walk_type

        walk_type(M._ISA)
    end -- _INIT

    M.has = function (name, options)
        checktype('has', 1, name, 'string')
        options = options or {}
        checktype('has', 2, options, 'table')
        attrs[name] = options

        if options.is == 'ro' then
            M[name] = function (obj, val)
                if val ~= nil then
                    error("Cannot set a read-only attribute ("
                          .. name .. ")")
                end
                return obj.values[name]
            end
        else
            M[name] = function (obj, val)
                if val ~= nil then
                    val = validate(name, options, val)
                    obj.values[name] = val
                    return val
                end
                return obj.values[name]
            end
        end
    end -- has

    M.method = function (name, func)
        checktype('method', 1, name, 'string')
        checktype('method', 2, func, 'function')
        M[name] = func
    end -- method

    M.overload = function (name, func)
        checktype('overload', 1, name, 'string')
        checktype('overload', 2, func, 'function')
        mt[name] = func
    end -- overload

    M.extends = function (...)
        local bases = {}

        for i, v in ipairs{...} do
            local base
            if basic_type(v) == 'string' then
                base = require(v)
            elseif v._NAME then
                base = v
            else
                argerror('extends', i, "string or Class expected")
            end

            if base:isa(M) then
                error("Circular class structure between '"
                      .. M._NAME .."' and '" .. base._NAME .. "'")
            end

            table.insert(bases, base)
            table.insert(M._ISA, base._ISA)
        end

        if #bases == 0 then
            error "Cannot extend without a Class name"
        end
 
        local function search (name)
            for i, b in ipairs(bases) do
                local v = b[name]
                if v then 
                    return v
                end
            end
        end -- search

        setmetatable(M, {
            __index = function (t, k) 
                          local v = rawget(t, v) or search(k)
                          t[k] = v
                          return v
                      end,
            __call  = function (t, ...)
                           return t.new(...)
                      end,
        })

        M.override = function (name, func)
            checktype('override', 1, name, 'string')
            checktype('override', 2, func, 'function')
            local super = search(name)
            if not super then
                error("Cannot override non-existent function "
                      .. name .. " in class " .. M._NAME)
            end

            local t = {}
            setmetatable(t, {__index = _G})
            t.super = super
            setfenv(func, t)
            M[name] = func
        end -- override

        M.before = function (name, func)
            checktype('before', 1, name, 'string')
            checktype('before', 2, func, 'function')
            local super = search(name)
            if not super then
                error("Cannot before non-existent function "
                      .. name .. " in class " .. M._NAME)
            end

            M[name] = function (...)
                local result = func(...)
                super(...)
                return result
            end
        end -- before

        M.around = function (name, func)
            checktype('around', 1, name, 'string')
            checktype('around', 2, func, 'function')
            local super = search(name)
            if not super then
                error("Cannot around non-existent function "
                      .. name .. " in class " .. M._NAME)
            end

            M[name] = function (...)
                return func(super,  ...)
            end
        end -- around

        M.after = function (name, func)
            checktype('after', 1, name, 'string')
            checktype('after', 2, func, 'function')
            local super = search(name)
            if not super then
                error("Cannot after non-existent function "
                      .. name .. " in class " .. M._NAME)
            end

            M[name] = function (...)
                super(...)
                return func(...)
            end
        end -- after

    end -- extends

    M.with = function (...)
        error "Roles are not yet implemented"
    end -- with

end -- class

function role (modname)
    checktype('role', 1, modname, 'string')
    if _G[modname] then
        error("name conflict for module '" .. modname .. "'")
    end

    error "Roles are not yet implemented"
end -- role

module(...) -- it's an empty module

_VERSION = "0.0"
_DESCRIPTION = "lua-Coat : Yet a Another Lua Object-Oriented Model"
_COPYRIGHT = "Copyright (c) 2009 Francois Perrad"
--
-- This library is licensed under the terms of the MIT license, like Lua itself.
--
