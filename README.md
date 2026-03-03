# dotfiles

Personal dotfiles for Linux, managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a Stow package that symlinks its contents into `$HOME`.

## Quick Setup

> Requires `curl` to be installed.

```bash
curl -fsSL https://owen3456.xyz/linux | bash
```

This runs the [Linux Setup Script](https://github.com/Owen-3456/Linux-Setup-Script), which clones this repository, installs dependencies, and symlinks everything into place using GNU Stow.

### Manual Setup

```bash
git clone https://github.com/Owen-3456/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow <package>  # e.g., stow zsh alacritty starship tmux
```

---

## Packages

### Zsh

**`zsh/.zshrc`** -- The core of this setup. An ~1800 line config that provides a full interactive shell environment with custom functions, aliases, keybindings, modern plugins, and multi-distro package management.

#### Shell Options & History

- Case-insensitive tab completion with menu selection
- Recursive globbing with `**` 
- Command spelling correction
- 10,000-line persistent history with cross-session sync, deduplication, and no duplicates in search
- Ctrl+S/Ctrl+Q flow control disabled (`stty -ixon`)

#### Environment

| Variable | Value                         |
| -------- | ----------------------------- |
| `EDITOR` | `nano`                        |
| `VISUAL` | `code -w` (VS Code)           |
| `XDG_*`  | Standard XDG base directories |

PATH includes `~/.local/bin`, `~/.cargo/bin`, and Flatpak export directories.

#### Zsh Plugins

Powered by [zinit](https://github.com/zdharma-continuum/zinit) plugin manager:

- **zsh-completions** -- Extra completion definitions
- **zsh-autosuggestions** -- Fish-like command suggestions from history
- **fzf-tab** -- FZF-powered tab completion with file previews
- **zsh-autopair** -- Auto-close brackets, quotes, and parentheses
- **zsh-you-should-use** -- Reminds you of existing aliases
- **zsh-auto-notify** -- Desktop notifications for long-running commands (>10s)
- **colorize** -- Syntax highlighting for cat/less/tail
- **history-search-multi-word** -- Enhanced history search with highlighting
- **fast-syntax-highlighting** -- Real-time command syntax highlighting

#### Aliases

Common commands are aliased to modern replacements when available:

| Alias          | Replacement                                 | Fallback          |
| -------------- | ------------------------------------------- | ----------------- |
| `ls`           | `eza` (with icons, long format, dirs first) | `ls --color=auto` |
| `top`          | `btop`                                      | original          |
| `neofetch`     | `fastfetch`                                 | `neofetch`        |
| `rm`           | `trash -v` (trash-cli)                      | `rm`              |
| `cd`           | `z` (zoxide)                                | `cd`              |
| `reload`       | `exec zsh` (restart shell)                  | N/A               |

Additional aliases: `mv -i` (confirm overwrite), `mkdir -p` (create parents), `cls` (clear), `copy` (xclip), and a full set of `ls` variants (`la`, `ll`, `lt`, `ltree`, `lf`, `ldir`, etc.).

#### Key Commands

These are the main custom functions defined in the zshrc:

##### `updatesys` -- Full System Upgrade

Detects the running distribution and performs a complete system update. Supports **7 distros**: Debian/Ubuntu, Arch, Fedora/RHEL, openSUSE, Alpine, Void Linux, and Solus.

- **Debian/Ubuntu**: Uses `nala` if available, falls back to `apt`. Runs update, upgrade, autoremove, and clean.
- **Arch**: Requires `yay`. Updates the keyring first, upgrades official repos via `pacman`, then AUR packages via `yay` (with cache cleaning to avoid stale builds). Removes orphaned packages.
- **Fedora**: `dnf update`, autoremove, clean.
- **openSUSE**: `zypper ref` + `zypper dup`.
- **Alpine**: `apk update && apk upgrade`.
- **Void**: `xbps-install -S && xbps-install -yu`.
- **Solus**: `eopkg update-repo && eopkg upgrade`.

Also updates **Flatpak** packages if installed. Prints a summary with package count, elapsed time, kernel version, and uptime.

##### `installpkg` -- Interactive Package Installer

Uses `fzf` to fuzzy-search all available packages with a live preview pane showing package details. Select a package and it installs automatically. Works on Debian/Ubuntu (via `apt`/`nala`) and Arch (via `pacman`/`yay`). Bound to **Ctrl+y**.

##### `removepkg` -- Interactive Package Remover

Same `fzf` interface but lists installed packages. The preview pane shows package info and reverse dependencies so you know what depends on it before removing.

##### `updatepkg` -- Selective Package Updater

Lists only packages with available updates. Multi-select with **Tab** in `fzf` to choose exactly which packages to upgrade, rather than updating everything.

##### `cleansys` -- System Cleanup

Cleans package manager caches, removes orphaned packages, truncates log files, vacuums journald (3 days), deletes temp files older than 5 days, empties the trash, and removes unused Flatpak runtimes. Prints a summary with time elapsed and disk usage.

##### `fzfkill` -- Interactive Process Killer

Lists processes sorted by CPU usage. Select one or more with `fzf` (multi-select with **Tab**), confirm, and they are killed.

##### `fzfdel` -- Interactive File Deletion

Fuzzy-search files and directories, multi-select, and move them to trash (recoverable). Bound to **Ctrl+x**.

#### Other Useful Functions

| Function         | Description                                                      |
| ---------------- | ---------------------------------------------------------------- |
| `extract <file>` | Universal archive extractor (tar, zip, rar, 7z, gz, bz2, etc.)   |
| `serve`          | Start an HTTP server in the current directory (Python/PHP)       |
| `ytdl`           | Interactive YouTube downloader via `yt-dlp`                      |
| `whatsmyip`      | Show internal and external IP addresses                          |
| `weather [city]` | Terminal weather forecast via `wttr.in`                          |
| `hb <file>`      | Upload file to a Hastebin instance and copy the URL to clipboard |
| `openremote`     | Open current git repo's remote URL in the browser                |
| `mkcd <dir>`     | Create a directory and cd into it                                |
| `up <n>`         | Go up N directory levels                                         |
| `gl`             | Pretty git log (graph, oneline, all branches)                    |
| `gs`             | Short git status with branch info                                |
| `keybinds`       | Print a table of all custom keybindings                          |
| `topdf <file>`   | Convert DOCX/PPTX/ODT files to PDF using LibreOffice             |
| `sysinfo`        | Display comprehensive system information summary                 |

#### Keybindings

| Key        | Action                                          |
| ---------- | ----------------------------------------------- |
| **Ctrl+f** | Zoxide interactive -- fuzzy directory jump      |
| **Ctrl+y** | `installpkg` -- fuzzy package installer         |
| **Ctrl+r** | Fuzzy history search (deduplicated, via `fzf`)  |
| **Ctrl+t** | Fuzzy file search (inserts path at cursor)      |
| **Ctrl+g** | Fuzzy directory search (inserts path at cursor) |
| **Ctrl+x** | `fzfdel` -- fuzzy file deletion                 |

#### Shell Integrations

The zshrc initializes these tools at the end of the file (if installed):

- **[Starship](https://starship.rs/)** -- Cross-shell prompt with powerline theme
- **[Zoxide](https://github.com/ajeetdsouza/zoxide)** -- Smarter `cd` with frecency (aliased to `cd`)
- **[FZF](https://github.com/junegunn/fzf)** -- Fuzzy finder for interactive searching

---

### Starship

**`starship/.config/starship.toml`** -- A powerline-style prompt with a dark gradient theme using Nerd Font icons.

Segments (left to right): Python venv, username, directory (truncated to 3 levels with icon substitutions like  for Documents), git branch/status, language versions (C, Go, Rust, Node.js, Java, etc.), Docker context, and current time. Shell indicator disabled.

---

### Alacritty

**`alacritty/.config/alacritty/alacritty.toml`** -- GPU-accelerated terminal emulator config.

- Font: JetBrainsMono Nerd Font, size 12
- Opacity: 0.9 (slightly transparent)
- Cursor: beam shape, no blink
- Starts maximized, 10,000-line scrollback
- Shell: `/bin/zsh`

---

### Tmux

**`tmux/.tmux.conf`** -- Terminal multiplexer config with a dark minimal theme.

- Mouse support enabled
- Windows/panes numbered from 1
- 50,000-line scrollback, 10ms escape time
- `prefix + r` to reload config
- Dark status bar (`#1a1a1a`) with powerline-style window tabs
- Auto-renumber windows, activity monitoring, clipboard integration

---

### Git

**`git/.gitconfig`** -- Global git configuration.

- Git LFS enabled
- Credential helper: `store`
- `safe.directory = /*` (trusts all directories)

---

### Nano

**`nano/.nanorc`** -- Text editor config with modern keybindings.

- Syntax highlighting for all supported languages
- 4-space soft tabs, auto-indent, trim trailing whitespace
- Line numbers, soft word wrap at 80 columns
- Remapped keys: Ctrl+S (save), Ctrl+Q (quit), Ctrl+Z (undo), Ctrl+F (find), Ctrl+H (replace)
- Mouse support, backup files stored in `~/.nano/backups`

---

### Fastfetch

**`fastfetch/.config/fastfetch/config.jsonc`** -- System information display (neofetch replacement).

Displays a boxed layout with sections for hardware (host, CPU, GPU, memory), OS info (kernel, WM), software (shell, terminal, packages), and uptime. Includes an "OS Age" field calculated from the filesystem birth timestamp. Uses the builtin logo with a yellow color scheme.

---

## Repository Structure

```text
~/.dotfiles/
├── alacritty/      # Terminal emulator config
├── fastfetch/      # System info display
├── git/            # Git global config
├── nano/           # Text editor config
├── opencode/       # OpenCode (AI editor) config
├── starship/       # Shell prompt theme
├── tmux/           # Terminal multiplexer config
└── zsh/            # Zsh shell config (~1800 lines)
```

Each directory mirrors the structure of `$HOME`. Running `stow <package>` from `~/.dotfiles/` creates the appropriate symlinks (e.g., `stow zsh` creates `~/.zshrc -> ~/.dotfiles/zsh/.zshrc`).

---

*Disclaimer: This README was mostly generated by AI.*
