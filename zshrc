setopt inc_append_history

bindkey -e .

# Git
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '%b '

setopt PROMPT_SUBST
PROMPT='[%F{blue}%~%f] %F{red}${vcs_info_msg_0_}%f λ '

alias vim="nvim"
alias ls='ls --color=auto'
alias ll='ls -lG'
alias la='ls -aG'

export PATH=/opt/homebrew/bin:$PATH

if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ] && [[ ! "$TERM_PROGRAM" = "vscode" ]]; then
 exec tmux new-session
fi

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# custom scripts
export PATH="$HOME/.config/bin/scripts:$PATH"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# history fix for TMUX
HISTSIZE=1000000 

# fzf completions
source <(fzf --zsh)

# zsh autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

ZSH_AUTOSUGGEST_STRATEGY=(history completion)

bindkey '^[[Z' autosuggest-accept

libraries=$HOME/Dev/libraries
export CPATH=/opt/homebrew/include:$libraries/include:/opt/homebrew/include/eigen3 
export LIBRARY_PATH=/opt/homebrew/lib:$libraries/lib
export CGAL_DIR=$libraries
export CMAKE_INSTALL_PREFIX=$libraries
export CMAKE_PREFIX_PATH=$libraries:$CMAKE_PREFIX_PATH
export DYLD_LIBRARY_PATH=$libraries/lib:$DYLD_LIBRARY_PATH

. "$HOME/.cargo/env"
