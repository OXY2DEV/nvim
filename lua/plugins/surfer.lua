local sur = require("syntax-tree-surfer")

function map(mode, key, action, options)
	local defaults = {
		noremap = true, silent = true
	}

	if options then
		defaults = vim.tbl_extend("force", defaults, options)
	end

	vim.keymap.set(mode, key, action, defaults)
end


map( -- Go to variable declarations
	"n", 
	"gv",
	function()
		sur.targeted_jump({ "variable_declaration" })
	end,
	{
		desc = "Go to variable"
	}
)

map( -- Go to functions
	"n", 
	"gf",
	function()
		sur.targeted_jump({ "function", "arrow_function", "function_definition" })
	end,
	{
		desc = "Go to function"
	}
)

map( -- Go to conditionals(if, else if, else, switch)
	"n", 
	"gc",
	function()
		sur.targeted_jump({ "if_statement", "else_clause", "else_statement", "elseif_statement", "switch_statement" })
	end,
	{
		desc = "Go to Conditional"
	}
)



