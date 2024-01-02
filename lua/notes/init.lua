local footnotes = require("notes.footnotes")

local function insert_blockquotes()
    vim.api.nvim_command("'<,'>s!^!> !")
end

local M = {}

M.find_footnotes = footnotes.find_footnotes
M.reorder_footnotes = footnotes.reorder_footnotes
M.insert_footnote = footnotes.insert_footnote
M.sort_footer = footnotes.sort_footer
M.insert_blockquotes = insert_blockquotes

return M
