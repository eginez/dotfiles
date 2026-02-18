#! /bin/bash
set -u          # die on undeclared vars
set -o pipefail # die on pipe failures
set -e          # die on error

DOTFILES=$(pwd -P)

install_packages() {
  echo "Installing packages..."
  if [[ "$(uname -s)" == "Darwin" ]]; then
    brew install zsh neovim fzf diff-so-fancy jq ripgrep tree ccls npm lua-language-server ghostty
  else
    sudo apt-get install -y vim zsh fzf jq ripgrep tree
  fi
}

install_zsh() {
  echo "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  echo "Adding powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

  echo "Linking zsh configs..."
  ln -sf $DOTFILES/zsh/zshrc ~/.zshrc
  ln -sf $DOTFILES/zsh/p10k.zsh ~/.p10k.zsh
  ln -sf $DOTFILES/zsh/lambda-color.zsh-theme ~/.oh-my-zsh/custom/themes/lambda-color.zsh-theme

  echo "Installing fzf key integration..."
  if [[ "$(uname -s)" == "Darwin" ]]; then
    $(brew --prefix)/opt/fzf/install
  fi
}

install_git() {
  echo "Linking git configs..."
  ln -sf $DOTFILES/git/gitconfig ~/.gitconfig
  ln -sf $DOTFILES/git/globalgitignore ~/.gitignore_global
}

install_tmux() {
  echo "Linking tmux config..."
  ln -sf $DOTFILES/tmux/tmux.conf ~/.tmux.conf
}

install_nvim() {
  echo "Linking nvim config..."
  mkdir -p ~/.config
  ln -sf $DOTFILES/nvim ~/.config/nvim
}

install_ghostty() {
  echo "Linking ghostty config..."
  mkdir -p ~/.config/ghostty
  ln -sf $DOTFILES/ghostty/config ~/.config/ghostty/config
}

install_packages
install_zsh
install_git
install_tmux
install_nvim
install_ghostty
