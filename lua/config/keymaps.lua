--[[
	Generated with 'conf-doc.nvim'

	Author: OXY2DEV
	Time: Thu Aug 22 19:43:59 2024
]]--

-- -+ ${link=func} from: KEYMAPS.md;range: 17,34;
---@param config { mode: string?, opts: table?, lhs: string, rhs: string }
local keymap = function (config)
    config = vim.tbl_deep_extend("force", {
        mode = "n",
        opts = {
            silent = true
        }
    }, config);

    local success, _ = pcall(vim.api.nvim_set_keymap, config.mode, config.lhs, config.rhs, config.opts);

    if success == false then
        vim.notify("[ keymaps.lua ]: Failed to set keymap for <" .. (config.lhs or "") .. "> for " .. (config.mode or "") .. "mode", vim.log.levels.WARN);
    end
end
-- -_

--from: KEYMAPS.md;range: 45,55;
keymap({ lhs = "<leader>q", rhs = "<CMD>q<CR>" });
keymap({ lhs = "<leader>w", rhs = "<CMD>w<CR>" });

keymap({ lhs = "<leader>W", rhs = "<CMD>wq<CR>" });
keymap({ lhs = "<leader>Q", rhs = "<CMD>q!<CR>" });

keymap({ lhs = "<leader>x", rhs = "<CMD>qa<CR>" });
keymap({ lhs = "<leader>X", rhs = "<CMD>qa!<CR>" });


--from: KEYMAPS.md;range: 60,67;
keymap({ lhs = "u", rhs = "" });
keymap({ mode = "v", lhs = "u", rhs = "" });

keymap({ lhs = "<leader>u", rhs = "<CMD>undo<CR>" });
keymap({ lhs = "<leader>r", rhs = "<CMD>redo<CR>" });


--from: KEYMAPS.md;range: 70,93;
keymap({
    mode = "n",
    lhs = "ff",
    rhs = "",

    opts = {
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
    }
});


--from: KEYMAPS.md;range: 96,100;
keymap({ mode = "n", lhs = "<leader>l", rhs = "<CMD>.lua<CR>" });
keymap({ mode = "v", lhs = "<leader>l", rhs = ":...'<,'>lua<CR>" });


--from: KEYMAPS.md;range: 108,113;
keymap({ mode = "n", lhs = "<leader>t", rhs = "<Cmd>Telescope<CR>" });
keymap({ mode = "n", lhs = "<leader>f", rhs = "<Cmd>Telescope file_browser<CR>" });
keymap({ mode = "n", lhs = "<leader>h", rhs = "<Cmd>Telescope highlights<CR>" });


--from: KEYMAPS.md;range: 118,125;
keymap({ mode = "n", lhs = "<leader>z", rhs = "<Cmd>tabp<CR>" })
keymap({ mode = "n", lhs = "<leader>m", rhs = "<Cmd>tabN<CR>" })

keymap({ mode = "n", lhs = "<leader>,", rhs = "<Cmd>BufScrollLeft<CR>" })
keymap({ mode = "n", lhs = "<leader>.", rhs = "<Cmd>TabScrollLeft<CR>" })


--from: KEYMAPS.md;range: 130,139;
keymap({ mode = "n", lhs = "<leader>c", rhs = "<Cmd>CompilerOpen<CR>" })
keymap({
    mode = "n",
    lhs = "<leader><S-c>",
    rhs = "<Cmd>CompilerStop<CR><Cmd>CompilerRedo<CR>"
})
keymap({ mode = "n", lhs = "<leader><S-t>", rhs = "<Cmd>CompilerToggleResults<CR>"})


