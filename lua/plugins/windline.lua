----------------------------------------------
----------------- Variables ------------------
----------------------------------------------
local windline = require('windline')

local helper = require('windline.helpers')
local sep = helper.separators

local utils = require('windline.utils')

local animation = require('wlanimation')
local efffects = require('wlanimation.effects')

local state = _G.WindLine.state



-- color list for basic
local hl_list = {
    Black = { 'white', 'black' },
    Inactive = { 'InactiveFg', 'InactiveBg' },
    Active = { 'ActiveFg', 'ActiveBg' },
}



--- The basic Statusline and it's components
local basic = {}
basic.divider = { '%=', '' }
basic.space = { ' ', '' }
basic.line_col = { [[ %3l:%-2c ]], hl_list.Black }
basic.progress = { [[%3p%% ]], hl_list.Black }
basic.bg = { ' ',  'StatusLine' }
basic.file_name_inactive = { '%f', hl_list.Inactive }
basic.line_col_inactive = { [[ %3l:%-2c ]], hl_list.Inactive }
basic.progress_inactive = { [[%3p%% ]], hl_list.Inactive }

-- Custom Text & Icons for each mode are declared HERE!
utils.change_mode_name({
	['n'] = { ' NORMAL', 'Normal' },
  ['no'] = { ' O-PENDING', 'Visual' },
  ['nov'] = { ' O-PENDING', 'Visual' },
  ['noV'] = { ' O-PENDING', 'Visual' },
  ['no'] = { ' O-PENDING', 'Visual' },
  ['niI'] = { ' NORMAL', 'Normal' },
  ['niR'] = { ' NORMAL', 'Normal' },
  ['niV'] = { ' NORMAL', 'Normal' },
  ['v'] = { '󰨞 VISUAL', 'Visual' },
  ['V'] = { '󰨞 V-LINE', 'Visual' },
  [''] = { '󰨞 V-BLOCK', 'Visual' },
  ['s'] = { ' SELECT', 'Visual' },
  ['S'] = { ' S-LINE', 'Visual' },
  [''] = { ' S-BLOCK', 'Visual' },
  ['i'] = { ' INSERT', 'Insert' },
  ['ic'] = { ' INSERT', 'Insert' },
  ['ix'] = { ' INSERT', 'Insert' },
  ['R'] = { '󰛔 REPLACE', 'Replace' },
  ['Rc'] = { '󰛔 REPLACE', 'Replace' },
  ['Rv'] = { 'V-REPLACE', 'Normal' },
  ['Rx'] = { '󰛔 REPLACE', 'Normal' },
  ['c'] = { ' COMMAND', 'Command' },
  ['cv'] = { ' COMMAND', 'Command' },
  ['ce'] = { ' COMMAND', 'Command' },
  ['r'] = { '󰛔 REPLACE', 'Replace' },
  ['rm'] = { ' MORE', 'Normal' },
  ['r?'] = { ' CONFIRM', 'Normal' },
  ['!'] = { ' SHELL', 'Normal' },
  ['t'] = { ' TERMINAL', 'Command' },
})




----------------------------------------------
----------------- Components -----------------
----------------------------------------------
basic.vi_mode = { -- refers to the right component
  name = 'vi_mode',
  hl_colors = {
    Normal = { 'white', 'black' },
    Insert = { 'black', 'white' },
    Visual = { 'black', 'green' },
    Replace = { 'black', 'cyan' },
    Command = { 'black', 'yellow' },
  },
  text = function()
    return ' ' .. state.mode[1] .. ' ' -- Empty " " spaces are used to increase component width
  end,
  hl = function()
    return state.mode[2]
  end,
}

basic.vi_mode_sep = { -- refers to the separator between the right and the 2nd right components
  name = 'vi_mode_sep',
  hl_colors = {
    Normal = { 'black', 'FilenameBg' },
    Insert = { 'white', 'FilenameBg' },
    Visual = { 'green', 'FilenameBg' },
    Replace = { 'cyan', 'FilenameBg' },
    Command = { 'yellow', 'FilenameBg' },
  },
  text = function()
    return sep.slant_right_2 -- separators can be "slant", "padded_slant", "fill" etc.
  end,
  hl = function()
    return state.mode[2]
  end,
}

