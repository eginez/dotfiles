-- LSP keymaps
return {
  "neovim/nvim-lspconfig",
  init = function()
    local keys = require("lazyvim.plugins.lsp.keymaps").get()
    -- change a keymap
    --keys[#keys + 1] = { "K", "<cmd>echo 'hello'<cr>" }
    -- disable a keymap
    --keys[#keys + 1] = { "K", false }
    -- add a keymap
    keys[#keys + 1] = { "<D-k>", "<cmd>lua vim.lsp.buf.declaration()<cr>" }
    keys[#keys + 1] = { "<D-i>", "<cmd>lua vim.lsp.buf.references()<cr>" }
  end,
}
