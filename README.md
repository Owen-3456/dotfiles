# dotfiles

Personal dotfiles for Linux, managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a Stow package that symlinks its contents into `$HOME`.

## Setup

```bash
git clone https://github.com/Owen-3456/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow zsh alacritty starship tmux   # or any subset
```

`stow zsh` creates `~/.zshrc -> ~/.dotfiles/zsh/.zshrc`, and so on for each package.

---

## Zsh

`zsh/.zshrc` -- the core of this setup (~1100 lines). Targets **CachyOS** and other Arch-based distros; package management is `pacman` plus `yay`/`paru` only.

**Shell** -- case-insensitive completion with menu select, `**` recursive globbing, spelling correction, 10,000-line history shared across sessions and deduplicated, flow control disabled (`stty -ixon`).

**Environment** -- `EDITOR=nano`, `VISUAL=code -w`, XDG base directories. PATH adds `~/.local/bin`, `~/.cargo/bin`, and the Flatpak export dirs.

### Plugins

Managed by [zinit](https://github.com/zdharma-continuum/zinit), which self-installs on first run:

| Plugin                      | Purpose                                     |
| --------------------------- | ------------------------------------------- |
| `zsh-completions`           | Extra completion definitions                |
| `zsh-autosuggestions`       | Fish-like suggestions from history          |
| `fzf-tab`                   | FZF tab completion with file previews       |
| `zsh-autopair`              | Auto-close brackets, quotes, parens         |
| `zsh-you-should-use`        | Reminds you of existing aliases             |
| `zsh-auto-notify`           | Desktop notification for long commands      |
| `history-search-multi-word` | Multi-word history search with highlighting |
| `fast-syntax-highlighting`  | Real-time command syntax highlighting       |

### Aliases

| Alias    | Replacement                    | Fallback          |
| -------- | ------------------------------ | ----------------- |
| `ls`     | `eza` (icons, dirs first, git) | `ls --color=auto` |
| `cat`    | `bat` (plain, no pager)        | `cat`             |
| `less`   | `bat` (full style, paged)      | `less`            |
| `top`    | `btop`                         | `top`             |
| `rm`     | `trash -v` (recoverable)       | `rm`              |
| `cd`     | `j` (zoxide, frecency-based)   | `cd`              |
| `reload` | `exec zsh`                     | --                |

Also `cp -i` / `mv -i` (confirm overwrite), `mkdir -p`, `copy` (xclip), and `ls` variants `ll`, `la`, `lt`, `lk`, `lx`, `lr`, `lw`, `lf`, `ldir`, `ltree`.

### Functions

| Function         | Description                                                           |
| ---------------- | --------------------------------------------------------------------- |
| `installpkg`     | `fzf` picker over repos + AUR, installs the selection (**Ctrl+y**)    |
| `removepkg`      | `fzf` picker over installed packages; preview shows reverse deps      |
| `updatepkg`      | `fzf` picker limited to packages with updates available               |
| `fzfkill`        | `fzf` process picker sorted by CPU, with signal choice                |
| `fzfdel`         | `fzf` file picker, moves selection to trash (**Ctrl+x**)              |
| `sysinfo`        | System health dashboard -- CPU, memory, disk, network, units, updates |
| `extract <file>` | Universal archive extractor (tar, zip, rar, 7z, gz, bz2, zst, ...)    |
| `topdf`          | Convert `.docx` / `.pptx` in the current directory to PDF             |
| `serve [port]`   | HTTP server in the current directory (python3, python, or php)        |
| `ytdl [url]`     | Download a video to `~/Videos` via `yt-dlp`                           |
| `whatsmyip`      | Show internal and external IP addresses                               |
| `weather [city]` | Terminal weather forecast via `wttr.in`                               |
| `hb <file>`      | Upload a file to Hastebin and copy the URL (plain HTTP)               |
| `openremote`     | Open the current repo's `origin` URL in the browser                   |
| `mkcd <dir>`     | Create a directory and `cd` into it                                   |
| `up <n>`         | Go up N directory levels                                              |
| `gl` / `gs`      | Pretty git log (graph, all branches) / short git status               |
| `keybinds`       | Print the custom keybinding table below                               |

### Keybindings

| Key        | Action                                          |
| ---------- | ----------------------------------------------- |
| **Ctrl+f** | Zoxide interactive -- fuzzy directory jump      |
| **Ctrl+y** | `installpkg` -- fuzzy package installer         |
| **Ctrl+r** | Fuzzy history search                            |
| **Ctrl+t** | Fuzzy file search (inserts path at cursor)      |
| **Ctrl+g** | Fuzzy directory search (inserts path at cursor) |
| **Ctrl+x** | `fzfdel` -- fuzzy file deletion                 |

Initialised at the end of the file, if installed: [Starship](https://starship.rs/) (prompt), [Zoxide](https://github.com/ajeetdsouza/zoxide) (aliased to `cd`), and [FZF](https://github.com/junegunn/fzf) (supplies Ctrl+r and Ctrl+t).

---

## Starship

`starship/.config/starship.toml` -- powerline prompt with a dark gradient theme and Nerd Font icons.

Segments left to right: Python venv, username, directory (3 levels, icon substitutions), git branch and status, language versions (C, Go, Rust, Node, Java, ...), Docker context, time.

## Alacritty

`alacritty/.config/alacritty/alacritty.toml` -- GPU-accelerated terminal.

JetBrainsMono Nerd Font 12, opacity 0.9, beam cursor without blink, starts maximized, 10,000-line scrollback, shell `/bin/zsh`.

## Tmux

`tmux/.tmux.conf` -- dark minimal theme.

Mouse support, windows and panes numbered from 1, 50,000-line scrollback, 10 ms escape time, `prefix + r` reloads, status bar `#1a1a1a` with powerline tabs, auto-renumbering and clipboard integration.

## Nano

`nano/.nanorc` -- syntax highlighting for all supported languages, 4-space soft tabs, auto-indent, line numbers, soft wrap, mouse support, backups in `~/.nano/backups`.

Remapped keys: **Ctrl+S** save, **Ctrl+Q** quit, **Ctrl+Z** undo, **Ctrl+F** find, **Ctrl+H** replace.

## Fastfetch

`fastfetch/.config/fastfetch/config.jsonc` -- boxed layout covering hardware, OS, software and uptime, plus an "OS Age" field derived from the filesystem birth timestamp. Builtin logo, yellow scheme.

---

## Repository Structure

```text
~/.dotfiles/
├── alacritty/      # Terminal emulator config
├── fastfetch/      # System info display
├── nano/           # Text editor config
├── opencode/       # OpenCode (AI editor) config
├── starship/       # Shell prompt theme
├── tmux/           # Terminal multiplexer config
└── zsh/            # Zsh shell config
```

Each directory mirrors the structure of `$HOME`.

---

*Disclaimer: This README was mostly generated by AI because I hate making READMEs.*
