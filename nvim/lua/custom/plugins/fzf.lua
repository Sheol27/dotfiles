return {
  'ibhagwan/fzf-lua',
  cmd = 'FzfLua',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
  previewers = {
        builtin = {
          syntax_limit_b = 1024 * 100, -- 100KB
        },
      },
    lsp = {
      symbols = {
        symbol_hl = function(s)
          return 'TroubleIcon' .. s
        end,
        symbol_fmt = function(s)
          return s:lower() .. '\t'
        end,
        child_prefix = false,
      },
      code_actions = {
        previewer = vim.fn.executable 'delta' == 1 and 'codeaction_native' or nil,
      },
    },
    keymap = {
      fzf = {
        ["ctrl-q"] = "select-all+accept",
      },
    },
  },
  keys = {
    -- { '<leader>s/', '<cmd>FzfLua grep_curbuf<cr>', desc = '[/] Fuzzily search in current buffer' },
    { '<leader>/', '<cmd>FzfLua grep_curbuf<cr>', desc = '[/] Fuzzily search in current buffer' },
    { '<leader>sh', '<cmd>FzfLua helptags<cr>', desc = '[S]earch [H]elp' },
    { '<leader>sk', '<cmd>FzfLua keymaps<cr>', desc = '[S]earch [K]eymaps' },
    { '<leader><leader>', '<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>', desc = '[ ] Find existing buffers' },
    { '<leader>sf', '<cmd>FzfLua files<cr>', desc = '[S]earch [F]iles' },
    { '<leader>ss', '<cmd>FzfLua builtin<cr>', desc = '[S]earch [S]elect FzfLua' },
    { '<leader>sw', '<cmd>FzfLua grep_cword<cr>', desc = '[S]earch current [W]ord' },
    { '<leader>sg', '<cmd>FzfLua live_grep<cr>', desc = '[S]earch by [G]rep' },
    { '<leader>sd', '<cmd>FzfLua diagnostics<cr>', desc = '[S]earch [D]iagnostics' },
    { '<leader>sr', '<cmd>FzfLua resume<cr>', desc = '[S]earch [R]esume' },
    { '<leader>sm', '<cmd>FzfLua marks<cr>', desc = '[S]earch [M]arks' },
    { '<leader>s.', '<cmd>FzfLua oldfiles<cr>', desc = '[S]earch Recent Files ("." for repeat)' },
    -- { 'gd', '<cmd>FzfLua lsp_definitions<cr>', desc = '[G]oto [D]efinition' },
    { 'gr', '<cmd>FzfLua lsp_references<cr>', desc = '[G]oto [R]eferences' },
    { 'gI', '<cmd>FzfLua lsp_implementations<cr>', desc = '[G]oto [I]mplementation' },
    { '<leader>D', '<cmd>FzfLua lsp_type_definitions<cr>', desc = 'Type [D]efinition' },
    { '<leader>ds', '<cmd>FzfLua lsp_document_symbols<cr>', desc = '[D]ocument [S]ymbols' },
    { '<leader>ws', '<cmd>FzfLua lsp_workspace_symbols<cr>', desc = '[W]orkspace [S]ymbols' },
    { '<leader>ca', '<cmd>FzfLua lsp_code_actions<cr>', desc = 'LSP: [C]ode [A]ctions' },

  },
}
