# dotfiles

Personal dotfiles managed with GNU Stow.

## Setup

### Debian/Ubuntu:

```shell
sudo apt update
sudo apt install nala -y
sudo nala install git stow fzf zoxide trash-cli jq curl starship bash-completion -y
git config credential.helper store
git clone https://github.com/Owen-3456/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow --adopt alacritty bash git starship fastfetch
```

### Arch:
```shell
sudo pacman -Syy
sudo pacman -Sy git stow fzf zoxide trash-cli jq curl starship bash-completion
git config credential.helper store
git clone https://github.com/Owen-3456/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow --adopt alacritty bash git starship fastfetch
```

### Recommended packages:

#### Debian/Ubuntu:
```shell
sudo apt update
sudo apt install nala -y
sudo apt install bat ripgrep nano fastfetch -y
```

#### Arch:
```shell
sudo pacman -Syy
sudo pacman -Sy bat ripgrep nano fastfetch
```