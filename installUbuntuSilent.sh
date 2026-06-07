#!/bin/bash
# Silent version: does NOT change the default shell (no chsh password prompt).
# All other behaviour is identical to installUbuntu.sh.
set -e

# ── Color helpers ─────────────────────────────────────────────────────────────

colorSetup() {
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
    RED="" GREEN="" YELLOW="" BLUE="" BOLD="" NORMAL=""
  fi
}

info()    { printf "${BLUE}  →  %s${NORMAL}\n" "$1"; }
success() { printf "${GREEN}  ✓  %s${NORMAL}\n" "$1"; }
warn()    { printf "${YELLOW}  !  %s${NORMAL}\n" "$1"; }
error()   { printf "${RED}  ✗  %s${NORMAL}\n" "$1" >&2; }

# ── Step functions ────────────────────────────────────────────────────────────

backupZshrc() {
  if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
    warn "Existing ~/.zshrc found — backing up to ~/.zshrc.backup"
    mv ~/.zshrc ~/.zshrc.backup
  fi
}

installPackages() {
  info "Updating package list"
  sudo apt-get update -y

  info "Installing base packages via apt"
  sudo apt-get install -y git zsh tree fzf ripgrep

  sudo apt-get install -y bat
  if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    sudo ln -sf "$(which batcat)" /usr/local/bin/bat
  fi

  sudo apt-get install -y fd-find
  if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
  fi

  info "Installing micro"
  curl https://getmic.ro | bash
  sudo mv micro /usr/local/bin/micro
  success "micro installed"

  info "Installing eza"
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
    | sudo tee /etc/apt/sources.list.d/gierens.list
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
  sudo apt-get update -y
  sudo apt-get install -y eza
  success "eza installed"

  info "Installing zoxide"
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  sudo mv ~/.local/bin/zoxide /usr/local/bin/zoxide 2>/dev/null || true
  success "zoxide installed"
}

installOhMyZsh() {
  export ZSH="$HOME/.oh-my-zsh"
  info "Installing oh-my-zsh"
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  success "oh-my-zsh installed"
}

installPlugins() {
  local target="${ZSH}/custom/plugins/zsh-autosuggestions"
  if [[ -d "$target" ]]; then
    warn "zsh-autosuggestions already cloned — skipping"
  else
    info "Cloning zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$target"
    success "zsh-autosuggestions cloned"
  fi
}

configureZshrc() {
  info "Setting theme to muse"
  sed 's,ZSH_THEME=[^;]*,ZSH_THEME="muse",' ~/.zshrc > ~/tempfilezshrc
  mv ~/tempfilezshrc ~/.zshrc

  info "Setting plugins"
  sed 's,^plugins=(.*,plugins=(git fzf zoxide zsh-autosuggestions colored-man-pages colorize last-working-dir),' ~/.zshrc > ~/tempfilezshrc
  mv ~/tempfilezshrc ~/.zshrc

  info "Appending custom config"
  cat >> ~/.zshrc << 'ZSHRC_EOF'

# ── Custom config ─────────────────────────────────────────────────────────────

export ZSH="$HOME/.oh-my-zsh"
export EDITOR=micro

alias fh='find . -name'
alias t='tree -C -h'
alias m='micro'
alias l='eza -luabgU --git --time-style=relative -s type'
alias c='z'
alias mm='micro "$(fzf --preview="bat --color=always {}")"'
alias mmm='micro "$(fd --type f | fzf --preview="bat --color=always {}")"'
ZSHRC_EOF

  success ".zshrc configured"
}

verify() {
  printf "\n${BOLD}── Verification ───────────────────────────────────────────${NORMAL}\n"
  local pass=0 fail=0
  check_cmd() {
    if command -v "$1" &>/dev/null; then success "$1"; ((pass++))
    else error "$1 not found"; ((fail++)); fi
  }
  check_cmd zsh; check_cmd eza; check_cmd zoxide; check_cmd fzf
  check_cmd micro; check_cmd bat; check_cmd fd; check_cmd rg

  [[ -d "$HOME/.oh-my-zsh" ]] && { success "oh-my-zsh exists"; ((pass++)); } || { error "oh-my-zsh missing"; ((fail++)); }
  [[ -d "${ZSH}/custom/plugins/zsh-autosuggestions" ]] && { success "zsh-autosuggestions cloned"; ((pass++)); } || { error "zsh-autosuggestions missing"; ((fail++)); }

  printf "\n${BOLD}%d passed, %d failed${NORMAL}\n" "$pass" "$fail"
  warn "Default shell was NOT changed (silent mode). Run: chsh -s \$(which zsh)"
  printf "${BOLD}Then run: exec zsh${NORMAL} to apply all changes\n"
}

# ── Main ──────────────────────────────────────────────────────────────────────

colorSetup
printf "\n${BOLD}── zsh-config-bundle installer (Ubuntu silent) ─────────────${NORMAL}\n\n"

backupZshrc
installPackages
installOhMyZsh
installPlugins
configureZshrc
verify
