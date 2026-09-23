# Clean, safe, production-ready Zsh configuration
# ------------------------------------------------

# ---------- 1. Basic Initialization & Security ----------
umask 022


# ---------- 2. Environment Variables ----------
export EDITOR="code --wait"
export VISUAL="$EDITOR"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Homebrew optimizations
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1


# ---------- 3. Path Configuration ----------
typeset -U path

# Rebuild PATH cleanly
path=(
    $HOME/bin
    $HOME/.local/bin
    $HOME/.lmstudio/bin
    /Library/PostgreSQL/17/bin
    /opt/homebrew/bin
    /opt/homebrew/sbin
    /usr/local/bin
    /usr/bin
    /bin
    /usr/sbin
    /sbin
)


# ---------- 4. History Configuration ----------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY


# ---------- 5. Shell Behavior & Directory Navigation ----------
setopt INTERACTIVE_COMMENTS
setopt NO_FLOW_CONTROL

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt PUSHD_TO_HOME
setopt AUTO_PARAM_SLASH


# ---------- 6. Key Bindings ----------
bindkey -e

bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

bindkey '^?' backward-delete-char
bindkey '^[[3~' delete-char


# ---------- 7. Completion System ----------
autoload -Uz compinit

if [[ $(date +%j) != $(/usr/bin/stat -f %Sm -t %j ~/.zcompdump 2>/dev/null) ]]; then
    compinit
else
    compinit -C
fi

zmodload zsh/complist

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors '${(s.:.)LS_COLORS}'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) * =01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -ww"

bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char


# ---------- 8. Plugin Loading ----------
# autosuggestions
if [[ -f "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
fi

# syntax highlighting
if [[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -f /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# fzf integration
if (( $+commands[fzf] )); then
    source <(fzf --zsh)
fi


# ---------- 9. Aliases ----------
# filesystem (prefer eza when available)
if (( $+commands[eza] )); then
    alias ls="eza --color=auto"
    alias ll="eza -lah --git --time-style=long-iso"
    alias la="eza -a"
    alias lt="eza --tree"
fi

# safety
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

# navigation
alias ..="cd .."
alias ...="cd ../.."

# git
alias ga="git add"
alias gc="git commit"
alias gco="git checkout"
alias gs="git status"
alias gd="git diff"
alias gl="git log --oneline --graph --decorate"
alias gp="git pull"

# utilities
alias df="df -h"
alias du="du -h"
alias path='echo $PATH | tr ":" "\n" | nl'
alias ports='lsof -i -P | grep LISTEN'
alias reload="source ~/.zshrc"

# python
alias python="python3"
alias pip="pip3"
alias serve="python3 -m http.server"
alias json="python3 -m json.tool"

# npm
alias ni="npm install"
alias nr="npm run"
alias ns="npm start"
alias nt="npm test"
alias nb="npm run build"


# ---------- 10. Custom Functions ----------
mkcd() {
    mkdir -p "$1" && cd "$1"
}

extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.rar)     unrar e "$1" ;;
            *.gz)      gunzip "$1" ;;
            *.tar)     tar xf "$1" ;;
            *.tbz2)    tar xjf "$1" ;;
            *.tgz)     tar xzf "$1" ;;
            *.zip)     unzip "$1" ;;
            *.Z)       uncompress "$1" ;;
            *.7z)      7z x "$1" ;;
            *)         echo "Unknown format: $1" ;;
        esac
    else
        echo "File not found: $1"
    fi
}

port() {
    lsof -i ":$1"
}


# ---------- 11. Theme & Prompt ----------
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"


# ---------- 12. External Tool Initialization ----------
if (( $+commands[starship] )); then
    eval "$(starship init zsh)"
fi

if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
fi

if (( $+commands[bat] )); then
    alias c="bat --paging=never"
    export BAT_THEME="ansi"
fi

if (( $+commands[rg] )); then
    alias rgi="rg --smart-case --hidden --follow"
fi

if (( $+commands[fd] )); then
    alias fdi="fd --hidden --follow"
fi

if (( $+commands[tldr] )); then
    alias help="tldr"
fi

if (( $+commands[htop] )); then
    alias top="htop"
fi

if [[ -x "$HOME/.local/bin/mise" ]]; then
    eval "$("$HOME/.local/bin/mise" activate zsh)"
fi
