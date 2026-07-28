return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	config = function()
		local autopairs = require("nvim-autopairs")
		autopairs.setup({})

		-- "<" isn't paired by default since it also means "less than" in most
		-- languages; only pair it in markup/generics contexts where "<...>" is
		-- actually a bracket.
		local Rule = require("nvim-autopairs.rule")
		autopairs.add_rules({
			Rule("<", ">", { "html", "xml", "javascriptreact", "typescriptreact", "rust", "markdown" }),
		})

		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		local cmp = require("cmp")
		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
	end,
}
