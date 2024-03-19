-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.winbar = "%=%m %f"
vim.opt.mouse = ""
vim.o.termguicolors = true

function ChangeLspServerPort(lspServerName, newPort)
  -- Stop the specified LSP server
  vim.cmd("LspStop " .. lspServerName)
  -- Give it a moment to stop; adjust as necessary
  vim.wait(500, function() end)
  -- Setup the LSP server again with the new port
  require("lspconfig")[lspServerName].setup({
    cmd = { "nc", "localhost", tostring(newPort) },
  })
  -- Start the LSP server again
  vim.cmd("LspStart " .. lspServerName)
end
