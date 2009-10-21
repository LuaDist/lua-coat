
--
-- lua-Coat : <http://lua-coat.luaforge.net/>
--

local pairs = pairs

local mc = require 'Coat.Meta.Class'
local mr = require 'Coat.Meta.Role'

module 'Coat.UML'

local function escape (txt)
    txt = txt:gsub( '&', '&amp;' )
    txt = txt:gsub( '<', '&lt;' )
    txt = txt:gsub( '>', '&gt;' )
    return txt
end

function to_dot ()
    local out = 'digraph {\n\n    node [shape=record];\n\n'
    for classname, class in pairs(mc.classes()) do
        out = out .. '    "' .. classname .. '"\n'
        out = out .. '        [label="{'
        if class.instance then
            out = out .. '&laquo;singleton&raquo;\\n'
        end
        out = out .. '\\N'
        local first = true
        for name, attr in mc.attributes(class) do
            if first then
                out = out .. '|'
                first = false
            end
            out = out .. name
            if attr.is then
                out = out .. ', is ' .. attr.is
            end
            if attr.isa then
                out = out .. ', isa ' .. escape(attr.isa)
            end
            if attr.does then
                out = out .. ', does ' .. attr.does
            end
            out = out .. '\\l'
        end
        first = true
        for name in mc.metamethods(class) do
            if first then
                out = out .. '|'
                first = false
            end
            out = out .. name .. '()\\l'
        end
        for name in mc.methods(class) do
            if first then
                out = out .. '|'
                first = false
            end
            out = out .. name .. '()\\l'
        end
        out = out .. '}"];\n'
        for name, attr in mc.attributes(class) do
            if attr.isa and mc.class(attr.isa) then
                out = out .. '    "' .. classname .. '" -> "' .. attr.isa .. '" // has\n'
                out = out .. '        [label = "' .. name .. '", arrowhead = none, arrowtail = odiamond];\n'
            end
            if attr.does and mr.role(attr.does) then
                out = out .. '    "' .. classname .. '" -> "' .. attr.does .. '" // has\n'
                out = out .. '        [label = "' .. name .. '", arrowhead = none, arrowtail = odiamond];\n'
            end
        end
        for parent in mc.parents(class) do
            out = out .. '    "' .. classname .. '" -> "' .. parent .. '" // extends\n'
            out = out .. '        [arrowhead = onormal, arrowtail = none, arrowsize = 2.0];\n'
        end
        for role in mc.roles(class) do
            out = out .. '    "' .. classname .. '" -> "' .. role .. '" // with\n'
            out = out .. '        [arrowhead = odot, arrowtail = none];\n'
        end
        out = out .. '\n'
    end
    for rolename, role in pairs(mr.roles()) do
        out = out .. '    "' .. rolename .. '"\n'
        out = out .. '        [label="{&laquo;role&raquo;\\n\\N'
        local first = true
        for name, attr in mr.attributes(role) do
            if first then
                out = out .. '|'
                first = false
            end
            out = out .. name
            if attr.is then
                out = out .. ', is ' .. attr.is
            end
            if attr.isa then
                out = out .. ', isa ' .. escape(attr.isa)
            end
            if attr.does then
                out = out .. ', does ' .. attr.does
            end
            out = out .. '\\l'
        end
        first = true
        for name in mr.methods(role) do
            if first then
                out = out .. '|'
                first = false
            end
            out = out .. name .. '()\\l'
        end
        out = out .. '}"];\n\n'
        for name, attr in mr.attributes(role) do
            if attr.isa and mc.class(attr.isa) then
                out = out .. '    "' .. rolename .. '" -> "' .. attr.isa .. '" // has\n'
                out = out .. '        [label = "' .. name .. '", arrowhead = none, arrowtail = odiamond];\n'
            end
            if attr.does and mr.role(attr.does) then
                out = out .. '    "' .. rolename .. '" -> "' .. attr.does .. '" // has\n'
                out = out .. '        [label = "' .. name .. '", arrowhead = none, arrowtail = odiamond];\n'
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
