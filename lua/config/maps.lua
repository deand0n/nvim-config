vim.keymap.set("n", "<leader>w", "<CMD>update<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<CMD>q<CR>", { desc = "Quit file" })

vim.keymap.set("n", "<leader>-", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })

vim.keymap.set("i", "jk", "<ESC>")

-- New Windows
vim.keymap.set("n", "<leader>[", "<CMD>vsplit<CR>")
vim.keymap.set("n", "<leader>]", "<CMD>split<CR>")
