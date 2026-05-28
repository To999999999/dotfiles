# =========================================================
# Environment / PATH
# =========================================================

export LANG="en_US.UTF-8"

# Nix
if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# Homebrew (macOS + Linuxbrew)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# fzf
if command -v fzf >/dev/null 2>&1; then
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi

  source <(fzf --zsh)
fi

# # zoxide (replaces cd)
# if command -v zoxide >/dev/null 2>&1; then
#   eval "$(zoxide init --cmd cd zsh)"
# fi

# Using nvim as the default editor
export EDITOR=nvim

# Open buffer line in editor
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^E' edit-command-line

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# Ruby gems
export PATH="$HOME/.gem/bin:$PATH"

# npm global packages
export PATH="$HOME/.npm-packages/bin:$PATH"

# =========================================================
# GPG / SSH
# =========================================================

export GPG_TTY="$(tty)"

export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"

gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1

gpg-connect-agent /bye >/dev/null 2>&1

# =========================================================
# Colors
# =========================================================

if [[ "$OSTYPE" == darwin* ]]; then
  export LSCOLORS="ExFxCxDxBxegedabagacad"
fi

autoload -U colors && colors

# =========================================================
# Completion system
# =========================================================

fpath=("$ZDOTDIR/completion" $fpath)

autoload -Uz compinit
compinit

zstyle ':completion:*:default' list-colors \
'no=00;37:fi=00;37:di=00;34:ln=00;35:ex=00;32:*.jpg=35:*.png=36'

zstyle ':completion:*:menu:*' select=1

zstyle ':completion:*:menu' select-prompt \
'%S%F{black}%K{yellow}Scrolling: %p%k%f%s'

zstyle ':completion:*' format 'Completing %d'

zstyle ':completion:*:matches' group 'yes'

zstyle ':completion:*:descriptions' format '%F{cyan}%d%f'

zstyle ':completion:*' list-prompt \
'%F{yellow}-- Completion Options --%f'

zstyle ':completion:*:match:*' list-colors \
'=(#b)fg=white,bold;bg=blue'

zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Z}' \
  'r:|[._-]=* r:|=*'

# zoxide (replaces cd)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd cd zsh)"
fi
# =========================================================
# Plugins
# =========================================================

source "$ZDOTDIR/antidote/antidote.zsh"

antidote load

# =========================================================
# Prompt
# =========================================================

[[ -f "$ZDOTDIR/.p10k.zsh" ]] && source "$ZDOTDIR/.p10k.zsh"

# =========================================================
# Aliases
# =========================================================

# Portable ls colors
if ls --color >/dev/null 2>&1; then
  alias ls='ls --color=auto'
else
  alias ls='ls -G'
fi

# Trick to prompt and cache the gpg-agent key password (needed for chatGPT, cause pinetry-curses conflicts with nvim)
alias nvimgpt='gpg --decrypt ~/.config/nvim/chatGPT_API_key.txt.gpg 1>/dev/null 2>/dev/null && nvim "+lua require(\"lazy\").load({plugins={\"ChatGPT.nvim\"}})"'

# =========================================================
# History
# =========================================================

export ZSH_SESSION_DIR="$ZDOTDIR/sessions"

mkdir -p "$ZSH_SESSION_DIR"

HISTFILE="$ZSH_SESSION_DIR/zsh_history"

HISTSIZE=2000
SAVEHIST=1000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
