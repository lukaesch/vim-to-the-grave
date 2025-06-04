vim = vim

vim.g.mapleader = " "
-- telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<C-ff>", builtin.git_files, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fs", function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)

-- Space PV back
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Vimspector
--vim.cmd([[
--nmap <F9> <cmd>call vimspector#Launch()<cr>
--nmap <F5> <cmd>call vimspector#StepOver()<cr>
--nmap <F8> <cmd>call vimspector#Reset()<cr>
--nmap <F11> <cmd>call vimspector#StepOver()<cr>")
--nmap <F12> <cmd>call vimspector#StepOut()<cr>")
--nmap <F10> <cmd>call vimspector#StepInto()<cr>")
--]])

vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
