#bash
#!/usr/bin/env bash

iatest=$(expr index "$-" i)

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Enable bash programmable completion features in interactive shells
if [ -f /usr/share/bash-completion/bash_completion ]; then
	. /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

#######################################################
# EXPORTS
#######################################################

# Disable the bell
if [[ $iatest -gt 0 ]]; then bind "set bell-style visible"; fi

# Expand the history size
export HISTFILESIZE=10000
export HISTSIZE=500
export HISTTIMEFORMAT="%F %T" # add timestamp to history

# Don't put duplicate lines in the history and do not add lines that start with a space
export HISTCONTROL=erasedups:ignoredups:ignorespace

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize
# Corrects minor spelling errors in directory names when using cd
shopt -s cdspell

# Causes bash to append to history instead of overwriting it so if you start a new terminal, you have old session history
shopt -s histappend
PROMPT_COMMAND='history -a'

# set up XDG folders
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Seeing as other scripts will use it might as well export it
export LINUXTOOLBOXDIR="$HOME/linuxtoolbox"

# Allow ctrl-S for history navigation (with ctrl-R)
[[ $- == *i* ]] && stty -ixon

# Ignore case on auto-completion
# Note: bind used instead of sticking these in .inputrc
if [[ $iatest -gt 0 ]]; then bind "set completion-ignore-case on"; fi

# Show auto-completion list automatically, without double tab
if [[ $iatest -gt 0 ]]; then bind "set show-all-if-ambiguous On"; fi

# Set the default editor
export EDITOR=nano
export VISUAL=code

# To have colors for ls and all grep commands such as grep, egrep and zgrep
export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'
#export GREP_OPTIONS='--color=auto' #deprecated

# Check if ripgrep is installed
if command -v rg &> /dev/null; then
    # Alias grep to rg if ripgrep is installed
    alias grep='rg'
else
    # Alias grep to /usr/bin/grep with GREP_OPTIONS if ripgrep is not installed
    alias grep="/usr/bin/grep $GREP_OPTIONS"
fi
unset GREP_OPTIONS

# Color for manpages in less makes manpages a little easier to read
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

#######################################################
# GENERAL ALIAS'S
#######################################################
# To temporarily bypass an alias, we precede the command with a \
# EG: the ls command is aliased, but to use the normal ls command you would type \ls

# Alias's to modified commands
alias cp='cpp'
alias mv='mv -i'
alias rm='trash -v'
alias mkdir='mkdir -p'
alias ls='eza -l -A --color=auto --group-directories-first --icons'
alias top='btop'
alias htop='btop'
alias man='tldr'
alias neofetch='fastfetch'
alias wget='wget --show-progress --progress=bar:force:noscroll'

# Git alias's
alias gl='git log --oneline --graph --decorate --all'
alias gs='git status -sb'


# Linutil alias
alias linutil="curl -fsSL https://christitus.com/linux | sh"

# Zoxide alias for cd
alias cd='z'

# Remove a directory and all files
alias rmd='trash --recursive --force --verbose '


# To see if a command is aliased, a file, or a built-in command
alias checkcommand="type -t"

# Show open ports
alias openports='netstat -nape --inet'

#######################################################
# SPECIAL FUNCTIONS
#######################################################
# Extracts any archive(s) (if unp isn't installed)
extract() {
	for archive in "$@"; do
		if [ -f "$archive" ]; then
			case $archive in
			*.tar.bz2) tar xvjf $archive ;;
			*.tar.gz) tar xvzf $archive ;;
			*.bz2) bunzip2 $archive ;;
			*.rar) rar x $archive ;;
			*.gz) gunzip $archive ;;
			*.tar) tar xvf $archive ;;
			*.tbz2) tar xvjf $archive ;;
			*.tgz) tar xvzf $archive ;;
			*.zip) unzip $archive ;;
			*.Z) uncompress $archive ;;
			*.7z) 7z x $archive ;;
			*) echo "don't know how to extract '$archive'..." ;;
			esac
		else
			echo "'$archive' is not a valid file!"
		fi
	done
}

