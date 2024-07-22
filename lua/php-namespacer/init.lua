local M = {}

function M:setup()
    vim.api.nvim_create_user_command("PhpAutoSort", function ()
        if vim.fn.expand("%:e") ~= "php" then
            print("You are not on a PHP file")
            return
        end

        local sorter = require("php-namespacer.sorter")
        sorter.sort()
    end, {})
end

return M

