
--
-- lua-Coat : <http://github.com/fperrad/lua-Coat/>
--

require 'Coat'

module(..., package.seeall)

local checktype = Coat.checktype

function has (role, name, options)
    checktype('has', 1, name, 'string')
    options = options or {}
    checktype('has', 2, options, 'table')
    table.insert(role._STORE, { 'has', name, options })
end

function method (role, meth, name, func)
    checktype(meth, 1, name, 'string')
    checktype(meth, 2, func, 'function')
    table.insert(role._STORE, { meth, name, func })
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
    M.method = function (...) return method(M, 'method', ...) end
    M.override = function (...) return method(M, 'override', ...) end
    M.before = function (...) return method(M, 'before', ...) end
    M.around = function (...) return method(M, 'around', ...) end
    M.after = function (...) return method(M, 'after', ...) end
    M.requires = function (...) return requires(M, ...) end
    M.excludes = function (...) return excludes(M, ...) end
    roles[modname] = M
end

--
-- Copyright (c) 2009 Francois Perrad
--
-- This library is licensed under the terms of the MIT/X11 license, like Lua itself.
--
