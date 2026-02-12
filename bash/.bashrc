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
    shopt -s dirspell
    shopt -s histappend
    shopt -s globstar
fi

# History configuration
export HISTFILESIZE=10000
export HISTSIZE=5000
export HISTTIMEFORMAT="%F %T "
export HISTCONTROL=erasedups:ignoredups:ignorespace
# Sync history across all sessions: append, clear local, reload from file
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }history -a; history -c; history -r"

# Interactive-only terminal tweaks
if [[ $- == *i* ]]; then
    bind "set bell-style visible"
    bind "set completion-ignore-case on"
    bind "set show-all-if-ambiguous On"
    stty -ixon
fi

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
alias cp='cp -i'
alias mv='mv -i'
command -v trash >/dev/null 2>&1 && alias rm='trash -v'
alias mkdir='mkdir -p'

# Enhanced ls variants using eza (with fallback to ls)
if command -v eza >/dev/null 2>&1; then
    alias ls='eza -l --group-directories-first --icons'                  # no hidden files
    alias la='eza -la --icons --group-directories-first'                 # show hidden files
    alias lx='eza -la --sort=ext --icons --group-directories-first'      # sort by extension
    alias lk='eza -la --sort=size --icons --group-directories-first'     # sort by size
    alias lc='eza -la --sort=changed --icons --group-directories-first'  # sort by change time
    alias lu='eza -la --sort=accessed --icons --group-directories-first' # sort by access time
    alias lr='eza -la --recurse --icons --group-directories-first'       # recursive ls
    alias lt='eza -la --sort=modified --icons --group-directories-first' # sort by date
    alias lm='eza -la --icons --group-directories-first | more'          # pipe through 'more'
    alias lw='eza -a --icons --group-directories-first'                  # wide listing format
    alias ll='eza -l --icons --group-directories-first'                  # long listing format (no hidden)
    alias lf='eza -la --icons -f'                                        # files only
    alias ldir='eza -la --icons -D'                                      # directories only
    alias ltree='eza -la --tree --icons --group-directories-first'       # tree view
else
    alias ls='ls -l --color=auto' # no hidden files
    alias la='ls -Alh'
    alias lx='ls -lXBha'
    alias lk='ls -lSrha'
    alias lc='ls -ltcrha'
    alias lu='ls -lturha'
    alias lr='ls -lRha'
    alias lt='ls -ltrha'
    alias lm='ls -alh | more'
    alias lw='ls -xAh'
    alias ll='ls -l --color=auto'
    alias lf="ls -la | grep -v '^d'"
    alias ldir="ls -la | grep '^d'"
fi
command -v btop >/dev/null 2>&1 && alias top='btop'
command -v btop >/dev/null 2>&1 && alias htop='btop'
command -v fastfetch >/dev/null 2>&1 && alias neofetch='fastfetch'
alias wget='wget --show-progress --progress=bar:force:noscroll'
alias cls='clear'

# Ripgrep integration
if command -v rg >/dev/null 2>&1; then
    alias grep='rg'
else
    alias grep='/usr/bin/grep --color=auto'
fi

# System aliases
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'

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
command -v xclip >/dev/null 2>&1 && alias copy='xclip -selection clipboard'

# =========================
# Distro detection & package helpers
# =========================

# Detect the current Linux distribution family.
# Sets the global _DISTRO variable to one of:
#   debian, arch, fedora, opensuse, alpine, void, solus, unknown
_detect_distro() {
    if [ -n "$_DISTRO" ]; then return; fi
    if [ -f /etc/debian_version ]; then
        _DISTRO="debian"
    elif [ -f /etc/arch-release ]; then
        _DISTRO="arch"
    elif [ -f /etc/fedora-release ] || [ -f /etc/redhat-release ]; then
        _DISTRO="fedora"
    elif [ -f /etc/SuSE-release ] || [ -f /etc/SUSE-brand ] || command grep -qi "suse\|opensuse" /etc/os-release 2>/dev/null; then
        _DISTRO="opensuse"
    elif [ -f /etc/alpine-release ]; then
        _DISTRO="alpine"
    elif [ -d /run/runit ] || command -v xbps-install >/dev/null 2>&1; then
        _DISTRO="void"
    elif command -v eopkg >/dev/null 2>&1; then
        _DISTRO="solus"
    else
        _DISTRO="unknown"
    fi
}

