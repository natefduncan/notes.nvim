" Title:        Md-Footnotes
" Description:  Plugin for markdown style footnotes

" Ignore if already loaded
if exists("g:loaded_md_footnotes")
    finish
endif
let g:loaded_md_footnotes= 1

" Defines a package path
let s:lua_deps_loc =  expand("<sfile>:h:r") . "/../lua/md-footnotes/plugin/deps"
exe "lua package.path = package.path .. ';" . s:lua_deps_loc . "/lua-?/init.lua'"

" Define commands
command! -nargs=0 FindFootnotes lua require("md-footnotes").find_footnotes()
command! -nargs=0 FindInlineNotes lua require("md-footnotes").find_inline_notes()

" This is an inline note. ^[inline note]
" This is a reference[^1]
" [^1]: This is the reference body.
