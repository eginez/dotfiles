-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps
---------------------
vim.cmd("nore ; :")
vim.cmd("cnoreabbrev W w")
vim.cmd("cnoreabbrev Q q")
vim.cmd("nnoremap <D-j> <C-o>")
vim.cmd("nnoremap <D-l> <C-i>")
keymap.set("n", "dw", 'vb"_d') -- delete word backwards

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>")

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- delete single character without copying into register
keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>") -- increment
keymap.set("n", "<leader>-", "<C-x>") -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s") -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width & height
keymap.set("n", "<leader>sx", ":close<CR>") -- close current split window

keymap.set("n", "<leader>to", ":tabnew<CR>") -- open new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close current tab
keymap.set("n", "<leader>tn", ":tabn<CR>") --  go to next tab
keymap.set("n", "<leader>tp", ":tabp<CR>") --  go to previous tab

----------------------
-- Plugin Keybinds
----------------------

-- toggle maximize current window (snacks.zen.zoom)
keymap.set("n", "<leader>sm", function() Snacks.zen.zoom() end, { desc = "Toggle window zoom" })

-- git pickers (LazyVim uses snacks.picker, not telescope)
keymap.set("n", "<leader>gc", function() Snacks.picker.git_log() end, { desc = "Git commits" })
keymap.set("n", "<leader>gfc", function() Snacks.picker.git_log_file() end, { desc = "Git commits (current file)" })
keymap.set("n", "<leader>gB", function() Snacks.picker.git_branches() end, { desc = "Git branches" })
keymap.set("n", "<leader>gs", function() Snacks.picker.git_status() end, { desc = "Git status" })

-- restart lsp server (not on youtube nvim video)
keymap.set("n", "<leader>rs", ":LspRestart<CR>") -- mapping to restart lsp if necessary

-- saved quickfix lists
keymap.set("n", "<leader>fq", ":QfPick<CR>", { desc = "Saved quickfix lists" })