# Install one or more packages using the appropriate package manager.
# Usage: _pkg_install pkg1 [pkg2 ...]
# Supports: debian (nala/apt), arch (yay/pacman), fedora (dnf),
#           opensuse (zypper), alpine (apk), void (xbps), solus (eopkg)
_pkg_install() {
    _detect_distro
    case "$_DISTRO" in
    debian)
        if command -v nala >/dev/null 2>&1; then
            sudo nala install -y "$@"
        else
            sudo apt install -y "$@"
        fi
        ;;
    arch)
        if command -v yay >/dev/null 2>&1; then
            yay -S --noconfirm "$@"
        else
            sudo pacman -S --noconfirm "$@"
        fi
        ;;
    fedora)
        sudo dnf install -y "$@"
        ;;
    opensuse)
        sudo zypper --non-interactive install "$@"
        ;;
    alpine)
        sudo apk add "$@"
        ;;
    void)
        sudo xbps-install -y "$@"
        ;;
    solus)
        sudo eopkg -y install "$@"
        ;;
    *)
        echo "Error: Unsupported distribution for auto-install."
        return 1
        ;;
    esac
}

# Prompt to install missing packages, then install if confirmed.
# Usage: _require_pkg "description" pkg1 [pkg2 ...]
# Returns 0 if all packages are available (or were just installed), 1 otherwise.
_require_pkg() {
    local desc="$1"
    shift
    local missing=()
    for pkg in "$@"; do
        command -v "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
    done
    if [ ${#missing[@]} -eq 0 ]; then return 0; fi
    echo "${missing[*]} required for $desc. Install now? (y/N): "
    read -r ans
    if [[ $ans =~ ^[Yy]$ ]]; then
        _pkg_install "${missing[@]}"
    else
        echo "Cancelled."
        return 1
    fi
}

# Check that a command is available, printing an error if not.
# Usage: _require_cmd cmd_name || return 1
_require_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: $1 is required but not installed. Please install $1 first."
        return 1
    fi
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
            *.rar) unrar x "$archive" ;;
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
    command grep -iIHrn --color=always "$1" . | less -r
}

# Cpp: copy a file with a simple progress bar via strace/awk
cpp() {
    (
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
    )
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
# Hastebin instance hosted by Chris Titus (https://christitus.com/)
# NOTE: This endpoint only supports HTTP. HTTPS is not available for this service.
hb() {
    if [ $# -eq 0 ]; then
        echo "No file path specified."
        return
    elif [ ! -f "$1" ]; then
        echo "File path does not exist."
        return
    fi
    local uri="http://bin.christitus.com/documents"
    local response
    response=$(curl -s -X POST -d @"$1" "$uri")
    if [ $? -eq 0 ]; then
        local hasteKey
        hasteKey=$(echo "$response" | jq -r '.key')
        local url="http://bin.christitus.com/$hasteKey"
        echo "$url" | xclip -selection clipboard
        echo "$url - Copied to clipboard."
    else
        echo "Failed to upload the document."
    fi
}

# Serve: start a temporary HTTP server in current directory
serve() {
    local port="${1:-8000}"
    local ip

    # Get local IP address
    if command -v ip >/dev/null 2>&1; then
        ip=$(ip -4 route get 1 2>/dev/null | awk '{print $7; exit}')
    elif command -v hostname >/dev/null 2>&1; then
        ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    fi
    ip="${ip:-localhost}"

    local url="http://${ip}:${port}"

    echo ""
    echo "┌─────────────────────────────────────┐"
    echo "│  🌐 HTTP Server                     │"
    echo "├─────────────────────────────────────┤"
    echo "│  Local:   http://localhost:${port}"
    echo "│  Network: ${url}"
    echo "│  Dir:     $(pwd)"
    echo "└─────────────────────────────────────┘"

    # Copy URL to clipboard if xclip is available
    if command -v xclip >/dev/null 2>&1; then
        echo -n "$url" | xclip -selection clipboard
        echo "Copied link to clipboard"
    fi

    echo ""
    echo "Press Ctrl+C to stop the server"
    echo ""
    echo "Logs:"
    echo ""

    # Start server (try python3, then python, then php)
    if command -v python3 >/dev/null 2>&1; then
        python3 -m http.server "$port"
    elif command -v python >/dev/null 2>&1; then
        python -m SimpleHTTPServer "$port"
    elif command -v php >/dev/null 2>&1; then
        php -S "0.0.0.0:${port}"
    else
        echo "Error: No suitable HTTP server found (python3, python, or php required)"
        return 1
    fi
}

# Installpkg: interactive package installation (fzf-based)
installpkg() {
    _require_cmd fzf || return 1
    _detect_distro
    local selected
    case "$_DISTRO" in
    debian)
        local installer="sudo apt install -y"
        command -v nala >/dev/null 2>&1 && installer="sudo nala install -y"
        selected=$(apt-cache pkgnames 2>/dev/null | sort | fzf --multi --header="Type to search available packages (Debian)" \
            --preview 'apt show {1} 2>/dev/null | head -40' \
            --preview-window=right:60%:wrap)
        [ -n "$selected" ] && echo "$selected" | xargs -r $installer
        ;;
    arch)
        if command -v yay >/dev/null 2>&1; then
            selected=$(yay -Slq 2>/dev/null | fzf --multi --header="Type to search repos + AUR (Arch/yay)" \
                --preview 'yay -Si {1} 2>/dev/null | head -40' \
                --preview-window=right:60%:wrap)
            [ -n "$selected" ] && echo "$selected" | xargs -r yay -S --noconfirm
        else
            selected=$(pacman -Slq 2>/dev/null | fzf --multi --header="Type to search repos (Arch/pacman)" \
                --preview 'pacman -Si {1} 2>/dev/null | head -40' \
                --preview-window=right:60%:wrap)
            [ -n "$selected" ] && echo "$selected" | xargs -r sudo pacman -S --noconfirm
        fi
        ;;
    *)
        echo "Error: Unsupported distribution for interactive install. Supported: Debian/Ubuntu and Arch."
        return 1
        ;;
    esac
}

