# zsh-config-bundle

A one-command zsh setup based on oh-my-zsh. Installs a curated set of modern CLI tools, configures the shell with sane defaults, and gets you productive in under 5 minutes.

![preview](https://github.com/dieterpl/zsh-config-bundle/raw/master/ps.png)

---

## What you get

### Tools

| Tool | Description |
|------|-------------|
| [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) | zsh framework with the `muse` theme |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder — powers history search, file picker, and more |
| [eza](https://github.com/eza-community/eza) | Modern `ls` with colours, icons, and git status |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` that learns your most-used directories |
| [bat](https://github.com/sharkdp/bat) | Syntax-highlighted `cat` with line numbers |
| [fd](https://github.com/sharkdp/fd) | Fast, user-friendly alternative to `find` |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast, modern `grep` |
| [micro](https://github.com/zyedidia/micro) | Intuitive terminal text editor |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Fish-style inline command suggestions |

### Aliases

| Alias | Expands to | Description |
|-------|-----------|-------------|
| `l` | `eza -luabgU --git --time-style=relative -s type` | Detailed file listing with git status |
| `t` | `tree -C -h` | Coloured directory tree |
| `m` | `micro` | Open micro editor |
| `c` | `z` | Jump to a directory (zoxide) |
| `fh` | `find . -name` | Find a file by name |
| `mm` | `fzf` → `micro` | Pick a file with fzf preview, open in micro |
| `mmm` | `fd` + `fzf` → `micro` | Search all files with fd, pick with fzf, open in micro |

### Key bindings (fzf)

| Key | Action |
|-----|--------|
| `Ctrl+R` | Fuzzy search shell history |
| `Ctrl+T` | Fuzzy search files in the current directory tree |
| `Alt+C` | Fuzzy jump into a subdirectory |

---

## Requirements

- `bash`, `curl`, `git`
- **macOS**: Xcode Command Line Tools (`xcode-select --install`) — Homebrew will be installed automatically if missing
- **Ubuntu / Arch**: `sudo` access

---

## Install

### macOS

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dieterpl/zsh-config-bundle/master/installMac.sh)"
```

### Ubuntu

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dieterpl/zsh-config-bundle/master/installUbuntu.sh)"
```

**Silent mode** (skips `chsh` — useful in containers or environments where changing the default shell requires no interaction):

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dieterpl/zsh-config-bundle/master/installUbuntuSilent.sh)"
```

### Arch Linux

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dieterpl/zsh-config-bundle/master/installArch.sh)"
```

---

## After install

Reload your shell to apply everything:

```bash
exec zsh
```

Quick smoke tests:

```bash
z --version          # zoxide working
eza --version        # eza working
echo $EDITOR         # should print: micro
```

Then try the key bindings: `Ctrl+R` for history search, `Ctrl+T` to pick a file.
