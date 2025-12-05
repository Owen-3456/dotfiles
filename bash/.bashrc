#!/usr/bin/env bash

# =========================
# Core: environment & shell
# =========================

# Source global definitions
if [ -f /etc/bashrc ]; then . /etc/bashrc; fi

# Shell options (interactive)
if [[ $- == *i* ]]; then
    shopt -s checkwinsize
    shopt -s cdspell
    shopt -s histappend
    shopt -s globstar
fi

# History configuration
export HISTFILESIZE=10000
export HISTSIZE=5000
export HISTTIMEFORMAT="%F %T"
export HISTCONTROL=erasedups:ignoredups:ignorespace
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }history -a"

# Interactive-only terminal tweaks
if [[ $- == *i* ]]; then
    bind "set bell-style visible"
    bind "set completion-ignore-case on"
    bind "set show-all-if-ambiguous On"
fi
[[ $- == *i* ]] && stty -ixon

# XDG Base Directories
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Misc environment
export LINUXTOOLBOXDIR="$HOME/linuxtoolbox"
export EDITOR=nano
export VISUAL="code -w"

# Path setup
case ":$PATH:" in
*":$HOME/.local/bin:"*) ;;
*) PATH="$PATH:$HOME/.local/bin" ;;
esac
case ":$PATH:" in
*":$HOME/.cargo/bin:"*) ;;
*) PATH="$PATH:$HOME/.cargo/bin" ;;
esac
case ":$PATH:" in
*":/var/lib/flatpak/exports/bin:"*) ;;
*) PATH="$PATH:/var/lib/flatpak/exports/bin" ;;
esac
case ":$PATH:" in
*":$HOME/.local/share/flatpak/exports/bin:"*) ;;
*) PATH="$PATH:$HOME/.local/share/flatpak/exports/bin" ;;
esac
export PATH

# =========================
# Completion
# =========================
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# =========================
# Colors and pager settings
# =========================
export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'
unset GREP_OPTIONS
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# Prefer bat/batcat if available
if command -v batcat >/dev/null 2>&1; then
    alias cat='batcat'
elif command -v bat >/dev/null 2>&1; then
    alias cat='bat'
fi

# =========================
# Aliases
# =========================
# Core aliases
alias mv='mv -i'
command -v trash >/dev/null 2>&1 && alias rm='trash -v'
alias mkdir='mkdir -p'
command -v eza >/dev/null 2>&1 && alias ls='eza -l -A --color=auto --group-directories-first --icons'
command -v btop >/dev/null 2>&1 && alias top='btop'
command -v btop >/dev/null 2>&1 && alias htop='btop'
command -v tldr >/dev/null 2>&1 && alias man='tldr'
command -v fastfetch >/dev/null 2>&1 && alias neofetch='fastfetch'
alias wget='wget --show-progress --progress=bar:force:noscroll'
alias cls='clear'

# Git functions (more flexible than aliases)
gl() {
    git log --oneline --graph --decorate --all --color=always "$@" | less -R
}

gs() {
    git -c color.status=always status --short --branch "$@"
}

# Utility aliases
alias linutil="curl -fsSL https://christitus.com/linux | sh"
alias rmd='trash --recursive --force --verbose '
alias checkcommand="type -t"
alias openports='netstat -nape --inet'
alias whatismyip="whatsmyip"
alias whatmyip="whatsmyip"
alias getip="whatsmyip"
command -v xclip >/dev/null 2>&1 && alias clip='xclip -selection clipboard'

# Fun / interactive helpers with dependency checks
# Ensure prior aliases of these names do not interfere with function definitions
unalias matrix 2>/dev/null || true
unalias cowsay 2>/dev/null || true
unalias excuse 2>/dev/null || true
matrix() {
    if ! command -v cmatrix >/dev/null 2>&1; then
        echo "cmatrix is required for this command. Install now? (y/N): "
        read -r ans
        if [[ $ans =~ ^[Yy]$ ]]; then
            if [ -f /etc/debian_version ]; then
                if command -v nala >/dev/null 2>&1; then sudo nala install -y cmatrix; else sudo apt install -y cmatrix; fi
            elif [ -f /etc/arch-release ]; then
                sudo pacman -S --noconfirm cmatrix
            else
                echo "Unsupported distro for auto-install."
                return 1
            fi
        else
            echo "Cancelled."
            return 1
        fi
    fi
    command cmatrix -s -C cyan
}

