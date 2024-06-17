---+ Icon: "" Title: "Neovim" Line count: "false" Padding: "0" BorderL: " " BorderR: " "
--- Created by: OXY2DEV
--- Usecase: Termux
---
--- Neovim dotfiles focusing on customisation & mobile-friendly user experience.
--- Meant to be used inside Termux
---
---  A nerd font is highly recommended
---
---+ Padding: "4" Icon: "" Title: "Features" Line count: "false" Padding: "0" BorderL: " " BorderR: " "
--- • Fully customisable setup out-of-the-box
--- • Beginner friendly code
--- • UI animations
---
--- And much more
---_
---+ Padding: "4" Icon: " " Title: "File structure" Line count: "false" Padding: "0" BorderL: " " BorderR: " "
---
---   nvim
---  ├─ 󰢱 init.lua
---  ├─  README.md
---  │
---  ╰─  lua
---     ├─  config
---     ├─  custom-plugins
---     ├─  plugins
---		├─ 󰯂 scripts
---		│
---		╰─  about.lua
---
---_
---_

---+ Title: "Load core files" Gap: "1" Border: " "
require("config/settings");
require("config/keymaps");
---_

---+ Title: "Load scripts" Gap: "1" Border: " "
require("scripts/foldtext");
require("scripts/beacon");
require("scripts/winopen");
---_

require("config/lazy");

--+
--
--+2
--
--+3
--
--+
--
--
--
--
--_
--
--_
--
--_
--
--_

-- vim:nospell:
