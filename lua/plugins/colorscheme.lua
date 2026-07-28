return {
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		lazy = false,
		config = function()
			require("tokyonight").setup({
				style = "storm",
			})
		end,
	},
	{
		"scottmckendry/cyberdream.nvim",
		priority = 1000,
		lazy = false,
		config = function()
			require("cyberdream").setup({
				transparent = false,
				italic_comments = true,
				borderless_telescope = false,
				terminal_colors = true,
			})

			-- Theme toggle: tokyonight (bluish) <-> cyberdream (red/black)
			local themes = { "tokyonight", "cyberdream" }
			local theme_index = 1

			local function toggle_theme()
				theme_index = (theme_index % #themes) + 1
				vim.cmd.colorscheme(themes[theme_index])
				vim.notify("Colorscheme: " .. themes[theme_index], vim.log.levels.INFO)
			end

			vim.cmd.colorscheme(themes[theme_index])

			vim.api.nvim_create_user_command("ToggleTheme", toggle_theme, {
				desc = "Toggle between tokyonight and cyberdream colorschemes",
			})

			vim.keymap.set("n", "<leader>tt", toggle_theme, { desc = "Toggle colorscheme" })
		end,
	},
}
