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

# Pre-cache sudo credentials so password prompts don't interrupt spinners.
# Usage: _sudo_auth || return 1
_sudo_auth() {
    if ! sudo -n true 2>/dev/null; then
        echo -e "  ${_ARROW} sudo authentication required"
        sudo -v || return 1
    fi
}

# =========================
# UI helpers (spinner, status messages)
# =========================
# Symbols
_TICK='\033[0;32m\033[1m✓\033[0m'
_CROSS='\033[0;31m\033[1m✗\033[0m'
_ARROW='\033[0;36m\033[1m›\033[0m'
_WARN_SYM='\033[1;33m\033[1m!\033[0m'
_DIM='\033[2m'
_BOLD='\033[1m'
_CYAN='\033[0;36m'
_GREEN='\033[0;32m'
_RED='\033[0;31m'
_YELLOW='\033[1;33m'
_RC='\033[0m'

_ui_ok()   { echo -e "       ${_TICK} $*"; }
_ui_fail() { echo -e "       ${_CROSS} $*"; }
_ui_info() { echo -e "       ${_ARROW} $*"; }
_ui_warn() { echo -e "       ${_WARN_SYM} ${_YELLOW}$*${_RC}"; }

_UI_STEP=0
_UI_TOTAL=0
_ui_step() {
    ((_UI_STEP++)) || true
    echo ""
    echo -e "  ${_BOLD}${_CYAN}[${_UI_STEP}/${_UI_TOTAL}]${_RC} ${_BOLD}$*${_RC}"
}

# Spinner: braille dot animation running in background
__spinner_pid=""
_start_spinner() {
    local msg="$1"
    {
        local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
        local i=0
        while true; do
            printf "\r       \033[0;36m%s\033[0m \033[2m%s\033[0m" "${frames[$i]}" "$msg"
            i=$(( (i + 1) % ${#frames[@]} ))
            sleep 0.08
        done
    } &
    __spinner_pid=$!
}

_stop_spinner() {
    if [[ -n "$__spinner_pid" ]]; then
        kill "$__spinner_pid" 2>/dev/null || true
        wait "$__spinner_pid" 2>/dev/null || true
        __spinner_pid=""
    fi
    printf "\r\033[K"
}

# Run a command silently with a spinner, logging output to file.
# Usage: _run_with_spinner "message" command [args...]
# On success: prints green tick + message. On failure: prints red cross + log hint.
_run_with_spinner() {
    local msg="$1"
    shift
    local log_file="${_UPDATESYS_LOG:-/tmp/updatesys-$$.log}"

    _start_spinner "$msg"

    local rc=0
    echo "=== $(date '+%H:%M:%S') :: $msg ===" >> "$log_file"
    "$@" >> "$log_file" 2>&1 || rc=$?

    _stop_spinner

    if [[ $rc -eq 0 ]]; then
        _ui_ok "$msg"
    else
        _ui_fail "$msg"
        echo -e "       ${_DIM}See log: ${log_file}${_RC}"
    fi

    return "$rc"
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
    export _UPDATESYS_LOG
    _UPDATESYS_LOG=$(mktemp /tmp/installpkg-XXXXXX.log)
    trap '_stop_spinner; trap - INT RETURN; return 130' INT
    trap '_stop_spinner; trap - INT RETURN' RETURN

    local selected pkg_list pkg_count

    echo ""
    echo -e "  ${_BOLD}Install Packages${_RC} ${_DIM}| ${_DISTRO} | log: ${_UPDATESYS_LOG}${_RC}"
    echo -e "  ${_DIM}──────────────────────────────────────${_RC}"
    _sudo_auth || return 1

    _UI_STEP=0 _UI_TOTAL=2

    # Step 1: Select packages
    _ui_step "Select packages"
    case "$_DISTRO" in
    debian)
        selected=$(apt-cache pkgnames 2>/dev/null | sort | fzf --multi --header="Type to search available packages (TAB for multi-select)" \
            --preview 'apt show {1} 2>/dev/null | head -40' \
            --preview-window=right:60%:wrap)
        ;;
    arch)
        if command -v yay >/dev/null 2>&1; then
            selected=$(yay -Slq 2>/dev/null | fzf --multi --header="Type to search repos + AUR (TAB for multi-select)" \
                --preview 'yay -Si {1} 2>/dev/null | head -40' \
                --preview-window=right:60%:wrap)
        else
            selected=$(pacman -Slq 2>/dev/null | fzf --multi --header="Type to search repos (TAB for multi-select)" \
                --preview 'pacman -Si {1} 2>/dev/null | head -40' \
                --preview-window=right:60%:wrap)
        fi
        ;;
    *)
        _ui_fail "Unsupported distribution. Supported: Debian/Ubuntu and Arch."
        return 1
        ;;
    esac

    if [ -z "$selected" ]; then
        _ui_info "No packages selected"
        return 0
    fi

    pkg_list=$(echo "$selected" | tr '\n' ' ')
    pkg_count=$(echo "$selected" | wc -l)
    _ui_ok "Selected $pkg_count package(s)"

    # Step 2: Install
    _ui_step "Installing packages"
    local -a pkg_array
    mapfile -t pkg_array <<< "$selected"
    case "$_DISTRO" in
    debian)
        if command -v nala >/dev/null 2>&1; then
            _run_with_spinner "Installing $pkg_count package(s)" sudo nala install -y "${pkg_array[@]}" || return 1
        else
            _run_with_spinner "Installing $pkg_count package(s)" sudo apt install -y "${pkg_array[@]}" || return 1
        fi
        ;;
    arch)
        if command -v yay >/dev/null 2>&1; then
            _run_with_spinner "Installing $pkg_count package(s)" yay -S --noconfirm "${pkg_array[@]}" || return 1
        else
            _run_with_spinner "Installing $pkg_count package(s)" sudo pacman -S --noconfirm "${pkg_array[@]}" || return 1
        fi
        ;;
    esac

    echo ""
    echo -e "  ${_GREEN}${_BOLD}  Done!${_RC} ${_DIM}Installed: ${pkg_list}${_RC}"
    echo ""
}

