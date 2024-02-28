return {
  "nvim-neorg/neorg",
  lazy = false,
  run = ":Neorg sync-parsers", -- This is the important bit!
  config = function()
    require("neorg").setup({
      load = {
        ["core.defaults"] = {},
        ["core.integrations.treesitter"] = {},
        ["core.concealer"] = {
          config = {
            folds = false,
          },
        }, -- Adds pretty icons to your documents
        ["core.dirman"] = { -- Manages Neorg workspaces
          config = {
            workspaces = {
              notes = "~/Documents/Notes",
            },
            default_workspace = "notes",
          },
        },
      },
    })
  end,
  keys = {
    { "<leader>ni", "<cmd>Neorg index<cr>", desc = "Index" },
    { "<leader>njt", "<cmd>Neorg journal today<cr>", desc = "Journal Today" },
    { "<leader>nn", "<cmd>Neorg keybind norg core.dirman.new.note<cr>", desc = "New note" },
  },
}