cowsay() {
    local missing=()
    command -v cowsay >/dev/null 2>&1 || missing+=(cowsay)
    command -v fortune >/dev/null 2>&1 || missing+=(fortune-mod)
    if [ ${#missing[@]} -gt 0 ]; then
        echo "${missing[*]} required for this command. Install now? (y/N): "
        read -r ans
        if [[ $ans =~ ^[Yy]$ ]]; then
            if [ -f /etc/debian_version ]; then
                if command -v nala >/dev/null 2>&1; then sudo nala install -y "${missing[@]}"; else sudo apt install -y "${missing[@]}"; fi
            elif [ -f /etc/arch-release ]; then
                sudo pacman -S --noconfirm "${missing[@]}"
            else
                echo "Unsupported distro for auto-install."
                return 1
            fi
        else
            echo "Cancelled."
            return 1
        fi
    fi
    fortune | command cowsay
}

excuse() {
    if ! command -v telnet >/dev/null 2>&1; then
        echo "telnet (inetutils) is required for this command. Install now? (y/N): "
        read -r ans
        if [[ $ans =~ ^[Yy]$ ]]; then
            if [ -f /etc/debian_version ]; then
                if command -v nala >/dev/null 2>&1; then sudo nala install -y inetutils; else sudo apt install -y inetutils; fi
            elif [ -f /etc/arch-release ]; then
                sudo pacman -S --noconfirm inetutils
            else
                echo "Unsupported distro for auto-install."
                return 1
            fi
        else
            echo "Cancelled."
            return 1
        fi
    fi
    telnet bofh.jeffballard.us 666 2>/dev/null
}

# =========================
# Functions
# =========================
# Extract: unpack various archive formats into current directory
extract() {
    for archive in "$@"; do
        if [ -f "$archive" ]; then
            case "$archive" in
            *.tar.bz2) tar xvjf "$archive" ;;
            *.tar.gz) tar xvzf "$archive" ;;
            *.bz2) bunzip2 "$archive" ;;
            *.rar) rar x "$archive" ;;
            *.gz) gunzip "$archive" ;;
            *.tar) tar xvf "$archive" ;;
            *.tbz2) tar xvjf "$archive" ;;
            *.tgz) tar xvzf "$archive" ;;
            *.zip) unzip "$archive" ;;
            *.Z) uncompress "$archive" ;;
            *.7z) 7z x "$archive" ;;
            *) echo "don't know how to extract '$archive'..." ;;
            esac
        else
            echo "'$archive' is not a valid file!"
        fi
    done
}

# Ftext: search recursively in current dir and page results
ftext() {
    grep -iIHrn --color=always "$1" . | less -r
}

# Cpp: copy a file with a simple progress bar via strace/awk
cpp() {
    set -e
    strace -q -ewrite cp -- "${1}" "${2}" 2>&1 |
        awk '{
        count += $NF
        if (count % 10 == 0) {
            percent = count / total_size * 100
            printf "%3d%% [", percent
            for (i=0;i<=percent;i++) printf "="
            printf ">"
            for (i=percent;i<100;i++) printf " "
            printf "]\r"
        }
    }
    END { print "" }' total_size="$(stat -c '%s' "${1}")" count=0
}

# Cpg: copy a file then cd into the destination if it's a directory
cpg() {
    if [ -d "$2" ]; then
        command cp "$1" "$2" && builtin cd "$2"
    else
        command cp "$1" "$2"
    fi
}

# Mvg: move a file then cd into the destination if it's a directory
mvg() {
    if [ -d "$2" ]; then
        command mv "$1" "$2" && builtin cd "$2"
    else
        command mv "$1" "$2"
    fi
}

# Mkcd: create a directory (parents) then cd into it
mkcd() {
    command mkdir -p "$1" && builtin cd "$1"
}

# Up: go up N directory levels (e.g., up 3)
up() {
    local levels=${1:-1}
    local path=""
    for ((i = 0; i < levels; i++)); do
        path="../$path"
    done
    builtin cd "${path%/}" || return 1
}

# Pwdtail: print the last two segments of current path
pwdtail() {
    pwd | awk -F/ '{nlast = NF -1;print $nlast"/"$NF}'
}

