package = 'lua-Coat'
version = '0.3.0-1'
source = {
    url = 'http://cloud.github.com/downloads/fperrad/lua-Coat/lua-coat-0.3.0.tar.gz',
    md5 = 'cd7d40e0a846f85ac0b8ce8977cdca36',
}
description = {
    summary = "Yet Another Lua Object-Oriented Model",
    detailed = [[
        lua-Coat is a Lua 5.1 port of Coat (http://www.sukria.net/perl/coat/),
        a Perl5 module which mimics Moose (http://www.iinteractive.com/moose/),
        an object system for Perl5 which borrows features from Perl6,
        CLOS (LISP), Smalltalk and many other languages.
    ]],
    homepage = 'http://lua-coat.luaforge.net/',
    maintainer = 'Francois Perrad',
    license = 'MIT/X11'
}
dependencies = {
    'lua >= 5.1',
}
build = {
    type = 'module',
    modules = {
        ['Coat']                = 'src/Coat.lua',
        ['Coat.Meta']           = 'src/Coat/Meta.lua',
        ['Coat.Role']           = 'src/Coat/Role.lua',
        ['Coat.Types']          = 'src/Coat/Types.lua',
    },
    copy_directories = { 'doc', 'patch', 'test' },
}
