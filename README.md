# dotfiles

Personal dotfiles managed with GNU Stow.

## Setup

### Debian/Ubuntu:

```shell
sudo apt update
sudo apt install -y git stow fzf zoxide trash-cli jq curl starship bash-completion bat ripgrep nano fastfetch
git config credential.helper store
git clone https://github.com/Owen-3456/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow --adopt alacritty bash git starship fastfetch
```

### Arch:
```shell
sudo pacman -Syy
sudo pacman -Sy --noconfirm git stow fzf zoxide trash-cli jq curl starship bash-completion bat ripgrep nano fastfetch
git config credential.helper store
git clone https://github.com/Owen-3456/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow --adopt alacritty bash git starship fastfetch
```
