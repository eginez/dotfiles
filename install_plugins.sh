#! /bin/bash

if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "have you installed brew yet??(Ctrl+C to quit)"
    read
    echo "installing tools"
    brew install zsh macvim fzf diff-so-fancy jq ripgrep
fi

#Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

#Create directories
mkdir -p ~/.vim.backup
mkdir -p ~/.vim


echo "Creating zshrc file"
rm -rf ~/.zshrc
ln -s `pwd -P`/zshrc ~/.zshrc

echo "Adding custom theme for zsh"
ln -s `pwd -P`/lambda-color.zsh-theme ~/.oh-my-zsh/custom/themes/lambda-color.zsh-theme

echo "Creating vimrc file"
ln -s `pwd -P`/vimrc ~/.vimrc

echo "Creating gitconfig file"
ln -s `pwd -P`/gitconfig ~/.gitconfig

echo "Installing fzf key integration"
$(brew --prefix)/opt/fzf/install

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim


echo "Start vim and execute :PlugInstall"

