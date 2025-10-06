# dotfiles

Personal dotfiles managed with GNU Stow.

## Setup

### Debian/Ubuntu:

```shell
sudo apt update
sudo apt install -y nala
sudo nala install -y git stow fzf zoxide trash-cli jq curl starship aspell aspell-enbash-completion bat ripgrep nano fastfetch
git clone https://github.com/Owen-3456/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow --override */
```

### Arch:
```shell
sudo pacman -Syy
sudo pacman -Sy --noconfirm git stow fzf zoxide trash-cli jq curl starship aspell aspell-enbash-completion bat ripgrep nano fastfetch
git clone https://github.com/Owen-3456/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow --override */
```
