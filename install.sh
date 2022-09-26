#!/bin/zsh

cp -v .zshrc ~/
cp -v .vimrc ~/
mkdir -p ~/.config/terminator
mkdir -p ~/.vim/colos
cp -v .config/terminator/config ~/.config/terminator/config
cp -v .vim/colors/codedark.vim ~/.vim/colors/codedark.vim