# Searches for text in all files in the current folder
ftext() {
	# -i case-insensitive
	# -I ignore binary files
	# -H causes filename to be printed
	# -r recursive search
	# -n causes line number to be printed
	# optional: -F treat search term as a literal, not a regular expression
	# optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
	grep -iIHrn --color=always "$1" . | less -r
}

# Copy file with a progress bar
cpp() {
    set -e
    strace -q -ewrite cp -- "${1}" "${2}" 2>&1 |
    awk '{
        count += $NF
        if (count % 10 == 0) {
            percent = count / total_size * 100
            printf "%3d%% [", percent
            for (i=0;i<=percent;i++)
                printf "="
            printf ">"
            for (i=percent;i<100;i++)
                printf " "
            printf "]\r"
        }
    }
    END { print "" }' total_size="$(stat -c '%s' "${1}")" count=0
}

# Copy and go to the directory
cpg() {
	if [ -d "$2" ]; then
		cp "$1" "$2" && cd "$2"
	else
		cp "$1" "$2"
	fi
}

# Move and go to the directory
mvg() {
	if [ -d "$2" ]; then
		mv "$1" "$2" && cd "$2"
	else
		mv "$1" "$2"
	fi
}

# Create and go to the directory
mkcd() {
	mkdir -p "$1"
	cd "$1"
}

# Goes up a specified number of directories  (i.e. up 4)
up() {
	local d=""
	limit=$1
	for ((i = 1; i <= limit; i++)); do
		d=$d/..
	done
	d=$(echo $d | sed 's/^\///')
	if [ -z "$d" ]; then
		d=..
	fi
	cd $d
}

# Returns the last 2 fields of the working directory
pwdtail() {
	pwd | awk -F/ '{nlast = NF -1;print $nlast"/"$NF}'
}

# Show the current distribution
distribution () {
    local dtype="unknown"  # Default to unknown

    # Use /etc/os-release for modern distro identification
    if [ -r /etc/os-release ]; then
        source /etc/os-release
        case $ID in
            fedora|rhel|centos)
                dtype="redhat"
                ;;
            sles|opensuse*)
                dtype="suse"
                ;;
            ubuntu|debian)
                dtype="debian"
                ;;
            gentoo)
                dtype="gentoo"
                ;;
            arch|manjaro)
                dtype="arch"
                ;;
            slackware)
                dtype="slackware"
                ;;
            *)
                # Check ID_LIKE only if dtype is still unknown
                if [ -n "$ID_LIKE" ]; then
                    case $ID_LIKE in
                        *fedora*|*rhel*|*centos*)
                            dtype="redhat"
                            ;;
                        *sles*|*opensuse*)
                            dtype="suse"
                            ;;
                        *ubuntu*|*debian*)
                            dtype="debian"
                            ;;
                        *gentoo*)
                            dtype="gentoo"
                            ;;
                        *arch*)
                            dtype="arch"
                            ;;
                        *slackware*)
                            dtype="slackware"
                            ;;
                    esac
                fi

                # If ID or ID_LIKE is not recognized, keep dtype as unknown
                ;;
        esac
    fi

    echo $dtype
}


DISTRIBUTION=$(distribution)
if [ "$DISTRIBUTION" = "redhat" ] || [ "$DISTRIBUTION" = "arch" ]; then
      alias cat='bat'
else
      alias cat='batcat'
fi 


# IP address lookup
alias whatismyip="whatsmyip"
function whatsmyip () {
    # Internal IP Lookup.
    if command -v ip &> /dev/null; then
        echo -n "Internal IP: "
        ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d/ -f1
    else
        echo -n "Internal IP: "
        ifconfig wlan0 | grep "inet " | awk '{print $2}'
    fi

    # External IP Lookup
    echo -n "External IP: "
    curl -4 ifconfig.me
}

