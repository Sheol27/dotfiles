return {
  'NeogitOrg/neogit',
  event = 'VeryLazy',
  lazy = true,
  dependencies = {
    'nvim-lua/plenary.nvim', -- required
    'sindrets/diffview.nvim', -- optional - Diff integration

    'ibhagwan/fzf-lua', -- optional
  },
  config = true,
  keys = { { '<leader>gg', '<cmd>Neogit<CR>', mode = { 'n' }, desc = 'Open Neogit' } },
}
