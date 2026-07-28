return {
	"hrsh7th/nvim-cmp",
	dependencies = { "hrsh7th/cmp-nvim-lsp", "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip", "rafamadriz/friendly-snippets"},
	config = function()
		local cmp = require("cmp")
		require("luasnip.loaders.from_vscode").lazy_load()

		-- Must be set before cmp.setup() below: cmp's own <S-Tab> mapping
		-- falls back to whatever was mapped here when the popup menu isn't
		-- visible, so this is what runs on a plain Shift-Tab dedent.
		vim.keymap.set("i", "<S-Tab>", "<C-d>", { desc = "Dedent line" })
		vim.keymap.set("v", "<S-Tab>", "<gv", { desc = "Dedent selection" })

		cmp.setup({
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<Tab>"] = cmp.mapping.select_next_item(),
				["<S-Tab>"] = cmp.mapping.select_prev_item(),
				["<CR>"] = cmp.mapping.confirm({ select = true }),
				["<C-Space>"] = cmp.mapping.complete(),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
			}),
		})
	end,
}
