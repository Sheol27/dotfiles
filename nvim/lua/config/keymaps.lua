-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Basics
vim.keymap.set("i", "fj", "<Esc>la")
vim.keymap.set("i", "fk", "<C-o>A")
vim.keymap.set("i", "jj", "<Esc>")
vim.keymap.set("i", "JJ", "<Esc>")
vim.keymap.set("t", "JJ", "<C-\\><C-n>", { noremap = true })
vim.keymap.set("t", "jj", "<C-\\><C-n>", { noremap = true })
