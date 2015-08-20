#!/bin/bash
set -e
set -u

setup() {
  dotfiles=$HOME/.dotfiles

  has() {
    type "$1" > /dev/null 2>&1
  }

  symlink() {
    [ -e "$2" ] || ln -s "$1" "$2"
  }

  if [ -d "$dotfiles" ]; then
    (cd "$dotfiles" && git pull --rebase)
  else
    git clone https://github.com/watarukura/.dotfiles "$dotfiles"
  fi

  has git && symlink "$dotfiles/.gitconfig" "$HOME/.gitconfig"

  if has bash; then
    symlink "$dotfiles/.bash_profile" "$HOME/.bash_profile"
    symlink "$dotfiles/.bashrc" "$HOME/.bashrc"

  if has peco; then
    mkdir -p "$HOME/.peco"
    symlink "$dotfiles/.peco/config.json" "$HOME/.peco/config.json"
  fi

  if has vim; then
    symlink "$dotfiles/.vimrc" "$HOME/.vimrc"
    mkdir -p "$HOME/.vim"
    symlink "$dotfiles/.vim/filetype.vim" "$HOME/.vim/filetype.vim"
    mkdir -p "$HOME/.vim/colors"
    symlink "$dotfiles/.vim/colors/traditional.vim" "$HOME/.vim/colors/traditional.vim"
    mkdir -p "$HOME/.vim/config"
    symlink "$dotfiles/.vim/config/plugins.vim" "$HOME/.vim/config/plugins.vim"
  
}

setup
