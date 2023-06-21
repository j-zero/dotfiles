#!/bin/zsh
# Directories
mkdir -p ~/.config/terminator
mkdir -p ~/.vim/colors
# Backup
cp -v ~/.zshrc ~/.zshrc.datenpirat.bak
cp -v ~/.vimrc ~/.vimrc.datenpirat.bak
cp -v .config/terminator/config ~/.config/terminator/config.datenpirat.bak
#cp -v -r ./.zsh ~/.zsh
#git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
#git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
#git clone https://github.com/zsh-users/zsh-completions ~/.zsh/zsh-completions
#git clone https://github.com/Aloxaf/fzf-tab ~/.zsh/fzf-tab
#git clone https://github.com/unixorn/fzf-zsh-plugin.git ~/.zsh/fzf-zsh-plugin


# Install
cp -v .zshrc ~/
cp -v .zsh_autorun ~/
cp -v .vimrc ~/
cp -v .config/terminator/config ~/.config/terminator/config
cp -v .vim/colors/codedark.vim ~/.vim/colors/codedark.vim
[[ ! -f ~/.zshrc.settings ]] && cp -v .zshrc.settings ~/

source ~/.zshrc
