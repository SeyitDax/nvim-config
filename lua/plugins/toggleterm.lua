return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
	require("toggleterm").setup({
		shell = "pwsh.exe -NoLogo -NoProfile -ExecutionPolicy RemoteSigned",
	})

	local terms = require("toggleterm.terminal")
	local Terminal = terms.Terminal

	local bottom_term = Terminal:new({ id = 1, direction = "horizontal" })
	local right_term = Terminal:new({ id = 2, direction = "vertical" })

	-- toggleterm docks a new terminal next to ANY already-open terminal window
	-- regardless of direction, instead of opening a fresh split. That makes a
	-- horizontal terminal nest inside an already-open vertical one (and vice
	-- versa) rather than spanning the full width/height on its own. Patch
	-- find_open_windows (only call site: ui.open_split) to ignore windows
	-- whose terminal direction differs from the one being opened, so same-
	-- direction terminals still stack as before, but bottom/right can coexist
	-- as independent splits.
	local ui = require("toggleterm.ui")
	local orig_find_open_windows = ui.find_open_windows
	local opening_direction

	ui.find_open_windows = function(comparator)
		local is_open, windows = orig_find_open_windows(comparator)
		if opening_direction then
			windows = vim.tbl_filter(function(w)
				local t = terms.get(w.term_id, true)
				return t and t.direction == opening_direction
			end, windows)
			is_open = #windows > 0
		end
		return is_open, windows
	end

	-- toggleterm.nvim ignores a `size` set in Terminal:new(); it only ever
	-- reads the size passed to :toggle()/:open() at call time, so it must be
	-- supplied here rather than at construction.
	local function toggle_independent(term, size)
		opening_direction = term.direction
		local ok, err = pcall(function() term:toggle(size) end)
		opening_direction = nil
		if not ok then error(err) end
	end

	vim.keymap.set("n", "<leader>\"", function() toggle_independent(bottom_term) end, { desc = "Terminal bottom" })
	vim.keymap.set("n", "<leader>tr", function() toggle_independent(right_term, 70) end, { desc = "Terminal right" })
	vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
	end,
}
