return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/nvim-cmp",
		"hrsh7th/cmp-nvim-lsp",
		"Hoffs/omnisharp-extended-lsp.nvim",
	},
	config = function()
		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = { "omnisharp" },
		})

		-- OmniSharp v1.39.9+ has a regression in its background diagnostics
		-- worker (thread-unsafe Queue.Enqueue in its analyzer status
		-- notifications) that corrupts the JSON-RPC stream and shows up here
		-- as "LSP[omnisharp]: Error INVALID_SERVER_MESSAGE: nil". Confirmed via
		-- lsp.log stack trace; matches https://github.com/OmniSharp/omnisharp-roslyn/issues/2574
		-- and https://github.com/neovim/neovim/issues/27395. Pinned to
		-- v1.39.8 (last known-good) via `:MasonInstall omnisharp@v1.39.8` —
		-- do NOT `:MasonUpdateAll` this package.

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
			   if client and client.name == "omnisharp" then
				   -- Native textDocument/definition can't resolve decompiled
				   -- BCL/NuGet symbols and crashes with "Cursor position
				   -- outside buffer"; omnisharp-extended-lsp handles that flow.
				   vim.keymap.set("n", "gd", require("omnisharp_extended").lsp_definition, opts)
			   else
				   vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
			   end
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
