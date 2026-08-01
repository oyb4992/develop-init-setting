bind 'set bell-style none'

if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
  bat_command=$(command -v bat 2>/dev/null || command -v batcat)
  export FZF_CTRL_T_OPTS="--preview '$bat_command --color=always --line-range=:500 {} 2>/dev/null || eza --tree --level=1 --icons=auto --color=always {} 2>/dev/null || ls -la {}'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons=auto --color=always {} 2>/dev/null || ls -la {}'"
  unset bat_command
fi
