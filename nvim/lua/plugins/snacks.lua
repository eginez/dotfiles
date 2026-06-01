return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      hidden = true,  -- show dotfiles in every picker (files, grep, explorer)
      ignored = true, -- show git-ignored files too (node_modules, build output, etc.)
      sources = {
        explorer = {
          hidden = true,
          ignored = true,
        },
      },
    },
  },
}