# Removepkg: interactive package removal (fzf-based)
removepkg() {
    _require_cmd fzf || return 1
    _detect_distro
    export _UPDATESYS_LOG
    _UPDATESYS_LOG=$(mktemp /tmp/removepkg-XXXXXX.log)
    trap '_stop_spinner; trap - INT RETURN; return 130' INT
    trap '_stop_spinner; trap - INT RETURN' RETURN

    local selected pkg_list pkg_count

    echo ""
    echo -e "  ${_BOLD}Remove Packages${_RC} ${_DIM}| ${_DISTRO} | log: ${_UPDATESYS_LOG}${_RC}"
    echo -e "  ${_DIM}──────────────────────────────────────${_RC}"
    _sudo_auth || return 1

    _UI_STEP=0 _UI_TOTAL=2

    # Step 1: Select packages
    _ui_step "Select packages"
    case "$_DISTRO" in
    debian)
        selected=$(dpkg --get-selections 2>/dev/null | command grep -v deinstall | cut -f1 | sort | fzf --multi --header="Type to filter installed packages (TAB for multi-select)" \
            --preview 'apt show {1} 2>/dev/null | head -20; echo "\n--- Reverse deps ---"; apt rdepends {1} 2>/dev/null | head -10' \
            --preview-window=right:60%:wrap)
        ;;
    arch)
        selected=$(pacman -Qq 2>/dev/null | fzf --multi --header="Type to filter installed packages (TAB for multi-select)" \
            --preview 'pacman -Qi {1} 2>/dev/null | head -20; echo "\n--- Reverse deps ---"; pactree -r {1} 2>/dev/null | head -10' \
            --preview-window=right:60%:wrap)
        ;;
    *)
        _ui_fail "Unsupported distribution. Supported: Debian/Ubuntu and Arch."
        return 1
        ;;
    esac

    if [ -z "$selected" ]; then
        _ui_info "No packages selected"
        return 0
    fi

    pkg_list=$(echo "$selected" | tr '\n' ' ')
    pkg_count=$(echo "$selected" | wc -l)
    _ui_ok "Selected $pkg_count package(s)"

    # Step 2: Remove
    _ui_step "Removing packages"
    local -a pkg_array
    mapfile -t pkg_array <<< "$selected"
    case "$_DISTRO" in
    debian)
        _run_with_spinner "Removing $pkg_count package(s)" sudo apt remove -y "${pkg_array[@]}" || return 1
        ;;
    arch)
        _run_with_spinner "Removing $pkg_count package(s)" sudo pacman -R --noconfirm "${pkg_array[@]}" || return 1
        ;;
    esac

    echo ""
    echo -e "  ${_GREEN}${_BOLD}  Done!${_RC} ${_DIM}Removed: ${pkg_list}${_RC}"
    echo ""
}

