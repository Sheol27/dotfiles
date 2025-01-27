vim.keymap.set('n', '<Esc><cr>', '<cmd>ToggleTerm direction=float<cr>', { desc = 'Terminal (Root Dir)' })
vim.keymap.set('t', '<Esc><cr>', '<cmd>close<cr>', { desc = 'Hide Terminal' })

vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<cr>', { desc = 'Delete buffer' })
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definiton' })

vim.keymap.set('n', '<leader><tab>s', '<cmd>tab split<CR>', { desc = 'Tab split' })
