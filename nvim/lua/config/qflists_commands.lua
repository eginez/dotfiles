local M = {}

function M.setup(qflists, store)
  if vim.g.opencode_qflists_commands_setup then
    return
  end
  vim.g.opencode_qflists_commands_setup = true

  vim.api.nvim_create_user_command("QfSave", function(opts)
    qflists.save(opts.args)
  end, {
    nargs = 1,
    complete = store.complete,
    desc = "Save current quickfix list",
  })

  vim.api.nvim_create_user_command("QfLoad", function(opts)
    qflists.load(opts.args)
  end, {
    nargs = 1,
    complete = store.complete,
    desc = "Load saved quickfix list",
  })

  vim.api.nvim_create_user_command("QfPick", function()
    qflists.pick()
  end, {
    nargs = 0,
    desc = "Pick and load a saved quickfix list",
  })
end

return M
