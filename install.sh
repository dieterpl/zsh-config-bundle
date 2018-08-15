#!/bin/sh
colorPrint(){
    printf "${BLUE}"
    echo "$1"
    printf "${NORMAL}"
}
colorSetup(){
      if which tput >/dev/null 2>&1; then
      ncolors=$(tput colors)
  fi
  if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    BOLD="$(tput bold)"
    NORMAL="$(tput sgr0)"
  else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    NORMAL=""
  fi
}
installBrew(){
    which -s brew
    if [[ $? != 0 ]] ; then
        # Install Homebrew
        colorPrint "Installing Brew"
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null
    else
        colorPrint "Brew already installed"
        brew update
    fi
}
colorSetup
colorPrint "Backing up zshrc"
if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
    printf "${YELLOW}Found ~/.zshrc.${NORMAL} ${GREEN}Backing up to ~/.zshrc.backup${NORMAL}\n";
    mv ~/.zshrc ~/.zshrc.backup;
fi
# Install Brew
installBrew
# Install apps
colorPrint "Installing ZSH ..."
brew install zsh
colorPrint "Installing tree ..."
brew install tree
colorPrint "Installing exa ..."
brew install exa
colorPrint "Installing fasd ..."
brew install fasd
colorPrint "Installing micro ..."
brew install micro
colorPrint "Installing fzf ..."
brew install fzf
#$(brew --prefix)/opt/fzf/install < dev/null
# Install oh-my-zsh
export ZSH = ~/.oh-my-zsh
colorPrint "Installing oh-my-zsh ..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" < /dev/null
cp "$ZSH"/templates/zshrc.zsh-template ~/.zshrc
# Set Theme
colorPrint "Setting Theme"
sed 's,ZSH_THEME=[^;]*,ZSH_THEME=muse,' ~/.zshrc > ~/tempfilezshrc
cp ~/tempfilezshrc ~/.zshrc
rm ~/tempfilezshrc
# Add plugins
colorPrint "Install plugins"
git clone https://github.com/junegunn/fzf.git ${ZSH}/custom/plugins/fzf
${ZSH}/custom/plugins/fzf/install --bin
git clone https://github.com/Treri/fzf-zsh.git ${ZSH}/custom/plugins/fzf-zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH}/plugins/zsh-autosuggestions
sed 's,^plugins=(,plugins=(brew git gitfast mvn zsh-autosuggestions fzf-zsh docker iterm2 last-working-dir colored-man-pages colorize,' ~/.zshrc > ~/tempfilezshrc
cp ~/tempfilezshrc ~/.zshrc
rm ~/tempfilezshrc
echo "eval \"\$(fasd --init auto zsh-hook zsh-ccomp zsh-ccomp-install zsh-wcomp zsh-wcomp-install)\"" >> ~/.zshrc
# Add aliases
colorPrint "Set Aliases"
echo "export EDITOR = micro"
echo "alias fh=\"find . -name\"" >> ~/.zshrc
echo "alias t=\"tree -C -h\"" >> ~/.zshrc
echo "alias m=\"micro\"" >> ~/.zshrc
echo "alias l=\"exa -luabgU --git --time-style default -s type\"" >> ~/.zshrc
echo "alias c=\"fasd_cd -d\"" >> ~/.zshrc
echo "alias mm=\"fasd -e micro --f\"" >> ~/.zshrc
echo "alias mmm\"fasd -e micro -i\"" >> ~/.zshrc
colorPrint "Changing Shell (admin)"
chsh -s $(which zsh)
