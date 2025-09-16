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

return M