# Updatepkg: interactive package update (fzf-based)
updatepkg() {
    _require_cmd fzf || return 1
    _detect_distro
    export _UPDATESYS_LOG
    _UPDATESYS_LOG=$(mktemp /tmp/updatepkg-XXXXXX.log)
    trap '_stop_spinner; trap - INT RETURN; return 130' INT
    trap '_stop_spinner; trap - INT RETURN' RETURN

    local upgradable selected pkg_list pkg_count

    echo ""
    echo -e "  ${_BOLD}Update Packages${_RC} ${_DIM}| ${_DISTRO} | log: ${_UPDATESYS_LOG}${_RC}"
    echo -e "  ${_DIM}──────────────────────────────────────${_RC}"
    _sudo_auth || return 1

    _UI_STEP=0 _UI_TOTAL=3

    # Step 1: Sync package database
    _ui_step "Syncing package database"
    case "$_DISTRO" in
    debian)
        if command -v nala >/dev/null 2>&1; then
            _run_with_spinner "Updating package lists" sudo nala update || return 1
        else
            _run_with_spinner "Updating package lists" sudo apt update || return 1
        fi
        upgradable=$(apt list --upgradable 2>/dev/null | command grep -v "^Listing" | cut -d/ -f1)
        ;;
    arch)
        _run_with_spinner "Syncing package database" sudo pacman -Sy || return 1
        if command -v yay >/dev/null 2>&1; then
            upgradable=$(yay -Qu 2>/dev/null | awk '{print $1}')
        else
            upgradable=$(pacman -Qu 2>/dev/null | awk '{print $1}')
        fi
        ;;
    *)
        _ui_fail "Unsupported distribution. Supported: Debian/Ubuntu and Arch."
        return 1
        ;;
    esac

    if [ -z "$upgradable" ]; then
        _ui_ok "System already up to date"
        echo ""
        return 0
    fi

    local avail_count
    avail_count=$(echo "$upgradable" | wc -l)
    _ui_ok "$avail_count update(s) available"

    # Step 2: Select packages
    _ui_step "Select packages to update"
    case "$_DISTRO" in
    debian)
        selected=$(echo "$upgradable" | fzf --multi --header="Select packages to update (TAB for multi-select)" \
            --preview 'apt show {1} 2>/dev/null | head -40' \
            --preview-window=right:60%:wrap)
        ;;
    arch)
        if command -v yay >/dev/null 2>&1; then
            selected=$(echo "$upgradable" | fzf --multi --header="Select packages to update (TAB for multi-select)" \
                --preview 'yay -Si {1} 2>/dev/null | head -40' \
                --preview-window=right:60%:wrap)
        else
            selected=$(echo "$upgradable" | fzf --multi --header="Select packages to update (TAB for multi-select)" \
                --preview 'pacman -Si {1} 2>/dev/null | head -40' \
                --preview-window=right:60%:wrap)
        fi
        ;;
    esac

    if [ -z "$selected" ]; then
        _ui_info "No packages selected"
        return 0
    fi

    pkg_list=$(echo "$selected" | tr '\n' ' ')
    pkg_count=$(echo "$selected" | wc -l)
    _ui_ok "Selected $pkg_count package(s)"

    # Step 3: Update
    _ui_step "Updating packages"
    local -a pkg_array
    mapfile -t pkg_array <<< "$selected"
    case "$_DISTRO" in
    debian)
        if command -v nala >/dev/null 2>&1; then
            _run_with_spinner "Updating $pkg_count package(s)" sudo nala install -y "${pkg_array[@]}" || return 1
        else
            _run_with_spinner "Updating $pkg_count package(s)" sudo apt install -y "${pkg_array[@]}" || return 1
        fi
        ;;
    arch)
        if command -v yay >/dev/null 2>&1; then
            _run_with_spinner "Updating $pkg_count package(s)" yay -S --noconfirm "${pkg_array[@]}" || return 1
        else
            _run_with_spinner "Updating $pkg_count package(s)" sudo pacman -S --noconfirm "${pkg_array[@]}" || return 1
        fi
        ;;
    esac

    echo ""
    echo -e "  ${_GREEN}${_BOLD}  Done!${_RC} ${_DIM}Updated: ${pkg_list}${_RC}"
    echo ""
}

