return {
  'ibhagwan/fzf-lua',
  cmd = 'FzfLua',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    lsp = {
      definitions = {
        handler = function(api, locations)
          print 'HELLo'
          if not locations or vim.tbl_isempty(locations) then
            vim.notify('No definitions found', vim.log.levels.INFO)
            return
          end
          if #locations == 1 then
            vim.lsp.util.jump_to_location(locations[1])
          else
            require('fzf-lua.providers.lsp').default_handler(api, locations)
          end
        end,
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
    { '<leader>s.', '<cmd>FzfLua oldfiles<cr>', desc = '[S]earch Recent Files ("." for repeat)' },
    -- { 'gd', '<cmd>FzfLua lsp_definitions<cr>', desc = '[G]oto [D]efinition' },
    { 'gr', '<cmd>FzfLua lsp_references<cr>', desc = '[G]oto [R]eferences' },
    { 'gI', '<cmd>FzfLua lsp_implementations<cr>', desc = '[G]oto [I]mplementation' },
    { '<leader>D', '<cmd>FzfLua lsp_type_definitions<cr>', desc = 'Type [D]efinition' },
    { '<leader>ds', '<cmd>FzfLua lsp_document_symbols<cr>', desc = '[D]ocument [S]ymbols' },
    { '<leader>ws', '<cmd>FzfLua lsp_workspace_symbols<cr>', desc = '[W]orkspace [S]ymbols' },
  },
}