# Removepkg: interactive package removal (fzf-based)
removepkg() {
    _require_cmd fzf || return 1
    _detect_distro
    local selected
    case "$_DISTRO" in
    debian)
        selected=$(dpkg --get-selections 2>/dev/null | command grep -v deinstall | cut -f1 | sort | fzf --multi --header="Type to filter installed packages (Debian)" \
            --preview 'apt show {1} 2>/dev/null | head -20; echo "\n--- Reverse deps ---"; apt rdepends {1} 2>/dev/null | head -10' \
            --preview-window=right:60%:wrap)
        [ -n "$selected" ] && echo "$selected" | xargs -r sudo apt remove -y
        ;;
    arch)
        selected=$(pacman -Qq 2>/dev/null | fzf --multi --header="Type to filter installed packages (Arch)" \
            --preview 'pacman -Qi {1} 2>/dev/null | head -20; echo "\n--- Reverse deps ---"; pactree -r {1} 2>/dev/null | head -10' \
            --preview-window=right:60%:wrap)
        [ -n "$selected" ] && echo "$selected" | xargs -r sudo pacman -R --noconfirm
        ;;
    *)
        echo "Error: Unsupported distribution for interactive removal. Supported: Debian/Ubuntu and Arch."
        return 1
        ;;
    esac
}

# Updatepkg: interactive package update (fzf-based)
updatepkg() {
    _require_cmd fzf || return 1
    _detect_distro
    echo "Checking for updates..."
    local upgradable selected pkg_list

    case "$_DISTRO" in
    debian)
        if command -v nala >/dev/null 2>&1; then
            sudo nala update >/dev/null 2>&1 || { echo "Failed to update package list"; return 1; }
        else
            sudo apt update >/dev/null 2>&1 || { echo "Failed to update package list"; return 1; }
        fi
        upgradable=$(apt list --upgradable 2>/dev/null | command grep -v "^Listing" | cut -d/ -f1)
        [ -z "$upgradable" ] && { echo "No updates available"; return 0; }
        selected=$(echo "$upgradable" | fzf --multi --header="Select packages to update (TAB for multi-select, Debian)" \
            --preview 'apt show {1} 2>/dev/null | head -40' \
            --preview-window=right:60%:wrap)
        if [ -n "$selected" ]; then
            pkg_list=$(echo "$selected" | tr '\n' ' ')
            echo "Installing: $pkg_list"
            if command -v nala >/dev/null 2>&1; then
                sudo nala install -y $pkg_list || { echo "Some packages failed to install"; return 1; }
            else
                sudo apt install -y $pkg_list || { echo "Some packages failed to install"; return 1; }
            fi
        fi
        ;;
    arch)
        sudo pacman -Sy >/dev/null 2>&1 || { echo "Failed to update package database"; return 1; }
        if command -v yay >/dev/null 2>&1; then
            upgradable=$(yay -Qu 2>/dev/null | awk '{print $1}')
            [ -z "$upgradable" ] && { echo "No updates available"; return 0; }
            selected=$(echo "$upgradable" | fzf --multi --header="Select packages to update (TAB for multi-select, Arch + AUR)" \
                --preview 'yay -Si {1} 2>/dev/null | head -40' \
                --preview-window=right:60%:wrap)
            if [ -n "$selected" ]; then
                pkg_list=$(echo "$selected" | tr '\n' ' ')
                echo "Updating: $pkg_list"
                yay -S --noconfirm $pkg_list || { echo "Some packages failed to update"; return 1; }
            fi
        else
            upgradable=$(pacman -Qu 2>/dev/null | awk '{print $1}')
            [ -z "$upgradable" ] && { echo "No updates available"; return 0; }
            selected=$(echo "$upgradable" | fzf --multi --header="Select packages to update (TAB for multi-select, Arch)" \
                --preview 'pacman -Si {1} 2>/dev/null | head -40' \
                --preview-window=right:60%:wrap)
            if [ -n "$selected" ]; then
                pkg_list=$(echo "$selected" | tr '\n' ' ')
                echo "Updating: $pkg_list"
                sudo pacman -S --noconfirm $pkg_list || { echo "Some packages failed to update"; return 1; }
            fi
        fi
        ;;
    *)
        echo "Error: Unsupported distribution for interactive update. Supported: Debian/Ubuntu and Arch."
        return 1
        ;;
    esac
}