function hb {
    if [ $# -eq 0 ]; then
        echo "No file path specified."
        return
    elif [ ! -f "$1" ]; then
        echo "File path does not exist."
        return
    fi

    uri="http://bin.christitus.com/documents"
    response=$(curl -s -X POST -d @"$1" "$uri")
    if [ $? -eq 0 ]; then
        hasteKey=$(echo $response | jq -r '.key')
        echo "http://bin.christitus.com/$hasteKey"
    else
        echo "Failed to upload the document."
    fi
}

# Package install function
installpkg() {
    # Check if fzf is installed
    if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf is required but not installed. Please install fzf first."
        return 1
    fi

    if [ -f /etc/debian_version ]; then
        echo "Debian-based system detected"
        # Check if nala is available, fallback to apt
        if command -v nala >/dev/null 2>&1; then
            echo "Using nala for package management"
            echo "Loading package list... (this may take a moment)"
            local packages=$(apt-cache search . | cut -d' ' -f1 | sort)
            if [ -z "$packages" ]; then
                echo "Error: No packages found. Try running 'sudo apt update' first."
                return 1
            fi
            local selected=$(echo "$packages" | fzf --multi --header="Select packages to install (TAB to select multiple, ENTER to confirm)" \
                --preview 'apt show {1} 2>/dev/null | head -20' --preview-window=right:60%:wrap)
            if [ -n "$selected" ]; then
                echo "Selected packages: $(echo "$selected" | tr '\n' ' ')"
                read -p "Do you want to install these packages? (y/N): " confirm
                if [[ $confirm =~ ^[Yy]$ ]]; then
                    echo "$selected" | xargs -r sudo nala install -y
                else
                    echo "Installation cancelled."
                fi
            else
                echo "No packages selected."
            fi
        else
            echo "Using apt for package management"
            echo "Loading package list... (this may take a moment)"
            local packages=$(apt-cache search . | cut -d' ' -f1 | sort)
            if [ -z "$packages" ]; then
                echo "Error: No packages found. Try running 'sudo apt update' first."
                return 1
            fi
            local selected=$(echo "$packages" | fzf --multi --header="Select packages to install (TAB to select multiple, ENTER to confirm)" \
                --preview 'apt show {1} 2>/dev/null | head -20' --preview-window=right:60%:wrap)
            if [ -n "$selected" ]; then
                echo "Selected packages: $(echo "$selected" | tr '\n' ' ')"
                read -p "Do you want to install these packages? (y/N): " confirm
                if [[ $confirm =~ ^[Yy]$ ]]; then
                    echo "$selected" | xargs -r sudo apt install -y
                else
                    echo "Installation cancelled."
                fi
            else
                echo "No packages selected."
            fi
        fi
    elif [ -f /etc/arch-release ]; then
        echo "Arch-based system detected"
        
        # Check if yay is available
        if command -v yay >/dev/null 2>&1; then
            echo "Using yay (includes AUR packages)"
            echo "Loading package list... (this may take a moment)"
            local packages=$(yay -Slq)
            if [ -z "$packages" ]; then
                echo "Error: No packages found. Try running 'yay -Sy' first."
                return 1
            fi
            local selected=$(echo "$packages" | fzf --multi --header="Select packages to install from repos + AUR (TAB to select multiple, ENTER to confirm)" \
                --preview 'yay -Si {1} 2>/dev/null | head -20' --preview-window=right:60%:wrap)
            if [ -n "$selected" ]; then
                echo "Selected packages: $(echo "$selected" | tr '\n' ' ')"
                read -p "Do you want to install these packages? (y/N): " confirm
                if [[ $confirm =~ ^[Yy]$ ]]; then
                    echo "$selected" | xargs -r yay -S --noconfirm
                else
                    echo "Installation cancelled."
                fi
            else
                echo "No packages selected."
            fi
        else
            echo "Using pacman (official repos only - install 'yay' for AUR access)"
            echo "Loading package list... (this may take a moment)"
            local packages=$(pacman -Slq)
            if [ -z "$packages" ]; then
                echo "Error: No packages found. Try running 'sudo pacman -Sy' first."
                return 1
            fi
            local selected=$(echo "$packages" | fzf --multi --header="Select packages to install (TAB to select multiple, ENTER to confirm)" \
                --preview 'pacman -Si {1} 2>/dev/null | head -20' --preview-window=right:60%:wrap)
            if [ -n "$selected" ]; then
                echo "Selected packages: $(echo "$selected" | tr '\n' ' ')"
                read -p "Do you want to install these packages? (y/N): " confirm
                if [[ $confirm =~ ^[Yy]$ ]]; then
                    echo "$selected" | xargs -r sudo pacman -S --noconfirm
                else
                    echo "Installation cancelled."
                fi
            else
                echo "No packages selected."
            fi
        fi
    else
        echo "Error: Unknown distribution. This function supports Debian/Ubuntu and Arch-based systems only."
        return 1
    fi
}

# Package remove function
removepkg() {
    # Check if fzf is installed
    if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf is required but not installed. Please install fzf first."
        return 1
    fi

    if [ -f /etc/debian_version ]; then
        echo "Debian-based system detected"
        # Check if nala is available, fallback to apt
        if command -v nala >/dev/null 2>&1; then
            echo "Using nala for package management"
            echo "Loading installed packages..."
            local packages=$(dpkg --get-selections | grep -v deinstall | cut -f1 | sort)
            if [ -z "$packages" ]; then
                echo "Error: No installed packages found."
                return 1
            fi
            local selected=$(echo "$packages" | fzf --multi --header="WARNING: Select packages to REMOVE (TAB to select multiple, ENTER to confirm)" \
                --preview 'apt show {1} 2>/dev/null | head -20; echo "\n--- Dependencies that depend on this package ---"; apt rdepends {1} 2>/dev/null | head -10' \
                --preview-window=right:60%:wrap)
            if [ -n "$selected" ]; then
                echo "WARNING: You are about to REMOVE these packages: $(echo "$selected" | tr '\n' ' ')"
                echo "This may also remove dependent packages."
                read -p "Are you sure you want to continue? (y/N): " confirm
                if [[ $confirm =~ ^[Yy]$ ]]; then
                    echo "$selected" | xargs -r sudo nala remove -y
                else
                    echo "Removal cancelled."
                fi
            else
                echo "No packages selected."
            fi
        else
            echo "Using apt for package management"
            echo "Loading installed packages..."
            local packages=$(dpkg --get-selections | grep -v deinstall | cut -f1 | sort)
            if [ -z "$packages" ]; then
                echo "Error: No installed packages found."
                return 1
            fi
            local selected=$(echo "$packages" | fzf --multi --header="WARNING: Select packages to REMOVE (TAB to select multiple, ENTER to confirm)" \
                --preview 'apt show {1} 2>/dev/null | head -20; echo "\n--- Dependencies that depend on this package ---"; apt rdepends {1} 2>/dev/null | head -10' \
                --preview-window=right:60%:wrap)
            if [ -n "$selected" ]; then
                echo "WARNING: You are about to REMOVE these packages: $(echo "$selected" | tr '\n' ' ')"
                echo "This may also remove dependent packages."
                read -p "Are you sure you want to continue? (y/N): " confirm
                if [[ $confirm =~ ^[Yy]$ ]]; then
                    echo "$selected" | xargs -r sudo apt remove -y
                else
                    echo "Removal cancelled."
                fi
            else
                echo "No packages selected."
            fi
        fi
    elif [ -f /etc/arch-release ]; then
        echo "Arch-based system detected"
        echo "Loading installed packages..."
        local packages=$(pacman -Qq)
        if [ -z "$packages" ]; then
            echo "Error: No installed packages found."
            return 1
        fi
        local selected=$(echo "$packages" | fzf --multi --header="WARNING: Select packages to REMOVE (TAB to select multiple, ENTER to confirm)" \
            --preview 'pacman -Qi {1} 2>/dev/null | head -20; echo "\n--- Packages that depend on this ---"; pactree -r {1} 2>/dev/null | head -10' \
            --preview-window=right:60%:wrap)
        if [ -n "$selected" ]; then
            echo "WARNING: You are about to REMOVE these packages: $(echo "$selected" | tr '\n' ' ')"
            echo "This may also remove dependent packages."
            read -p "Are you sure you want to continue? (y/N): " confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                echo "$selected" | xargs -r sudo pacman -R --noconfirm
            else
                echo "Removal cancelled."
            fi
        else
            echo "No packages selected."
        fi
    else
        echo "Error: Unknown distribution. This function supports Debian/Ubuntu and Arch-based systems only."
        return 1
    fi
}

upgradesys() {
    echo "Starting system upgrade..."
    
    if [ -f /etc/debian_version ]; then
        echo "Debian-based system detected"
        # Check if nala is available, fallback to apt
        if command -v nala >/dev/null 2>&1; then
            echo "Using nala for package management"
            echo "Updating package list..."
            if ! sudo nala update; then
                echo "Failed to update package list"
                return 1
            fi
            
            echo "Upgrading system packages..."
            if ! sudo nala upgrade -y; then
                echo "Failed to upgrade packages"
                return 1
            fi
            
            echo "Cleaning up..."
            sudo nala autopurge -y
            sudo nala clean
        else
            echo "Using apt for package management"
            echo "Updating package list..."
            if ! sudo apt update; then
                echo "Failed to update package list"
                return 1
            fi
            
            echo "Upgrading system packages..."
            if ! sudo apt upgrade -y; then
                echo "Failed to upgrade packages"
                return 1
            fi
            
            echo "Cleaning up..."
            sudo apt autoremove -y
            sudo apt autoclean
        fi
        
        # Check if reboot is required
        if [ -f /var/run/reboot-required ]; then
            echo "WARNING: System reboot is required to complete the upgrade."
            read -p "Do you want to reboot now? (y/N): " reboot_confirm
            if [[ $reboot_confirm =~ ^[Yy]$ ]]; then
                echo "Rebooting system..."
                sudo reboot
            else
                echo "Please remember to reboot your system later."
            fi
        fi
        
    elif [ -f /etc/arch-release ]; then
        echo "Arch-based system detected"
        echo "Updating package database and upgrading system..."
        if ! sudo pacman -Syu --noconfirm; then
            echo "Failed to upgrade system"
            return 1
        fi
        
        echo "Cleaning package cache..."
        sudo pacman -Sc --noconfirm
        
        # Check for orphaned packages
        local orphans=$(pacman -Qtdq 2>/dev/null)
        if [ -n "$orphans" ]; then
            echo "Found orphaned packages: $orphans"
            read -p "Do you want to remove orphaned packages? (y/N): " remove_orphans
            if [[ $remove_orphans =~ ^[Yy]$ ]]; then
                echo "$orphans" | sudo pacman -Rns --noconfirm -
                echo "Orphaned packages removed"
            fi
        fi
        
    else
        echo "Error: Unknown distribution. This function supports Debian/Ubuntu and Arch-based systems only."
        return 1
    fi
    
    echo "System upgrade completed successfully!"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p)"
    
    # Show available updates if any (for Debian-based systems)
    if [ -f /etc/debian_version ]; then
        local updates=$(apt list --upgradable 2>/dev/null | grep -c upgradable)
        if [ "$updates" -gt 1 ]; then
            echo "Pending updates: $((updates - 1))"
        else
            echo "System is up to date"
        fi
    fi
}

