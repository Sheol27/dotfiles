local M = {}

---Return the Oil directory if we're in an Oil buffer, otherwise nil
---@return string|nil
function M.get_oil_dir()
  if vim.bo.filetype == "oil" then
    local ok, oil = pcall(require, "oil")
    if ok then
      return oil.get_current_dir()
    end
  end
  return nil
end

function M.open_oil_nav_tab()
  local ok, oil = pcall(require, 'oil')
  if not ok then return end

  local dir = (oil.get_current_dir())
  or (vim.api.nvim_buf_get_name(0) ~= '' and vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':p:h'))
  or vim.loop.cwd()

  local has_scheme = dir:match('^%w[%w%-]*://') ~= nil
  local local_dir  = dir
    :gsub('^oil[%-%w]*://', '')  
    :gsub('/+$', '')

  vim.cmd('tabnew') 
  vim.t.nav_tab = true            
  if not has_scheme then         
    vim.cmd('tcd ' .. vim.fn.fnameescape(local_dir))
  end

  oil.open(has_scheme and dir or local_dir)
end



function _G.CustomTabline()
  local out = {}
  local current = vim.api.nvim_get_current_tabpage()
  for i, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local hl = (tab == current) and "%#TabLineSel#" or "%#TabLine#"
    local win = vim.api.nvim_tabpage_get_win(tab)
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)

    local tvars = vim.t[tab]
    local label

    if tvars and tvars.nav_tab then
      local dir = name
      if name:match("^oil[%-%w]*://") then
        dir = name:gsub("^oil[%-%w]*://", ""):gsub("/+$", "")
      else
        dir = vim.fn.fnamemodify(name, ":p:h")
      end
      local pretty = vim.fn.fnamemodify(dir, ":~")
      local leaf   = vim.fn.fnamemodify(pretty, ":t")
      local parent = vim.fn.fnamemodify(pretty, ":h:t")
      local short  = (parent ~= "" and parent ~= ".") and (parent .. "/" .. leaf) or leaf
      local ssh    = name:match("^oil%-ssh://") ~= nil
      local icon   = ssh and "󰣀" or "󰉋" 
      label = icon .. " Oil " .. short
    else
      label = vim.fn.fnamemodify(name, ":t")
      if label == "" then label = "[No Name]" end
    end

    table.insert(out, hl .. "%" .. i .. "T " .. label .. " %T")
  end
  table.insert(out, "%#TabLineFill#")
  return table.concat(out)
end

function M.set_custom_tabline() 
  vim.o.tabline = "%!v:lua.CustomTabline()"
end

return M
