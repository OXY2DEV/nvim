-- HINT INFO WARN ERROR   

local ns = vim.api.nvim_create_namespace("demo");
local buf = vim.api.nvim_get_current_buf();

local severity = vim.diagnostic.severity;

vim.diagnostic.set(ns, buf, {
	{
		bufnr = buf,

		lnum = 0,
		col = 3,
		end_col = 7,

		message = "Some `text` to [hint]",
		severity = severity.HINT
	},
	{
		bufnr = buf,

		lnum = 0,
		col = 8,
		end_col = 12,

		message = "Some `text` to *inform*",
		severity = severity.INFO
	},
	{
		bufnr = buf,

		lnum = 0,
		col = 13,
		end_col = 17,

		message = "Some `text` to **warn**",
		severity = severity.WARN
	},
	{
		bufnr = buf,

		lnum = 0,
		col = 18,
		end_col = 24,

		message = "Some `text` to error.",
		severity = severity.ERROR
	},
}, {});
