#!/usr/bin/env bash
# Set up these dotfiles on CachyOS.
#
# Usage (from bash or zsh):
#   ~/.dotfiles/install.sh        (or: bash install.sh / zsh install.sh)
#   bash <(curl -fsSL https://raw.githubusercontent.com/Owen-3456/dotfiles/main/install.sh)
#
# Asks before each step that changes the system. Safe to re-run: packages use
# --needed, an existing clone is left alone, and files that are already
# stowed aren't treated as conflicts.

# The script is written for bash. If started from zsh/sh (e.g. `zsh install.sh`),
# re-run it under bash. This block must stay POSIX so any shell can parse it;
# shells read scripts a command at a time, so the bash-only code below is never
# reached. Bash is always installed on CachyOS.
if [ -z "${BASH_VERSION:-}" ] || (shopt -oq posix) 2>/dev/null; then
    if ! command -v bash >/dev/null 2>&1; then
        echo "Error: bash is required but wasn't found." >&2
        exit 1
    fi
    if [ ! -f "$0" ]; then
        # Piped in (e.g. `curl ... | zsh`): there's no file to re-run
        echo "Error: run this with bash, e.g.: bash <(curl -fsSL https://raw.githubusercontent.com/Owen-3456/dotfiles/main/install.sh)" >&2
        exit 1
    fi
    exec bash "$0" "$@"
fi

set -Eeuo pipefail

REPO_URL="https://github.com/Owen-3456/dotfiles.git"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
CURRENT_USER=$(id -un)
problems=()  # non-fatal failures, listed in the final summary

# =========================
# UI helpers
# =========================
step() { printf '\n\033[1;36m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
info() { printf '    \033[0;36m›\033[0m %s\n' "$*"; }
ok()   { printf '    \033[0;32m✓\033[0m %s\n' "$*"; }
warn() { printf '    \033[1;33m!\033[0m %s\n' "$*" >&2; }
die()  { printf '\n\033[0;31m✗ %s\033[0m\n' "$*" >&2; exit 1; }

# Any unhandled failure: say what failed instead of exiting silently
trap 'die "Command failed (exit $?) on line $LINENO: $BASH_COMMAND"' ERR
trap 'printf "\n"; die "Interrupted."' INT

# Print a list of words in indented columns
list() { printf '%s\n' "$@" | column | sed 's/^/        /'; }

# Prompt and print the answer. Reads from /dev/tty so prompts still work
# when the script itself is piped in. Callers must use `$(ask ...) || exit 1`:
# set -e is ignored inside functions called from if/||/&& (e.g. confirm), so a
# failed read would otherwise just loop.
ask() {
    local reply
    read -r -p "$(printf '    \033[1;35m?\033[0m %s ' "$1")" reply </dev/tty ||
        die "No input (end of file). Aborting."
    printf '%s' "$reply"
}

# Yes/no prompt. Usage: confirm "Question?" [Y|N]  (default Y)
confirm() {
    local default=${2:-Y} hint reply
    [[ $default == Y ]] && hint="[Y/n]" || hint="[y/N]"
    while true; do
        reply=$(ask "$1 $hint") || exit 1
        case ${reply:-$default} in
        [Yy]*) return 0 ;;
        [Nn]*) return 1 ;;
        esac
    done
}

# =========================
# Preflight
# =========================
step "Checking system"

[[ $EUID -ne 0 ]] || die "Run this as your normal user, not root (sudo is used where needed)."

[[ -r /etc/os-release ]] || die "Can't detect the distro: /etc/os-release is missing."
distro_id=$(. /etc/os-release && printf '%s' "${ID:-}")
distro_name=$(. /etc/os-release && printf '%s' "${PRETTY_NAME:-${NAME:-unknown}}")
[[ $distro_id == cachyos ]] || die "Unsupported distro: $distro_name. This script only supports CachyOS."
command -v pacman >/dev/null || die "pacman wasn't found."
ok "Distro: $distro_name"

{ true </dev/tty; } 2>/dev/null || die "No terminal found. This script is interactive; run it from a terminal."

command -v sudo >/dev/null || die "sudo is required but isn't installed."
info "Some steps need root; you may be asked for your sudo password"
sudo -v || die "Couldn't get sudo access. Make sure $CURRENT_USER is allowed to use sudo."
ok "sudo access"

if [[ -e /var/lib/pacman/db.lck ]]; then
    die "pacman is locked (/var/lib/pacman/db.lck). Wait for any other package manager to finish; if none is running, remove the lock with: sudo rm /var/lib/pacman/db.lck"
fi

if command -v curl >/dev/null; then
    curl -fsS --max-time 10 -o /dev/null https://github.com 2>/dev/null ||
        die "Can't reach github.com. Check your internet connection."
    ok "Internet connection"
fi

# =========================
# Base tools
# =========================
# Full upgrade first: refreshing the package database (-Sy) and installing
# without also upgrading (-u) is a partial upgrade, which isn't supported.
step "Updating system and installing base tools"
info "Runs 'pacman -Syu' and installs git, base-devel, stow and zsh (required for the rest)"
confirm "Continue?" || die "Cancelled."
sudo pacman -Syu --needed --noconfirm git base-devel stow zsh ||
    die "System update failed. Fix the pacman error above and re-run."
