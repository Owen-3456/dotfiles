#!/usr/bin/env zsh

# =========================
# Core: environment & shell
# =========================

# Source global definitions
[[ -f /etc/zshrc ]] && . /etc/zshrc
[[ -f /etc/zsh/zshrc ]] && . /etc/zsh/zshrc

# History configuration
export HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
export HISTSIZE=10000
export SAVEHIST=10000
setopt SHARE_HISTORY         # share history across all sessions (implies INC_APPEND_HISTORY)
setopt HIST_IGNORE_DUPS      # ignore consecutive duplicates
setopt HIST_IGNORE_ALL_DUPS  # remove older duplicate entries
setopt HIST_IGNORE_SPACE     # ignore commands starting with space
setopt HIST_REDUCE_BLANKS    # remove superfluous blanks
setopt HIST_FIND_NO_DUPS     # don't display duplicates when searching history

# Interactive shell options
if [[ -o interactive ]]; then
    setopt CORRECT             # spelling correction for commands (like cdspell)
    setopt GLOBSTAR_SHORT      # ** for recursive globbing (like bash globstar)
    setopt INTERACTIVE_COMMENTS # allow comments in interactive shell
    setopt NO_BEEP             # visible bell equivalent — just disable beep
    stty -ixon                 # disable Ctrl+S/Ctrl+Q flow control
fi

# XDG Base Directories
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Misc environment
export EDITOR=nano
export VISUAL="code -w"
export BAT_THEME="ansi"  # Consistent colors with terminal theme

# Path setup (idempotent additions)
typeset -U path  # unique entries only
path+=(
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    /var/lib/flatpak/exports/bin
    "$HOME/.local/share/flatpak/exports/bin"
)
export PATH

# =========================
# Zinit plugin manager
# =========================
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
    echo "Installing zinit..."
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" 2>/dev/null
fi
source "${ZINIT_HOME}/zinit.zsh"

