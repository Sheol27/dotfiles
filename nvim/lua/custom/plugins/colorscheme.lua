return {
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    init = function()
      vim.cmd.colorscheme 'tokyonight'
      vim.cmd.hi 'Comment gui=none'
    end,
    opts = {
      transparent = true,
    },
  },
  {
    'shaunsingh/nord.nvim',
    priority = 1000,
    init = function() end,
  },
}
