--- Created by: OXY2DEV
--- Usecase: Termux
---
--- A Neovim configuration focusing on cusomisation and mobile-froendly user
--- experience used for "web development" and "neovim plugin development"

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


--require("custom_plugins/trail-nvim/lua/trail").setup();