# =========================
# Completion
# =========================
autoload -Uz compinit
[[ -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh" ]] || mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"

# Case-insensitive completion (like bash set completion-ignore-case on)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
# Show all completions immediately (like bash show-all-if-ambiguous)
setopt NO_LIST_AMBIGUOUS
# Group completions by type
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%d%b'
# Use menu selection
zstyle ':completion:*' menu select

# Zinit plugins
zinit light zsh-users/zsh-completions               # extra completion definitions
zinit light zsh-users/zsh-autosuggestions            # fish-like autosuggestions
zinit light Aloxaf/fzf-tab                           # fzf-based tab completion
zinit light hlissner/zsh-autopair                    # auto-close brackets, quotes, parens
zinit light MichaelAquilina/zsh-you-should-use       # reminds you of existing aliases
zinit light MichaelAquilina/zsh-auto-notify          # desktop notifications for long commands
zinit light zdharma-continuum/history-search-multi-word  # better history search with highlighting
zinit light zdharma-continuum/fast-syntax-highlighting   # fast command syntax highlighting (must be last)

# zsh-autosuggestions configuration
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# zsh-auto-notify configuration - ignore interactive/long-running commands
export AUTO_NOTIFY_IGNORE=(
    "npm" "yarn" "pnpm" "bun" "deno"                    # Node package managers (interactive dev servers)
    "tmux" "screen" "byobu"                             # Terminal multiplexers  
    "ssh" "mosh" "telnet"                               # Remote connections
    "vi" "vim" "nvim" "nano" "emacs" "code"             # Editors
    "less" "more" "man" "tldr" "bat"                    # Pagers/viewers
    "htop" "btop" "top" "watch"                         # System monitors
    "python" "python3" "node" "irb" "ruby"              # REPLs
    "tig" "lazygit"                                     # Git interactive tools (git itself removed)
    "fzf" "ranger" "mc" "nnn" "lf"                      # File managers
    "music" "mpv" "vlc" "ffplay"                        # Media players
    "serve" "ytdl"                                      # Custom interactive functions
)

# fzf-tab configuration
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'if [[ -d $realpath ]]; then eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath; elif [[ -f $realpath ]]; then bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || cat $realpath; fi'

# FZF shell integration (provides Ctrl+R, Ctrl+T, Alt+C keybindings)
if (( $+commands[fzf] )); then
    eval "$(fzf --zsh)"
fi

# =========================
# Colors and pager settings
# =========================
export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# =========================
# Aliases
# =========================
# Core aliases
alias cp='cp -i'
alias mv='mv -i'
(( $+commands[trash] )) && alias rm='trash -v'
alias mkdir='mkdir -p'

# Enhanced ls variants using eza (with fallback to ls)
if (( $+commands[eza] )); then
    alias ls='eza --group-directories-first --icons --git'                          # compact, no hidden
    alias ll='eza -l --group-directories-first --icons --git'                       # long listing, no hidden
    alias la='eza -la --group-directories-first --icons --git'                      # long listing + hidden
    alias lt='eza -la --sort=modified --group-directories-first --icons --git'      # sort by modified time
    alias lk='eza -la --sort=size --group-directories-first --icons --git'          # sort by size
    alias lx='eza -la --sort=ext --group-directories-first --icons --git'           # sort by extension
    alias lr='eza -la --recurse --group-directories-first --icons --git'            # recursive
    alias lw='eza -a --group-directories-first --icons --git'                       # compact + hidden
    alias lf='eza -la --icons --git -f'                                             # files only
    alias ldir='eza -la --icons --git -D'                                           # directories only
    alias ltree='eza -la --tree --group-directories-first --icons --git'            # tree view
else
    alias ls='command ls --color=auto'                                        # compact, no hidden
    alias ll='command ls -lh --color=auto'                                    # long listing, no hidden
    alias la='command ls -lAh --color=auto'                                   # long listing + hidden
    alias lt='command ls -lAht --color=auto'                                  # sort by modified time
    alias lk='command ls -lAhS --color=auto'                                 # sort by size
    alias lx='command ls -lAhXB --color=auto'                                # sort by extension
    alias lr='command ls -lAhR --color=auto'                                 # recursive
    alias lw='command ls -xA --color=auto'                                   # compact + hidden
    alias lf="command ls -lAh --color=auto | command grep -v '^d'"           # files only
    alias ldir="command ls -la --color=auto | command grep '^d'"             # directories only
fi
(( $+commands[btop] )) && alias top='btop'
alias wget='wget --show-progress --progress=bar:force:noscroll'
alias cls='clear'

# Bat aliases for syntax highlighting
if (( $+commands[bat] )); then
    alias cat='bat --style=plain --paging=never'
    alias less='bat --style=full --paging=always'
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# Grep: always use color (ripgrep available as 'rg')
alias grep='/usr/bin/grep --color=auto'

# System aliases
alias reboot='sudo shutdown -r now'
alias reload='exec zsh'

# Git functions (more flexible than aliases)
gl() {
    git log --oneline --graph --decorate --all --color=always "$@" | less -R
}

gs() {
    git -c color.status=always status --short --branch "$@"
}

# Utility aliases
linutil() {
    echo "This will download and run a remote script from https://christitus.com/linux"
    read "ans?Continue? (y/N): "
    if [[ $ans =~ ^[Yy]$ ]]; then
        curl -fsSL https://christitus.com/linux | sh
    else
        echo "Cancelled."
    fi
}
alias checkcommand="whence -w"
alias openports='ss -tulnp'
alias myip="whatsmyip"
(( $+commands[xclip] )) && alias copy='xclip -selection clipboard'

# =========================
# Distro detection & package helpers
# =========================

# Detect the current Linux distribution family.
# Sets the global _DISTRO variable to one of:
#   debian, arch, fedora, opensuse, alpine, void, solus, unknown
_detect_distro() {
    [[ -n "$_DISTRO" ]] && return
    if [[ -f /etc/debian_version ]]; then
        _DISTRO="debian"
    elif [[ -f /etc/arch-release ]]; then
        _DISTRO="arch"
    elif [[ -f /etc/fedora-release ]] || [[ -f /etc/redhat-release ]]; then
        _DISTRO="fedora"
    elif [[ -f /etc/SuSE-release ]] || [[ -f /etc/SUSE-brand ]] || command grep -qi "suse\|opensuse" /etc/os-release 2>/dev/null; then
        _DISTRO="opensuse"
    elif [[ -f /etc/alpine-release ]]; then
        _DISTRO="alpine"
    elif [[ -d /run/runit ]] || (( $+commands[xbps-install] )); then
        _DISTRO="void"
    elif (( $+commands[eopkg] )); then
        _DISTRO="solus"
    else
        _DISTRO="unknown"
    fi
}

# Install one or more packages using the appropriate package manager.
# Usage: _pkg_install pkg1 [pkg2 ...]
_pkg_install() {
    _detect_distro
    case "$_DISTRO" in
    debian)
        if (( $+commands[nala] )); then
            sudo nala install -y "$@"
        else
            sudo apt install -y "$@"
        fi
        ;;
    arch)
        if (( $+commands[yay] )); then
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
_require_pkg() {
    local desc="$1"
    shift
    local missing=()
    for pkg in "$@"; do
        (( $+commands[$pkg] )) || missing+=("$pkg")
    done
    [[ ${#missing[@]} -eq 0 ]] && return 0
    read "ans?${missing[*]} required for $desc. Install now? (y/N): "
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
    if ! (( $+commands[$1] )); then
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
_TICK='\033[0;32m\033[1m\u2713\033[0m'
_CROSS='\033[0;31m\033[1m\u2717\033[0m'
_ARROW='\033[0;36m\033[1m\u203a\033[0m'
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

# Spinner: rotating line animation running in background
__spinner_pid=""
_start_spinner() {
    local msg="$1"
    # Disable job control monitoring to prevent "terminated" messages
    setopt local_options no_monitor
    {
        local frames=('|' '/' '-' '\')
        local i=0
        while true; do
            printf "\r       \033[0;36m%s\033[0m \033[2m%s\033[0m" "${frames[$((i + 1))]}" "$msg"
            i=$(( (i + 1) % ${#frames[@]} ))
            sleep 0.08
        done
    } &
    __spinner_pid=$!
    disown
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
        if [[ -f "$archive" ]]; then
            case "$archive" in
            *.tar.bz2) tar xvjf "$archive" ;;
            *.tar.gz) tar xvzf "$archive" ;;
            *.tar.xz) tar xvJf "$archive" ;;
            *.tar.zst) tar --zstd -xvf "$archive" ;;
            *.bz2) bunzip2 "$archive" ;;
            *.rar) unrar x "$archive" ;;
            *.gz) gunzip "$archive" ;;
            *.xz) unxz "$archive" ;;
            *.zst) unzstd "$archive" ;;
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

# Cpg: copy a file then cd into the destination if it's a directory
cpg() {
    if [[ -d "$2" ]]; then
        command cp "$1" "$2" && builtin cd "$2"
    else
        command cp "$1" "$2"
    fi
}

# Mvg: move a file then cd into the destination if it's a directory
mvg() {
    if [[ -d "$2" ]]; then
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
    local dir_path=""
    for ((i = 0; i < levels; i++)); do
        dir_path="../$dir_path"
    done
    builtin cd "${dir_path%/}" || return 1
}

# Whatsmyip: show internal (active interface) and external IPv4
whatsmyip() {
    echo -n "Internal IP: "
    if (( $+commands[ip] )); then
        ip -4 route get 1 2>/dev/null | awk '{print $7; exit}'
    elif (( $+commands[hostname] )) && hostname -I >/dev/null 2>&1; then
        hostname -I | awk '{print $1}'
    else
        echo "Unknown"
    fi
    echo -n "External IP: "
    curl -4 -s --connect-timeout 5 --max-time 10 ifconfig.me || echo "Unknown"
}

# Portscan: quick TCP port scan on a target using nmap
portscan() {
    _require_cmd nmap || return 1
    if [[ -z "$1" ]]; then
        echo "Usage: portscan <host>"
        return 1
    fi
    nmap -p- "$1" 2>/dev/null
}

# Hb: upload a file to hastebin-like service and print URL
# Hastebin instance hosted by Chris Titus (https://christitus.com/)
# NOTE: This endpoint only supports HTTP. HTTPS is not available for this service.
hb() {
    _require_cmd jq || return 1
    _require_cmd curl || return 1
    if [[ $# -eq 0 ]]; then
        echo "No file path specified."
        return
    elif [[ ! -f "$1" ]]; then
        echo "File path does not exist."
        return
    fi
    local uri="http://bin.christitus.com/documents"
    local response
    response=$(curl -s --connect-timeout 5 --max-time 30 -X POST -d @"$1" "$uri")
    if [[ $? -eq 0 ]] && [[ -n "$response" ]]; then
        local hasteKey
        hasteKey=$(echo "$response" | jq -r '.key' 2>/dev/null)
        if [[ -z "$hasteKey" ]] || [[ "$hasteKey" = "null" ]]; then
            echo "Failed to parse response from server."
            return 1
        fi
        local url="http://bin.christitus.com/$hasteKey"
        if (( $+commands[xclip] )); then
            echo "$url" | xclip -selection clipboard
            echo "$url - Copied to clipboard."
        else
            echo "$url"
        fi
    else
        echo "Failed to upload the document."
    fi
}

# Serve: start a temporary HTTP server in current directory
serve() {
    local port="${1:-8000}"
    local ip

    # Get local IP address
    if (( $+commands[ip] )); then
        ip=$(ip -4 route get 1 2>/dev/null | awk '{print $7; exit}')
    elif (( $+commands[hostname] )); then
        ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    fi
    ip="${ip:-localhost}"

    local url="http://${ip}:${port}"

    local line_local="  Local:   http://localhost:${port}"
    local line_network="  Network: ${url}"
    local line_dir="  Dir:     $(pwd)"
    local title="  HTTP Server"

    # Find longest line to size the box
    local max_len=${#title}
    for line in "$line_local" "$line_network" "$line_dir"; do
        [[ ${#line} -gt $max_len ]] && max_len=${#line}
    done
    max_len=$((max_len + 2)) # padding

    local border=$(printf '%.0s─' {1..$max_len})
    echo ""
    printf '┌%s┐\n' "$border"
    printf '│%-*s│\n' "$max_len" "$title"
    printf '├%s┤\n' "$border"
    printf '│%-*s│\n' "$max_len" "$line_local"
    printf '│%-*s│\n' "$max_len" "$line_network"
    printf '│%-*s│\n' "$max_len" "$line_dir"
    printf '└%s┘\n' "$border"

    # Copy URL to clipboard if xclip is available
    if (( $+commands[xclip] )); then
        echo -n "$url" | xclip -selection clipboard
        echo "Copied link to clipboard"
    fi

    echo ""
    echo "Press Ctrl+C to stop the server"
    echo ""
    echo "Logs:"
    echo ""

    # Start server (try python3, then python, then php)
    if (( $+commands[python3] )); then
        python3 -m http.server "$port"
    elif (( $+commands[python] )); then
        python -m SimpleHTTPServer "$port"
    elif (( $+commands[php] )); then
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
    trap '_stop_spinner; trap - INT; trap - EXIT; return 130' INT
    trap '_stop_spinner; trap - INT; trap - EXIT' EXIT

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
        if (( $+commands[yay] )); then
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

    if [[ -z "$selected" ]]; then
        _ui_info "No packages selected"
        return 0
    fi

    pkg_list=$(echo "$selected" | tr '\n' ' ')
    pkg_count=$(echo "$selected" | wc -l)
    _ui_ok "Selected $pkg_count package(s)"

    # Step 2: Install
    _ui_step "Installing packages"
    local -a pkg_array
    pkg_array=("${(f)selected}")
    case "$_DISTRO" in
    debian)
        if (( $+commands[nala] )); then
            _run_with_spinner "Installing $pkg_list" sudo nala install -y "${pkg_array[@]}" || return 1
        else
            _run_with_spinner "Installing $pkg_list" sudo apt install -y "${pkg_array[@]}" || return 1
        fi
        ;;
    arch)
        if (( $+commands[yay] )); then
            _run_with_spinner "Installing $pkg_list" yay -S --noconfirm "${pkg_array[@]}" || return 1
        else
            _run_with_spinner "Installing $pkg_list" sudo pacman -S --noconfirm "${pkg_array[@]}" || return 1
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
    trap '_stop_spinner; trap - INT; trap - EXIT; return 130' INT
    trap '_stop_spinner; trap - INT; trap - EXIT' EXIT

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

    if [[ -z "$selected" ]]; then
        _ui_info "No packages selected"
        return 0
    fi

    pkg_list=$(echo "$selected" | tr '\n' ' ')
    pkg_count=$(echo "$selected" | wc -l)
    _ui_ok "Selected $pkg_count package(s)"

    # Step 2: Remove
    _ui_step "Removing packages"
    local -a pkg_array
    pkg_array=("${(f)selected}")
    case "$_DISTRO" in
    debian)
        _run_with_spinner "Removing $pkg_list" sudo apt remove -y "${pkg_array[@]}" || return 1
        ;;
    arch)
        _run_with_spinner "Removing $pkg_list" sudo pacman -R --noconfirm "${pkg_array[@]}" || return 1
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
    trap '_stop_spinner; trap - INT; trap - EXIT; return 130' INT
    trap '_stop_spinner; trap - INT; trap - EXIT' EXIT

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
        if (( $+commands[nala] )); then
            _run_with_spinner "Updating package lists" sudo nala update || return 1
        else
            _run_with_spinner "Updating package lists" sudo apt update || return 1
        fi
        upgradable=$(apt list --upgradable 2>/dev/null | command grep -v "^Listing" | cut -d/ -f1)
        ;;
    arch)
        _run_with_spinner "Syncing package database" sudo pacman -Sy || return 1
        if (( $+commands[yay] )); then
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

    if [[ -z "$upgradable" ]]; then
        _ui_ok "System already up to date"
        echo ""
        return 0
    fi

    local avail_count
    avail_count=$(echo "$upgradable" | command grep -c '.')
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
        if (( $+commands[yay] )); then
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

    if [[ -z "$selected" ]]; then
        _ui_info "No packages selected"
        return 0
    fi

    pkg_list=$(echo "$selected" | tr '\n' ' ')
    pkg_count=$(echo "$selected" | wc -l)
    _ui_ok "Selected $pkg_count package(s)"

    # Step 3: Update
    _ui_step "Updating packages"
    local -a pkg_array
    pkg_array=("${(f)selected}")
    case "$_DISTRO" in
    debian)
        if (( $+commands[nala] )); then
            _run_with_spinner "Updating $pkg_list" sudo nala install -y "${pkg_array[@]}" || return 1
        else
            _run_with_spinner "Updating $pkg_list" sudo apt install -y "${pkg_array[@]}" || return 1
        fi
        ;;
    arch)
        if (( $+commands[yay] )); then
            _run_with_spinner "Updating $pkg_list" yay -S --noconfirm "${pkg_array[@]}" || return 1
        else
            _run_with_spinner "Updating $pkg_list" sudo pacman -S --noconfirm "${pkg_array[@]}" || return 1
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
        if (( $+commands[rate-mirrors] )); then
            if [[ -s "/etc/pacman.d/mirrorlist" ]]; then
                sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
            fi
            _start_spinner "Optimising mirrors (rate-mirrors)"
            local rc=0
            echo "=== $(date '+%H:%M:%S') :: rate-mirrors ===" >> "$log_file"
            sudo rate-mirrors --top-mirrors-number-to-retest=5 --disable-comments --save /etc/pacman.d/mirrorlist --allow-root arch >> "$log_file" 2>&1 || rc=$?
            _stop_spinner
            if [[ $rc -ne 0 ]] || [[ ! -s "/etc/pacman.d/mirrorlist" ]]; then
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
        if (( $+commands[nala] )); then
            if [[ -f "/etc/apt/sources.list.d/nala-sources.list" ]]; then
                sudo cp /etc/apt/sources.list.d/nala-sources.list /etc/apt/sources.list.d/nala-sources.list.bak
            fi
            _start_spinner "Optimising mirrors (nala fetch)"
            local rc=0
            echo "=== $(date '+%H:%M:%S') :: nala fetch ===" >> "$log_file"
            sudo nala fetch --auto -y >> "$log_file" 2>&1 || rc=$?
            _stop_spinner
            if [[ $rc -ne 0 ]]; then
                _ui_warn "Mirror optimisation failed, restoring backup"
                if [[ -f "/etc/apt/sources.list.d/nala-sources.list.bak" ]]; then
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
    if (( $+commands[flatpak] )); then
        _run_with_spinner "Updating flatpak packages" flatpak update -y
    fi
}