basic.file_name = { -- refers to the 2nd right component
  text = function()
    local name = vim.fn.expand('%:p:t')
    if name == '' then
        name = '[No Name]'
    end
    return name .. ' '
  end,
  hl_colors = { 'FilenameFg', 'FilenameBg' }, -- background color is File names background and foreground is File name foreground
}


----------------------------------------------
---------------- Animations ------------------
----------------------------------------------
local status_color = '' -- controls the color of the waves
local change_color = function()
  local anim_colors = {
    '#90CAF9',
    '#64B5F6',
    '#42A5F5',
    '#2196F3',
    '#1E88E5',
    '#1976D2',
    '#1565C0',
    '#0D47A1',
  }
  if status_color == 'blue' then
    anim_colors = {
      '#03c03c',
      '#03ad36',
      '#02862a',
      '#027324',
      '#02601e',
      '#014d18',
      '#013a12',
      '#01260c',
    }
    status_color = 'green'
  else
    status_color = 'blue'
  end

  animation.stop_all()
  animation.animation({
    data = { -- numbers are definig the direction. Here is for right to left
      { 'waveleft1', efffects.list_color(anim_colors, 2) },
      { 'waveleft2', efffects.list_color(anim_colors, 3) },
      { 'waveleft3', efffects.list_color(anim_colors, 4) },
      { 'waveleft4', efffects.list_color(anim_colors, 5) },
      { 'waveleft5', efffects.list_color(anim_colors, 6) },
    },
    timeout = 500,
    delay = 200,
    interval = 200,
  })

  animation.animation({
    data = { -- Here is for left to right
      { 'waveright1', efffects.list_color(anim_colors, 6) },
      { 'waveright2', efffects.list_color(anim_colors, 5) },
      { 'waveright3', efffects.list_color(anim_colors, 4) },
      { 'waveright4', efffects.list_color(anim_colors, 3) },
      { 'waveright5', efffects.list_color(anim_colors, 2) },
    },
    timeout = 500,
    delay = 200,
    interval = 200,
  })
end

local wave_left = {
  text = function()
    return { -- the left wave
      { sep.slant_right_2 .. ' ', { 'FilenameBg', 'waveleft1' } },
      { sep.slant_right_2 .. ' ', { 'waveleft1', 'waveleft2' } },
      { sep.slant_right_2 .. ' ', { 'waveleft2', 'waveleft3' } },
      { sep.slant_right_2 .. ' ', { 'waveleft3', 'waveleft4' } },
      { sep.slant_right_2 .. ' ', { 'waveleft4', 'waveleft5' } },
      { sep.slant_right_2 .. ' ', { 'waveleft5', 'wavedefault' } },
    }
  end,
  click = change_color,
}

local wave_right = {
  text = function()
    return { -- the right wave
      { sep.slant_right_2 .. " ", { 'wavedefault', 'waveright1' } },
      { sep.slant_right_2 .. " ", { 'waveright1', 'waveright2' } },
      { sep.slant_right_2 .. " ", { 'waveright2', 'waveright3' } },
      { sep.slant_right_2 .. " ", { 'waveright3', 'waveright4' } },
      { sep.slant_right_2 .. " ", { 'waveright4', 'waveright5' } },
      { sep.slant_right_2 .. " ", { 'waveright5', 'ActiveBg' } },
    }
  end,
  click = change_color,
}

local wave_left_2 = { -- 2nd version of wave
   text = function()
     return {
	 			 { sep.slant_right_2 .. " ", { "waveleft1", 'waveleft1' } },
         { sep.slant_right_2 .. " ", { 'waveleft1', 'waveleft2' } },
         { sep.slant_right_2 .. " ", { 'waveleft2', 'waveleft3' } },
         { sep.slant_right_2 .. " ", { 'waveleft3', 'waveleft4' } },
         { sep.slant_right_2 .. " ", { 'waveleft4', 'waveleft5' } },
         { sep.slant_right_2 .. " ", { 'waveleft5', 'waveleft5' } },
       }
   end,
   click = change_color,
}
local wave_left_2_infinte = { -- used in terminal to make infinite wave
   text = function()
     return {
	 			 { sep.slant_right_2 .. " ", { "waveleft5", 'waveleft1' } },
         { sep.slant_right_2 .. " ", { 'waveleft1', 'waveleft2' } },
         { sep.slant_right_2 .. " ", { 'waveleft2', 'waveleft3' } },
         { sep.slant_right_2 .. " ", { 'waveleft3', 'waveleft4' } },
         { sep.slant_right_2 .. " ", { 'waveleft4', 'waveleft5' } },
         { sep.slant_right_2 .. " ", { 'waveleft5', 'FilenameBg' } },
       }
   end,
   click = change_color,
}

