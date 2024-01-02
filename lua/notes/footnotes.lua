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
                body_pattern = "%[%^" .. ref_n .. "%]: (.-)\n"
                ref = ref_n
                i = i_n or i
            end

            -- footnote
            if i_min == i_s then
                body_pattern = "%[%^" .. ref_s .. "%]: (.-)\n"
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

function M.sort_footer()
    local content = utils.buffer_to_string()
    local footnotes = find_footnotes(content)
    local cur_row, cur_col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_command(": norm! G")
    local last_row, _ = unpack(vim.api.nvim_win_get_cursor(0))

    -- Find start and end row for footnotes
    local end_row
    local start_row
    for i = last_row, 1, -1 do
        vim.api.nvim_command(":" .. last_row)
        local current_line = vim.api.nvim_get_current_line()
        local is_footer = utils.string_starts(current_line, [[[^]])
        if is_footer then
            if end_row == nil then end_row = last_row end
            start_row = last_row
        end
        if start_row ~= nil and end_row ~= nil and is_footer == false then break end
        last_row = last_row - 1
    end

    -- Get footnotes
    local footer = {}
    for _, note in pairs(footnotes) do
        if note[1] ~= nil then
            table.insert(footer, note)
        end
    end

    -- Delete footer rows
    vim.api.nvim_command(":" .. start_row)
    vim.api.nvim_command(": norm! " .. end_row - start_row + 1 .. "ddj")

    -- Insert footer in correct order
    for i = 1, #footer do
        vim.api.nvim_command(": norm! o")
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local ref = footer[i][1]
        local body = footer[i][2]
        vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { "[^" .. ref .. "]: " ..  body})
    end
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
    M.sort_footer()
end

function M.insert_footnote()
    -- Insert zero footnote
    local row, col
    row, col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_buf_set_text(0, row - 1, col+1, row - 1, col+1, { "[^0]" })

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
