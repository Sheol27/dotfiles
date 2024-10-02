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
      vim.g.sonokai_style = "atlantis"
    end,
  },
  {
    "rebelot/kanagawa.nvim",
    opts = {
      transparent = true,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-frappe",
    },
  },
}
