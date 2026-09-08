return {
	"folke/tokyonight.nvim",
	priority = 1000,
	lazy = false,
	config = function()
		require("tokyonight").setup({
			style = "storm",
		})

		-- Styles: "storm" (dark, default) <-> "day" (light, for bright rooms),
		-- persisted across restarts.
		local styles = { "storm", "day" }
		local state_file = vim.fn.stdpath("state") .. "/tokyonight_style.txt"

		local function load_style_index()
			local f = io.open(state_file, "r")
			if not f then
				return 1
			end
			local saved = vim.trim(f:read("*a") or "")
			f:close()
			for i, name in ipairs(styles) do
				if name == saved then
					return i
				end
			end
			return 1
		end

		local function save_style(name)
			local f = io.open(state_file, "w")
			if f then
				f:write(name)
				f:close()
			else
				vim.notify("Failed to save theme style to " .. state_file, vim.log.levels.WARN)
			end
		end

		local style_index = load_style_index()

		local function apply(index)
			style_index = index
			local style = styles[style_index]
			vim.o.background = (style == "day") and "light" or "dark"
			require("tokyonight").setup({ style = style })
			vim.cmd.colorscheme("tokyonight")
			save_style(style)
		end

		local function toggle_background()
			apply((style_index % #styles) + 1)
			vim.notify("tokyonight: " .. styles[style_index], vim.log.levels.INFO)
		end

		apply(style_index)

		vim.api.nvim_create_user_command("ToggleBackground", toggle_background, {
			desc = "Toggle tokyonight between storm (dark) and day (light)",
		})

		vim.keymap.set("n", "<leader>tb", toggle_background, { desc = "Toggle light/dark background" })
	end,
}
