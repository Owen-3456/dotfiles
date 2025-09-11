#!/usr/bin/bash
#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# Environment Variables
export EDITOR='nano'
export VISUAL='code'

# Custom Functions
mkcd() {
	if [ -z "$1" ]; then
		echo "Error: No directory name provided."
		return 1
	fi

	if ! mkdir -p "$1"; then
		echo "Error: Failed to create directory '$1'."
		return 1
	fi

	if ! cd "$1"; then
		echo "Error: Failed to change directory to '$1'."
		return 1
	fi
}

# Custom Aliases

# Pacman helper function
pacmanhelp() {
	echo '
Update: -Sy
Upgrade: -Syu
Install: -S
Search: -Ss
Search Installed: -Qs
Remove: -R
Remove pack and deps: -Rs
Install from file: -U
Clear cache: -Scc
'
}

# Linutil alias
alias linutil="curl -fsSL https://christitus.com/linux | sh"

# Zoxide setup
export PATH="$HOME/.local/bin:$PATH"
eval "$(zoxide init bash)"

# Enables bash completions
if [ -f /usr/share/bash-completion/bash_completion ]; then
	. /usr/share/bash-completion/bash_completion
fi

#oh-my-posh config
eval "$(oh-my-posh init bash --config "$HOME"/.config/oh-my-posh/nordcustom.omp.json)"

fastfetch