# Helper: optimise mirrors (arch/debian only)
_optimize_mirrors() {
    local log_file="${_UPDATESYS_LOG:-/tmp/updatesys-$$.log}"
    case "$1" in
    arch)
        if command -v rate-mirrors >/dev/null 2>&1; then
            if [ -s "/etc/pacman.d/mirrorlist" ]; then
                sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
            fi
            _start_spinner "Optimising mirrors (rate-mirrors)"
            local rc=0
            echo "=== $(date '+%H:%M:%S') :: rate-mirrors ===" >> "$log_file"
            sudo rate-mirrors --top-mirrors-number-to-retest=5 --disable-comments --save /etc/pacman.d/mirrorlist --allow-root arch >> "$log_file" 2>&1 || rc=$?
            _stop_spinner
            if [ $rc -ne 0 ] || [ ! -s "/etc/pacman.d/mirrorlist" ]; then
                _ui_warn "Mirror optimisation failed, restoring backup"
                sudo cp /etc/pacman.d/mirrorlist.bak /etc/pacman.d/mirrorlist
            else
                _ui_ok "Mirrors optimised"
            fi
        else
            _ui_info "rate-mirrors not installed, skipping"
        fi
        ;;
    debian)
        if command -v nala >/dev/null 2>&1; then
            if [ -f "/etc/apt/sources.list.d/nala-sources.list" ]; then
                sudo cp /etc/apt/sources.list.d/nala-sources.list /etc/apt/sources.list.d/nala-sources.list.bak
            fi
            _start_spinner "Optimising mirrors (nala fetch)"
            local rc=0
            echo "=== $(date '+%H:%M:%S') :: nala fetch ===" >> "$log_file"
            sudo nala fetch --auto -y >> "$log_file" 2>&1 || rc=$?
            _stop_spinner
            if [ $rc -ne 0 ]; then
                _ui_warn "Mirror optimisation failed, restoring backup"
                if [ -f "/etc/apt/sources.list.d/nala-sources.list.bak" ]; then
                    sudo cp /etc/apt/sources.list.d/nala-sources.list.bak /etc/apt/sources.list.d/nala-sources.list
                fi
            else
                _ui_ok "Mirrors optimised"
            fi
        else
            _ui_info "nala not installed, skipping mirror optimisation"
        fi
        ;;
    esac
}

# Helper: update flatpak packages if flatpak is installed
_update_flatpaks() {
    if command -v flatpak >/dev/null 2>&1; then
        _run_with_spinner "Updating flatpak packages" flatpak update -y
    fi
}