# Whatsmyip: show internal (active interface) and external IPv4
whatsmyip() {
    echo -n "Internal IP: "
    if command -v ip >/dev/null 2>&1; then
        ip -4 route get 1 2>/dev/null | awk '{print $7; exit}'
    elif command -v hostname >/dev/null 2>&1 && hostname -I >/dev/null 2>&1; then
        hostname -I | awk '{print $1}'
    else
        echo "Unknown"
    fi
    echo -n "External IP: "
    curl -4 -s ifconfig.me || echo "Unknown"
}

# Portscan: quick TCP port scan on a target using nmap
portscan() {
    nmap -p- "$1" 2>/dev/null
}

# Hb: upload a file to hastebin-like service and print URL
hb() {
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

# Installpkg: interactive package installation for Debian/Arch (fzf-based)
installpkg() { # Debian/Arch only
    if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf is required but not installed. Please install fzf first."
        return 1
    fi
    if [ -f /etc/debian_version ]; then
        local installer="sudo apt install -y"
        command -v nala >/dev/null 2>&1 && installer="sudo nala install -y"
        local selected=$(apt-cache pkgnames 2>/dev/null | sort | fzf --multi --header="Type to search available packages (Debian)" \
            --preview 'apt show {1} 2>/dev/null | head -40' \
            --preview-window=right:60%:wrap)
        [ -n "$selected" ] && echo "$selected" | xargs -r $installer
    elif [ -f /etc/arch-release ]; then
        if command -v yay >/dev/null 2>&1; then
            local selected=$(yay -Slq 2>/dev/null | fzf --multi --header="Type to search repos + AUR (Arch/yay)" \
                --preview 'yay -Si {1} 2>/dev/null | head -40' \
                --preview-window=right:60%:wrap)
            [ -n "$selected" ] && echo "$selected" | xargs -r yay -S --noconfirm
        else
            local selected=$(pacman -Slq 2>/dev/null | fzf --multi --header="Type to search repos (Arch/pacman)" \
                --preview 'pacman -Si {1} 2>/dev/null | head -40' \
                --preview-window=right:60%:wrap)
            [ -n "$selected" ] && echo "$selected" | xargs -r sudo pacman -S --noconfirm
        fi
    else
        echo "Error: Unknown distribution. Supported: Debian/Ubuntu and Arch."
        return 1
    fi
}

# Removepkg: interactive package removal for Debian/Arch (fzf-based)
removepkg() { # Debian/Arch only
    if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf is required but not installed. Please install fzf first."
        return 1
    fi
    if [ -f /etc/debian_version ]; then
        local selected=$(dpkg --get-selections 2>/dev/null | grep -v deinstall | cut -f1 | sort | fzf --multi --header="Type to filter installed packages (Debian)" \
            --preview 'apt show {1} 2>/dev/null | head -20; echo "\n--- Reverse deps ---"; apt rdepends {1} 2>/dev/null | head -10' \
            --preview-window=right:60%:wrap)
        [ -n "$selected" ] && echo "$selected" | xargs -r sudo apt remove -y
    elif [ -f /etc/arch-release ]; then
        local selected=$(pacman -Qq 2>/dev/null | fzf --multi --header="Type to filter installed packages (Arch)" \
            --preview 'pacman -Qi {1} 2>/dev/null | head -20; echo "\n--- Reverse deps ---"; pactree -r {1} 2>/dev/null | head -10' \
            --preview-window=right:60%:wrap)
        [ -n "$selected" ] && echo "$selected" | xargs -r sudo pacman -R --noconfirm
    else
        echo "Error: Unknown distribution. Supported: Debian/Ubuntu and Arch."
        return 1
    fi
}

# Updatepkg: interactive package update for Debian/Arch (fzf-based)
updatepkg() { # Debian/Arch only
    if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf is required but not installed. Please install fzf first."
        return 1
    fi

    if [ -f /etc/debian_version ]; then
        echo "Checking for updates..."
        # Update package list first
        if command -v nala >/dev/null 2>&1; then
            sudo nala update >/dev/null 2>&1 || {
                echo "Failed to update package list"
                return 1
            }
            local upgradable=$(apt list --upgradable 2>/dev/null | grep -v "^Listing" | cut -d/ -f1)
        else
            sudo apt update >/dev/null 2>&1 || {
                echo "Failed to update package list"
                return 1
            }
            local upgradable=$(apt list --upgradable 2>/dev/null | grep -v "^Listing" | cut -d/ -f1)
        fi

        if [ -z "$upgradable" ]; then
            echo "No updates available"
            return 0
        fi

        local selected=$(echo "$upgradable" | fzf --multi --header="Select packages to update (TAB for multi-select, Debian)" \
            --preview 'apt show {1} 2>/dev/null | head -40' \
            --preview-window=right:60%:wrap)

        if [ -n "$selected" ]; then
            if command -v nala >/dev/null 2>&1; then
                echo "$selected" | xargs -r sudo nala install -y
            else
                echo "$selected" | xargs -r sudo apt install -y
            fi
        fi

    elif [ -f /etc/arch-release ]; then
        echo "Checking for updates..."

        if command -v yay >/dev/null 2>&1; then
            # Update package database first (includes AUR)
            yay -Sy >/dev/null 2>&1 || {
                echo "Failed to update package database"
                return 1
            }

            local upgradable=$(yay -Qu 2>/dev/null | awk '{print $1}')

            if [ -z "$upgradable" ]; then
                echo "No updates available"
                return 0
            fi

            local selected=$(echo "$upgradable" | fzf --multi --header="Select packages to update (TAB for multi-select, Arch + AUR)" \
                --preview 'yay -Si {1} 2>/dev/null | head -40' \
                --preview-window=right:60%:wrap)

            [ -n "$selected" ] && echo "$selected" | xargs -r yay -S --noconfirm
        else
            # Update package database first
            sudo pacman -Sy >/dev/null 2>&1 || {
                echo "Failed to update package database"
                return 1
            }

            local upgradable=$(pacman -Qu 2>/dev/null | awk '{print $1}')

            if [ -z "$upgradable" ]; then
                echo "No updates available"
                return 0
            fi

            local selected=$(echo "$upgradable" | fzf --multi --header="Select packages to update (TAB for multi-select, Arch)" \
                --preview 'pacman -Si {1} 2>/dev/null | head -40' \
                --preview-window=right:60%:wrap)

            [ -n "$selected" ] && echo "$selected" | xargs -r sudo pacman -S --noconfirm
        fi

    else
        echo "Error: Unknown distribution. Supported: Debian/Ubuntu and Arch."
        return 1
    fi
}

# Updatesys: update/upgrade system packages (Debian/Arch) with optional cleanup
updatesys() {
    echo "Starting system upgrade..."
    local packages_updated=0
    local start_time=$(date +%s)

    if [ -f /etc/debian_version ]; then
        echo "Debian-based system detected"

        # Update package lists first
        if command -v nala >/dev/null 2>&1; then
            echo "Using nala for package management"
            sudo nala update || {
                echo "Failed to update package list"
                return 1
            }
        else
            echo "Using apt for package management"
            local apt_opts="-o Acquire::Queue-Mode=host -o APT::Acquire::Retries=3"
            if command -v aria2c >/dev/null 2>&1; then
                apt_opts="$apt_opts -o Acquire::http::Dl-Limit=0 -o Acquire::https::Dl-Limit=0"
                echo "Using aria2c for faster downloads"
            fi
            sudo apt $apt_opts update || {
                echo "Failed to update package list"
                return 1
            }
        fi

        # Check for available updates
        local upgradable_list=$(apt list --upgradable 2>/dev/null | grep -v "^Listing")
        packages_updated=$(echo "$upgradable_list" | grep -c '^' 2>/dev/null || echo 0)

        if [ "$packages_updated" -eq 0 ]; then
            echo "No updates available. System is already up to date."
            return 0
        fi

        echo ""
        echo "Available updates ($packages_updated packages):"
        echo "$upgradable_list" | cut -d/ -f1 | column
        echo ""
        read -p "Do you want to upgrade all these packages? (y/N): " confirm
        if [[ ! $confirm =~ ^[Yy]$ ]]; then
            echo "Update cancelled."
            return 0
        fi

        # Perform upgrade
        if command -v nala >/dev/null 2>&1; then
            sudo nala upgrade -y || {
                echo "Failed to upgrade packages"
                return 1
            }
            sudo nala autopurge -y
            sudo nala clean
        else
            sudo apt $apt_opts upgrade -y || {
                echo "Failed to upgrade packages"
                return 1
            }
            sudo apt autoremove -y
            sudo apt autoclean
        fi

        # Check for reboot requirement
        if [ -f /var/run/reboot-required ]; then
            echo ""
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

        if command -v yay >/dev/null 2>&1; then
            echo "Checking for updates (pacman + AUR)..."
            # Sync database
            yay -Sy >/dev/null 2>&1 || {
                echo "Failed to update package database"
                return 1
            }

            # Get list of upgradable packages
            local upgradable_list=$(yay -Qu 2>/dev/null)
            packages_updated=$(echo "$upgradable_list" | grep -c '^' 2>/dev/null || echo 0)

            if [ "$packages_updated" -eq 0 ]; then
                echo "No updates available. System is already up to date."
                return 0
            fi

            echo ""
            echo "Available updates ($packages_updated packages):"
            echo "$upgradable_list" | awk '{print $1}' | column
            echo ""
            read -p "Do you want to upgrade all these packages? (y/N): " confirm
            if [[ ! $confirm =~ ^[Yy]$ ]]; then
                echo "Update cancelled."
                return 0
            fi

            # Enable parallel downloads
            local yay_opts="--noconfirm --overwrite='*'"
            local failed_packages=()
            if grep -q "^ParallelDownloads" /etc/pacman.conf 2>/dev/null; then
                echo "Parallel downloads enabled"
            else
                echo "Note: Enable ParallelDownloads in /etc/pacman.conf for faster updates"
            fi

            # Try to update all packages first
            echo "Attempting to update all packages..."
            if ! yay -Su $yay_opts 2>&1; then
                echo ""
                echo "Batch update failed. Attempting individual package updates..."
                echo ""

                # Get list of packages to update
                local pkg_list=$(echo "$upgradable_list" | awk '{print $1}')
                local total=$(echo "$pkg_list" | wc -l)
                local current=0

                # Update each package individually
                while IFS= read -r pkg; do
                    ((current++))
                    echo "[$current/$total] Updating $pkg..."
                    if ! yay -S --noconfirm --overwrite='*' "$pkg" 2>&1 | tail -20; then
                        echo "  ✗ Failed to update $pkg"
                        failed_packages+=("$pkg")
                    else
                        echo "  ✓ Updated $pkg"
                    fi
                    echo ""
                done <<<"$pkg_list"
            fi

            echo "Cleaning package cache..."
            yay -Sc --noconfirm 2>/dev/null || true
        else
            echo "Checking for updates..."
            # Sync database
            sudo pacman -Sy >/dev/null 2>&1 || {
                echo "Failed to update package database"
                return 1
            }

            # Get list of upgradable packages
            local upgradable_list=$(pacman -Qu 2>/dev/null)
            packages_updated=$(echo "$upgradable_list" | grep -c '^' 2>/dev/null || echo 0)

            if [ "$packages_updated" -eq 0 ]; then
                echo "No updates available. System is already up to date."
                return 0
            fi

            echo ""
            echo "Available updates ($packages_updated packages):"
            echo "$upgradable_list" | awk '{print $1}' | column
            echo ""
            read -p "Do you want to upgrade all these packages? (y/N): " confirm
            if [[ ! $confirm =~ ^[Yy]$ ]]; then
                echo "Update cancelled."
                return 0
            fi

            # Enable parallel downloads if not already set
            local failed_packages=()
            if grep -q "^ParallelDownloads" /etc/pacman.conf 2>/dev/null; then
                echo "Parallel downloads enabled"
            else
                echo "Note: Enable ParallelDownloads in /etc/pacman.conf for faster updates"
            fi

            # Try to update all packages first
            echo "Attempting to update all packages..."
            if ! sudo pacman -Su --noconfirm --overwrite='*' 2>&1; then
                echo ""
                echo "Batch update failed. Attempting individual package updates..."
                echo ""

                # Get list of packages to update
                local pkg_list=$(echo "$upgradable_list" | awk '{print $1}')
                local total=$(echo "$pkg_list" | wc -l)
                local current=0

                # Update each package individually
                while IFS= read -r pkg; do
                    ((current++))
                    echo "[$current/$total] Updating $pkg..."
                    if ! sudo pacman -S --noconfirm --overwrite='*' "$pkg" 2>&1 | tail -20; then
                        echo "  ✗ Failed to update $pkg"
                        failed_packages+=("$pkg")
                    else
                        echo "  ✓ Updated $pkg"
                    fi
                    echo ""
                done <<<"$pkg_list"
            fi

            echo "Cleaning package cache (keeping installed versions)..."
            yes | sudo pacman -Sc >/dev/null 2>&1 || true
        fi

        # Check for orphaned packages
        local orphans=$(pacman -Qtdq 2>/dev/null)
        if [ -n "$orphans" ]; then
            echo ""
            echo "Found orphaned packages:"
            echo "$orphans"
            read -p "Do you want to remove these orphaned packages? (y/N): " remove_orphans
            if [[ $remove_orphans =~ ^[Yy]$ ]]; then
                echo "$orphans" | sudo pacman -Rns --noconfirm - 2>/dev/null && echo "Orphaned packages removed" || echo "Some packages could not be removed"
            fi
        fi

        # Clear cache directories
        echo "Cleaning additional caches..."
        paccache -rk 2 2>/dev/null || true # Keep only 2 most recent versions if paccache is available

    else
        echo "Error: Unknown distribution. This function supports Debian/Ubuntu and Arch-based systems only."
        return 1
    fi

    # Calculate duration
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))

    # Success summary (runs for both distros)
    echo ""
    echo "===================================="
    echo "System upgrade completed successfully!"
    echo "===================================="
    echo "Packages updated: $packages_updated"
    if [ ${#failed_packages[@]} -gt 0 ]; then
        echo "Failed packages:"
        for pkg in "${failed_packages[@]}"; do
            echo "  - $pkg"
        done
        echo "Tip: Close running applications and try again"
    fi
    echo "Time taken: ${minutes}m ${seconds}s"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p)"

    # Show remaining updates
    if [ -f /etc/debian_version ]; then
        local updates=$(apt list --upgradable 2>/dev/null | grep -v "^Listing" | wc -l)
        if [ "$updates" -gt 0 ]; then
            echo "Pending updates: $updates"
        else
            echo "System is up to date"
        fi
    elif [ -f /etc/arch-release ]; then
        if command -v yay >/dev/null 2>&1; then
            local updates=$(yay -Qu 2>/dev/null | wc -l)
        else
            local updates=$(pacman -Qu 2>/dev/null | wc -l)
        fi
        if [ "$updates" -gt 0 ]; then
            echo "Pending updates: $updates"
        else
            echo "System is up to date"
        fi
    fi
}