local wave_right_2 = { -- 2nd version of wave
   text = function()
     return {
	 			{ sep.slant_right_2 .. " ", { 'wavedefault', 'waveright1' } },
         { sep.slant_right_2 .. " ", { 'waveright1', 'waveright2' } },
         { sep.slant_right_2 .. " ", { 'waveright2', 'waveright3' } },
         { sep.slant_right_2 .. " ", { 'waveright3', 'waveright4' } },
         { sep.slant_right_2 .. " ", { 'waveright4', 'waveright5' } },
         { sep.slant_right_2 .. " ", { 'waveright5', 'FilenameBg' } },
       }
   end,
   click = change_color,
}




-- The custom statusline
local custom = {}

----------------------------------------------
----------------- Components -----------------
----------------------------------------------
custom.file_name = { -- custom file name component to be used with wave
  text = function()
    local name = vim.fn.expand('%:p:t')
    if name == '' then
        name = '[No Name]'
    end
    return name .. ' '
  end,
  hl_colors = { 'FilenameFg', 'wavedefault' },
}

custom.file_name_divider = { '%=', { "wavedefault", "FilenameBg" } } -- divider between file name and wave


custom.vi_mode_sep = { -- used in the terminal. The right component
  name = 'vi_mode_sep',
  hl_colors = {
    Normal = { 'black', 'waveleft1' },
    Insert = { 'white', 'waveleft1' },
    Visual = { 'green', 'waveleft1' },
    Replace = { 'cyan', 'waveleft1' },
    Command = { 'yellow', 'waveleft1' },
  },
  text = function()
    return sep.slant_right_2
  end,
  hl = function()
    return state.mode[2]
  end,
}


----------------------------------------------
---------- Statusline Declarations -----------
----------------------------------------------
local default = { -- the regular statusline
  filetypes = { 'default' },
  active = {
    basic.vi_mode,
    basic.vi_mode_sep,
    { ' ', '' },
    basic.file_name,
    wave_left,
    { ' ', { 'FilenameBg', 'wavedefault' } },
    basic.divider,
    wave_right,
    basic.line_col,
    basic.progress,
  },
  inactive = {
    basic.file_name_inactive,
    basic.divider,
    basic.divider,
    basic.line_col_inactive,
    { '', { 'white', 'InactiveBg' } },
    basic.progress_inactive,
  },
}

local readme = { -- statusline for markdown and help
	filetypes = { "markdown", "json", "help" },
	active = {
		custom.file_name_divider,
		wave_left,
		{ " ", "" },
		custom.file_name,
		{ " ", "" },
		wave_right_2,
		custom.file_name_divider,
	}
}

local terminal = { -- statusline for the terminal
	filetypes = { "toggleterm" },
	active = {
		basic.vi_mode,
		custom.vi_mode_sep,

		wave_left_2,
		wave_left_2_infinte,

		basic.divider
	}
}


----------------------------------------------
--------------- Global Setup -----------------
----------------------------------------------
windline.setup({
    colors_name = function(colors)
        colors.FilenameFg = colors.white
        colors.FilenameBg = colors.black_light

        colors.wavedefault = "#1F1E2F" --colors.black_light
        colors.waveleft1 = colors.wavedefault
        colors.waveleft2 = colors.wavedefault
        colors.waveleft3 = colors.wavedefault
        colors.waveleft4 = colors.wavedefault
        colors.waveleft5 = colors.wavedefault

        colors.waveright1 = colors.wavedefault
        colors.waveright2 = colors.wavedefault
        colors.waveright3 = colors.wavedefault
        colors.waveright4 = colors.wavedefault
        colors.waveright5 = colors.wavedefault
        return colors
    end,
    statuslines = {
        default,
				readme,
				terminal
    },
})

-- animation loop
vim.defer_fn(function()
    change_color()
end, 100)





