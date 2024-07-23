local Sorter = {}

function Sorter:get_text_buffer()
    return vim.api.nvim_get_current_buf()
end

function Sorter:get_use_declarations(text_buffer)
    local parser = vim.treesitter.get_parser(text_buffer)
    if not parser then
        print("No parser found")
        return
    end

    local tree = parser:parse()[1]
    if not tree then
        print("Failed to open parser")
        return
    end

    local root = tree:root()

    -- Create a query
    local query = [[
        (namespace_use_declaration) @use_declaration
    ]]

    local lang = vim.treesitter.language.get_lang("php")
    local query_obj = vim.treesitter.query.parse(lang, query)

    return query_obj:iter_captures(root, 0, 0, -1)
end

function Sorter:sort()
    local buffer = Sorter:get_text_buffer()
    local nodes = Sorter:get_use_declarations(buffer)

    local ast_nodes = {}
    for id, node in nodes do
        local start_row, start_col, end_row, end_col = node:range()
        table.insert(ast_nodes, node)
    end

    table.sort(ast_nodes, function (a, b)
        local _, _, _, a_end_col = a:range()
        local _, _, _, b_end_col = b:range()

        return a_end_col < b_end_col
    end)

    for i, node in ipairs(ast_nodes) do
        local node_type = node:type()
        local start_row, start_col, end_row, end_col = node:range()
        print(string.format("Index: %d Node: %s Line: %d Length: %d Content: %s", i, node_type, start_row + 1, end_col, vim.treesitter.get_node_text(node, buffer)))
    end
end


return Sorter

