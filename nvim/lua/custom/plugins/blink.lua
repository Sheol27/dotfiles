return {
  'saghen/blink.cmp',
  dependencies = { 'rafamadriz/friendly-snippets' },

  version = '1.*',
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = { 
      preset = 'default',
      ['<C-space>'] = false,
      ['<C-e>'] = {'show', 'fallback'},
      ['<C-n>'] = {'select_next', 'fallback'},
      ['<C-p>'] = {'select_prev', 'fallback'},
    },
    appearance = {
      nerd_font_variant = 'mono'
    },

    completion = { 
      menu = { auto_show = false } ,
      documentation = { auto_show = false } ,
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" }
}
