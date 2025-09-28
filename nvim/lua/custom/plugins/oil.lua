return {
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      vim.api.nvim_set_hl(0, 'OilWinbarCWD',  { link = 'Directory' })
      vim.api.nvim_set_hl(0, 'OilWinbarPath', { link = 'Text' })
      vim.api.nvim_set_hl(0, 'OilWinbarSep',  { link = 'Text' })

      CustomOilBar = function()
        local ok, oil = pcall(require, 'oil')
        if not ok then return '' end

        local dir = oil.get_current_dir()
        if not dir then return '' end

        local cwd = vim.fn.getcwd(0, 0)

        local function noslash(p) return (p or ''):gsub('/+$', '') end
        local function strip_scheme(p) return (p or ''):gsub('^oil[%-%w]*://', '') end

        local dir_clean = noslash(strip_scheme(dir))
        local cwd_clean = noslash(cwd)

        local dir_disp
        local inside = false
        if dir_clean:sub(1, #cwd_clean) == cwd_clean and #dir_clean > #cwd_clean then
          dir_disp = vim.fn.fnamemodify(dir, ':.')
          inside = true
        else
          dir_disp = strip_scheme(dir)
        end

        local cwd_disp = vim.fn.fnamemodify(cwd, ':~') 

        if dir_clean == cwd_clean then
          return table.concat({
            '%#OilWinbarCWD#', ' ', cwd_disp, '%*'
          })
        end

        local sep = "❰!❱"

        if inside then
          sep = "›"
        end

        return table.concat({
          '%#OilWinbarCWD#',  ' ', cwd_disp, '%*',
          ' ', '%#OilWinbarSep#', sep, '%*', ' ',
          '%#OilWinbarPath#', dir_disp, '%*',
        })
      end

      local oil = require('oil')
      local utils = require("custom.utils");

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
          ['gr'] = 'actions.refresh',
          ['gw'] = { "actions.cd", mode = "n" },
          ["T"] = utils.open_oil_nav_tab
        },
        win_options = {
          winbar = '%!v:lua.CustomOilBar()',
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

      vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = '[E]xplorer' })
    end,
  },
}
