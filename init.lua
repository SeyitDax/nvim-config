local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git", "clone", "--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", lazypath,
	})
	end
	vim.opt.rtp:prepend(lazypath)
	vim.g.mapleader = " "

	vim.opt.number = true
	vim.opt.relativenumber = true
	vim.opt.termguicolors = true
	vim.opt.shell = "pwsh.exe"
	vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
	vim.opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
	vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
	vim.opt.shellquote = ""
	vim.opt.shellxquote = ""

	require("lazy").setup("plugins")

	vim.keymap.set("i", "kj", "<Esc>", { desc = "Exit insert mode" })
	vim.keymap.set("t", "kj", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

	-- Jump to specific terminal by number (like VS Code Ctrl+1, Ctrl+2)
	vim.keymap.set("n", "<C-1>", ":1ToggleTerm<CR>", { desc = "Focus terminal 1" })
	vim.keymap.set("n", "<C-2>", ":2ToggleTerm<CR>", { desc = "Focus terminal 2" })

	-- Navigate between splits (file and terminals) with Ctrl+arrow keys
	vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move left" })
	vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move right" })
	vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move down" })
	vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move up" })