# Updatesys: update/upgrade system packages with optional cleanup
# Supports: Debian/Ubuntu, Arch, Fedora, openSUSE, Alpine, Void, Solus
# Usage: updatesys [-m|--optimize-mirrors]
updatesys() {
    local optimize_mirrors=0
    for arg in "$@"; do
        case "$arg" in
        -m|--optimize-mirrors) optimize_mirrors=1 ;;
        *)
            echo "Usage: updatesys [-m|--optimize-mirrors]"
            return 1
            ;;
        esac
    done

    _detect_distro
    local start_time=$(date +%s)
    local packages_updated=0
    export _UPDATESYS_LOG
    _UPDATESYS_LOG=$(mktemp /tmp/updatesys-XXXXXX.log)

    # Cleanup spinner on Ctrl+C or unexpected exit
    trap '_stop_spinner; echo -e "\n       ${_CROSS} Interrupted"; echo -e "       ${_DIM}Log: ${_UPDATESYS_LOG}${_RC}"; trap - INT; trap - EXIT; return 130' INT
    trap '_stop_spinner; trap - INT; trap - EXIT' EXIT

    # Determine distro label and package manager
    local distro_label packager_label
    case "$_DISTRO" in
    debian)   distro_label="Debian/Ubuntu"; packager_label="apt"
              (( $+commands[nala] )) && packager_label="nala" ;;
    arch)     distro_label="Arch Linux"; packager_label="pacman"
              (( $+commands[yay] )) && packager_label="yay" ;;
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
    debian) _UI_TOTAL=$(( optimize_mirrors ? 5 : 4 )) ;;
    arch)   _UI_TOTAL=$(( optimize_mirrors ? 6 : 5 )) ;;
    *)      _UI_TOTAL=3 ;;
    esac

    case "$_DISTRO" in
    debian)
        # Step 1 (optional): Optimise mirrors
        if [[ $optimize_mirrors -eq 1 ]]; then
            _ui_step "Optimising mirrors"
            _optimize_mirrors debian
        fi

        # Step 2: Sync package lists
        _ui_step "Syncing package lists"
        if [[ "$packager_label" = "nala" ]]; then
            _run_with_spinner "Updating package lists" sudo nala update || return 1
        else
            _run_with_spinner "Updating package lists" sudo apt -o Acquire::Queue-Mode=host -o APT::Acquire::Retries=3 update || return 1
        fi

        # Check for available updates
        local upgradable_list=$(apt list --upgradable 2>/dev/null | command grep -v "^Listing")
        packages_updated=$(echo "$upgradable_list" | command grep -c '.')

        if [[ "$packages_updated" -eq 0 ]]; then
            _ui_info "No updates available"
        fi

        # Step 3: Upgrade packages
        _ui_step "Upgrading packages"
        if [[ "$packages_updated" -eq 0 ]]; then
            _ui_ok "System already up to date"
        elif [[ "$packager_label" = "nala" ]]; then
            _run_with_spinner "Upgrading $packages_updated packages" sudo nala upgrade -y || return 1
        else
            _run_with_spinner "Upgrading $packages_updated packages" sudo apt -o Acquire::Queue-Mode=host -o APT::Acquire::Retries=3 upgrade -y || return 1
        fi

        # Step 4: Cleanup
        _ui_step "Cleaning up"
        if [[ "$packager_label" = "nala" ]]; then
            _run_with_spinner "Removing unused packages" sudo nala autopurge -y
            _run_with_spinner "Cleaning package cache" sudo nala clean
        else
            _run_with_spinner "Removing unused packages" sudo apt autoremove -y
            _run_with_spinner "Cleaning package cache" sudo apt autoclean
        fi

        # Step 5: Flatpaks
        _ui_step "Updating flatpaks"
        _update_flatpaks
        if ! (( $+commands[flatpak] )); then
            _ui_info "Flatpak not installed, skipping"
        fi

        # Reboot check
        if [[ -f /var/run/reboot-required ]]; then
            echo ""
            _ui_warn "System reboot is required to complete the upgrade"
        fi
        ;;

    arch)
        if ! (( $+commands[yay] )); then
            _ui_fail "yay is required but not installed"
            _ui_info "Install yay first: https://github.com/Jguer/yay"
            return 1
        fi

        # Step 1 (optional): Optimise mirrors
        if [[ $optimize_mirrors -eq 1 ]]; then
            _ui_step "Optimising mirrors"
            _optimize_mirrors arch
        fi

        # Step 2: Update keyring
        _ui_step "Updating keyring"
        _run_with_spinner "Updating archlinux-keyring" sudo pacman -Sy --noconfirm --needed archlinux-keyring || return 1

        # Check for available updates
        local upgradable_list=$(yay -Qu 2>/dev/null)
        packages_updated=$(echo "$upgradable_list" | command grep -c '.')

        # Step 3: Check updates
        _ui_step "Checking for updates"
        if [[ "$packages_updated" -eq 0 ]]; then
            _ui_ok "System already up to date"
        else
            _ui_ok "$packages_updated updates available"

            if ! command grep -q "^ParallelDownloads" /etc/pacman.conf 2>/dev/null; then
                _ui_info "Tip: Enable ParallelDownloads in /etc/pacman.conf for faster updates"
            fi
        fi

        # Step 4: Upgrade packages
        _ui_step "Upgrading packages"
        if [[ "$packages_updated" -eq 0 ]]; then
            _ui_ok "Nothing to upgrade"
        else
            _run_with_spinner "Upgrading official packages" sudo pacman -Syu --noconfirm || return 1

            # AUR packages
            local aur_updates
            aur_updates=$(yay -Qua 2>/dev/null)
            if [[ -n "$aur_updates" ]]; then
                # Clean stale yay build cache for listed packages
                local aur_list
                aur_list=$(echo "$aur_updates" | awk '{print $1}')
                for pkg in ${(f)aur_list}; do
                    local cache_dir="$HOME/.cache/yay/$pkg"
                    if [[ -d "$cache_dir" ]]; then
                        command rm -rf "$cache_dir" 2>/dev/null || true
                    fi
                done

                local aur_count aur_rc=0
                aur_count=$(echo "$aur_updates" | wc -l)
                # Refresh sudo timestamp before AUR updates (which may take a long time to build)
                sudo -v || return 1
                _start_spinner "Upgrading $aur_count AUR packages"
                echo "=== $(date '+%H:%M:%S') :: yay -Sua ===" >> "$_UPDATESYS_LOG"
                yay -Sua --noconfirm >> "$_UPDATESYS_LOG" 2>&1 || aur_rc=$?
                _stop_spinner
                if [[ $aur_rc -eq 0 ]]; then
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
        if [[ -n "$orphans" ]]; then
            _start_spinner "Removing orphaned packages"
            echo "$orphans" | sudo pacman -Rns --noconfirm - >> "$_UPDATESYS_LOG" 2>&1
            local rc=$?
            _stop_spinner
            if [[ $rc -eq 0 ]]; then
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
        if ! (( $+commands[flatpak] )); then
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
        if ! (( $+commands[flatpak] )); then
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
        if ! (( $+commands[flatpak] )); then
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
        if ! (( $+commands[flatpak] )); then
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
        if ! (( $+commands[flatpak] )); then
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
        if ! (( $+commands[flatpak] )); then
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
    if [[ "$packages_updated" -gt 0 ]]; then
        echo -e "    ${_TICK} ${_DIM}Packages processed: ${packages_updated}${_RC}"
    fi
    echo -e "    ${_TICK} ${_DIM}Kernel: $(uname -r)${_RC}"
    echo -e "    ${_TICK} ${_DIM}Uptime: $(uptime -p)${_RC}"

    # Show remaining updates
    local updates=0
    case "$_DISTRO" in
    debian)   updates=$(apt list --upgradable 2>/dev/null | command grep -v "^Listing" | command grep -c '.') ;;
    arch)     updates=$(yay -Qu 2>/dev/null | command grep -c '.') ;;
    fedora)   updates=$(dnf check-update 2>/dev/null | command grep -c '^[a-zA-Z]') ;;
    opensuse) updates=$(zypper list-updates 2>/dev/null | command grep -c '^v') ;;
    alpine)   updates=$(apk version -l '<' 2>/dev/null | command grep -c '.') ;;
    void)     updates=$(xbps-install -nu 2>/dev/null | command grep -c '.') ;;
    solus)    updates=$(eopkg lu 2>/dev/null | command grep -c '.') ;;
    esac

    if [[ "$updates" -gt 0 ]]; then
        echo -e "    ${_WARN_SYM} ${_YELLOW}Pending updates: $updates${_RC}"
    else
        echo -e "    ${_TICK} ${_GREEN}System is up to date${_RC}"
    fi
    echo -e "    ${_DIM}Full log: ${_UPDATESYS_LOG}${_RC}"
    echo ""
}

