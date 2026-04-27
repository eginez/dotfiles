-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

local doc_dir = vim.fn.stdpath("config") .. "/doc"
if vim.fn.isdirectory(doc_dir) == 1 then
  vim.cmd("silent! helptags " .. vim.fn.fnameescape(doc_dir))
end

require("config.qflists").setup()
require("config.workbench").setup()