ok "System up to date"

# =========================
# Clone repo
# =========================
step "Getting dotfiles"
if [[ -d "$DOTFILES_DIR/.git" ]]; then
    ok "Using existing clone at $DOTFILES_DIR"
elif [[ -e "$DOTFILES_DIR" ]]; then
    die "$DOTFILES_DIR exists but isn't a git repo. Move it aside and re-run."
else
    confirm "Clone $REPO_URL to $DOTFILES_DIR?" || die "Cancelled."
    git clone "$REPO_URL" "$DOTFILES_DIR" || die "Couldn't clone $REPO_URL."
    ok "Cloned to $DOTFILES_DIR"
fi

# =========================
# AUR helper (yay)
# =========================
# yay ships in the CachyOS repos, so no AUR build is needed
step "Setting up yay"
if command -v yay >/dev/null; then
    ok "yay already installed"
else
    confirm "yay isn't installed (needed for AUR packages). Install it?" || die "Cancelled."
    sudo pacman -S --needed --noconfirm yay || die "Couldn't install yay from the CachyOS repos."
    command -v yay >/dev/null || die "yay was installed but isn't on PATH."
    ok "Installed yay"
fi

# Remove any other AUR helper so yay is the only one. Done after yay is in
# place, so a failed yay install never leaves the system without a helper.
mapfile -t other_helpers < <(pacman -Qq | grep -E '^(paru|pikaur|trizen|aura|pakku|aurman|pacaur|yaourt)(-bin|-git)?(-debug)?$' || true)
if (( ${#other_helpers[@]} )); then
    warn "Other AUR helpers installed: ${other_helpers[*]}"
    if confirm "Remove them so yay is the only AUR helper?"; then
        if sudo pacman -Rns --noconfirm "${other_helpers[@]}"; then
            ok "Removed ${other_helpers[*]}"
        else
            warn "Couldn't remove ${other_helpers[*]} (see error above). Continuing."
            problems+=("Couldn't remove other AUR helpers: ${other_helpers[*]}")
        fi
    else
        info "Keeping ${other_helpers[*]}"
    fi
else
    ok "No other AUR helpers installed"
fi

# =========================
# Packages
# =========================
step "Installing packages"
if [[ ! -f "$DOTFILES_DIR/packages.txt" ]]; then
    warn "No packages.txt in $DOTFILES_DIR, skipping package install"
else
    # Strip comments and whitespace, drop blank lines
    mapfile -t packages < <(sed -e 's/#.*//' -e 's/[[:space:]]//g' -e '/^$/d' "$DOTFILES_DIR/packages.txt")
    if (( ${#packages[@]} == 0 )); then
        warn "packages.txt is empty, skipping package install"
    else
        info "${#packages[@]} packages in packages.txt (already installed ones are skipped):"
        list "${packages[@]}"
        if confirm "Install these packages?"; then
            if yay -S --needed --noconfirm "${packages[@]}"; then
                ok "Packages installed"
            else
                warn "Package install failed (see error above). Some or all packages may not be installed."
                confirm "Continue to stowing anyway?" N || die "Stopped after package install failed."
                problems+=("Package install failed; re-run the script or install the rest with yay")
            fi
        else
            info "Skipped package install"
        fi
    fi
fi

# =========================
# Stow
# =========================
command -v stow >/dev/null || die "stow isn't installed."

# Print the files in $HOME that stowing a package would clobber. Targets that
# already resolve into the repo (i.e. previously stowed) don't count.
find_conflicts() {
    local pkg=$1 src target
    while IFS= read -r -d '' src; do
        target="$HOME/${src#"$DOTFILES_DIR/$pkg/"}"
        [[ -e "$target" || -L "$target" ]] || continue
        [[ "$(realpath -m "$target")" == "$(realpath -m "$src")" ]] && continue
        printf '%s\n' "$target"
    done < <(find "$DOTFILES_DIR/$pkg" \( -type f -o -type l \) -print0)
}

# Rename a file to <file>.old, adding a timestamp if that's already taken
rename_old() {
    local dest="$1.old"
    if [[ -e "$dest" || -L "$dest" ]]; then
        dest="$1.old.$(date +%Y%m%d-%H%M%S)"
    fi
    if ! mv -- "$1" "$dest"; then
        warn "Couldn't rename ${1/#$HOME/\~}"
        return 1
    fi
    ok "Renamed ${1/#$HOME/\~} -> ${dest/#$HOME/\~}"
}

# Resolve conflicts for one package. Returns 1 if the package should be skipped.
resolve_conflicts() {
    local pkg=$1 f choice
    local -a conflicts
    mapfile -t conflicts < <(find_conflicts "$pkg")
    (( ${#conflicts[@]} )) || return 0

    warn "$pkg: ${#conflicts[@]} existing file(s) would be replaced:"
    for f in "${conflicts[@]}"; do
        printf '        %s\n' "${f/#$HOME/\~}" >&2
    done
    while true; do
        choice=$(ask "[r]ename existing to *.old / [o]verwrite (delete existing) / [s]kip $pkg [R/o/s]") || exit 1
        case ${choice:-r} in
        [Rr]*)
            for f in "${conflicts[@]}"; do
                rename_old "$f" || return 1
            done
            return 0
            ;;
        [Oo]*)
            for f in "${conflicts[@]}"; do
                if ! rm -rf -- "$f"; then
                    warn "Couldn't delete ${f/#$HOME/\~}"
                    return 1
                fi
                ok "Deleted ${f/#$HOME/\~}"
            done
            return 0
            ;;
        [Ss]*) return 1 ;;
        esac
    done
}

step "Linking dotfiles with stow"
# Every non-hidden top-level directory in the repo is a stow package
mapfile -t found < <(find "$DOTFILES_DIR" -mindepth 1 -maxdepth 1 -type d ! -name '.*' -printf '%f\n' | sort)
(( ${#found[@]} )) || die "No stow packages found in $DOTFILES_DIR."
info "Found ${#found[@]} packages:"
list "${found[@]}"

selected=()
while true; do
    choice=$(ask "Stow [a]ll / [c]hoose individually / [n]one? [A/c/n]") || exit 1
    case ${choice:-a} in
    [Aa]*) selected=("${found[@]}"); break ;;
    [Cc]*)
        for pkg in "${found[@]}"; do
            if confirm "Stow $pkg?"; then selected+=("$pkg"); fi
        done
        break
        ;;
    [Nn]*) break ;;
    esac
done

stowed=()
for pkg in "${selected[@]}"; do
    if ! resolve_conflicts "$pkg"; then
        info "Skipped $pkg"
        continue
    fi
    # --no-folding links individual files rather than whole directories, so
    # apps that write extra files into e.g. ~/.config/atuin don't dump them in the repo.
    if stow --no-folding --restow -d "$DOTFILES_DIR" -t "$HOME" "$pkg"; then
        stowed+=("$pkg")
        ok "Stowed $pkg"
    else
        warn "stow failed for $pkg (see error above), skipping"
        problems+=("stow failed for $pkg")
    fi
done
(( ${#stowed[@]} )) || info "Nothing stowed"

# Was a package stowed in this run?
is_stowed() { [[ " ${stowed[*]} " == *" $1 "* ]]; }

# =========================
# Extras
# =========================
step "Finishing up"

# .nanorc sets backupdir; nano refuses to start if that directory doesn't exist
if is_stowed nano; then
    if mkdir -p "$HOME/.nano/backups"; then
        ok "Created ~/.nano/backups"
    else
        warn "Couldn't create ~/.nano/backups; nano won't start until it exists"
        problems+=("Couldn't create ~/.nano/backups (needed for nano to start)")
    fi
fi

# TPM isn't self-installing (zinit is, on first shell start)
if is_stowed tmux; then
    if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
        ok "TPM already installed"
    elif confirm "Install TPM (tmux plugin manager) to ~/.tmux/plugins/tpm?"; then
        if git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"; then
            ok "Installed TPM"
        else
            warn "Couldn't install TPM. Install it later with: git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
            problems+=("TPM not installed")
        fi
    fi
fi

# zsh was installed with the base tools; make it the default shell
zsh_path=$(command -v zsh || true)
current_shell=$(getent passwd "$CURRENT_USER" | cut -d: -f7)
if [[ -z "$zsh_path" ]]; then
    warn "zsh isn't installed, leaving default shell alone"
    problems+=("zsh isn't installed, so it wasn't set as the default shell")
elif [[ "$(realpath -m "$current_shell")" == "$(realpath -m "$zsh_path")" ]]; then
    ok "zsh is already the default shell"
elif confirm "Set zsh as your default shell? (currently ${current_shell:-unknown})"; then
    # chsh only accepts shells listed in /etc/shells (the zsh package adds itself)
    if ! grep -qxF "$zsh_path" /etc/shells; then
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi
    # Via sudo so chsh doesn't ask for the user's password on top of sudo's
    if sudo chsh -s "$zsh_path" "$CURRENT_USER"; then
        ok "Default shell set to $zsh_path (takes effect next login)"
    else
        warn "Couldn't change default shell. Do it later with: chsh -s $zsh_path"
        problems+=("Default shell not changed")
    fi
fi

# =========================
# Summary
# =========================
if (( ${#problems[@]} )); then
    step "Done, with problems:"
    for p in "${problems[@]}"; do warn "$p"; done
else
    step "Done!"
fi
if is_stowed zsh; then info "Log out and back in (or run 'exec zsh'); zinit installs its plugins on first start"; fi
if is_stowed atuin; then info "Atuin sync: 'atuin login' (or 'atuin register'), then 'atuin sync'"; fi
if is_stowed tmux; then info "Tmux plugins: start tmux and press prefix + I"; fi
echo