# Cleansys: perform system cleanup (cache, logs, orphans, trash)
cleansys() {
    _detect_distro
    local start_time=$(date +%s)
    export _UPDATESYS_LOG
    _UPDATESYS_LOG=$(mktemp /tmp/cleansys-XXXXXX.log)
    trap '_stop_spinner; trap - INT; trap - EXIT; return 130' INT
    trap '_stop_spinner; trap - INT; trap - EXIT' EXIT

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
        if (( $+commands[nala] )); then
            _run_with_spinner "Cleaning package cache" sudo nala clean
            _run_with_spinner "Removing unused packages" sudo nala autoremove -y
        else
            _run_with_spinner "Cleaning package cache" sudo apt-get clean
            _run_with_spinner "Removing unused packages" sudo apt-get autoremove -y
        fi
        ;;
    arch)
        if (( $+commands[yay] )); then
            _run_with_spinner "Cleaning package cache" yay -Sc --noconfirm
        else
            _run_with_spinner "Cleaning package cache" sudo pacman -Sc --noconfirm
        fi

        local orphans=$(pacman -Qtdq 2>/dev/null)
        if [[ -n "$orphans" ]]; then
            _start_spinner "Removing orphaned packages"
            echo "$orphans" | sudo pacman -Rns --noconfirm - >> "$_UPDATESYS_LOG" 2>&1
            local rc=$?
            _stop_spinner
            if [[ $rc -eq 0 ]]; then
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
    if (( $+commands[journalctl] )); then
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
    if (( $+commands[flatpak] )); then
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
    if [[ -n "$disk_before" ]] && [[ -n "$disk_after" ]] && [[ "$disk_before" -gt "$disk_after" ]]; then
        freed=$(( (disk_before - disk_after) / 1024 ))
    fi

    echo ""
    echo -e "  ${_GREEN}${_BOLD}──────────────────────────────────────${_RC}"
    echo -e "  ${_GREEN}${_BOLD}  All clean!${_RC}  ${_DIM}Completed in ${duration}s${_RC}"
    echo -e "  ${_GREEN}${_BOLD}──────────────────────────────────────${_RC}"
    echo ""
    if [[ "$freed" -gt 0 ]]; then
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

    if [[ -n "$pids" ]]; then
        echo "Selected PIDs: $pids"
        read "sig?Signal? [t]erm (default) / [k]ill / [number]: "
        local signal
        case "$sig" in
        k|K)       signal="-9" ;;
        [0-9]*)    signal="-$sig" ;;
        *)         signal="-15" ;;
        esac
        read "confirm?Send signal $signal to these processes? (y/N): "
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
    _require_cmd yt-dlp || return 1

    local default_dir="$HOME/Videos"
    local url quality download_dir height format

    # Accept URL as first argument, or prompt interactively
    if [[ -n "$1" ]]; then
        url="$1"
    else
        read "url?YouTube URL: "
        if [[ -z "$url" ]]; then
            echo "No URL provided. Aborting."
            return 1
        fi
    fi

    # Accept quality as second argument, or prompt interactively
    if [[ -n "$2" ]]; then
        quality="$2"
    else
        read "quality?Quality (default 1080p): "
    fi
    quality=${quality:-1080p}

    # Accept output directory as third argument, or prompt interactively
    if [[ -n "$3" ]]; then
        download_dir="$3"
    else
        read "download_dir?Output directory (default $default_dir): "
    fi
    download_dir=${download_dir:-$default_dir}
    mkdir -p "$download_dir" || {
        echo "Failed to create $download_dir"
        return 1
    }

    (
        builtin cd "$download_dir" || return

        # Build a simple format string based on requested resolution
        height=$(echo "$quality" | sed 's/[^0-9]//g')
        if [[ -n "$height" ]]; then
            format="bestvideo[height<=$height]+bestaudio[ext=m4a]/best"
        else
            format="bestvideo+bestaudio/best"
        fi

        if (( $+commands[aria2c] )); then
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
    curl -s --connect-timeout 5 --max-time 15 "wttr.in/${1:-}"
}

