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
command! -nargs=0 ReorderFootnotes lua require("notes").reorder_footnotes()
command! -nargs=0 InsertFootnote lua require("notes").insert_footnote()


