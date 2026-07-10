return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/nvim-cmp",
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = { "omnisharp" },
		})

		local capabilities = require("cmp_nvim_lsp").default_capabilities()
		
		vim.lsp.config("omnisharp", {
		capabilities = capabilities,
		cmd = {
			"dotnet",
			vim.fn.stdpath("data") .. "/mason/packages/omnisharp/libexec/OmniSharp.dll",
			"--languageserver",
			"--hostPID", tostring(vim.fn.getpid()),
			-- Let 'gd' jump into decompiled BCL/NuGet source to inspect
			"--RoslynExtensionsOptions:EnableDecompilationSupport=true",
			-- Run Rosyln analyzers (needed for CA-series warning, e.g. disposal rules)
--			"--RoslynExtensionsOptions:EnableAnalyzersSupport=true",
			-- Restrict the analyzers to only work on the open document instead of the whole solution
--			"--RoslynExtensionsOptions:AnalyzeOpenDocumentsOnly=true",
		},
		})
		vim.lsp.enable("omnisharp")

		-- Don't clutter the buffer with always-on inline diagnostic text;
		-- show the message in a float only when the cursor rests on it.
		vim.diagnostic.config({
			virtual_text = false,
			float = { border = "rounded", source = true },
			signs = true,
			underline = true,
		})

		vim.o.updatetime = 300 -- default 4000ms is too slow for hover-to-reveal
		vim.api.nvim_create_autocmd("CursorHold", {
			callback = function()
				vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
			end,
		})

		-- LSP keymaps, active once a language server attaches
		vim.api.nvim_create_autocmd("LspAttach", {
		   callback = function(args)
			   local opts = { buffer = args.buf }
			   local client = vim.lsp.get_client_by_id(args.data.client_id)
			   if client and client.name == "omnisharp" then
				   -- OmniSharp emits semantic token types containing spaces
				   -- (e.g. "class name"), which are invalid Neovim highlight
				   -- group names and throw E5248 on every edit, causing lag.
				   client.server_capabilities.semanticTokensProvider = nil
			   end
			
			   vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, opts)
			   vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
			   vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
			   vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
			   vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
			   vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
			   vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
			   vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
		   end,
		})
	end,
}
