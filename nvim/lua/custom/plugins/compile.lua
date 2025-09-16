return {
  "ej-shafran/compile-mode.nvim",
  version = "^5.0.0",
  dependencies = { 
    "nvim-lua/plenary.nvim",
    { "m00qek/baleia.nvim", tag = "v1.4.0" },
  },
  dev = true,
  config = function()
    local levels = require("compile-mode.errors").level

    ---@type CompileModeOpts
    vim.g.compile_mode = {
      -- debug = true,
      baleia_setup = true,
      bang_expansion = true,
      default_command = "",
      error_regexp_table = {
        rust = {
          regex = "^.*\\( -->\\|panicked at\\) \\(.*\\):\\([0-9]\\+\\):\\([0-9]\\+\\)",
          filename = 2,
          row = 3,
          col = 4,
        }
      }
    }
  end
}
