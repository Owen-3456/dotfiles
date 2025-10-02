# dotfiles

Personal dotfiles managed with GNU Stow.

## Setup

### 1. Install GNU Stow

APT:
```shell
sudo apt install stow
```

Pacman:
```shell
sudo pacman -S stow
```

### 2. Clone this repo

```shell
git clone https://github.com/owen-3456/dotfiles.git ~/.dotfiles
```

### 3. Navigate to the repo

```shell
cd ~/.dotfiles
```

### 4. Install configs

```shell
stow [package-name]
```

## Packages

- `alacritty/` - Terminal config
- `bash/` - Shell config  
- `fastfetch/` - System info
- `git/` - Git config
- `oh-my-posh/` - Shell prompt

## .bashrc requirements

Debian/Ubuntu:
```shell
sudo apt install fzf bat trash-cli jq curl starship
```

or

```shell
sudo nala install fzf bat trash-cli jq curl starship
```

Arch Linux:
```shell
sudo pacman -Sy fzf bat trash-cli jq curl starship
```
