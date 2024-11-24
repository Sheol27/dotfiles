-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<Ctrl-d>", "<Ctrl-d>zz")
vim.keymap.set("n", "<Ctrl-u>", "<Ctrl-u>zz")
vim.keymap.set("n", "<leader>fx", ":!chmod +x %<CR>", { desc = "Make file executable" })

vim.keymap.set("n", "<Esc><cr>", "<cmd>ToggleTerm direction=float<cr>", { desc = "Terminal (Root Dir)" })

vim.keymap.set("t", "<Esc><cr>", "<cmd>close<cr>", { desc = "Hide Terminal" })

vim.keymap.set("n", "<leader><tab>s", "<cmd>tab split<CR>", { desc = "Tab split" })

-- Lua function to capitalize each word in selection
function capitalize_words()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  -- Get the selected text
  local lines = vim.fn.getline(start_pos[2], end_pos[2])

  -- Concatenate lines into a single string
  local text = table.concat(lines, "\n")

  -- Capitalize each word
  text = string.gsub(text, "%f[%w]%w*", function(word)
    return string.gsub(word, "^%l", string.upper)
  end)

  -- Replace the selection with the capitalized text
  vim.fn.setline(start_pos[2], vim.split(text, "\n"))
end

-- Keymap to capitalize words in visual mode
vim.api.nvim_set_keymap(
  "v",
  "<leader>bc",
  ":lua capitalize_words()<CR>",
  { noremap = true, silent = true, desc = "Capitalize each word" }
)
