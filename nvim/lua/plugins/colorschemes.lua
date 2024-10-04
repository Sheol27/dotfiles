return {
  {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    config = function()
      require("catppuccin").setup({
        transparent_background = true,
      })
    end,
  },
  { "ellisonleao/gruvbox.nvim", lazy = false, opts = { transparent_mode = true } },
  {
    "sainnhe/sonokai",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.sonokai_enable_italic = true
      vim.g.sonokai_style = "shusia"
      vim.g.sonokai_transparent_background = 2
      vim.g.sonokai_diagnostic_text_highlight = 1
      vim.g.sonokai_diagnostic_virtual_text = "colored"
      -- vim.g.sonokai_inlay_hints_background = "dimmed"
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "sonokai",
    },
  },
}