# Topdf: convert docx/pptx files to PDF in current directory
topdf() {
    _require_cmd libreoffice || return 1
    _require_cmd fzf || return 1

    export _UPDATESYS_LOG
    _UPDATESYS_LOG=$(mktemp /tmp/topdf-XXXXXX.log)
    trap '_stop_spinner; trap - INT; trap - EXIT; return 130' INT
    trap '_stop_spinner; trap - INT; trap - EXIT' EXIT

    # Find all convertible files
    local files=()
    local f
    for f in ./*.docx(N) ./*.pptx(N); do
        files+=("$f")
    done

    if [[ ${#files[@]} -eq 0 ]]; then
        echo ""
        _ui_info "No .docx or .pptx files found in current directory"
        echo ""
        return 0
    fi

    # Header
    echo ""
    echo -e "  ${_BOLD}Convert to PDF${_RC} ${_DIM}| ${#files[@]} file(s) found | log: ${_UPDATESYS_LOG}${_RC}"
    echo -e "  ${_DIM}──────────────────────────────────────${_RC}"

    # List files
    echo ""
    local i=1
    for f in "${files[@]}"; do
        echo -e "    ${_DIM}$i.${_RC} ${f:t}"
        ((i++))
    done

    # Show options
    echo ""
    echo -e "  ${_CYAN}Options:${_RC}"
    echo -e "    ${_DIM}[a]${_RC} Convert all"
    echo -e "    ${_DIM}[s]${_RC} Select specific files (fzf)"
    echo -e "    ${_DIM}[c]${_RC} Cancel"
    echo ""
    read "choice?  Choose option: "

    local to_convert=()
    case "$choice" in
        a|A)
            to_convert=("${files[@]}")
            ;;
        s|S)
            # Use fzf for file selection
            local selected
            selected=$(printf '%s\n' "${files[@]}" | sed 's|^\./||' | fzf --multi \
                --header="Select files to convert (TAB for multi-select, ENTER to confirm)" \
                --preview 'file {}' \
                --preview-window=right:40%:wrap)

            if [[ -z "$selected" ]]; then
                echo ""
                _ui_info "No files selected"
                echo ""
                return 0
            fi

            # Convert selected basenames back to full paths
            local line
            for line in "${(f)selected}"; do
                to_convert+=("./$line")
            done
            ;;
        c|C|*)
            echo ""
            _ui_info "Cancelled"
            echo ""
            return 0
            ;;
    esac

    # Set up UI
    _UI_STEP=0
    _UI_TOTAL=${#to_convert[@]}

    # Convert files
    echo ""
    local converted=0
    local failed=0

    for f in "${to_convert[@]}"; do
        _ui_step "Converting ${f:t}"
        local dirname="${f:h}"

        _start_spinner "Converting to PDF"
        echo "=== $(date '+%H:%M:%S') :: ${f:t} ===" >> "$_UPDATESYS_LOG"
        if libreoffice --headless --convert-to pdf "$f" --outdir "$dirname" >> "$_UPDATESYS_LOG" 2>&1; then
            _stop_spinner
            if command rm "$f" 2>/dev/null; then
                _ui_ok "Converted and removed original"
                ((converted++))
            else
                _ui_warn "Converted but failed to remove original"
                ((converted++))
            fi
        else
            _stop_spinner
            _ui_fail "Conversion failed"
            ((failed++))
        fi
    done

    # Summary
    echo ""
    echo -e "  ${_GREEN}${_BOLD}──────────────────────────────────────${_RC}"
    echo -e "  ${_GREEN}${_BOLD}  Done!${_RC}"
    echo -e "  ${_GREEN}${_BOLD}──────────────────────────────────────${_RC}"
    echo ""
    if [[ "$converted" -gt 0 ]]; then
        echo -e "    ${_TICK} ${_DIM}Converted: ${converted}${_RC}"
    fi
    if [[ "$failed" -gt 0 ]]; then
        echo -e "    ${_CROSS} ${_DIM}Failed: ${failed}${_RC}"
    fi
    echo -e "    ${_DIM}Full log: ${_UPDATESYS_LOG}${_RC}"
    echo ""
}

# Sysinfo: quick system health dashboard
sysinfo() {
    echo ""
    echo -e "  ${_BOLD}System Health${_RC}"
    echo -e "  ${_DIM}──────────────────────────────────────${_RC}"

    # --- Host & Kernel ---
    echo ""
    echo -e "  ${_BOLD}${_CYAN}Host${_RC}"
    echo -e "    ${_DIM}Hostname:${_RC}  $(hostname)"
    echo -e "    ${_DIM}Kernel:${_RC}    $(uname -r)"
    echo -e "    ${_DIM}Uptime:${_RC}    $(uptime -p | sed 's/^up //')"

    # --- CPU ---
    echo ""
    echo -e "  ${_BOLD}${_CYAN}CPU${_RC}"
    local cpu_model load1 load5 load15 cores usage_pct
    cpu_model=$(awk -F': ' '/^model name/{print $2; exit}' /proc/cpuinfo 2>/dev/null || echo "Unknown")
    cores=$(nproc 2>/dev/null || echo 1)
    read -r load1 load5 load15 _ < /proc/loadavg
    usage_pct=$(awk "BEGIN {printf \"%.0f\", ($load1 / $cores) * 100}")
    echo -e "    ${_DIM}Model:${_RC}     ${cpu_model}"
    echo -e "    ${_DIM}Cores:${_RC}     ${cores}"
    local load_color="${_GREEN}"
    if [[ "$usage_pct" -ge 90 ]]; then load_color="${_RED}"
    elif [[ "$usage_pct" -ge 70 ]]; then load_color="${_YELLOW}"; fi
    echo -e "    ${_DIM}Load:${_RC}      ${load1} ${load5} ${load15}  ${load_color}(${usage_pct}%)${_RC}"
    if (( $+commands[sensors] )); then
        local cpu_temp
        cpu_temp=$(sensors 2>/dev/null | awk '/^(Package id 0|Tctl|CPU|Core 0):/{for(i=1;i<=NF;i++){if($i~/^\+[0-9]/){gsub(/[+°C]/,"",$i); print $i; exit}}}')
        if [[ -n "$cpu_temp" ]]; then
            local temp_int=${cpu_temp%%.*}
            local temp_color="${_GREEN}(ok)${_RC}"
            if [[ "$temp_int" -ge 80 ]]; then
                temp_color="${_RED}(hot!)${_RC}"
            elif [[ "$temp_int" -ge 60 ]]; then
                temp_color="${_YELLOW}(warm)${_RC}"
            fi
            echo -e "    ${_DIM}Temp:${_RC}      ${cpu_temp}\u00b0C  ${temp_color}"
        fi
    fi

    # --- Memory ---
    echo ""
    echo -e "  ${_BOLD}${_CYAN}Memory${_RC}"
    local mem_total mem_used mem_dummy mem_pct swap_total swap_used swap_dummy swap_pct
    read -r mem_total mem_used mem_dummy mem_pct <<< "$(command free -m | awk '/^Mem:/{printf "%s %s %s %.0f", $2, $3, $4, $3/$2*100}')"
    local mem_color="${_GREEN}"
    if [[ "$mem_pct" -ge 90 ]]; then mem_color="${_RED}"
    elif [[ "$mem_pct" -ge 70 ]]; then mem_color="${_YELLOW}"; fi
    echo -e "    ${_DIM}RAM:${_RC}       ${mem_used}M / ${mem_total}M  ${mem_color}(${mem_pct}%)${_RC}"
    read -r swap_total swap_used swap_dummy swap_pct <<< "$(command free -m | awk '/^Swap:/{if($2>0) printf "%s %s %s %.0f", $2, $3, $4, $3/$2*100; else print "0 0 0 0"}')"
    if [[ "$swap_total" -gt 0 ]]; then
        echo -e "    ${_DIM}Swap:${_RC}      ${swap_used}M / ${swap_total}M  (${swap_pct}%)"
    else
        echo -e "    ${_DIM}Swap:${_RC}      none"
    fi

    # --- Disk ---
    echo ""
    echo -e "  ${_BOLD}${_CYAN}Disk${_RC}"
    local line mount used total pct disk_color
    while IFS= read -r line; do
        mount=$(echo "$line" | awk '{print $6}')
        used=$(echo "$line" | awk '{print $3}')
        total=$(echo "$line" | awk '{print $2}')
        pct=$(echo "$line" | awk '{gsub(/%/,"",$5); print $5}')
        disk_color="${_GREEN}"
        if [[ "$pct" -ge 90 ]]; then disk_color="${_RED}"
        elif [[ "$pct" -ge 70 ]]; then disk_color="${_YELLOW}"; fi
        echo -e "    ${_DIM}${mount}:${_RC}  ${used} / ${total}  ${disk_color}(${pct}%)${_RC}"
    done <<< "$(df -h --output=source,size,used,avail,pcent,target -x tmpfs -x devtmpfs -x efivarfs 2>/dev/null | tail -n +2)"

    # --- Network ---
    echo ""
    echo -e "  ${_BOLD}${_CYAN}Network${_RC}"
    local default_iface default_ip
    default_iface=$(ip -4 route show default 2>/dev/null | awk '{print $5; exit}')
    default_ip=$(ip -4 route get 1 2>/dev/null | awk '{print $7; exit}')
    if [[ -n "$default_iface" ]]; then
        echo -e "    ${_DIM}Interface:${_RC} ${default_iface}"
        echo -e "    ${_DIM}Local IP:${_RC}  ${default_ip:-unknown}"
    else
        echo -e "    ${_DIM}Status:${_RC}    no network"
    fi

    # --- Listening ports (top 5) ---
    if (( $+commands[ss] )); then
        local listeners
        listeners=$(ss -tulnp 2>/dev/null | awk 'NR>1 && $1 ~ /^(tcp|udp)/{split($5,a,":"); port=a[length(a)]; proto=$1; proc=$7; gsub(/.*users:\(\("/,"",proc); gsub(/".*/,"",proc); if(port+0 > 0) printf "    %-6s %-8s %s\n", port, proto, proc}' | sort -t' ' -k1 -n -u | head -5)
        if [[ -n "$listeners" ]]; then
            echo ""
            echo -e "  ${_BOLD}${_CYAN}Listening Ports${_RC} ${_DIM}(top 5)${_RC}"
            echo -e "    ${_DIM}PORT   PROTO    PROCESS${_RC}"
            echo "$listeners"
        fi
    fi

    # --- Top processes by CPU ---
    echo ""
    echo -e "  ${_BOLD}${_CYAN}Top Processes${_RC} ${_DIM}(by CPU)${_RC}"
    echo -e "    ${_DIM}CPU%   MEM%   PID    COMMAND${_RC}"
    ps -eo pcpu,pmem,pid,comm --sort=-pcpu 2>/dev/null | awk 'NR>1 && NR<=6{printf "    %-6s %-6s %-6s %s\n", $1, $2, $3, $4}'

    # --- Systemd failed units ---
    if (( $+commands[systemctl] )); then
        local failed
        failed=$(systemctl --no-pager --no-legend list-units --state=failed 2>/dev/null)
        echo ""
        if [[ -n "$failed" ]]; then
            local fail_count
            fail_count=$(echo "$failed" | wc -l)
            echo -e "  ${_BOLD}${_CYAN}Systemd${_RC}  ${_RED}${fail_count} failed unit(s)${_RC}"
            echo "$failed" | awk '{printf "    %s %s\n", $1, $2}' | head -5
        else
            echo -e "  ${_BOLD}${_CYAN}Systemd${_RC}  ${_GREEN}all units healthy${_RC}"
        fi
    fi

    # --- Pending updates ---
    _detect_distro
    local updates=0
    case "$_DISTRO" in
    debian)   updates=$(apt list --upgradable 2>/dev/null | command grep -v "^Listing" | command grep -c '.') ;;
    arch)     updates=$(pacman -Qu 2>/dev/null | command grep -c '.')
              if (( $+commands[yay] )); then
                  local aur_updates
                  aur_updates=$(yay -Qua 2>/dev/null | command grep -c '.')
                  updates=$((updates + aur_updates))
              fi ;;
    fedora)   updates=$(dnf check-update 2>/dev/null | command grep -c '^[a-zA-Z]') ;;
    esac
    echo ""
    if [[ "$updates" -gt 0 ]]; then
        echo -e "  ${_BOLD}${_CYAN}Updates${_RC}  ${_YELLOW}${updates} package(s) pending${_RC}"
    else
        echo -e "  ${_BOLD}${_CYAN}Updates${_RC}  ${_GREEN}system is up to date${_RC}"
    fi

    echo ""
}

