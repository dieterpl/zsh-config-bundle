#!/bin/bash
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

installBrew() {
  if which -s brew; then
    info "Homebrew already installed — updating"
    brew update
  else
    info "Installing Homebrew"
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  # Make brew available in the current session (required on Apple Silicon)
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

installPackages() {
  local packages=(zsh tree micro fzf eza zoxide bat fd ripgrep)
  for pkg in "${packages[@]}"; do
    info "Installing $pkg"
    brew install "$pkg"
    success "$pkg installed"
  done
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
  sed 's,^plugins=(.*,plugins=(git brew fzf zoxide zsh-autosuggestions colored-man-pages colorize last-working-dir iterm2),' ~/.zshrc > ~/tempfilezshrc
  mv ~/tempfilezshrc ~/.zshrc

  info "Appending custom config"
  cat >> ~/.zshrc << 'ZSHRC_EOF'

# ── Custom config ─────────────────────────────────────────────────────────────

# Homebrew (Apple Silicon — no-op on Intel where /usr/local/bin is already in PATH)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

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

changeDefaultShell() {
  if [[ "$(basename "$SHELL")" == "zsh" ]]; then
    info "zsh is already the default shell — skipping"
  else
    info "Changing default shell to zsh (may prompt for password)"
    chsh -s "$(which zsh)"
    success "Default shell changed to zsh"
  fi
}

verify() {
  printf "\n${BOLD}── Verification ───────────────────────────────────────────${NORMAL}\n"
  local pass=0 fail=0
  check_cmd() {
    if command -v "$1" &>/dev/null; then
      success "$1"
      ((pass++))
    else
      error "$1 not found"
      ((fail++))
    fi
  }
  check_cmd zsh
  check_cmd eza
  check_cmd zoxide
  check_cmd fzf
  check_cmd micro
  check_cmd bat
  check_cmd fd
  check_cmd rg

  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    success "oh-my-zsh directory exists"
    ((pass++))
  else
    error "oh-my-zsh directory missing"
    ((fail++))
  fi

  if [[ -d "${ZSH}/custom/plugins/zsh-autosuggestions" ]]; then
    success "zsh-autosuggestions cloned correctly"
    ((pass++))
  else
    error "zsh-autosuggestions missing from custom/plugins"
    ((fail++))
  fi

  if grep -q "plugins=(" ~/.zshrc && grep -q "fzf" ~/.zshrc; then
    success ".zshrc plugins line looks correct"
    ((pass++))
  else
    warn ".zshrc plugins line may need review"
  fi

  printf "\n${BOLD}%d passed, %d failed${NORMAL}\n" "$pass" "$fail"

  printf "\n${BOLD}── Next steps ──────────────────────────────────────────────${NORMAL}\n"
  info "Open a new terminal (or run: exec zsh) to apply all changes"
  info "Ctrl+R — fzf history search"
  info "Ctrl+T — fzf file search"
  info "Alt+C  — fzf directory jump"
  info "l      — eza file listing"
  info "z <dir> — jump to a directory (zoxide)"
  info "mm     — open a file in micro via fzf"
}

# ── Main ──────────────────────────────────────────────────────────────────────

colorSetup
printf "\n${BOLD}── zsh-config-bundle installer (macOS) ─────────────────────${NORMAL}\n\n"

backupZshrc
installBrew
installPackages
installOhMyZsh
installPlugins
configureZshrc
changeDefaultShell
verify
