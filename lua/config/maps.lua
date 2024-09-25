vim.keymap.set("n", "<C-s>", "<CMD>update<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<CMD>q<CR>", { desc = "Quit file" })

vim.keymap.set("n", "<leader>-n", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>-f", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })

vim.keymap.set("i", "jk", "<ESC>")

-- New Windows
vim.keymap.set("n", "<leader>[", "<CMD>vsplit<CR>")
vim.keymap.set("n", "<leader>]", "<CMD>split<CR>")

vim.keymap.set("n", "<TAB>", "<CMD>tabnext<CR>")
vim.keymap.set("n", "<S-TAB>", "<CMD>tabnext<CR>")