# Helper: optimize mirrors (arch/debian only)
_optimize_mirrors() {
    local YELLOW='\033[1;33m' RED='\033[0;31m' GREEN='\033[0;32m' RC='\033[0m'
    case "$1" in
    arch)
        if command -v rate-mirrors >/dev/null 2>&1; then
            echo -e "${YELLOW}Optimizing mirrors using rate-mirrors...${RC}"
            if [ -s "/etc/pacman.d/mirrorlist" ]; then
                sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
            fi
            if ! sudo rate-mirrors --top-mirrors-number-to-retest=5 --disable-comments --save /etc/pacman.d/mirrorlist --allow-root arch >/dev/null 2>&1 || [ ! -s "/etc/pacman.d/mirrorlist" ]; then
                echo -e "${RED}Rate-mirrors failed, restoring backup.${RC}"
                sudo cp /etc/pacman.d/mirrorlist.bak /etc/pacman.d/mirrorlist
            else
                echo -e "${GREEN}Mirror list optimized!${RC}"
            fi
        fi
        ;;
    debian)
        if command -v nala >/dev/null 2>&1; then
            echo -e "${YELLOW}Optimizing mirrors using nala fetch...${RC}"
            if [ -f "/etc/apt/sources.list.d/nala-sources.list" ]; then
                sudo cp /etc/apt/sources.list.d/nala-sources.list /etc/apt/sources.list.d/nala-sources.list.bak
            fi
            if ! sudo nala fetch --auto -y 2>/dev/null; then
                echo -e "${RED}Nala fetch failed, restoring backup if available.${RC}"
                if [ -f "/etc/apt/sources.list.d/nala-sources.list.bak" ]; then
                    sudo cp /etc/apt/sources.list.d/nala-sources.list.bak /etc/apt/sources.list.d/nala-sources.list
                fi
            else
                echo -e "${GREEN}Mirror list optimized!${RC}"
            fi
        fi
        ;;
    esac
}

# Helper: update flatpak packages if flatpak is installed
_update_flatpaks() {
    if command -v flatpak >/dev/null 2>&1; then
        local YELLOW='\033[1;33m' RC='\033[0m'
        echo ""
        echo -e "${YELLOW}Updating flatpak packages...${RC}"
        flatpak update -y
    fi
}

