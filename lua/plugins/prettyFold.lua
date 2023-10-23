require('pretty-fold').setup{
	keep_indentation = false,
	fill_char = '─',
	sections = {
		left = {
			"─", "content", ""
		},
		right = {
			' ', 'number_of_folded_lines', ': ', 'percentage', ' ─',
		}
	},
}

