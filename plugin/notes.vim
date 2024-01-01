" Title:        Notes
" Description:  Plugin for markdown style footnotes

" Ignore if already loaded
if exists("g:loaded_notes")
    finish
endif
let g:loaded_notes= 1

" Defines a package path
let s:lua_deps_loc =  expand("<sfile>:h:r") . "/../lua/notes/plugin/deps"
exe "lua package.path = package.path .. ';" . s:lua_deps_loc . "/lua-?/init.lua'"

" Define commands
command! -nargs=0 FindFootnotes lua require("notes").find_footnotes()
command! -nargs=0 FindInlineNotes lua require("notes").find_inline_notes()

" This is an inline note. ^[inline note]
" This is a reference[^1]
" [^1]: This is the reference body.
