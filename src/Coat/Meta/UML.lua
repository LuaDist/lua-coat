
--
-- lua-Coat : <http://lua-coat.luaforge.net/>
--

local ipairs = ipairs
local pairs = pairs

local m = require 'Coat.Meta'

module 'Coat.Meta.UML'

local reserved = {
    after = true,
    around = true,
    before = true,
    can = true,
    does = true,
    extends = true,
    has = true,
    instance = true,
    isa = true,
    method = true,
    new = true,
    overload = true,
    override = true,
    type = true,
    with = true,
    _ATTR = true,
    _DOES = true,
    _INIT = true,
    _INSTANCE = true,
    _ISA = true,
    _M = true,
    _MT = true,
    _NAME = true,
    _PARENT = true,
    _ROLE = true,
    __gc = true,
}

function to_dot ()
    local classes = m.classes()
    local roles = m.roles()
    local out = 'digraph {\n\n    node [shape=record];\n\n'
    for _, class in pairs(classes) do
        out = out .. '    "' .. class._NAME .. '"\n'
        out = out .. '        [label="{'
        if class.instance then
            out = out .. '&laquo;singleton&raquo;\\n'
        end
        out = out .. '\\N'
        local first = true
        for name, attr in pairs(class._ATTR) do
            if first then
                out = out .. '|'
                first = false
            end
            out = out .. name
            if attr.is then
                out = out .. ', is ' .. attr.is
            end
            if attr.isa then
                out = out .. ', isa ' .. attr.isa
            end
            if attr.does then
                out = out .. ', does ' .. attr.isa
            end
            out = out .. '\\l'
        end
        first = true
        for name in pairs(class._MT) do
            if name ~= '__index' then
                if first then
                    out = out .. '|'
                    first = false
                end
                out = out .. name .. '()\\l'
            end
        end
        for name in pairs(class) do
            if not reserved[name] and not class._ATTR[name] then
                if first then
                    out = out .. '|'
                    first = false
                end
                out = out .. name .. '()\\l'
            end
        end
        out = out .. '}"];\n'
        for name, attr in pairs(class._ATTR) do
            if attr.isa and classes[attr.isa] then
                out = out .. '    "' .. class._NAME .. '" -> "' .. attr.isa .. '" // has\n'
                out = out .. '        [label = "' .. name .. '", arrowhead = none, arrowtail = odiamond];\n'
            end
            if attr.does and roles[attr.does] then
                out = out .. '    "' .. class._NAME .. '" -> "' .. attr.does .. '" // has\n'
                out = out .. '        [label = "' .. name .. '", arrowhead = none, arrowtail = odiamond];\n'
            end
        end
        for _, parent in ipairs(class._PARENT) do
            out = out .. '    "' .. class._NAME .. '" -> "' .. parent._NAME .. '" // extends\n'
            out = out .. '        [arrowhead = onormal, arrowtail = none, arrowsize = 2.0];\n'
        end
        for _, role in ipairs(class._ROLE) do
            out = out .. '    "' .. class._NAME .. '" -> "' .. role._NAME .. '" // with\n'
            out = out .. '        [arrowhead = odot, arrowtail = none];\n'
        end
        out = out .. '\n'
    end
    for _, role in pairs(roles) do
        out = out .. '    "' .. role._NAME .. '"\n'
        out = out .. '        [label="{&laquo;role&raquo;\\n\\N'
        local first = true
        for _, v in ipairs(role._STORE) do
            if v[1] == 'has' then
                if first then
                    out = out .. '|'
                    first = false
                end
                local name, attr = v[2], v[3]
                out = out .. name
                if attr.is then
                    out = out .. ', is ' .. attr.is
                end
                if attr.isa then
                    out = out .. ', isa ' .. attr.isa
                end
                if attr.does then
                    out = out .. ', does ' .. attr.isa
                end
                out = out .. '\\l'
            end
        end
        first = true
        for _, v in ipairs(role._STORE) do
            if v[1] == 'method' then
                if first then
                    out = out .. '|'
                    first = false
                end
                local name = v[2]
                out = out .. name .. '()\\l'
            end
        end
        out = out .. '}"];\n\n'
        for _, v in pairs(role._STORE) do
            if v[1] == 'has' then
                local name, attr = v[2], v[3]
                if attr.isa and classes[attr.isa] then
                    out = out .. '    "' .. role._NAME .. '" -> "' .. attr.isa .. '" // has\n'
                    out = out .. '        [label = "' .. name .. '", arrowhead = none, arrowtail = odiamond];\n'
                end
                if attr.does and roles[attr.does] then
                    out = out .. '    "' .. role._NAME .. '" -> "' .. attr.does .. '" // has\n'
                    out = out .. '        [label = "' .. name .. '", arrowhead = none, arrowtail = odiamond];\n'
                end
            end
        end
    end
    out = out .. '}'
    return out
end

--
-- Copyright (c) 2009 Francois Perrad
--
-- This library is licensed under the terms of the MIT/X11 license,
-- like Lua itself.
--
