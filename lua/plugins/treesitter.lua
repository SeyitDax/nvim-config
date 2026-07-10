return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = { "c_sharp", "lua", "vim", "vimdoc", "query" },
			auto_install = true,
			highlight = {
				enable = true,
			},
		})
	end,
}