# Updatesys: update/upgrade system packages with optional cleanup
# Supports: Debian/Ubuntu, Arch, Fedora, openSUSE, Alpine, Void, Solus
updatesys() {
    _detect_distro
    echo "Starting system upgrade..."
    local packages_updated=0
    local start_time=$(date +%s)
    local CYAN='\033[0;36m' YELLOW='\033[1;33m' RED='\033[0;31m' GREEN='\033[0;32m' RC='\033[0m'

    case "$_DISTRO" in
    debian)
        echo "Debian-based system detected"
        _optimize_mirrors debian
        local PACKAGER="apt" apt_opts=""
        if command -v nala >/dev/null 2>&1; then
            PACKAGER="nala"
            echo -e "${CYAN}Using nala for package management${RC}"
        else
            echo "Using apt for package management"
        fi

        if [ "$PACKAGER" = "nala" ]; then
            sudo nala update || { echo "Failed to update package list"; return 1; }
        else
            apt_opts="-o Acquire::Queue-Mode=host -o APT::Acquire::Retries=3"
            sudo apt $apt_opts update || { echo "Failed to update package list"; return 1; }
        fi

        local upgradable_list=$(apt list --upgradable 2>/dev/null | command grep -v "^Listing")
        packages_updated=$(echo "$upgradable_list" | command grep -c '^' 2>/dev/null || echo 0)

        if [ "$packages_updated" -eq 0 ]; then
            echo "No updates available. System is already up to date."
            _update_flatpaks
            return 0
        fi

        echo "Upgrading $packages_updated packages..."
        if [ "$PACKAGER" = "nala" ]; then
            sudo nala upgrade -y || { echo "Failed to upgrade packages"; return 1; }
            sudo nala autopurge -y
            sudo nala clean
        else
            sudo apt $apt_opts upgrade -y || { echo "Failed to upgrade packages"; return 1; }
            sudo apt autoremove -y
            sudo apt autoclean
        fi

        _update_flatpaks

        if [ -f /var/run/reboot-required ]; then
            echo ""
            echo -e "${YELLOW}WARNING: System reboot is required to complete the upgrade.${RC}"
        fi
        ;;

    arch)
        echo "Arch-based system detected"
        _optimize_mirrors arch
        if ! command -v yay >/dev/null 2>&1; then
            echo -e "${RED}Error: yay is required but not installed.${RC}"
            echo "Install yay first: https://github.com/Jguer/yay"
            return 1
        fi

        echo -e "${CYAN}Using yay for package management (pacman + AUR)${RC}"

        echo "Updating archlinux-keyring..."
        sudo pacman -Sy --noconfirm --needed archlinux-keyring || { echo "Failed to update keyring"; return 1; }

        local upgradable_list=$(yay -Qu 2>/dev/null)
        packages_updated=$(echo "$upgradable_list" | command grep -c '^' 2>/dev/null || echo 0)

        if [ "$packages_updated" -eq 0 ]; then
            echo "No updates available. System is already up to date."
            _update_flatpaks
            return 0
        fi

        echo "Upgrading $packages_updated packages..."

        if ! command grep -q "^ParallelDownloads" /etc/pacman.conf 2>/dev/null; then
            echo "Note: Enable ParallelDownloads in /etc/pacman.conf for faster updates"
        fi

        echo "Upgrading official repository packages..."
        sudo pacman -Su --noconfirm || { echo -e "${RED}Failed to upgrade official packages${RC}"; return 1; }

        local aur_updates
        aur_updates=$(yay -Qua 2>/dev/null)
        if [ -n "$aur_updates" ]; then
            local aur_list
            aur_list=$(echo "$aur_updates" | awk '{print $1}')
            for pkg in $aur_list; do
                local cache_dir="$HOME/.cache/yay/$pkg"
                if [ -d "$cache_dir" ]; then
                    echo "Cleaning yay cache for $pkg"
                    rm -rf "$cache_dir" || true
                fi
            done

            echo ""
            echo "Upgrading AUR packages..."
            if ! yay -Sua --noconfirm; then
                echo -e "${YELLOW}Some AUR packages may have failed to update${RC}"
            fi
        fi

        echo "Cleaning package cache..."
        yay -Sc --noconfirm 2>/dev/null || true
        paccache -rk 2 2>/dev/null || true

        local orphans=$(pacman -Qtdq 2>/dev/null)
        if [ -n "$orphans" ]; then
            echo "Removing orphaned packages..."
            echo "$orphans" | sudo pacman -Rns --noconfirm - 2>/dev/null && echo "Orphaned packages removed" || echo "Some packages could not be removed"
        fi

        _update_flatpaks
        ;;

    fedora)
        echo "Fedora/RHEL-based system detected"
        echo -e "${CYAN}Using dnf for package management${RC}"
        echo "Updating system packages..."
        sudo dnf update -y || { echo "Failed to update packages"; return 1; }
        echo "Cleaning package cache..."
        sudo dnf autoremove -y
        sudo dnf clean all
        _update_flatpaks
        ;;

    opensuse)
        echo "openSUSE-based system detected"
        echo -e "${CYAN}Using zypper for package management${RC}"
        echo "Refreshing repositories..."
        sudo zypper ref || { echo "Failed to refresh repositories"; return 1; }
        echo "Performing distribution upgrade..."
        sudo zypper --non-interactive dup || { echo "Failed to upgrade packages"; return 1; }
        echo "Cleaning package cache..."
        sudo zypper clean
        _update_flatpaks
        ;;

    alpine)
        echo "Alpine Linux detected"
        echo -e "${CYAN}Using apk for package management${RC}"
        echo "Updating package index..."
        sudo apk update || { echo "Failed to update package index"; return 1; }
        echo "Upgrading packages..."
        sudo apk upgrade || { echo "Failed to upgrade packages"; return 1; }
        _update_flatpaks
        ;;

    void)
        echo "Void Linux detected"
        echo -e "${CYAN}Using xbps for package management${RC}"
        echo "Syncing repositories..."
        sudo xbps-install -S || { echo "Failed to sync repositories"; return 1; }
        echo "Upgrading packages..."
        sudo xbps-install -yu || { echo "Failed to upgrade packages"; return 1; }
        _update_flatpaks
        ;;

    solus)
        echo "Solus detected"
        echo -e "${CYAN}Using eopkg for package management${RC}"
        echo "Updating repository..."
        sudo eopkg -y update-repo || { echo "Failed to update repository"; return 1; }
        echo "Upgrading packages..."
        sudo eopkg -y upgrade || { echo "Failed to upgrade packages"; return 1; }
        _update_flatpaks
        ;;

    *)
        echo -e "${RED}Error: Unknown distribution.${RC}"
        echo "This function supports:"
        echo "  - Debian/Ubuntu (apt/nala)"
        echo "  - Arch Linux (pacman/yay)"
        echo "  - Fedora/RHEL (dnf)"
        echo "  - openSUSE (zypper)"
        echo "  - Alpine (apk)"
        echo "  - Void Linux (xbps)"
        echo "  - Solus (eopkg)"
        return 1
        ;;
    esac

    # Calculate duration
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))

    # Success summary
    echo ""
    echo -e "${GREEN}====================================${RC}"
    echo -e "${GREEN}System upgrade completed successfully!${RC}"
    echo -e "${GREEN}====================================${RC}"
    if [ "$packages_updated" -gt 0 ]; then
        echo "Packages processed: $packages_updated"
    fi
    echo "Time taken: ${minutes}m ${seconds}s"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p)"

    # Show remaining updates
    local updates=0
    case "$_DISTRO" in
    debian)   updates=$(apt list --upgradable 2>/dev/null | command grep -v "^Listing" | wc -l) ;;
    arch)     updates=$(yay -Qu 2>/dev/null | wc -l) ;;
    fedora)   updates=$(dnf check-update 2>/dev/null | command grep -c '^[a-zA-Z]' || echo 0) ;;
    opensuse) updates=$(zypper list-updates 2>/dev/null | command grep -c '^v' || echo 0) ;;
    alpine)   updates=$(apk version -l '<' 2>/dev/null | wc -l) ;;
    void)     updates=$(xbps-install -nu 2>/dev/null | wc -l) ;;
    solus)    updates=$(eopkg lu 2>/dev/null | command grep -c '^' || echo 0) ;;
    esac

    if [ "$updates" -gt 0 ]; then
        echo -e "${YELLOW}Pending updates: $updates${RC}"
    else
        echo -e "${GREEN}System is up to date${RC}"
    fi
}

