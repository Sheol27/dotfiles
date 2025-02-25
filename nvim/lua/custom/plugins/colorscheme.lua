return {
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    init = function()
      -- vim.cmd.colorscheme 'tokyonight'
      vim.cmd.hi 'Comment gui=none'
    end,
    opts = {
      transparent = true,
    },
  },
  {
    'sainnhe/sonokai',
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.sonokai_enable_italic = true
      vim.g.sonokai_style = 'espresso'
      vim.cmd.colorscheme 'sonokai'
    end,
  },
}
