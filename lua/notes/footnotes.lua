local utils = require("notes.utils")

local M = {}

local function find_pattern (pattern, content)
    local t = {}
    for m in string.gmatch(content, pattern) do
        table.insert(t, m)
    end
    return t
end

function M.find_footnotes()
    local pattern = "%[%^.-%]"
    local content = utils.buffer_to_string()
    print(utils.dump(find_pattern(pattern, content)))
end

function M.find_inline_notes()
    local pattern = "%^%[.-%]"
    local content = utils.buffer_to_string()
    print(utils.dump(find_pattern(pattern, content)))
end

return M
