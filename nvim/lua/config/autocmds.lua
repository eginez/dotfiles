-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Rules to suppress when toggling. markdownlint-cli2 uses a JSON config file,
-- not --disable flags, so we write a temp file and inject --config at runtime.
local md_suppressed_rules = { "MD013" }
local _md_lint_tmp_config = nil
local _md_lint_original_args = nil

vim.api.nvim_create_user_command("ToggleMdLinting", function()
  local lint = require("lint")
  local linter = lint.linters["markdownlint-cli2"]
  if not linter then
    vim.notify("markdownlint-cli2 linter not found", vim.log.levels.WARN)
    return
  end
  if type(linter.args) == "function" then
    vim.notify("Cannot toggle: linter uses dynamic args", vim.log.levels.WARN)
    return
  end

  if _md_lint_tmp_config then
    linter.args = _md_lint_original_args or {}
    _md_lint_tmp_config = nil
    _md_lint_original_args = nil
    vim.notify("MD lint rules re-enabled: " .. table.concat(md_suppressed_rules, ", "), vim.log.levels.INFO)
  else
    local config = {}
    for _, rule in ipairs(md_suppressed_rules) do config[rule] = false end
    _md_lint_tmp_config = vim.fn.tempname() .. ".json"
    _md_lint_original_args = vim.deepcopy(linter.args or {})
    local f = io.open(_md_lint_tmp_config, "w")
    if f then f:write(vim.fn.json_encode(config)); f:close() end
    linter.args = vim.list_extend({ "--config", _md_lint_tmp_config }, vim.deepcopy(_md_lint_original_args))
    vim.diagnostic.reset(nil, 0)
    vim.notify("MD lint rules disabled: " .. table.concat(md_suppressed_rules, ", "), vim.log.levels.INFO)
  end
end, { desc = "Toggle suppressed markdown lint rules" })