# Youtube download function
ytdl() {
    local download_dir="$HOME/Downloads/Videos"
    
    if [ -z "$1" ]; then
        echo "Error: Please provide a YouTube URL"
        echo "Usage: ytdl <youtube-url>"
        return 1
    fi
    
    if [ ! -d "$download_dir" ]; then
        mkdir -p "$download_dir"
    fi
    
    (
        cd "$download_dir" || return
        
        if hash aria2c 2> /dev/null; then
            youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' \
                --merge-output-format mp4 \
                --external-downloader aria2c \
                -o '%(title)s-%(id)s-%(format_id)s.%(ext)s' "$1"
        else
            youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' \
                --merge-output-format mp4 \
                -o '%(title)s-%(id)s-%(format_id)s.%(ext)s' "$1"
        fi
    )
}

#######################################################
# Final settings and init scripts
#######################################################

# Check if the shell is interactive
if [[ $- == *i* ]]; then
    # Bind Ctrl+f to insert 'zi' followed by a newline
    bind '"\C-f":"zi\n"'
fi

export PATH=$PATH:"$HOME/.local/bin:$HOME/.cargo/bin:/var/lib/flatpak/exports/bin:/.local/share/flatpak/exports/bin"

eval "$(starship init bash)"
eval "$(zoxide init bash)"
if command -v brew &> /dev/null; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi