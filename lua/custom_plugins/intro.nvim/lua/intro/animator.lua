local animator = {};
local renderer = require("intro.renderer");

animator.get_max_frames = function (animations)
	local _m = 0;

	for _, animation in ipairs(animations) do
		if #animation.frames > _m then
			_m = #animation.frames;
		end
	end

	return _m;
end

animator.text_animator = function (buffer, window, animation, frame_number)
	local current_align = renderer.tbl_clamp(animation.aligns, frame_number) or "center";

	local current_value = renderer.tbl_clamp(animation.frames, frame_number);

	local win_h = vim.api.nvim_win_get_height(window);

	renderer.update_line(buffer, window, math.floor((win_h - renderer.height) / 2) + (animation.line or 0), {
		align = current_align,
		value = current_value
	})
end

animator.animate = function (buffer, window, config_table)
	if not config_table then
		return;
	end

	local max = animator.get_max_frames(config_table.values);
	local timer = vim.uv.new_timer();

	local frame = 1;

	timer:start(config_table.delay or 0, config_table.interval or 50, vim.schedule_wrap(function ()
		if frame > max then
			timer:stop();
			return;
		end

		for _, animation in ipairs(config_table.values) do
			if animation.type == "text" then
				animator.text_animator(buffer, window, animation, frame);
			end
		end

		frame = frame + 1;
	end));
end

return animator;