# Cleansys: perform system cleanup (cache, logs, orphans, trash)
# Supports: Debian/Ubuntu (nala/apt), Arch (yay/pacman)
cleansys() {
    _detect_distro
    echo "Starting system cleanup..."
    local start_time=$(date +%s)
    local YELLOW='\033[1;33m' RED='\033[0;31m' GREEN='\033[0;32m' RC='\033[0m'

    # Package manager cleanup
    echo -e "${YELLOW}Cleaning package manager cache...${RC}"
    case "$_DISTRO" in
    debian)
        if command -v nala >/dev/null 2>&1; then
            sudo nala clean
            sudo nala autoremove -y
        else
            sudo apt-get clean
            sudo apt-get autoremove -y
        fi
        echo "APT cache size: $(sudo du -sh /var/cache/apt 2>/dev/null | cut -f1)"
        ;;
    arch)
        if command -v yay >/dev/null 2>&1; then
            yay -Sc --noconfirm
        else
            sudo pacman -Sc --noconfirm
        fi
        local orphans=$(pacman -Qtdq 2>/dev/null)
        if [ -n "$orphans" ]; then
            echo "Removing orphaned packages..."
            echo "$orphans" | sudo pacman -Rns --noconfirm - 2>/dev/null || true
        fi
        paccache -rk 2 2>/dev/null || true
        ;;
    *)
        echo -e "${RED}Unsupported distribution for package cleanup. Supported: Debian/Ubuntu and Arch.${RC}"
        return 1
        ;;
    esac

    # Common cleanup: temp files
    echo -e "${YELLOW}Cleaning temporary files...${RC}"
    if [ -d /var/tmp ]; then
        sudo find /var/tmp -type f -atime +5 -delete 2>/dev/null || true
    fi
    if [ -d /tmp ]; then
        sudo find /tmp -type f -atime +5 -delete 2>/dev/null || true
    fi

    # Truncate old log files
    echo -e "${YELLOW}Truncating old log files...${RC}"
    if [ -d /var/log ]; then
        sudo find /var/log -type f -name "*.log" -exec truncate -s 0 {} \; 2>/dev/null || true
    fi

    # Clean journald logs (systemd systems)
    if command -v journalctl >/dev/null 2>&1; then
        echo -e "${YELLOW}Vacuuming journald logs (keeping 3 days)...${RC}"
        sudo journalctl --vacuum-time=3d 2>/dev/null || true
    fi

    # Clean user cache and trash
    echo -e "${YELLOW}Cleaning user cache (files older than 5 days)...${RC}"
    if [ -d "$HOME/.cache" ]; then
        find "$HOME/.cache/" -type f -atime +5 -delete 2>/dev/null || true
    fi

    echo -e "${YELLOW}Emptying trash...${RC}"
    if [ -d "$HOME/.local/share/Trash" ]; then
        find "$HOME/.local/share/Trash" -mindepth 1 -delete 2>/dev/null || true
    fi

    # Clean flatpak unused runtimes
    if command -v flatpak >/dev/null 2>&1; then
        echo -e "${YELLOW}Removing unused flatpak runtimes...${RC}"
        flatpak uninstall --unused -y 2>/dev/null || true
    fi

    # Calculate duration
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo ""
    echo -e "${GREEN}====================================${RC}"
    echo -e "${GREEN}System cleanup completed!${RC}"
    echo -e "${GREEN}====================================${RC}"
    echo "Time taken: ${duration}s"

    # Show disk usage
    echo ""
    echo "Disk usage:"
    df -h / | tail -1 | awk '{print "  Root: " $3 " used / " $2 " total (" $5 " used)"}'
}

