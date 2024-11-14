return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "work",
        path = "~/obsidian/work",
      },
    },
    daily_notes = {
      folder = "Journal",
    },

    ---@param title string|?
    ---@return string
    note_id_func = function(title)
      local suffix = ""
      if title ~= nil then
        -- If title is given, transform it into valid file name.
        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        -- If title is nil, just add 4 random uppercase letters to the suffix.
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return suffix
    end,
  },
  keys = {
    { "<leader>zd", "<cmd>ObsidianToday<cr>", desc = "Daily notes" },
    { "<leader>zz", "<cmd>ObsidianNew<cr>", desc = "New note" },
    { "<leader>zo", "<cmd>ObsidianSearch<cr>", desc = "Find and open note" },
    { "<leader>ze", "<cmd>ObsidianExtractNote<cr>", desc = "Extract text into new note" },
    { "<leader>zw", "<cmd>ObsidianWorkspace<cr>", desc = "Change workspace" },
  },
}
