--- Option configuration for Neovim

---|fS

--- Prefer dark background.
vim.o.background = "dark";

--- Use breakindent for blocks of wrapped text.
vim.o.breakindent = true;

--- Cmdline height.
vim.o.cmdheight = 1;
--- For `q:`.
vim.o.cmdwinheight = 5;

--- Useful when using multiple windows.
vim.o.cursorline = true;

--- Confirm before exiting.
vim.o.confirm = true;

--- Change the fill characters for fold, end of buffer and
--- last line.
vim.o.fillchars = "fold: ,eob: ,lastline: ";

--- Close all folds that aren't under the cursor.
vim.o.foldclose = "all";
--- Use markers for folding.
vim.o.foldmethod = "marker";
vim.o.foldmarker = "|fS,|fE";

--- `:h` should be 25% of the total display height.
--- `cmdheight` is assumed to be 1.
vim.o.helpheight = math.ceil((vim.o.lines - 1) * 0.25);

--- Allow `listchars` to be shown.
vim.o.list = true;
vim.o.listchars = "eol:↩,tab:│ ,trail:╴";

--- Only allow using mouse/touch for `Normal` mode.
vim.o.mouse = "n";
--- Enable line numbers.
vim.o.number = true;

--- Smaller completion window.
vim.o.pumheight = 5;
--- Slightly transparent completion window.
vim.o.pumblend = 20;

--- Use relative line numbers.
vim.o.relativenumber = true;

--- BUG, Custom ruler format with custom statusline can mess
--- up incoming messages!
vim.o.ruler = true;
vim.o.rulerformat = " %l | %c";

--- I don't want to constantly go to the edge of the screen
--- just to scroll.
vim.o.scrolloff = 999;
vim.o.sidescrolloff = 15;

--- Use 4 spaces per indent level.
vim.o.shiftwidth = 4;

--- Do not show partial commands. It bugs out on Termux.
--- Also slows down stuff in Visual mode.
--- vim.o.showcmd = false;

--- No point in showing the mode(use custom statusline).
--- vim.o.showmode = false;

--- This isn't required. It's here just for completeness.
vim.o.softtabstop = 4;

--- Enable spelling.
--- I also use camelCase & don't want spell
--- on buffers with no syntax.
vim.o.spell = true;
vim.o.spelloptions = "camel,noplainbuffer";

--- `:sp` opens split below.
vim.o.splitbelow = true;
--- `:vsp` opens split to the right.
vim.o.splitright = true;

--- Use 256-colors.
vim.o.termguicolors = true;

--- Each tab counts for 4 spaces.
vim.o.tabstop = 4;

--- I normally don't use wrap.
vim.o.wrap = false;

---|fE

--- Load a fallback colorscheme
if vim.fn.has("nvim-0.9.5") == 0 then
	--- On versions older then 0.9.5 load
	--- habamax.
	vim.cmd.colorscheme("habamax");
end

-- Configuration for diagnostics.
vim.diagnostic.config({
	severity_sort = true,

	signs = {
		text = {
			[vim.diagnostic.severity.INFO] = "󰀨 ",
			[vim.diagnostic.severity.HINT] = "󰁨 ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.ERROR] = "󰅙 ",
		}
	}
});

---|fS "feat: Completion types"
vim.g.__completion_kinds = {
	default = {
		icon = "󰘎 ",
		hl = "CompletionDefault",

		border_hl = "CompletionDefaultBg"
	},

	text = {
		icon = " 󰉿 ",
		hl = "CompletionDefault",

		border_hl = "CompletionDefaultBg"
	},
	method = {
		icon = " 󰆦 ",
		hl = "Color6"
	},
	["function"] = {
		icon = " 󰡱 ",
		hl = "CompletionFunction",

		border_hl = "CompletionFunctionBg"
	},
	constructor = {
		icon = " 󰌗 ",
		hl = "CompletionConstructor",

		border_hl = "CompletionConstructorBg"
	},
	field = {
		icon = " 󱏒 ",
		hl = "CompletionField",

		border_hl = "CompletionFieldBg"
	},
	variable = {
		icon = " 󰏖 ",
		hl = "CompletionVariable",

		border_hl = "CompletionVariableBg"
	},
	class = {
		icon = "  ",
		hl = "CompletionClass",

		border_hl = "CompletionClassBg"
	},
	interface = {
		icon = " 󰴠 ",
		hl = "CompletionInterface",

		border_hl = "CompletionInterfaceBg"
	},
	module = {
		icon = " 󰆧 ",
		hl = "CompletionModule",

		border_hl = "CompletionModuleBg"
	},
	property = {
		icon = "  ",
		hl = "CompletionProperty",

		border_hl = "CompletionPropertyBg"
	},
	unit = {
		icon = " 󰓅 ",
		hl = "CompletionUnit",

		border_hl = "CompletionUnitBg"
	},
	value = {
		icon = " 󰔌 ",
		hl = "CompletionValue",

		border_hl = "CompletionValueBg"
	},
	enum = {
		icon = " 󰕠 ",
		hl = "CompletionEnum",

		border_hl = "CompletionEnumBg"
	},
	keyword = {
		icon = " 󰗗 ",
		hl = "CompletionKeyword",

		border_hl = "CompletionKeywordBg"
	},
	snippet = {
		icon = "  ",
		hl = "CompletionSnippet",

		border_hl = "CompletionSnippetBg"
	},
	color = {
		icon = " 󱥚 ",
		hl = "CompletionColor",

		border_hl = "CompletionColorBg"
	},
	file = {
		icon = "  ",
		hl = "CompletionFile",

		border_hl = "CompletionFileBg"
	},
	reference = {
		icon = "  ",
		hl = "CompletionReference",

		border_hl = "CompletionReferenceBg"
	},
	folder = {
		icon = "  ",
		hl = "CompletionFolder",

		border_hl = "CompletionFolderBg"
	},
	enummember = {
		icon = " 󱁉 ",
		hl = "CompletionEnum",

		border_hl = "CompletionEnumBg"
	},
	constant = {
		icon = "  ",
		hl = "CompletionConst",

		border_hl = "CompletionConstBg"
	},
	struct = {
		icon = " 󰐫 ",
		hl = "CompletionStruct",

		border_hl = "CompletionStructBg"
	},
	event = {
		icon = " 󰔎 ",
		hl = "CompletionConst",

		border_hl = "CompletionConstBg"
	},
	operator = {
		icon = " 󰙴 ",
		hl = "CompletionOperator",

		border_hl = "CompletionOperatorBg"
	},
	typeparameter = {
		icon = " 󰮄 ",
		hl = "CompletionType",

		border_hl = "CompletionTypeBg"
	},
};
---|fE