# Updatesys: update/upgrade system packages with optional cleanup
# Supports: Debian/Ubuntu, Arch, Fedora, openSUSE, Alpine, Void, Solus
# Output uses spinners and step headers for a clean, readable UI.
# All command output is redirected to a log file; errors surface clearly.
updatesys() {
    _detect_distro
    local start_time=$(date +%s)
    local packages_updated=0
    export _UPDATESYS_LOG
    _UPDATESYS_LOG=$(mktemp /tmp/updatesys-XXXXXX.log)

    # Cleanup spinner on Ctrl+C or unexpected exit
    trap '_stop_spinner; echo -e "\n       ${_CROSS} Interrupted"; echo -e "       ${_DIM}Log: ${_UPDATESYS_LOG}${_RC}"; trap - INT RETURN; return 130' INT
    trap '_stop_spinner; trap - INT RETURN' RETURN

    # Determine distro label and package manager
    local distro_label packager_label
    case "$_DISTRO" in
    debian)   distro_label="Debian/Ubuntu"; packager_label="apt"
              command -v nala >/dev/null 2>&1 && packager_label="nala" ;;
    arch)     distro_label="Arch Linux"; packager_label="pacman"
              command -v yay >/dev/null 2>&1 && packager_label="yay" ;;
    fedora)   distro_label="Fedora/RHEL"; packager_label="dnf" ;;
    opensuse) distro_label="openSUSE"; packager_label="zypper" ;;
    alpine)   distro_label="Alpine"; packager_label="apk" ;;
    void)     distro_label="Void Linux"; packager_label="xbps" ;;
    solus)    distro_label="Solus"; packager_label="eopkg" ;;
    *)
        _ui_fail "Unknown distribution"
        _ui_info "Supported: Debian/Ubuntu, Arch, Fedora, openSUSE, Alpine, Void, Solus"
        return 1
        ;;
    esac

    # Header
    echo ""
    echo -e "  ${_BOLD}System Update${_RC} ${_DIM}| ${distro_label} | ${packager_label} | log: ${_UPDATESYS_LOG}${_RC}"
    echo -e "  ${_DIM}──────────────────────────────────────${_RC}"
    _sudo_auth || return 1

    # Set step count based on distro
    _UI_STEP=0
    case "$_DISTRO" in
    debian) _UI_TOTAL=5 ;; # mirrors, sync, upgrade, cleanup, flatpaks
    arch)   _UI_TOTAL=6 ;; # mirrors, keyring, sync, upgrade (official+AUR), cleanup, flatpaks
    *)      _UI_TOTAL=3 ;; # sync, upgrade, flatpaks
    esac

    case "$_DISTRO" in
    debian)
        # Step 1: Optimise mirrors
        _ui_step "Optimising mirrors"
        _optimize_mirrors debian

        # Step 2: Sync package lists
        _ui_step "Syncing package lists"
        if [ "$packager_label" = "nala" ]; then
            _run_with_spinner "Updating package lists" sudo nala update || return 1
        else
            _run_with_spinner "Updating package lists" sudo apt -o Acquire::Queue-Mode=host -o APT::Acquire::Retries=3 update || return 1
        fi

        # Check for available updates
        local upgradable_list=$(apt list --upgradable 2>/dev/null | command grep -v "^Listing")
        packages_updated=$(echo "$upgradable_list" | command grep -c '^' 2>/dev/null || echo 0)

        if [ "$packages_updated" -eq 0 ]; then
            _ui_info "No updates available"
        fi

        # Step 3: Upgrade packages
        _ui_step "Upgrading packages"
        if [ "$packages_updated" -eq 0 ]; then
            _ui_ok "System already up to date"
        elif [ "$packager_label" = "nala" ]; then
            _run_with_spinner "Upgrading $packages_updated packages" sudo nala upgrade -y || return 1
        else
            _run_with_spinner "Upgrading $packages_updated packages" sudo apt -o Acquire::Queue-Mode=host -o APT::Acquire::Retries=3 upgrade -y || return 1
        fi

        # Step 4: Cleanup
        _ui_step "Cleaning up"
        if [ "$packager_label" = "nala" ]; then
            _run_with_spinner "Removing unused packages" sudo nala autopurge -y
            _run_with_spinner "Cleaning package cache" sudo nala clean
        else
            _run_with_spinner "Removing unused packages" sudo apt autoremove -y
            _run_with_spinner "Cleaning package cache" sudo apt autoclean
        fi

        # Step 5: Flatpaks
        _ui_step "Updating flatpaks"
        _update_flatpaks
        if ! command -v flatpak >/dev/null 2>&1; then
            _ui_info "Flatpak not installed, skipping"
        fi

        # Reboot check
        if [ -f /var/run/reboot-required ]; then
            echo ""
            _ui_warn "System reboot is required to complete the upgrade"
        fi
        ;;

    arch)
        if ! command -v yay >/dev/null 2>&1; then
            _ui_fail "yay is required but not installed"
            _ui_info "Install yay first: https://github.com/Jguer/yay"
            return 1
        fi

        # Step 1: Optimise mirrors
        _ui_step "Optimising mirrors"
        _optimize_mirrors arch

        # Step 2: Update keyring
        _ui_step "Updating keyring"
        _run_with_spinner "Updating archlinux-keyring" sudo pacman -Sy --noconfirm --needed archlinux-keyring || return 1

        # Check for available updates
        local upgradable_list=$(yay -Qu 2>/dev/null)
        packages_updated=$(echo "$upgradable_list" | command grep -c '^' 2>/dev/null || echo 0)

        # Step 3: Check updates
        _ui_step "Checking for updates"
        if [ "$packages_updated" -eq 0 ]; then
            _ui_ok "System already up to date"
        else
            _ui_ok "$packages_updated updates available"

            if ! command grep -q "^ParallelDownloads" /etc/pacman.conf 2>/dev/null; then
                _ui_info "Tip: Enable ParallelDownloads in /etc/pacman.conf for faster updates"
            fi
        fi

        # Step 4: Upgrade packages
        _ui_step "Upgrading packages"
        if [ "$packages_updated" -eq 0 ]; then
            _ui_ok "Nothing to upgrade"
        else
            _run_with_spinner "Upgrading official packages" sudo pacman -Su --noconfirm || return 1

            # AUR packages
            local aur_updates
            aur_updates=$(yay -Qua 2>/dev/null)
            if [ -n "$aur_updates" ]; then
                # Clean stale yay build cache for listed packages
                local aur_list
                aur_list=$(echo "$aur_updates" | awk '{print $1}')
                for pkg in $aur_list; do
                    local cache_dir="$HOME/.cache/yay/$pkg"
                    if [ -d "$cache_dir" ]; then
                        rm -rf "$cache_dir" 2>/dev/null || true
                    fi
                done

                local aur_count aur_rc=0
                aur_count=$(echo "$aur_updates" | wc -l)
                _start_spinner "Upgrading $aur_count AUR packages"
                echo "=== $(date '+%H:%M:%S') :: yay -Sua ===" >> "$_UPDATESYS_LOG"
                yay -Sua --noconfirm >> "$_UPDATESYS_LOG" 2>&1 || aur_rc=$?
                _stop_spinner
                if [ $aur_rc -eq 0 ]; then
                    _ui_ok "Upgraded $aur_count AUR packages"
                else
                    _ui_warn "Some AUR packages may have failed (see log)"
                fi
            else
                _ui_ok "No AUR updates"
            fi
        fi

        # Step 5: Cleanup
        _ui_step "Cleaning up"
        _run_with_spinner "Cleaning package cache" bash -c 'yay -Sc --noconfirm 2>/dev/null; paccache -rk 2 2>/dev/null; true'

        local orphans=$(pacman -Qtdq 2>/dev/null)
        if [ -n "$orphans" ]; then
            _start_spinner "Removing orphaned packages"
            echo "$orphans" | sudo pacman -Rns --noconfirm - >> "$_UPDATESYS_LOG" 2>&1
            local rc=$?
            _stop_spinner
            if [ $rc -eq 0 ]; then
                _ui_ok "Orphaned packages removed"
            else
                _ui_warn "Some orphans could not be removed"
            fi
        else
            _ui_ok "No orphaned packages"
        fi

        # Step 6: Flatpaks
        _ui_step "Updating flatpaks"
        _update_flatpaks
        if ! command -v flatpak >/dev/null 2>&1; then
            _ui_info "Flatpak not installed, skipping"
        fi
        ;;

    fedora)
        _ui_step "Upgrading packages"
        _run_with_spinner "Updating system packages" sudo dnf update -y || return 1

        _ui_step "Cleaning up"
        _run_with_spinner "Removing unused packages" sudo dnf autoremove -y
        _run_with_spinner "Cleaning package cache" sudo dnf clean all

        _ui_step "Updating flatpaks"
        _update_flatpaks
        if ! command -v flatpak >/dev/null 2>&1; then
            _ui_info "Flatpak not installed, skipping"
        fi
        ;;

    opensuse)
        _ui_step "Syncing repositories"
        _run_with_spinner "Refreshing repositories" sudo zypper ref || return 1

        _ui_step "Upgrading packages"
        _run_with_spinner "Performing distribution upgrade" sudo zypper --non-interactive dup || return 1
        _run_with_spinner "Cleaning package cache" sudo zypper clean

        _ui_step "Updating flatpaks"
        _update_flatpaks
        if ! command -v flatpak >/dev/null 2>&1; then
            _ui_info "Flatpak not installed, skipping"
        fi
        ;;

    alpine)
        _ui_step "Syncing repositories"
        _run_with_spinner "Updating package index" sudo apk update || return 1

        _ui_step "Upgrading packages"
        _run_with_spinner "Upgrading packages" sudo apk upgrade || return 1

        _ui_step "Updating flatpaks"
        _update_flatpaks
        if ! command -v flatpak >/dev/null 2>&1; then
            _ui_info "Flatpak not installed, skipping"
        fi
        ;;

    void)
        _ui_step "Syncing repositories"
        _run_with_spinner "Syncing repositories" sudo xbps-install -S || return 1

        _ui_step "Upgrading packages"
        _run_with_spinner "Upgrading packages" sudo xbps-install -yu || return 1

        _ui_step "Updating flatpaks"
        _update_flatpaks
        if ! command -v flatpak >/dev/null 2>&1; then
            _ui_info "Flatpak not installed, skipping"
        fi
        ;;

    solus)
        _ui_step "Syncing repositories"
        _run_with_spinner "Updating repository" sudo eopkg -y update-repo || return 1

        _ui_step "Upgrading packages"
        _run_with_spinner "Upgrading packages" sudo eopkg -y upgrade || return 1

        _ui_step "Updating flatpaks"
        _update_flatpaks
        if ! command -v flatpak >/dev/null 2>&1; then
            _ui_info "Flatpak not installed, skipping"
        fi
        ;;
    esac

    # Summary
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))

    echo ""
    echo -e "  ${_GREEN}${_BOLD}──────────────────────────────────────${_RC}"
    echo -e "  ${_GREEN}${_BOLD}  All done!${_RC}  ${_DIM}Completed in ${minutes}m ${seconds}s${_RC}"
    echo -e "  ${_GREEN}${_BOLD}──────────────────────────────────────${_RC}"
    echo ""
    if [ "$packages_updated" -gt 0 ]; then
        echo -e "    ${_TICK} ${_DIM}Packages processed: ${packages_updated}${_RC}"
    fi
    echo -e "    ${_TICK} ${_DIM}Kernel: $(uname -r)${_RC}"
    echo -e "    ${_TICK} ${_DIM}Uptime: $(uptime -p)${_RC}"

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
        echo -e "    ${_WARN_SYM} ${_YELLOW}Pending updates: $updates${_RC}"
    else
        echo -e "    ${_TICK} ${_GREEN}System is up to date${_RC}"
    fi
    echo -e "    ${_DIM}Full log: ${_UPDATESYS_LOG}${_RC}"
    echo ""
}

