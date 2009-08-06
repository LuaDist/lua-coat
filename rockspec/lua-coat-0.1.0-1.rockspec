package = 'lua-Coat'
version = '0.1.0-1'
source = {
    url = 'http://github.com/fperrad/lua-Coat/download/lua-coat-0.1.0.tar.gz',
    md5 = 'cd9a4581e3dd281cecb9a72ddf27c2ac',
}
description = {
    summary = "Yet a Another Lua Object-Oriented Model",
    detailed = [[
Perl5, like Lua, has no OO model, just OO mechanism.
This allows a proliferation (or experimentation) of different model.

Now with [Moose][], Perl5 find its _ultimate_ OO model.
Moose borrows all the best features from Perl6, CLOS (LISP), Smalltalk
and many other languages.
Moose is built on top of a metaobject protocol, with full introspection.

[Coat][] is light-weight Perl5 module which just mimics Moose.

Finally, lua-Coat is the Lua port of Coat.

Small lua patches allow a syntax close to Perl5 Moose. See patch/.

  [Moose]: http://www.iinteractive.com/moose/
  [Coat]: http://www.sukria.net/perl/coat/
    ]],
    homepage = 'http://github.com/fperrad/lua-Coat',
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
        ['Coat.Types']          = 'src/Coat/Types.lua',
    },
    copy_directories = { 'doc', 'patch', 'test' },
}
