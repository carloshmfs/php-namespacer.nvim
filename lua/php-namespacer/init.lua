local M = {}

function M:setup()
    vim.api.nvim_create_user_command("PhpAutoSort", function ()
        if vim.fn.expand("%:e") ~= "php" then
            print("You are not on a PHP file")
            return
        end

        local buf = vim.api.nvim_get_current_buf()

        local parser = vim.treesitter.get_parser(buf)
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

        for id, node in query_obj:iter_captures(root, 0, 0, -1) do
            local node_type = node:type()
            local start_row, start_col, end_row, end_col = node:range()

            print(string.format("Node: %s, Range: [%d, %d] - [%d, %d]", node_type, start_row, start_col, end_row, end_col))
        end
    end, {})
end

return M

