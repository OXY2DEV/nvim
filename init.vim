lua << EOF

-- Set the path where to search for config files
package.path = "/data/data/com.termux/files/home/.config/nvim/?.lua"
require "lua/main"

EOF

source ~/.config/nvim/lua/plugins/coc.vim
source ~/.config/nvim/lua/plugins/emmet.vim

