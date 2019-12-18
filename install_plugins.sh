#! /bin/bash

#Create directories
mkdir -p ~/.vim.backup
mkdir -p ~/.vim

echo "Creating vimrc file"
ln -s `pwd -P`/vimrc ~/.vimrc

echo "Creating gitconfig file"
ln -s `pwd -P`/gitconfig ~/.gitconfig

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim


#echo "Downloading vim plugins"
##Pathogen
#mkdir -p ~/.vim/autoload ~/.vim/bundle && \
#curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
#
##NerdTree
#cd ~/.vim/bundle
#git clone https://github.com/scrooloose/nerdtree.git
#
##Supertab
#cd ~/.vim/bundle
#git clone https://github.com/ervandew/supertab.git
#
##Airline
#cd ~/.vim/bundle
#git clone https://github.com/vim-airline/vim-airline
#
##Solarized
#cd ~/vim/bundle
#git clone git://github.com/altercation/vim-colors-solarized.git




