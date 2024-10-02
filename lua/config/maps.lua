vim.keymap.set("n", "<C-s>", "<CMD>update<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<CMD>q<CR>", { desc = "Quit file" })

vim.keymap.set("n", "<leader>-n", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>-f", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })

vim.keymap.set("i", "jk", "<ESC>")
vim.keymap.set("i", "<ESC>", "<Nop>")

-- New Windows
vim.keymap.set("n", "<leader>[", "<CMD>vsplit<CR>")
vim.keymap.set("n", "<leader>]", "<CMD>split<CR>")

vim.keymap.set("n", "<C-h>", "<C-W>h")
vim.keymap.set("n", "<C-j>", "<C-W>j")
vim.keymap.set("n", "<C-k>", "<C-W>k")
vim.keymap.set("n", "<C-l>", "<C-W>l")
vim.keymap.set("n", "<C-up>", "<CMD>resize -1<CR>")
vim.keymap.set("n", "<C-down>", "<CMD>resize +1<CR>")
vim.keymap.set("n", "<C-left>", "<CMD>vertical resize -1<CR>")
vim.keymap.set("n", "<C-right>", "<CMD>vertical resize +1<CR>")

vim.keymap.set("n", "<TAB>", "<CMD>tabnext<CR>")
vim.keymap.set("n", "<S-TAB>", "<CMD>tabnext<CR>")

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<leader>gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { desc = "Go to Declaration" })
vim.keymap.set("n", "<leader>gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { desc = "Go to Definition" })