# Cleansys: perform system cleanup (cache, logs, orphans, trash)
# Supports: Debian/Ubuntu (nala/apt), Arch (yay/pacman)
cleansys() {
    _detect_distro
    local start_time=$(date +%s)
    export _UPDATESYS_LOG
    _UPDATESYS_LOG=$(mktemp /tmp/cleansys-XXXXXX.log)
    trap '_stop_spinner; trap - INT RETURN; return 130' INT
    trap '_stop_spinner; trap - INT RETURN' RETURN

    # Get disk usage before cleanup
    local disk_before
    disk_before=$(df --output=used / 2>/dev/null | tail -1 | tr -d ' ')

    echo ""
    echo -e "  ${_BOLD}System Cleanup${_RC} ${_DIM}| ${_DISTRO} | log: ${_UPDATESYS_LOG}${_RC}"
    echo -e "  ${_DIM}──────────────────────────────────────${_RC}"
    _sudo_auth || return 1

    _UI_STEP=0 _UI_TOTAL=5

    # Step 1: Package manager cleanup
    _ui_step "Package manager cache"
    case "$_DISTRO" in
    debian)
        if command -v nala >/dev/null 2>&1; then
            _run_with_spinner "Cleaning package cache" sudo nala clean
            _run_with_spinner "Removing unused packages" sudo nala autoremove -y
        else
            _run_with_spinner "Cleaning package cache" sudo apt-get clean
            _run_with_spinner "Removing unused packages" sudo apt-get autoremove -y
        fi
        ;;
    arch)
        if command -v yay >/dev/null 2>&1; then
            _run_with_spinner "Cleaning package cache" yay -Sc --noconfirm
        else
            _run_with_spinner "Cleaning package cache" sudo pacman -Sc --noconfirm
        fi

        local orphans=$(pacman -Qtdq 2>/dev/null)
        if [ -n "$orphans" ]; then
            _start_spinner "Removing orphaned packages"
            echo "$orphans" | sudo pacman -Rns --noconfirm - >> "$_UPDATESYS_LOG" 2>&1
            local rc=$?
            _stop_spinner
            if [ $rc -eq 0 ]; then
                _ui_ok "Orphaned packages removed"
            else
                _ui_warn "Some orphans could not be removed"
            fi
        else
            _ui_ok "No orphaned packages"
        fi

        _run_with_spinner "Pruning old package versions" bash -c 'paccache -rk 2 2>/dev/null; true'
        ;;
    *)
        _ui_fail "Unsupported distribution. Supported: Debian/Ubuntu and Arch."
        return 1
        ;;
    esac

    # Step 2: Temporary files
    _ui_step "Temporary files"
    _run_with_spinner "Cleaning /tmp and /var/tmp" bash -c '
        [ -d /var/tmp ] && sudo find /var/tmp -type f -atime +5 -delete 2>/dev/null
        [ -d /tmp ] && sudo find /tmp -type f -atime +5 -delete 2>/dev/null
        true'

    # Step 3: Logs
    _ui_step "System logs"
    _run_with_spinner "Truncating old log files" bash -c '
        [ -d /var/log ] && sudo find /var/log -type f -name "*.log" -exec truncate -s 0 {} \; 2>/dev/null
        true'
    if command -v journalctl >/dev/null 2>&1; then
        _run_with_spinner "Vacuuming journald logs (keeping 3 days)" sudo journalctl --vacuum-time=3d
    fi

    # Step 4: User cache and trash
    _ui_step "User cache and trash"
    _run_with_spinner "Cleaning user cache (files older than 5 days)" bash -c "
        [ -d \"$HOME/.cache\" ] && find \"$HOME/.cache/\" -type f -atime +5 -delete 2>/dev/null
        true"
    _run_with_spinner "Emptying trash" bash -c "
        [ -d \"$HOME/.local/share/Trash\" ] && find \"$HOME/.local/share/Trash\" -mindepth 1 -delete 2>/dev/null
        true"

    # Step 5: Flatpak cleanup
    _ui_step "Flatpak cleanup"
    if command -v flatpak >/dev/null 2>&1; then
        _run_with_spinner "Removing unused flatpak runtimes" bash -c 'flatpak uninstall --unused -y 2>/dev/null; true'
    else
        _ui_info "Flatpak not installed, skipping"
    fi

    # Summary
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local disk_after
    disk_after=$(df --output=used / 2>/dev/null | tail -1 | tr -d ' ')
    local freed=0
    if [ -n "$disk_before" ] && [ -n "$disk_after" ] && [ "$disk_before" -gt "$disk_after" ]; then
        freed=$(( (disk_before - disk_after) / 1024 ))
    fi

    echo ""
    echo -e "  ${_GREEN}${_BOLD}──────────────────────────────────────${_RC}"
    echo -e "  ${_GREEN}${_BOLD}  All clean!${_RC}  ${_DIM}Completed in ${duration}s${_RC}"
    echo -e "  ${_GREEN}${_BOLD}──────────────────────────────────────${_RC}"
    echo ""
    if [ "$freed" -gt 0 ]; then
        echo -e "    ${_TICK} ${_DIM}Freed: ~${freed}MB${_RC}"
    fi
    local disk_info
    disk_info=$(df -h / | tail -1 | awk '{print $3 " used / " $2 " total (" $5 ")"}')
    echo -e "    ${_TICK} ${_DIM}Disk: ${disk_info}${_RC}"
    echo -e "    ${_DIM}Full log: ${_UPDATESYS_LOG}${_RC}"
    echo ""
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