# Fzfkill: interactively search and kill processes with fzf
fzfkill() {
    _require_cmd fzf || return 1

    local pids
    pids=$(ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | sed 1d |
        fzf --multi --header="Select processes to kill (TAB for multi-select, ENTER to confirm)" \
            --preview 'ps -fp {1} 2>/dev/null' \
            --preview-window=right:50%:wrap | awk '{print $1}')

    if [ -n "$pids" ]; then
        echo "Selected PIDs: $pids"
        read -p "Signal? [t]erm (default) / [k]ill / [number]: " sig
        local signal
        case "$sig" in
        k|K)       signal="-9" ;;
        [0-9]*)    signal="-$sig" ;;
        *)         signal="-15" ;;
        esac
        read -p "Send signal $signal to these processes? (y/N): " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            echo "$pids" | xargs -r kill "$signal" && echo "Signal sent successfully" || echo "Failed to signal some processes"
        else
            echo "Operation cancelled"
        fi
    else
        echo "No processes selected"
    fi
}

# Ytdl: download YouTube video into ~/Videos (mp4)
ytdl() {
    local default_dir="$HOME/Videos"
    local url quality download_dir height format

    # Accept URL as first argument, or prompt interactively
    if [ -n "$1" ]; then
        url="$1"
    else
        read -e -p "YouTube URL: " url
        if [ -z "$url" ]; then
            echo "No URL provided. Aborting."
            return 1
        fi
    fi

    # Accept quality as second argument, or prompt interactively
    if [ -n "$2" ]; then
        quality="$2"
    else
        read -e -p "Quality (default 1080p): " quality
    fi
    quality=${quality:-1080p}

    # Accept output directory as third argument, or prompt interactively
    if [ -n "$3" ]; then
        download_dir="$3"
    else
        read -e -p "Output directory (default $default_dir): " download_dir
    fi
    download_dir=${download_dir:-$default_dir}
    mkdir -p "$download_dir" || {
        echo "Failed to create $download_dir"
        return 1
    }

    if ! command -v yt-dlp >/dev/null 2>&1; then
        echo "Error: yt-dlp is not installed. Please install it first."
        return 1
    fi

    (
        builtin cd "$download_dir" || return

        # Build a simple format string based on requested resolution
        height=$(echo "$quality" | sed 's/[^0-9]//g')
        if [ -n "$height" ]; then
            format="bestvideo[height<=$height]+bestaudio[ext=m4a]/best"
        else
            format="bestvideo+bestaudio/best"
        fi

        if command -v aria2c >/dev/null 2>&1; then
            yt-dlp -f "$format" --merge-output-format mp4 --external-downloader aria2c -o '%(title)s-%(id)s.%(ext)s' "$url"
        else
            yt-dlp -f "$format" --merge-output-format mp4 -o '%(title)s-%(id)s.%(ext)s' "$url"
        fi
    )
}

# Openremote: open the current git origin remote URL in default browser
openremote() {
    local url
    url=$(git remote get-url origin 2>/dev/null) || {
        echo "No remote found"
        return 1
    }
    # Convert SSH URLs to HTTPS so the browser can open them
    url=$(echo "$url" | sed -e 's|^git@\(.*\):\(.*\)$|https://\1/\2|' -e 's|\.git$||')
    xdg-open "$url"
}

# Weather: get weather for a city (default: auto-detect location)
weather() {
    curl -s "wttr.in/${1:-}"
}

# =========================
# Keybindings and init
# =========================

# Show custom keybindings
keybinds() {
    local CYAN='\033[0;36m'
    local YELLOW='\033[1;33m'
    local GREEN='\033[0;32m'
    local RC='\033[0m'

    echo ""
    echo -e "${CYAN}┌─────────────────────────────────────────────────────┐${RC}"
    echo -e "${CYAN}│${RC}${YELLOW}  Custom Keybindings                                 ${RC}${CYAN}│${RC}"
    echo -e "${CYAN}├─────────────────────────────────────────────────────┤${RC}"
    echo -e "${CYAN}│${RC}${GREEN}  Ctrl+f     Zoxide interactive (zi)                 ${RC}${CYAN}│${RC}"
    echo -e "${CYAN}│${RC}${GREEN}  Ctrl+y     Install package (installpkg)            ${RC}${CYAN}│${RC}"
    echo -e "${CYAN}│${RC}${GREEN}  Ctrl+r     Fuzzy history search                    ${RC}${CYAN}│${RC}"
    echo -e "${CYAN}│${RC}${GREEN}  Ctrl+t     Fuzzy file search                       ${RC}${CYAN}│${RC}"
    echo -e "${CYAN}│${RC}${GREEN}  Ctrl+g     Fuzzy directory search                  ${RC}${CYAN}│${RC}"
    echo -e "${CYAN}│${RC}${GREEN}  Ctrl+x     Fuzzy delete (fzfdel)                   ${RC}${CYAN}│${RC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────────┘${RC}"
    echo ""
}

