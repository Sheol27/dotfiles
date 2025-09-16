return {
  {
    'NeogitOrg/neogit',
    event = 'VeryLazy',
    lazy = true,
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      'sindrets/diffview.nvim', -- optional - Diff integration

      'ibhagwan/fzf-lua', -- optional
    },
    config = function()
      require('neogit').setup {
        integrations = {
          diffview = true,
          fzf_lua = true
        }
      }
      vim.api.nvim_create_autocmd('User', {
        pattern = 'NeogitStatusRefreshed',
        callback = function()
          vim.cmd 'set autoread | checktime'
        end,
      })
    end,
    keys = { { '<leader>gg', '<cmd>Neogit<CR>', mode = { 'n' }, desc = 'Open Neogit' } },
  },
  {
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Jump to next git [c]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Jump to previous git [c]hange' })

        -- Actions
        -- visual mode
        map('v', '<leader>ghs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'git [s]tage hunk' })
        map('v', '<leader>ghr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'git [r]eset hunk' })
        -- normal mode
        map('n', '<leader>ghs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
        map('n', '<leader>ghr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
        map('n', '<leader>ghS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
        map('n', '<leader>ghu', gitsigns.stage_buffer, { desc = 'git [u]ndo stage hunk' })
        map('n', '<leader>ghR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
        map('n', '<leader>ghp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
        map('n', '<leader>ghb', gitsigns.blame_line, { desc = 'git [b]lame line' })
        map('n', '<leader>ghd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
        map('n', '<leader>ghD', function()
          gitsigns.diffthis '@'
        end, { desc = 'git [D]iff against last commit' })
        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
        map('n', '<leader>tD', gitsigns.preview_hunk_inline, { desc = '[T]oggle git show [D]eleted' })
      end,
    },
    keys = {
      { '<leader>gc', '<cmd>FzfLua git_commits<CR>', desc = 'Commits' },
      { '<leader>gs', '<cmd>FzfLua git_status<CR>', desc = 'Status' },
    },
  },
}
