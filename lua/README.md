# 📦 File structure

```text
📦 nvim/
├─ 📄 README.md
├─ 🔩 init.lua
╰─ 🛸 lua/
   ├─ 🧭 config/
   ╷  ├─ 🔩 settings.lua
   ╷  ├─ 🧩 keymaps.lua
   ╷  ╰─ 💤 lazy.lua
   ╷
   ├─ 📦 plugins/
   ╷  ╰─ ...
   ├─ 🪷 custom_plugins
   ╷  ├─ 📄 markview.nvim
   ╷  ├─ 💡 helpview.nvim
   ╷  ├─ 🎇 bars-N-lines.nvim
   ╷  ├─ 📦 foldtext.nvim
   ╷  ├─ ...
   ╷  ╰─ 📏 indent.nvim
   ╰─ ✨ scripts/
```

Configuration is divided in 4 different folders.

- `config/`, for Neovim configuration.
- `plugins/`, for plugin specific configuration.
- `custom_plugins/`, for custom made plugins.
- `scripts/`, small files that adds extra utilities.


