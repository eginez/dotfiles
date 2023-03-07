#! /bin/bash
set -u  # die on undeclared vars
set -o pipefail # die on pipe failures
set -e #die on error

DWL="sudo apt-get install -y vim zsh fzf jq ripgrep tree"
## missing ccls in linux
## snap install --classic cls

if [[ USE_NVIM ]]; then
  VIM=neovim
else
  VIM=macvim
fi

DWNL_DARWIN="brew install zsh $VIM fzf diff-so-fancy jq ripgrep tree ccls npm"

if [[ "$(uname -s)" == "Darwin" ]]; then
	DWL=$DWNL_DARWIN
fi

# Download software
echo "Downloading software..."
$DWL

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

echo "Adding power10k"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
ln -s `pwd -P`/p10k.zsh ~/.p10k.zsh

echo "Adding better zsh vim mode"
git clone https://github.com/jeffreytse/zsh-vi-mode ${ZSH:-$HOME}/custom/plugins/zsh-vi-mode

echo "Creating vimrc file"
ln -s `pwd -P`/vimrc ~/.vimrc

echo "Creating gitconfig file"
ln -s `pwd -P`/gitconfig ~/.gitconfig

echo "Creating tmux config file"
ln -s `pwd -P`/tmux.conf ~/.tmux.conf


echo "Installing fzf key integration"
if [[ "$(uname -s)" == "Darwin" ]]; then
	$(brew --prefix)/opt/fzf/install
fi

if [[ USE_NVIM ]]; then
  echo "configuring nvim"
  ln -s `pwd -P`/nvim-config/nvim ~/.config
  nvim +PackerSync +qall
else
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim


  echo "Start vim and execute :PlugInstall"
  ## vim -u plugins.vim  +PlugInstall +qall  # Install plugins only
  vim +PlugInstall +qall
  vim +CocInstall coc-json coc-tsserver
fi