# Fzfkill: interactively search and kill processes with fzf
fzfkill() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf is required but not installed. Please install fzf first."
        return 1
    fi

    local pids
    pids=$(ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | sed 1d |
        fzf --multi --header="Select processes to kill (TAB for multi-select, ENTER to confirm)" \
            --preview 'ps -fp {1} 2>/dev/null' \
            --preview-window=right:50%:wrap | awk '{print $1}')

    if [ -n "$pids" ]; then
        echo "Selected PIDs: $pids"
        read -p "Are you sure you want to kill these processes? (y/N): " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            echo "$pids" | xargs -r kill -9 && echo "Processes killed successfully" || echo "Failed to kill some processes"
        else
            echo "Operation cancelled"
        fi
    else
        echo "No processes selected"
    fi
}

# Ytdl: download YouTube video into ~/Downloads/Videos (mp4)
ytdl() {
    local download_dir="$HOME/Downloads/Videos"
    [ -z "$1" ] && {
        echo "Usage: ytdl <youtube-url>"
        return 1
    }

    if ! command -v yt-dlp >/dev/null 2>&1; then
        echo "Error: yt-dlp is not installed. Please install it first."
        return 1
    fi

    [ ! -d "$download_dir" ] && mkdir -p "$download_dir"
    (
        builtin cd "$download_dir" || return
        if command -v aria2c >/dev/null 2>&1; then
            yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' --merge-output-format mp4 --external-downloader aria2c -o '%(title)s-%(id)s.%(ext)s' "$1"
        else
            yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' --merge-output-format mp4 -o '%(title)s-%(id)s.%(ext)s' "$1"
        fi
    )
}

# Openremote: open the current git origin remote URL in default browser
openremote() {
    url=$(git remote get-url origin)
    xdg-open "$url" || echo "No remote found"
}

# =========================
# Tmux auto-attach
# =========================
if [[ $- == *i* ]] && command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ]; then
    # Attach to existing session or create a new one
    tmux attach-session 2>/dev/null || tmux new-session
fi

# =========================
# Keybindings and init
# =========================
if [[ $- == *i* ]]; then
    bind '"\C-f":"zi\n"'
    bind '"\C-y":"installpkg\n"'
fi

eval "$(starship init bash)"
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
    alias cd='z'
fi
if command -v brew &>/dev/null; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