if [[ $- == *i* ]]; then
    bind '"\C-f":"zi\n"'
    bind '"\C-y":"installpkg\n"'
    bind '"\C-x":"fzfdel\n"'

    # FZF integration
    if command -v fzf >/dev/null 2>&1; then
        # Ctrl+r: fuzzy history search
        __fzf_history__() {
            local output
            output=$(HISTTIMEFORMAT='' history | sed 's/^ *[0-9]* *//' | tac | awk '!seen[$0]++' | fzf --height 40% --reverse --border --prompt="History ❯ " --query="$READLINE_LINE")
            READLINE_LINE="$output"
            READLINE_POINT=${#READLINE_LINE}
        }
        bind -x '"\C-r": __fzf_history__'

        # Ctrl+t: fuzzy file search (insert selected file at cursor)
        __fzf_file__() {
            local output quoted_output
            if command -v fd >/dev/null 2>&1; then
                output=$(fd --type f --hidden --exclude .git | fzf --height 40% --reverse --border --prompt="Files ❯ " --preview 'head -100 {}' --preview-window=right:50%:wrap)
            else
                output=$(find . -type f -not -path '*/.git/*' 2>/dev/null | fzf --height 40% --reverse --border --prompt="Files ❯ " --preview 'head -100 {}' --preview-window=right:50%:wrap)
            fi
            if [ -n "$output" ]; then
                # Quote the path if it contains spaces or special characters
                printf -v quoted_output '%q' "$output"
                READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$quoted_output${READLINE_LINE:$READLINE_POINT}"
                READLINE_POINT=$((READLINE_POINT + ${#quoted_output}))
            fi
        }
        bind -x '"\C-t": __fzf_file__'

        # Ctrl+g: fuzzy directory search (insert selected dir at cursor)
        __fzf_cd__() {
            local dir quoted_dir
            if command -v fd >/dev/null 2>&1; then
                dir=$(fd --type d --hidden --exclude .git | fzf --height 40% --reverse --border --prompt="Dirs ❯ " --preview 'ls -la {}' --preview-window=right:50%:wrap)
            else
                dir=$(find . -type d -not -path '*/.git/*' 2>/dev/null | fzf --height 40% --reverse --border --prompt="Dirs ❯ " --preview 'ls -la {}' --preview-window=right:50%:wrap)
            fi
            if [ -n "$dir" ]; then
                # Quote the path if it contains spaces or special characters
                printf -v quoted_dir '%q' "$dir"
                READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$quoted_dir${READLINE_LINE:$READLINE_POINT}"
                READLINE_POINT=$((READLINE_POINT + ${#quoted_dir}))
            fi
        }
        bind -x '"\C-g": __fzf_cd__'
    fi
fi

# Fuzzy delete: select multiple files/dirs to trash
fzfdel() {
    _require_cmd fzf || return 1
    _require_cmd trash || return 1

    local selected
    if command -v fd >/dev/null 2>&1; then
        selected=$(fd --hidden --exclude .git --exclude .Trash --exclude .local/share/Trash |
            fzf --multi --height 60% --reverse --border --prompt="Delete ❯ " \
                --header="TAB to select multiple, ENTER to confirm" \
                --preview '[[ -d {} ]] && ls -la {} || head -100 {}' \
                --preview-window=right:50%:wrap)
    else
        selected=$(find . -not -path '*/.git/*' -not -path '*/.Trash/*' -not -path '*/.local/share/Trash/*' 2>/dev/null |
            fzf --multi --height 60% --reverse --border --prompt="Delete ❯ " \
                --header="TAB to select multiple, ENTER to confirm" \
                --preview '[[ -d {} ]] && ls -la {} || head -100 {}' \
                --preview-window=right:50%:wrap)
    fi

    if [ -n "$selected" ]; then
        local count=$(echo "$selected" | wc -l)
        echo "Selected $count item(s) for deletion:"
        echo "$selected"
        echo ""
        read -p "Move these to trash? (y/N): " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            echo "$selected" | while IFS= read -r file; do
                trash -v "$file"
            done
            echo "Done. Use 'trash-list' to view or 'trash-restore' to recover."
        else
            echo "Cancelled."
        fi
    else
        echo "No files selected."
    fi
}

eval "$(starship init bash)"
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
    alias cd='z'
fi
