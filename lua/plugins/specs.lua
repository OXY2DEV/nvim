local specs = require("specs");
local w = 0

require("specs").setup({
	min_jump = 30,

	popup = {
		delay_ms = 30,

		width = 0,
		blend = 25,
		inc_ms = 8,

		fader = specs.exp_fader,

		resizer = function(width, ccol, cnt)
			if (width + cnt) < 80 then
			  local v = {w + cnt, ccol};
				w = w + 1;

				return v;
			else 
				w = 0;
				return nil;
			end
		end
	}
})
