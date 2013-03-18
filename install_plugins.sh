#! /bin/bash

if [ ! -d ~/.vim.backup ];
then
    mkdir -p ~/.vim.backup
fi

if [ ! -d ~/.vim ];
then
    mkdir -p ~/.vim
fi

#NerdTree
wget -O tmp.zip  http://www.vim.org/scripts/download_script.php?src_id=17123 
unzip -d ~/.vim tmp.zip && rm tmp.zip

#Molokai
wget -O molokai.vim http://www.vim.org/scripts/download_script.php?src_id=9750
if [ ! -d ~/.vim/colors ];
then
    mkdir -p ~/.vim/colors
fi
mv molokai.vim ~/.vim/colors
