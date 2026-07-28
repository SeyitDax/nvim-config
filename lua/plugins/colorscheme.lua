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
			-- Softer-than-pure-black bg, and every accent kept inside the
			-- red -> orange -> gold band (no magenta/pink, no gold overused).
			local palette = {
				bg = "#130c0c",
				bg_alt = "#221313",
				bg_highlight = "#351818",
				fg = "#f0e4d8",
				grey = "#7d6360",
				red = "#ff3232", -- primary: keywords, control flow
				brick = "#d9433f", -- secondary red: field/member access
				coral = "#ff6b4a", -- strings (kept in the red family, not gold)
				orange = "#ff8c42", -- functions, types
				gold = "#e0a54a", -- numbers, booleans, constants only
			}

			require("cyberdream").setup({
				transparent = false,
				italic_comments = true,
				borderless_pickers = false,
				terminal_colors = true,
				colors = {
					bg = palette.bg,
					bg_alt = palette.bg_alt,
					bg_highlight = palette.bg_highlight,
					fg = palette.fg,
					grey = palette.grey,
					red = palette.red,
					orange = palette.orange,
					yellow = palette.gold,
					green = palette.coral,
					cyan = palette.orange,
					blue = palette.grey,
					magenta = palette.red,
					pink = palette.brick,
					purple = palette.brick,
				},
			})

			-- Applied on every ColorScheme event (not just once at startup) so
			-- these win even if something else (e.g. nvim-treesitter's own
			-- default highlight links) sets these groups again afterward --
			-- that's what was silently undoing the `overrides` table before.
			local function set_highlights()
				local hl = vim.api.nvim_set_hl
				local groups = {
					Normal = { fg = palette.fg, bg = palette.bg },
					NormalFloat = { fg = palette.fg, bg = palette.bg_alt },
					Comment = { fg = palette.grey, italic = true },

					Statement = { fg = palette.red, bold = true },
					Keyword = { fg = palette.red, bold = true },
					Conditional = { fg = palette.red, bold = true },
					Repeat = { fg = palette.red, bold = true },
					["@keyword"] = { fg = palette.red, bold = true },
					["@keyword.function"] = { fg = palette.red, bold = true },
					["@keyword.return"] = { fg = palette.red, bold = true },
					["@conditional"] = { fg = palette.red, bold = true },

					Function = { fg = palette.orange },
					["@function"] = { fg = palette.orange },
					["@function.call"] = { fg = palette.orange },
					["@method"] = { fg = palette.orange },
					Type = { fg = palette.orange, bold = true },
					["@type"] = { fg = palette.orange, bold = true },
					["@module"] = { fg = palette.orange },
					["@namespace"] = { fg = palette.orange },
					["@constructor"] = { fg = palette.orange },

					String = { fg = palette.coral },
					["@string"] = { fg = palette.coral },

					Number = { fg = palette.gold },
					["@number"] = { fg = palette.gold },
					Boolean = { fg = palette.gold },
					["@boolean"] = { fg = palette.gold },
					Constant = { fg = palette.gold },
					["@constant"] = { fg = palette.gold },
					["@constant.builtin"] = { fg = palette.gold, bold = true },

					Identifier = { fg = palette.fg },
					["@variable"] = { fg = palette.fg },
					["@variable.parameter"] = { fg = palette.fg },
					["@variable.builtin"] = { fg = palette.fg, bold = true },
					["@field"] = { fg = palette.brick },
					["@property"] = { fg = palette.brick },
					["@variable.member"] = { fg = palette.brick },

					Operator = { fg = palette.fg },
					Delimiter = { fg = palette.grey },
					["@operator"] = { fg = palette.fg },
					["@punctuation.delimiter"] = { fg = palette.grey },
					["@punctuation.bracket"] = { fg = palette.grey },
					["@punctuation.special"] = { fg = palette.grey },

					LineNr = { fg = palette.grey, bg = "NONE" },
					CursorLineNr = { fg = palette.red, bold = true, bg = "NONE" },
					CursorLine = { bg = palette.bg_highlight },
					SignColumn = { bg = "NONE" },

					StatusLine = { fg = palette.fg, bg = palette.bg_alt },
					StatusLineNC = { fg = palette.grey, bg = palette.bg },
					WinSeparator = { fg = palette.bg_highlight },
					VertSplit = { fg = palette.bg_highlight },
					FloatBorder = { fg = palette.red, bg = palette.bg_alt },
					Pmenu = { fg = palette.fg, bg = palette.bg_alt },
					PmenuSel = { fg = palette.bg, bg = palette.red },
				}
				for group, opts in pairs(groups) do
					hl(0, group, opts)
				end
			end

			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "cyberdream",
				callback = set_highlights,
			})

			-- Theme toggle: tokyonight (bluish) <-> cyberdream (red/black),
			-- persisted across restarts.
			local themes = { "tokyonight", "cyberdream" }
			local state_dir = vim.fn.stdpath("state")
			local state_file = state_dir .. "/theme_choice.txt"

			local function load_theme_index()
				local f = io.open(state_file, "r")
				if not f then
					return 1
				end
				local saved = vim.trim(f:read("*a") or "")
				f:close()
				for i, name in ipairs(themes) do
					if name == saved then
						return i
					end
				end
				return 1
			end

			local function save_theme(name)
				-- io.open won't create missing parent directories on its own.
				vim.fn.mkdir(state_dir, "p")
				local f = io.open(state_file, "w")
				if f then
					f:write(name)
					f:close()
				else
					vim.notify("Failed to save theme choice to " .. state_file, vim.log.levels.WARN)
				end
			end

			local theme_index = load_theme_index()

			local function apply(index)
				theme_index = index
				vim.cmd.colorscheme(themes[theme_index])
				save_theme(themes[theme_index])
			end

			local function toggle_theme()
				apply((theme_index % #themes) + 1)
				vim.notify("Colorscheme: " .. themes[theme_index], vim.log.levels.INFO)
			end

			apply(theme_index)

			vim.api.nvim_create_user_command("ToggleTheme", toggle_theme, {
				desc = "Toggle between tokyonight and cyberdream colorschemes",
			})

			vim.keymap.set("n", "<leader>tt", toggle_theme, { desc = "Toggle colorscheme" })
		end,
	},
}
