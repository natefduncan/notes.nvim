local footnotes = require("notes.footnotes")

local M = {}

M.find_footnotes = footnotes.find_footnotes
M.reorder_footnotes = footnotes.reorder_footnotes
M.insert_footnote = footnotes.insert_footnote
M.sort_footer = footnotes.sort_footer

return M
