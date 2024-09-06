local scopes = {};

scopes.lua = {
	"do_statement",
	"while_statement",
	"repeat_statement",
	"if_statement",
	"for_statement",
	"function_declaration",
	"function_definition",
};

scopes.html = {
	"element"
};

scopes.scss = {
	"rule_set"
};
scopes.sass = scopes.scss;

return scopes;
