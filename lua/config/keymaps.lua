---+ Title: "Helper function to create keymaps"nano
---
--- @param mode nil | string
--- @param keymap string
--- @param action any
--- @param options nil | table
local createKeymap = function (mode, keymap, action, options)
	--- @diagnostic disable-next-line
	local _opts = vim.tbl_extend("keep", options or {}, {
		silent = true
	});

	--- @diagnostic disable-next-line
	vim.api.nvim_set_keymap(mode or "n", keymap, action, _opts);
end
---_

---+ Title: "Saving & quitting"
createKeymap(nil, "<leader>q", ":quit<CR>");
createKeymap(nil, "<leader>x", ":quitall<CR>");

createKeymap(nil, "<leader>w", ":write<CR>");
createKeymap(nil, "<leader>wq", ":wq<CR>");

createKeymap(nil, "fq", ":quit!<CR>");
createKeymap(nil, "fw", ":write!<CR>");
---_

---+ Title: "Folding"
createKeymap(nil, "<leader>", "za");
---_

--+ Title: "Code execution"
createKeymap(nil, "<leader>l", ":.lua<CR>");
createKeymap("v", "<leader>l", ":'<,'>lua<CR>");
--_

---+ Title: "Movements"
createKeymap(nil, "u", "");
createKeymap(nil, "<leader>u", ":undo<CR>")
createKeymap(nil, "<leader>r", ":redo<CR>")

-- createKeymap("i", 'z', 'iz');

createKeymap(nil, "<leader><leader>", ":Beacon<CR>");
---_