# =========================
# Keybindings and init
# =========================

# Show custom keybindings
keybinds() {
    echo ""
    echo -e "${_CYAN}\u250c\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2510${_RC}"
    echo -e "${_CYAN}\u2502${_RC}${_YELLOW}  Custom Keybindings                                 ${_RC}${_CYAN}\u2502${_RC}"
    echo -e "${_CYAN}\u251c\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2524${_RC}"
    echo -e "${_CYAN}\u2502${_RC}${_GREEN}  Ctrl+f     Zoxide interactive (ji)                 ${_RC}${_CYAN}\u2502${_RC}"
    echo -e "${_CYAN}\u2502${_RC}${_GREEN}  Ctrl+y     Install package (installpkg)            ${_RC}${_CYAN}\u2502${_RC}"
    echo -e "${_CYAN}\u2502${_RC}${_GREEN}  Ctrl+r     Fuzzy history search                    ${_RC}${_CYAN}\u2502${_RC}"
    echo -e "${_CYAN}\u2502${_RC}${_GREEN}  Ctrl+t     Fuzzy file search                       ${_RC}${_CYAN}\u2502${_RC}"
    echo -e "${_CYAN}\u2502${_RC}${_GREEN}  Ctrl+g     Fuzzy directory search                  ${_RC}${_CYAN}\u2502${_RC}"
    echo -e "${_CYAN}\u2502${_RC}${_GREEN}  Ctrl+x     Fuzzy delete (fzfdel)                   ${_RC}${_CYAN}\u2502${_RC}"
    echo -e "${_CYAN}\u2514\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2518${_RC}"
    echo ""
}

