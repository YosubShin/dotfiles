# =============
#    INIT
# =============

# Senstive functions which are not pushed to Github
# It contains GOPATH, some functions, aliases etc...
[ -r ~/.zsh_private ] && source ~/.zsh_private

# =============
#    ALIAS
# =============
alias gb="git branch --sort=authordate"
alias gbd="git branch -D"
alias gs="git status"

# =============
#    EXPORT
# =============
#

export PATH="/usr/local/go/bin:$GOBIN:$HOME/.cargo/bin:$PATH"

export EDITOR="emacs"
export LSCOLORS=cxBxhxDxfxhxhxhxhxcxcx
export CLICOLOR=1

# support colors in less
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# =============
#    HISTORY
# =============

## Command history configuration
HISTFILE=$HOME/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

setopt append_history
setopt extended_history
setopt hist_expire_dups_first
# ignore duplication command history list
setopt hist_ignore_dups 
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
# share command history data
setopt share_history 

# ===================
#    PLUGINS
# ===================

source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# ===================
#    THIRD PARTY
# ===================
# brew install direnv
# https://github.com/direnv/direnv
eval "$(direnv hook zsh)"
