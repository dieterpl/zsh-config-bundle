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

colorSetup
colorPrint "Backing up zshrc"
if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
    printf "${YELLOW}Found ~/.zshrc.${NORMAL} ${GREEN}Backing up to ~/.zshrc.backup${NORMAL}\n";
    mv ~/.zshrc ~/.zshrc.backup;
fi
# Install Brew
# Install apps
colorPrint "Installing Git ..."
sudo apt-get -y install git
colorPrint "Installing ZSH ..."
sudo apt-get -y install zsh
colorPrint "Installing tree ..."
sudo apt-get -y install tree
colorPrint "Installing exa ..."
curl -Lo exa.zip "https://github.com/ogham/exa/releases/download/v0.8.0/exa-linux-x86_64-0.8.0.zip"
unzip -o exa.zip -d "./"
rm -f exa.zip
sudo mv exa-linux-x86_64 /usr/bin/exa
rm -rf exa-linux-x86_64
colorPrint "Installing fasd ..."
curl -Lo fasd.zip "https://github.com/clvv/fasd/zipball/1.0.1"
unzip -o fasd.zip -d "./"
rm -f fasd.zip
sudo mv clvv-fasd-4822024/fasd /usr/bin/fasd
rm -rf clvv-fasd-4822024
colorPrint "Installing micro ..."
curl https://getmic.ro | bash
sudo mv micro /usr/bin/micro

#$(brew --prefix)/opt/fzf/install < dev/null
# Install oh-my-zsh
colorPrint "Installing oh-my-zsh ..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" < /dev/null
export ZSH=~/.oh-my-zsh
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
# Set Theme
colorPrint "Setting Theme"
sed 's,ZSH_THEME=[^;]*,ZSH_THEME=muse,' ~/.zshrc > ~/tempfilezshrc
cp ~/tempfilezshrc ~/.zshrc
rm ~/tempfilezshrc
# Add plugins
colorPrint "Installing fzf ..."
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
colorPrint "Install plugins"
git clone https://github.com/Treri/fzf-zsh.git ${ZSH}/custom/plugins/fzf-zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH}/plugins/zsh-autosuggestions
sed 's,^plugins=(,plugins=(brew git gitfast mvn zsh-autosuggestions fzf-zsh docker last-working-dir colored-man-pages colorize,' ~/.zshrc > ~/tempfilezshrc
cp ~/tempfilezshrc ~/.zshrc
rm ~/tempfilezshrc
echo "eval \"\$(fasd --init auto zsh-hook zsh-ccomp zsh-ccomp-install zsh-wcomp zsh-wcomp-install)\"" >> ~/.zshrc
# Add aliases
colorPrint "Set Aliases"
echo "export ZSH=~/.oh-my-zsh"  >> ~/.zshrc
echo "export EDITOR=micro" >> ~/.zshrc
echo "alias fh=\"find . -name\"" >> ~/.zshrc
echo "alias t=\"tree -C -h\"" >> ~/.zshrc
echo "alias m=\"micro\"" >> ~/.zshrc
echo "alias l=\"exa -luabgU --git --time-style default -s type\"" >> ~/.zshrc
echo "alias c=\"fasd_cd -d\"" >> ~/.zshrc
echo "alias mm=\"fasd -e micro --f\"" >> ~/.zshrc
echo "alias mmm\"fasd -e micro -i\"" >> ~/.zshrc
colorPrint "Changing Shell (admin)"
chsh -s $(which zsh)
