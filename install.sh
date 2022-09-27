#!/bin/zsh
# Directories
mkdir -p ~/.config/terminator
mkdir -p ~/.vim/colors
# Backup
cp -v ~/.zshrc ~/.zshrc.datenpirat.bak
cp -v ~/.vimrc ~/.vimrc.datenpirat.bak
cp -v .config/terminator/config ~/.config/terminator/config.datenpirat.bak

# Install
cp -v .zshrc ~/
cp -v .vimrc ~/
cp -v .config/terminator/config ~/.config/terminator/config
cp -v .vim/colors/codedark.vim ~/.vim/colors/codedark.vim