# Fuzzy delete: select multiple files/dirs to trash
fzfdel() {
    _require_cmd fzf || return 1
    _require_cmd trash || return 1

    local selected
    if (( $+commands[fd] )); then
        selected=$(fd --hidden --exclude .git --exclude .Trash --exclude .local/share/Trash |
            fzf --multi --height 60% --reverse --border --prompt="Delete > " \
                --header="TAB to select multiple, ENTER to confirm" \
                --preview '[[ -d {} ]] && ls -la {} || head -100 {}' \
                --preview-window=right:50%:wrap)
    else
        selected=$(find . -not -path '*/.git/*' -not -path '*/.Trash/*' -not -path '*/.local/share/Trash/*' 2>/dev/null |
            fzf --multi --height 60% --reverse --border --prompt="Delete > " \
                --header="TAB to select multiple, ENTER to confirm" \
                --preview '[[ -d {} ]] && ls -la {} || head -100 {}' \
                --preview-window=right:50%:wrap)
    fi

    if [[ -n "$selected" ]]; then
        local count=$(echo "$selected" | wc -l)
        echo "Selected $count item(s) for deletion:"
        echo "$selected"
        echo ""
        read "confirm?Move these to trash? (y/N): "
        if [[ $confirm =~ ^[Yy]$ ]]; then
            local f
            for f in "${(f)selected}"; do
                trash -v "$f"
            done
            echo "Done. Use 'trash-list' to view or 'trash-restore' to recover."
        else
            echo "Cancelled."
        fi
    else
        echo "No files selected."
    fi
}

