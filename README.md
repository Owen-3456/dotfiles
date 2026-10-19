# dotfiles

Personal dotfiles for [CachyOS](https://cachyos.org/), managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a Stow package that mirrors `$HOME`, so stowing it symlinks its files into place.

## Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Owen-3456/dotfiles/main/install.sh)
```

Or from a clone (it must be at `~/.dotfiles`):

```bash
git clone https://github.com/Owen-3456/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

`install.sh` asks before each step and is safe to re-run. It:

1. Checks it's running on CachyOS with sudo access and an internet connection
2. Runs a full system upgrade and installs `git`, `base-devel`, `stow` and `zsh`
3. Clones this repo to `~/.dotfiles` (if it isn't there already)
4. Installs `yay` and offers to remove any other AUR helper (paru, pikaur, ...)
5. Installs everything in [`packages.txt`](packages.txt)
6. Stows the packages you pick. If a file is already in the way, you can rename it to `*.old`, delete it, or skip that package
7. Creates `~/.nano/backups`, installs TPM for tmux, and sets zsh as your default shell

Afterwards, log out and back in. Zinit installs its plugins on the first shell start. Then run `atuin login` (or `atuin register`) and `atuin sync`, and press `prefix + I` inside tmux to install its plugins.

To stow a single package by hand:

```bash
stow --no-folding -d ~/.dotfiles -t ~ <package>
```

---

## Zsh

`zsh/.zshrc` is the core of this setup.

- **Shell**: case-insensitive completion with menu select, `**` recursive globbing, spelling correction, flow control disabled (`stty -ixon`).
- **History**: [Atuin](https://atuin.sh/) is the single source of truth. Zsh keeps only a 10,000-entry in-memory buffer (for autosuggestions) and writes no `.zsh_history`. Commands starting with a space aren't recorded.
- **Environment**: `EDITOR=nano`, `VISUAL=code -w`, XDG base directories. PATH adds `~/.local/bin`, `~/.cargo/bin` and the Flatpak export dirs.

### Plugins

Managed by [zinit](https://github.com/zdharma-continuum/zinit), which installs itself on first run.

| Plugin                     | Purpose                                |
| -------------------------- | -------------------------------------- |
| `zsh-completions`          | Extra completion definitions           |
| `zsh-autosuggestions`      | Fish-like suggestions from history     |
| `fzf-tab`                  | FZF tab completion with file previews  |
| `zsh-autopair`             | Auto-close brackets, quotes, parens    |
| `zsh-you-should-use`       | Reminds you of existing aliases        |
| `zsh-auto-notify`          | Desktop notification for long commands |
| `fast-syntax-highlighting` | Real-time command syntax highlighting  |

### Aliases

Each replacement only applies if the tool is installed.

| Alias  | Replacement                    |
| ------ | ------------------------------ |
| `ls`   | `eza` (icons, dirs first, git) |
| `cat`  | `bat` (plain, no pager)        |
| `less` | `bat` (full style, paged)      |
| `top`  | `btop`                         |
| `rm`   | `trash -v` (recoverable)       |
| `cd`   | `j` (zoxide, frecency-based)   |

Also: `cp -i` / `mv -i` (confirm overwrite), `mkdir -p`, `reload` (`exec zsh`), `copy` (xclip), `openports` (`ss -tulnp`), `checkcommand` (`whence -w`), `myip` (`whatsmyip`), `reboot`, and the `ls` variants `ll`, `la`, `lt`, `lk`, `lx`, `lr`, `lw`, `lf`, `ldir`, `ltree`.

### Functions

| Function                     | Description                                                                          |
| ---------------------------- | ------------------------------------------------------------------------------------ |
| `installpkg`                 | `fzf` picker over repos + AUR, installs the selection (**Ctrl+y**)                   |
| `removepkg`                  | `fzf` picker over installed packages; preview shows reverse deps                     |
| `updatepkg`                  | Browse pending repo + AUR updates in `fzf`, then run a full `yay -Syu`               |
| `fzfkill`                    | `fzf` process picker sorted by CPU, with signal choice                               |
| `fzfdel`                     | `fzf` file picker, moves selection to trash (**Ctrl+x**)                             |
| `sysinfo`                    | System health dashboard: CPU, memory, disk, network, units, updates                  |
| `extract <file>`             | Universal archive extractor (tar, zip, rar, 7z, gz, bz2, zst, ...)                   |
| `topdf`                      | Convert `.docx` / `.pptx` in the current directory to PDF, then delete the originals |
| `serve [port]`               | HTTP server in the current directory (python3, python, or php)                       |
| `ytdl [url] [quality] [dir]` | Download a video with `yt-dlp` (default 1080p into `~/Videos`)                       |
| `whatsmyip`                  | Show internal and external IP addresses                                              |
| `weather [city]`             | Terminal weather forecast via `wttr.in`                                              |
| `hb <file>`                  | Upload a file to Hastebin and copy the URL (plain HTTP)                              |
| `openremote`                 | Open the current repo's `origin` URL in the browser                                  |
| `portscan <host>`            | Full TCP port scan via `nmap`                                                        |
| `linutil`                    | Run Chris Titus' Linux utility script (asks first)                                   |
| `mkcd <dir>`                 | Create a directory and `cd` into it                                                  |
| `cpg` / `mvg`                | Copy / move a file, then `cd` into the destination if it's a dir                     |
| `up <n>`                     | Go up N directory levels                                                             |
| `gl` / `gs`                  | Pretty git log (graph, all branches) / short git status                              |
| `keybinds`                   | Print the custom keybinding table below                                              |

### Keybindings

| Key        | Action                                          |
| ---------- | ----------------------------------------------- |
| **Ctrl+f** | Zoxide interactive: fuzzy directory jump        |
| **Ctrl+y** | `installpkg`: fuzzy package installer           |
| **Ctrl+r** | Atuin history search                            |
| **Ctrl+t** | Fuzzy file search (inserts path at cursor)      |
| **Ctrl+g** | Fuzzy directory search (inserts path at cursor) |
| **Ctrl+x** | `fzfdel`: fuzzy file deletion                   |

---

## Other configs

- **Atuin** (`atuin/.config/atuin/config.toml`): only sets `sync_address` to a self-hosted sync server (`http://edoras:8899`); everything else is Atuin's defaults.
- **Starship** (`starship/.config/starship.toml`): plain single-line prompt in mid-brightness contrasting colours, with extra context pushed to the right edge. Left: `user@host:` (󰣀 over SSH, red user as root), path with the repo root in bold, git branch / state / status / `+-` line counts, Python venv, a sudo-cached icon and a `❯` that turns red on failure. Right: exit code, duration of commands over 2s, background jobs, language versions (inside projects only), Docker/Kubernetes context, RAM and battery warnings, and the time.
- **Alacritty** (`alacritty/.config/alacritty/alacritty.toml`): JetBrainsMono Nerd Font 12, opacity 0.9, non-blinking beam cursor, starts maximized, 10,000-line scrollback, runs zsh.
- **Tmux** (`tmux/.tmux.conf`): dark minimal theme with a centred window list. Mouse support, windows and panes numbered from 1, 50,000-line scrollback, `prefix + r` reloads. Plugins via [TPM](https://github.com/tmux-plugins/tpm): `tmux-sensible`, `tmux-resurrect` + `tmux-continuum` (sessions saved and auto-restored) and `tmux-yank`.
- **Nano** (`nano/.nanorc`): syntax highlighting, 4-space soft tabs, auto-indent, line numbers, soft wrap, mouse support, spell check with `aspell`, backups in `~/.nano/backups`. Keys are remapped to common defaults: **Ctrl+S** save, **Ctrl+Q** quit, **Ctrl+C** / **Ctrl+X** / **Ctrl+V** copy / cut / paste, **Ctrl+Z** / **Ctrl+Y** undo / redo, **Ctrl+F** find, **Ctrl+H** replace, **Ctrl+G** go to line.
- **Fastfetch** (`fastfetch/.config/fastfetch/config.jsonc`): boxed layout covering hardware, OS, software and uptime, plus an "OS Age" field from the root filesystem's creation date.

---

## Repository structure

```text
~/.dotfiles/
├── install.sh      # Setup script
├── packages.txt    # Packages installed by install.sh
├── alacritty/      # Terminal emulator
├── atuin/          # Shell history sync
├── fastfetch/      # System info display
├── nano/           # Text editor
├── starship/       # Shell prompt
├── tmux/           # Terminal multiplexer
└── zsh/            # Zsh shell
```

---

*Disclaimer: This README was mostly generated by AI because I hate making READMEs.*
