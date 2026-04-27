local M = {}

local store = require("config.qflists_store")
local commands = require("config.qflists_commands")

local function normalize_title(name, opts)
  return (opts and opts.title) or name
end

local function set_items(title, items)
  vim.fn.setqflist({}, "r", {
    title = title,
    items = items,
  })
end

local function persist(name, payload)
  store.save(name, payload)
end

local function open_list(opts)
  if opts and opts.open == false then
    return
  end

  if vim.fn.exists(":Trouble") == 2 then
    vim.cmd("Trouble qflist open")
  else
    vim.cmd("copen")
  end
end

function M.save(name, opts)
  if not name or name == "" then
    vim.notify("Quickfix save requires a name", vim.log.levels.ERROR)
    return
  end

  local qf = vim.fn.getqflist({ items = 1, title = 1 })
  if not qf.items or vim.tbl_isempty(qf.items) then
    vim.notify("Quickfix list is empty", vim.log.levels.WARN)
    return
  end

  local payload = {
    title = normalize_title(name, opts) or qf.title,
    items = {},
  }

  for _, item in ipairs(qf.items) do
    table.insert(payload.items, {
      filename = item.filename or (item.bufnr and item.bufnr > 0 and vim.api.nvim_buf_get_name(item.bufnr) or nil),
      lnum = item.lnum,
      col = item.col,
      end_lnum = item.end_lnum,
      end_col = item.end_col,
      text = item.text,
      type = item.type,
    })
  end

  persist(name, payload)
  vim.notify(string.format("Saved quickfix list '%s'", name))
end

function M.set(items, opts)
  opts = opts or {}
  if type(items) ~= "table" or vim.tbl_isempty(items) then
    vim.notify("Quickfix set requires at least one item", vim.log.levels.WARN)
    return
  end

  local title = opts.title or opts.name or "Quickfix"
  local payload = {
    title = title,
    items = items,
  }

  set_items(title, items)

  if opts.name and opts.save ~= false then
    persist(opts.name, payload)
  end

  open_list(opts)
end

function M.load(name, opts)
  if not name or name == "" then
    vim.notify("Quickfix load requires a name", vim.log.levels.ERROR)
    return
  end

  local payload, err = store.load(name)
  if not payload then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  set_items((opts and opts.title) or payload.title or name, payload.items)
  open_list(opts)
end

function M.names()
  return store.names()
end

function M.complete(arg_lead)
  return store.complete(arg_lead)
end

function M.pick(opts)
  local names = M.names()
  if vim.tbl_isempty(names) then
    vim.notify("No saved quickfix lists")
    return
  end

  vim.ui.select(names, {
    prompt = "Load quickfix list",
    format_item = function(name)
      return name
    end,
  }, function(choice)
    if choice then
      M.load(choice, opts)
    end
  end)
end

function M.setup()
  if vim.g.opencode_qflists_setup then
    return
  end
  vim.g.opencode_qflists_setup = true

  commands.setup(M, store)
end

return M