# Zsh keybindings (zle widgets)
if [[ -o interactive ]]; then
    # Fix common key bindings (Home, End, Delete, etc.)
    bindkey '^[[H'    beginning-of-line     # Home
    bindkey '^[[F'    end-of-line           # End
    bindkey '^[[3~'   delete-char           # Delete
    bindkey '^[[1~'   beginning-of-line     # Home (alternate)
    bindkey '^[[4~'   end-of-line           # End (alternate)
    bindkey '^?'      backward-delete-char  # Backspace
    bindkey '^[[3;5~' delete-word           # Ctrl+Delete
    bindkey '^H'      backward-delete-word  # Ctrl+Backspace

    # Ctrl+f: zoxide interactive
    __zsh_ji_widget() {
        BUFFER="ji"
        zle accept-line
    }
    zle -N __zsh_ji_widget
    bindkey '^f' __zsh_ji_widget

    # Ctrl+y: installpkg
    __zsh_installpkg_widget() {
        BUFFER="installpkg"
        zle accept-line
    }
    zle -N __zsh_installpkg_widget
    bindkey '^y' __zsh_installpkg_widget

    # Ctrl+x: fzfdel
    __zsh_fzfdel_widget() {
        BUFFER="fzfdel"
        zle accept-line
    }
    zle -N __zsh_fzfdel_widget
    bindkey '^x' __zsh_fzfdel_widget

    # Ctrl+g: fuzzy directory search (insert selected dir at cursor)
    # Note: FZF's built-in Alt+C changes directory; this inserts path at cursor instead
    if (( $+commands[fzf] )); then
        __fzf_insert_dir__() {
            local dir
            if (( $+commands[fd] )); then
                dir=$(fd --type d --hidden --exclude .git | fzf --height 40% --reverse --border --prompt="Dirs > " --preview 'eza -1 --color=always {} 2>/dev/null || ls -la {}' --preview-window=right:50%:wrap)
            else
                dir=$(find . -type d -not -path '*/.git/*' 2>/dev/null | fzf --height 40% --reverse --border --prompt="Dirs > " --preview 'ls -la {}' --preview-window=right:50%:wrap)
            fi
            if [[ -n "$dir" ]]; then
                local quoted_dir="${(q)dir}"
                BUFFER="${BUFFER[1,$CURSOR]}${quoted_dir}${BUFFER[$((CURSOR+1)),-1]}"
                CURSOR=$((CURSOR + ${#quoted_dir}))
            fi
            zle reset-prompt
        }
        zle -N __fzf_insert_dir__
        bindkey '^g' __fzf_insert_dir__
    fi
fi

# Initialize starship prompt
eval "$(starship init zsh)"

# Initialize zoxide (use 'j' and 'ji' to avoid conflict with zinit's 'zi' alias)
if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh --cmd j)"
    alias cd='j'
fi
