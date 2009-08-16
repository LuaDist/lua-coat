
--
-- lua-Coat : <http://lua-coat.luaforge.net/>
--

require 'Coat'

local ipairs = ipairs
local setfenv = setfenv
local setmetatable = setmetatable
local _G = _G
local package = package
local table = table

local checktype = Coat.checktype

module 'Coat.Role'

function has (role, name, options)
    checktype('has', 1, name, 'string')
    checktype('has', 2, options or {}, 'table')
    table.insert(role._STORE, { 'has', name, options })
end

function method (role, name, func)
    checktype('method', 1, name, 'string')
    checktype('method', 2, func, 'function')
    table.insert(role._STORE, { 'method', name, func })
end

function requires (role, ...)
    for i, meth in ipairs{...} do
        checktype('requires', i, meth, 'string')
        table.insert(role._REQ, meth)
    end
end

function excludes (role, ...)
    for i, r in ipairs{...} do
        checktype('excludes', i, r, 'string')
        table.insert(role._EXCL, r)
    end
end

local roles = {}
function _G.Coat.Meta.roles ()
    return roles
end

function _G.Coat.Meta.role (name)
    return roles[name]
end

function _G.role (modname)
    checktype('role', 1, modname, 'string')
    if _G[modname] then
        error("name conflict for module '" .. modname .. "'")
    end

    local M = {}
    _G[modname] = M
    package.loaded[modname] = M
    setmetatable(M, { __index = _G })
    setfenv(2, M)
    M._NAME = modname
    M._M = M
    M._STORE = {}
    M._REQ = {}
    M._EXCL = {}
    M.has = function (...) return has(M, ...) end
    M.method = function (...) return method(M, ...) end
    M.requires = function (...) return requires(M, ...) end
    M.excludes = function (...) return excludes(M, ...) end
    roles[modname] = M
end

--
-- Copyright (c) 2009 Francois Perrad
--
-- This library is licensed under the terms of the MIT/X11 license,
-- like Lua itself.
--
