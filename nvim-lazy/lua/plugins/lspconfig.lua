local util = require("lspconfig.util")
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

    -- Add filetype detection for Mojo
    vim.filetype.add({
      extension = {
        mojo = "mojo",
        ["🔥"] = "mojo",
      },
    })
  end,

  opts = function(_, opts)
    -- Ensure servers table exists
    opts.servers = opts.servers or {}

    -- Add Mojo LSP
    opts.servers.mojo = {
      cmd = { "mojo-lsp-server" }, -- Replace with actual command
      filetypes = { "mojo" },
      root_dir = function(fname)
        return require("lspconfig.util").find_git_ancestor(fname) or vim.fn.getcwd()
      end,
      settings = {},
    }
  end,
}
