local wilder = require("wilder");

local gradient = {
	"#c2e59c",
	"#a7e4a5",
	"#8be1b1",
	"#6edebf",
	"#50dacd",
	"#33d4db",
	"#1fcde7",
	"#2ac6ef",
	"#46bdf4",
	"#64b3f4"
}

for i, fg in ipairs(gradient) do
  gradient[i] = wilder.make_hl('WilderGradient' .. i, 'Pmenu', {{a = 1}, {a = 1}, {foreground = fg, background = "#1E1E2E"}})
end

local S_gradient = {
	"#83a4d4",
	"#83aedb",
	"#85b8e2",
	"#88c2e7",
	"#8cccec",
	"#92d6f1",
	"#99dff5",
	"#a1e9f8",
	"#abf2fc",
	"#b6fbff"
}

for i, fg in ipairs(S_gradient) do
  S_gradient[i] = wilder.make_hl('WilderSGradient' .. i, 'Pmenu', {{a = 1}, {a = 1}, {foreground = fg, background = "#45485B"}})
end


-- {{{3 Setup
wilder.setup({
	modes = { ":", "/", "?" },

	next_key = "<C-Down>",
	previous_key = "<C-Up>",

	accept_key = "<Tab>",
	reject_key = "<S-Tab>"
})
-- }}}3


-- {{{3 Renderer Options
wilder.set_option("renderer", wilder.popupmenu_renderer(
	wilder.popupmenu_palette_theme({
		highlights = {
			gradient = gradient,
			selected_gradient = S_gradient
		},
		highlighter = wilder.highlighter_with_gradient({
			wilder.basic_highlighter()
		}),
		border = "rounded",

		max_height = "75%", min_height = "25%",

		prompt_position = "bottom"
	})
))
-- }}}3
