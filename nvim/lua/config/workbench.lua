local M = {}

local function find_repos(cwd)
  local out = {}
  for _, p in ipairs(vim.fn.glob((cwd or vim.fn.getcwd()) .. "/*/.git", false, true)) do
    table.insert(out, vim.fn.fnamemodify(p, ":h"))
  end
  return out
end

local function status_porcelain(repo)
  local ok, r = pcall(function()
    return vim.system(
      { "git", "-C", repo, "status", "--porcelain=v1", "-z" },
      { text = false }
    ):wait()
  end)
  if not ok or not r or r.code ~= 0 then return nil end
  return r.stdout or ""
end

-- Map "path-in-repo" -> first changed line, derived from `git diff -U0 HEAD`.
-- Best-effort: any failure (git missing, parse error, etc.) returns an empty
-- map, and callers default each lookup to lnum=1.
local function first_hunk_map(repo)
  local ok, r = pcall(function()
    return vim.system(
      { "git", "-C", repo, "diff", "--no-color", "--unified=0", "HEAD" },
      { text = true }
    ):wait()
  end)
  if not ok or not r or r.code ~= 0 then return {} end
  local map, current = {}, nil
  for line in vim.gsplit(r.stdout or "", "\n", { plain = true }) do
    local b = line:match("^%+%+%+ b/(.+)$")
    if b then
      current = b
    elseif current then
      local n = line:match("^@@ %-%S+ %+(%d+)")
      if n and not map[current] then
        map[current] = tonumber(n)
      end
    end
  end
  return map
end

local function items_for(repo)
  local out = status_porcelain(repo)
  if not out then return {} end
  local name = vim.fn.fnamemodify(repo, ":t")
  local hunks = first_hunk_map(repo)
  local fields = vim.split(out, "\0", { plain = true })
  local items, i = {}, 1
  while i <= #fields and fields[i] ~= "" do
    local entry = fields[i]
    local xy, path = entry:sub(1, 2), entry:sub(4)
    -- Rename/copy in -z porcelain emits "XY new\0old\0"; skip the old path.
    if xy:sub(1, 1) == "R" or xy:sub(1, 1) == "C" then
      i = i + 1
    end
    table.insert(items, {
      filename = repo .. "/" .. path,
      lnum = hunks[path] or 1,
      col = 1,
      text = string.format("%s %s", xy, path),
      type = vim.trim(xy):sub(1, 1),
      repo = name,
    })
    i = i + 1
  end
  return items
end

local function collect()
  local repos = find_repos()
  if #repos < 2 then
    vim.notify(
      "Workbench: need >=2 sibling .git dirs in cwd (found " .. #repos .. ")",
      vim.log.levels.WARN
    )
    return nil
  end
  local items = {}
  for _, r in ipairs(repos) do
    vim.list_extend(items, items_for(r))
  end
  if #items == 0 then
    vim.notify("Workbench: no changes across " .. #repos .. " repos")
    return nil
  end
  return items
end

local source_registered = false
local items_state = {}

local function ensure_trouble_source()
  if source_registered then return true end
  local ok_sources, sources = pcall(require, "trouble.sources")
  local ok_item, Item = pcall(require, "trouble.item")
  if not (ok_sources and ok_item) then return false end
  if not sources.sources["workbench"] then
    sources.register("workbench", {
      config = {
        modes = {
          workbench = {
            source = "workbench",
            groups = { { "repo", format = "{repo} ({count})" } },
            sort = { "filename", "pos" },
            format = "{text:ts} {pos}",
          },
        },
      },
      get = function(cb, _ctx)
        local out = {}
        for _, it in ipairs(items_state) do
          table.insert(out, Item.new({
            source = "workbench",
            filename = it.filename,
            pos = { it.lnum or 1, (it.col or 1) - 1 },
            text = it.text,
            repo = it.repo,
          }))
        end
        cb(out)
      end,
    })
  end
  source_registered = true
  return true
end

local DASHBOARD_FTS = {
  snacks_dashboard = true,
  dashboard = true,
  alpha = true,
  starter = true,
  ministarter = true,
}

local function ensure_normal_buffer()
  -- If we're parked on a dashboard / starter buffer, swap it for a normal
  -- empty buffer so Trouble has a "main" window to send opens to.
  if DASHBOARD_FTS[vim.bo.filetype] then
    vim.cmd("enew")
  end
end

function M.status()
  local items = collect()
  if not items then return end

  ensure_normal_buffer()

  if ensure_trouble_source() then
    items_state = items
    require("trouble").open({ mode = "workbench" })
  else
    for _, it in ipairs(items) do
      it.text = "[" .. it.repo .. "] " .. it.text
    end
    require("config.qflists").set(items, { title = "Workbench status", open = true })
  end
end

function M.lazygit()
  local repos = find_repos()
  if #repos == 0 then
    vim.notify("Workbench: no sibling repos in cwd", vim.log.levels.WARN)
    return
  end
  local labels = {}
  for _, r in ipairs(repos) do
    local n = #items_for(r)
    local tag = n == 0 and "clean" or (n .. " changed")
    table.insert(labels, string.format("%s  (%s)", vim.fn.fnamemodify(r, ":t"), tag))
  end
  vim.ui.select(labels, { prompt = "Workbench → lazygit:" }, function(_, idx)
    if idx and Snacks and Snacks.lazygit then
      Snacks.lazygit({ cwd = repos[idx] })
    elseif idx then
      vim.cmd("tabnew")
      vim.fn.termopen({ "lazygit" }, { cwd = repos[idx] })
      vim.cmd("startinsert")
    end
  end)
end

function M.setup()
  if vim.g.workbench_setup then return end
  vim.g.workbench_setup = true

  vim.api.nvim_create_user_command("WorkbenchStatus", function()
    M.status()
  end, { desc = "Unified git status across sibling repos (grouped in Trouble)" })

  vim.api.nvim_create_user_command("WorkbenchLazygit", function()
    M.lazygit()
  end, { desc = "Pick a sibling repo, open lazygit in it" })
end

return M
