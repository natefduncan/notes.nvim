local utils = require("notes.utils")

local M = {}

--(%d, body): numbered footnote
--(%a, body): footnote
--(nil, body): inline note
local function find_pattern (pattern, content)
    local t = {}
    for m in string.gmatch(content, pattern) do
        table.insert(t, m)
    end
    return t
end

local function get_min(t)
    local min = math.huge
    for _, v in pairs(t) do
        if v == nil then goto continue end
        min = min < v and min or v
        ::continue::
    end
    return min
end

local function find_footnotes (content)
    local pattern_n = "%[%^(%d-)%][^:]"
    local pattern_s = "%[%^(%a-)%][^:]"
    local pattern_in = "%^%[(.-)%]"
    local t = {}
    local i = 0
    while true do
        -- search patterns
        local i_n, _, ref_n = string.find(content, pattern_n, i+1)
        local i_s, _, ref_s = string.find(content, pattern_s, i+1)
        local i_in, _, body_in = string.find(content, pattern_in, i+1)

        -- find min
        local i_min = get_min({i_n, i_s, i_in})
        if i_min == nil or i_min == math.huge then break end

        -- foonotes
        if i_min == i_n or i_min == i_s then
            local body_pattern
            local ref
            -- numbered footnote
            if i_min == i_n then
                body_pattern = "%[%^" .. ref_n .. "%]: (.-\n)"
                ref = ref_n
                i = i_n or i
            end

            -- footnote
            if i_min == i_s then
                body_pattern = "%[%^" .. ref_s .. "%]: (.-\n)"
                ref = ref_s
                i = i_s or i
            end

            local _, _, body = string.find(content .. "\n", body_pattern)
            table.insert(t, {ref, body})
        end

        -- inline notes
        if i_min == i_in then
            table.insert(t, {nil, body_in})
            i = i_in or i
       end
    end
    return t
end

function M.find_footnotes()
    local content = utils.buffer_to_string()
    print(utils.dump(find_footnotes(content)))
end

local function replace_ref(old_ref, new_ref)
    local cmd = [[%s/\[^]]
    .. old_ref
    .. [[\]/\[^]]
    .. new_ref
    .. [[\]/g]]
    vim.api.nvim_command(cmd)
end

function M.reorder_footnotes()
    local content = utils.buffer_to_string()
    local footnotes = find_footnotes(content)
    local holders = {}
    for i, note in pairs(footnotes) do
        local ref = note[1]
        if tonumber(ref) ~= nil then
            local holder = "{" .. i .. "}"
            replace_ref(ref, holder)
            holders[holder] = i
        end
    end
    -- Replace holders
    for holder, i in pairs(holders) do
        replace_ref(holder, i)
    end
end

function M.insert_footnote()
    -- Insert zero footnote
    local row, col
    row, col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { "[^0]" })

    -- New buffer
    vim.api.nvim_command(":below 4split")
    vim.api.nvim_command('norm! Go')
    row, col = unpack(vim.api.nvim_win_get_cursor(0))

    -- Insert footnote body
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { "[^0]: " })
    vim.api.nvim_command('norm! A')

    -- Reorder
    M.reorder_footnotes()
end

return M
