local M = {}

local function lists_dir()
  return vim.fn.getcwd() .. "/.qflists"
end

local function ensure_lists_dir()
  vim.fn.mkdir(lists_dir(), "p")
end

local function normalize_name(name)
  return name:gsub("[/\\]", "_")
end

function M.path(name)
  return string.format("%s/%s.json", lists_dir(), normalize_name(name))
end

function M.save(name, payload)
  ensure_lists_dir()
  vim.fn.writefile({ vim.json.encode(payload) }, M.path(name))
end

function M.load(name)
  local path = M.path(name)
  if vim.fn.filereadable(path) == 0 then
    return nil, string.format("Quickfix list '%s' not found", name)
  end

  local lines = vim.fn.readfile(path)
  local ok, payload = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not ok or type(payload) ~= "table" or type(payload.items) ~= "table" then
    return nil, string.format("Quickfix list '%s' is invalid", name)
  end

  return payload
end

function M.names()
  if vim.fn.isdirectory(lists_dir()) == 0 then
    return {}
  end

  local paths = vim.fn.glob(lists_dir() .. "/*.json", false, true)
  local names = {}
  for _, path in ipairs(paths) do
    table.insert(names, vim.fn.fnamemodify(path, ":t:r"))
  end
  table.sort(names)
  return names
end

function M.complete(arg_lead)
  local matches = {}
  for _, name in ipairs(M.names()) do
    if arg_lead == "" or vim.startswith(name, arg_lead) then
      table.insert(matches, name)
    end
  end
  return matches
end

return M
