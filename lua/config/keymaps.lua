---+ type: function; title: Helper function;
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

---+ type: custom; icon: 󰌌 ; hl: @attribute; title: Save & quit;
createKeymap(nil, "<leader>q", "<Cmd>quit<CR>");
createKeymap(nil, "<leader>x", "<Cmd>quitall<CR>");

createKeymap(nil, "<leader>w", "<Cmd>write<CR>");
createKeymap(nil, "<leader>wq", "<Cmd>wq<CR>");

createKeymap(nil, "fq", "<Cmd>quit!<CR>");
createKeymap(nil, "fw", "<Cmd>write!<CR>");
---_

---+ type: custom; icon:  ; hl: @conditional; title: Code folding;
createKeymap(nil, "<leader>", "", {
	callback = function ()
		local cursor = vim.api.nvim_win_get_cursor(0);

		if vim.fn.foldlevel(cursor[1]) < 1 then
			return;
		end

		if vim.fn.foldclosed(cursor[1]) ~= -1 then
			vim.cmd("foldopen");
		else
			vim.cmd("foldclose");
		end
	end
});
---_

--+ type: custom; title: Code execution;
createKeymap(nil, "<leader>l", "<Cmd>.lua<CR>");
createKeymap("v", "<leader>l", ":'<,'>lua<CR>");
--_

---+ type: custom; icon:  ; hl: @operator; title: Editing;
createKeymap(nil, "u", "");
createKeymap(nil, "<leader>u", "<Cmd>undo<CR>")
createKeymap(nil, "<leader>r", "<Cmd>redo<CR>")

createKeymap(nil, "<leader><leader>", "<Cmd>Beacon<CR>");

createKeymap(nil, "<leader>d", "", {
	callback = function ()
		local diagnostics = require("config.diagnostic");

		if diagnostics.enable == true then
			diagnostics.clear();
			diagnostics.enable = false;
		else
			diagnostics.enable = true;
			diagnostics.get_diagnostics()
		end
	end
})
---_

---+ type: custom; icon: 󰭎 ; hl: @diff.plus; title: Telescope;
createKeymap(nil, "<leader>t", "<Cmd>Telescope<CR>");
createKeymap(nil, "<leader>?", "<Cmd>Telescope frecency<CR>");
createKeymap(nil, "<leader>g", "<Cmd>Telescope glyph<CR>");
createKeymap(nil, "<leader>f", "<Cmd>Telescope file_browser<CR>");
createKeymap(nil, "<leader>s", "<Cmd>Telescope find_files<CR>");
createKeymap(nil, "<leader>U", "<Cmd>Telescope undo<CR>");
createKeymap(nil, "<leader>h", "<Cmd>Telescope highlights<CR>");
---_

---+ type: custom; title: Terminal; icon:  ; hl: rainbow3;
createKeymap(nil, "<leader>t", "<cmd>Terminal<CR>");
createKeymap(nil, "<leader>T", "<cmd>Terminal float<CR>");
---_

---+  type: custom; title: Tabs & Buffers; icon: 󰓩 ; hl: rainbow6;
createKeymap(nil, "<leader>z", "<Cmd>tabp<CR>");
createKeymap(nil, "<leader>m", "<Cmd>tabN<CR>");

createKeymap(nil, "<leader>,", "<Cmd>TabScrollLeft<CR>");
createKeymap(nil, "<leader>.", "<Cmd>BufScrollLeft<CR>");
---_

---+ type: custom; title: Windows; icon:  ; hl: @conditional;
-- Incomplete
---_

---+ type: custom; title: Scrolling; icon:  ; hl: rainbow: 3;
local _guicursor;
local in_scroll = false;

createKeymap(nil, "<PageDown>", "", {
	callback = function ()
		local cursor = vim.api.nvim_win_get_cursor(0);

		if in_scroll == true then
			return;
		end

		require("animations").cursor.y(0, cursor[1] + math.floor(vim.o.lines * 0.75), {
			interval = 50,
			ease = "ease-out-sine",
			steps = 10,

			on_init = function ()
				_guicursor = vim.g.guicursor;
				in_scroll = true;

				vim.cmd("set guicursor=a:CursorHidden");
			end,
			on_complete = function ()
				in_scroll = false;
				vim.cmd("set guicursor=" .. (_guicursor or "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"));
			end
		})
	end
});
createKeymap(nil, "<PageUp>", "", {
	callback = function ()
		local cursor = vim.api.nvim_win_get_cursor(0);

		if in_scroll == true then
			return;
		end

		require("animations").cursor.y(0, cursor[1] - math.floor(vim.o.lines * 0.75), {
			interval = 50,
			ease = "ease-out-sine",
			steps = 10,

			on_init = function ()
				_guicursor = vim.g.guicursor;
				in_scroll = true;

				vim.cmd("set guicursor=a:CursorHidden");
			end,
			on_complete = function ()
				in_scroll = false;
				vim.cmd("set guicursor=" .. (_guicursor or "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"));
			end
		})
	end
});
---_
