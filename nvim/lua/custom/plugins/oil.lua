return {
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      CustomOilBar = function()
        local path = vim.fn.expand '%'
        path = path:gsub('oil://', '')

        return '  ' .. vim.fn.fnamemodify(path, ':.')
      end

      local oil = require('oil')
      oil.setup {
        columns = { 'icon', "permissions", "size", "mtime" },
        keymaps = {
          ['<C-e>'] = 'actions.open_external',
          ['<C-y>'] = 'actions.yank_entry',
          ['<C-h>'] = false,
          ['<C-l>'] = false,
          ['<C-k>'] = false,
          ['<C-j>'] = false,
          ['<M-h>'] = 'actions.select_split',
          ['g-'] = 'actions.cd',
          ["<leader>f"] = {
            callback = function()
              local dir = oil.get_current_dir()
              if not dir then return end
              local ok, fzf = pcall(require, "fzf-lua")
              if not ok then
                vim.notify("fzf-lua not found", vim.log.levels.ERROR)
                return
              end
              fzf.files({ cwd = dir })
            end,
            desc = "fzf-lua files in current oil dir",
          },
        },
        win_options = {
          winbar = '%{v:lua.CustomOilBar()}',
        },
        delete_to_trash = true,
        view_options = {
          show_hidden = true,
          is_always_hidden = function(name, _)
            local folder_skip = { 'dev-tools.locks', 'dune.lock', '_build' }
            return vim.tbl_contains(folder_skip, name)
          end,
        },

        silence_scp_warning = true,
        extra_scp_args = { '-O' },
      }

      vim.keymap.set('n', '-', '<CMD>Oil --float<CR>', { desc = '[E]xplorer' })
    end,
  },
}
