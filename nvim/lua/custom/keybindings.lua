local utils = require("custom.utils");

vim.keymap.set('n', '<Esc><cr>', '<cmd>ToggleTerm direction=float<cr>', { desc = 'Terminal (Root Dir)' })
vim.keymap.set('t', '<Esc><cr>', '<cmd>close<cr>', { desc = 'Hide Terminal' })

vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<cr>', { desc = 'Delete buffer' })
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definiton' })

vim.keymap.set('n', '<leader><tab>s', '<cmd>tab split<CR>', { desc = 'Tab split' })
vim.keymap.set('n', '<leader><tab>c', '<cmd>tabclose<CR>', { desc = 'Tab close' })

vim.keymap.set('n', ']q', ':cnext<CR>zz', { desc = 'cnext', noremap = true, silent = true })
vim.keymap.set('n', '[q', ':cprevious<CR>zz', { desc = 'cprevious', noremap = true, silent = true })

local diagnostics_enabled = false

local function ToggleDiagnostics()
  diagnostics_enabled = not diagnostics_enabled
  if diagnostics_enabled then
    local diagnostic_signs = {}

    if vim.g.have_nerd_font then
      local signs = { ERROR = '', WARN = '', INFO = '', HINT = '' }
      for type, icon in pairs(signs) do
        diagnostic_signs[vim.diagnostic.severity[type]] = icon
      end
    end

    vim.diagnostic.config {
      virtual_text = {
        prefix = '■ ',
      },
      signs = { text = diagnostic_signs },
    }

    vim.diagnostic.show()
    print 'Diagnostics ➤ ON'
  else
    vim.diagnostic.hide()
    vim.diagnostic.config {
      virtual_text = false,
      signs = false,
      underline = false,
    }
    print 'Diagnostics ➤ OFF'
  end
end

vim.keymap.set('n', '<leader>td', ToggleDiagnostics, { desc = 'Toggle LSP diagnostics' })

vim.keymap.set("n", '<leader>cc', function() 
  vim.g.compilation_directory = utils.get_oil_dir()
  vim.cmd("Compile")
end, { desc = 'Compile' })

vim.keymap.set("n", '<leader>cr', function()
  vim.g.compilation_directory = utils.get_oil_dir()
  vim.cmd("Recompile")
end, { desc = 'Recompile' })

vim.keymap.set("n", ']e', function()
  vim.cmd(tostring(vim.v.count1) .. "NextError")
end, { desc = 'Next compile error' })

vim.keymap.set("n", '[e', function()
  vim.cmd(tostring(vim.v.count1) .. "PrevError")
end, { desc = 'Previous compile error' })


vim.keymap.set("n", 'ge', '<Cmd>CurrentError<CR>', { desc = 'Current compile error' })
vim.keymap.set("n", 'g0', '<Cmd>FirstError<CR>', { desc = 'First compile error' })
vim.keymap.set("n", '<leader>cs', '<Cmd>QuickfixErrors<CR>', { desc = 'Send errors to qf' })
vim.keymap.set("n", '<leader>cq', function()
  require("compile-mode").close_buffer()
end, { desc = 'Close compilation buffer' })


local function smart_nav(dir)
  local wincmd = { h = "h", j = "j", k = "k", l = "l" }
  local tmux   = { h = "L", j = "D", k = "U", l = "R" }

  return function()
    local in_tmux = vim.env.TMUX ~= nil
    local cur_buf = vim.api.nvim_get_current_buf()
    local was_term = vim.fn.mode() == "t" or vim.bo[cur_buf].buftype == "terminal"
    local cur_win = vim.api.nvim_get_current_win()

    if was_term then
      pcall(vim.cmd, "stopinsert")
    else
      vim.cmd("wincmd " .. wincmd[dir])
    end

    local function finish_after_move()
      local new_win = vim.api.nvim_get_current_win()

      if new_win == cur_win then
        if in_tmux then
          local args = { "tmux", "select-pane", "-" .. tmux[dir] }
          if vim.system then
            vim.system(args)
          else
            vim.fn.system(args)
          end
        end

        if was_term then
          vim.schedule(function() pcall(vim.cmd, "startinsert") end)
        end
      else
        local buf = vim.api.nvim_win_get_buf(0)
        if vim.bo[buf].buftype == "terminal" then
          vim.schedule(function() pcall(vim.cmd, "startinsert") end)
        end
      end
    end

    vim.schedule(finish_after_move)
  end
end

local opts = { silent = true, noremap = true, desc = "Navigate splits / tmux" }
vim.keymap.set({ "n", "t" }, "<C-h>", smart_nav("h"), opts)
vim.keymap.set({ "n", "t" }, "<C-j>", smart_nav("j"), opts)
vim.keymap.set({ "n", "t" }, "<C-k>", smart_nav("k"), opts)
vim.keymap.set({ "n", "t" }, "<C-l>", smart_nav("l"), opts)

vim.keymap.set("n", "<leader>-", function()
  local initial_path = utils.get_oil_dir()

  if not initial_path then
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname ~= "" then
      initial_path = vim.fn.fnamemodify(bufname, ":p:h")
    else
      initial_path =  vim.loop.cwd()
    end
  end

  local ok, dir = pcall(vim.fn.input, "Directory: ", initial_path, "dir")

  if not ok or dir == "" then
    return
  end

  require("oil").open(dir)
end, { desc = "Open Oil in custom dir" })

vim.keymap.set('n', '<leader>ot', utils.open_oil_nav_tab, { desc = 'Oil: open navigation tab here' })
