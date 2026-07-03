# =========================================================
# Exit if non-interactive
# =========================================================

case $- in
    *i*) ;;
      *) return;;
esac

# =========================================================
# Environment / PATH
# =========================================================

export LANG="en_US.UTF-8"

export PATH="$HOME/.local/bin:$PATH"

# Nix
if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# Homebrew
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - bash)"
fi

# Ruby gems
export PATH="$HOME/.gem/bin:$PATH"

# npm global packages
export PATH="$HOME/.npm-packages/bin:$PATH"

# =========================================================
# Completion
# =========================================================

# bash-completion
if [[ -f /etc/bash_completion ]]; then
  source /etc/bash_completion
fi

# Homebrew bash-completion
if [[ -f /opt/homebrew/etc/profile.d/bash_completion.sh ]]; then
  source /opt/homebrew/etc/profile.d/bash_completion.sh
fi

# Case-insensitive completion
bind 'set completion-ignore-case on'

# Show all matches immediately
bind 'set show-all-if-ambiguous on'

# Colored completion
bind 'set colored-stats on'

# Mark symlinked directories
bind 'set mark-symlinked-directories on'

# Tab menu completion
bind 'TAB:menu-complete'

# Shift-Tab backwards
bind '"\e[Z": menu-complete-backward'

# =========================================================
# GPG / SSH
# =========================================================

export GPG_TTY="$(tty)"

export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"

gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1

# =========================================================
# fzf
# =========================================================

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
fi

# =========================================================
# Colors
# =========================================================

if [[ "$TERM" == *256color* ]] || [[ "$TERM" == xterm-color ]]; then
  color_prompt=yes
fi

if [[ "$color_prompt" == yes ]]; then
  PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
  PS1='\u@\h:\w\$ '
fi

unset color_prompt

# =========================================================
# Terminal title
# =========================================================

case "$TERM" in
xterm*|rxvt*)
  PS1="\[\e]0;\u@\h: \w\a\]$PS1"
  ;;
*)
  ;;
esac

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
alias nvimgpt='gpg --decrypt ~/.config/nvim/chatGPT_API_key.txt.gpg 1>/dev/null 2>/dev/null && nvim'

# =========================================================
# Vim mode
# =========================================================

set -o vi

# =========================================================
# History
# =========================================================

HISTSIZE=2000
HISTFILESIZE=1000

shopt -s histappend

PROMPT_COMMAND='history -a'

HISTCONTROL=ignoredups:ignorespace
