return {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    config = function()
        local mc = require("multicursor-nvim")
        mc.setup()

        local set = vim.keymap.set

        set({"n", "x"}, "<leader><up>", function() mc.lineAddCursor(-1) end, { desc = "Add new cursor up"})
        set({"n", "x"}, "<leader><down>", function() mc.lineAddCursor(1) end, { desc = "Add new cursor down"})

        -- Add or skip adding a new cursor by matching word/selection
        set({"n", "x"}, "<leader>mn", function() mc.matchAddCursor(1) end, { desc = "Add new cursor by match (f)"})
        set({"n", "x"}, "<leader>mN", function() mc.matchAddCursor(-1) end, { desc = "Add new cursor by match (b)"})

        mc.addKeymapLayer(function(layerSet)
            layerSet("n", "<esc>", function()
                if not mc.cursorsEnabled() then
                    mc.enableCursors()
                else
                    mc.clearCursors()
                end
            end)
        end)

        -- Customize how cursors look.
        local hl = vim.api.nvim_set_hl
        hl(0, "MultiCursorCursor", { reverse = true })
        hl(0, "MultiCursorVisual", { link = "Visual" })
        hl(0, "MultiCursorSign", { link = "SignColumn"})
        hl(0, "MultiCursorMatchPreview", { link = "Search" })
        hl(0, "MultiCursorDisabledCursor", { reverse = true })
        hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
        hl(0, "MultiCursorDisabledSign", { link = "SignColumn"})
    end
}
