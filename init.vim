lua << EOF

-- lua code here
--package.searchpath = "~/.config/nvim/lua/?.lua"

package.path = "/data/data/com.termux/files/home/.config/nvim/?.lua"
require "lua/main"

EOF

source ~/.config/nvim/lua/plugins/coc.vim
source ~/.config/nvim/lua/plugins/emmet.vim

