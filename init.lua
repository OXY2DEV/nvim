--- Created by: OXY2DEV
--- Usecase: Termux
---
--- A Neovim configuration focusing on cusomisation and mobile-froendly user
--- experience used for "web development" and "neovim plugin development"

---+ Title: "Load core files" Gap: "1" Border: " "
require("config/settings");
require("config/keymaps");
---_

---+ Title: "Load scripts"
require("scripts/foldtext");
require("scripts/whereAmI");
---_

--print("Hello World");
