#!/bin/bash
# alias
alias la='ls -la'
alias ll='ls -l'
alias rm='rm -i'
alias cp='cp -pi'
alias mv='mv -i'

# golang & ghq
export GOPATH=$HOME
export PATH=$PATH:$GOPATH/bin

function ghq-update(){
    ghq list | sed -E 's;^;https://;g' | xargs -n 1 -P 10 ghq get -u
}

# enhancd
source ~/.enhancd/enhancd.sh

# peco
peco-mdfind-cd() {
  local FILENAME="$1"

  if [ -z "$FILENAME" ] ; then
    echo "Usage: peco-mdfind-cd <FILENAME>" >&2
    return 1
  fi

  local DIR=$(mdfind -onlyin ~ -name ${FILENAME} | grep -e "/${FILENAME}$" | peco | head -n 1)

  if [ -n "$DIR" ] ; then
    DIR=${DIR%/*}
    echo "pushd \"$DIR\""
    pushd "$DIR"
  fi
}

peco-docker-cd() {
  peco-mdfind-cd "Dockerfile"
}

peco-vagrant-cd() {
  peco-mdfind-cd "Vagrantfile"
}

peco-find-cd() {
  local FILENAME="$1"
  local MAXDEPTH="${2:-3}"
  local BASE_DIR="${3:-`pwd`}"

  if [ -z "$FILENAME" ] ; then
    echo "Usage: peco-find-cd <FILENAME> [<MAXDEPTH> [<BASE_DIR>]]" >&2
    return 1
  fi

  local DIR=$(find ${BASE_DIR} -maxdepth ${MAXDEPTH} -name ${FILENAME} | peco | head -n 1)

  if [ -n "$DIR" ] ; then
    DIR=${DIR%/*}
    echo "pushd \"$DIR\""
    pushd "$DIR"
  fi
}

peco-git-cd() {
  peco-find-cd ".git" "$@"
}

_replace_by_history() {
  local l=$(HISTTIMEFORMAT= history | tail -r | sed -e 's/^\s*[0-9]*    \+\s\+//' | peco --query "$READLINE_LINE")
  READLINE_LINE="$l"
  READLINE_POINT=${#l}
  }
bind -x '"\C-r": _replace_by_history'
bind    '"\C-xr": reverse-search-history'
