# dotfiles

Personal dotfiles for Linux, managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a Stow package that symlinks its contents into `$HOME`.

## Setup

```bash
sudo pacman -S --needed --noconfirm git stow zsh starship atuin fzf zoxide eza bat fd trash-cli btop xclip jq libnotify pacman-contrib ttf-jetbrains-mono-nerd yay yt-dlp aria2 libreoffice-fresh nmap lm_sensors unzip unrar 7zip
git clone https://github.com/Owen-3456/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow zsh starship atuin
chsh -s /bin/zsh
```

`stow zsh` creates `~/.zshrc -> ~/.dotfiles/zsh/.zshrc`, and so on for each package. Stow `alacritty`, `tmux`, `nano` and `fastfetch` too if you want them.

All of the above are in the Arch `extra` repo or the CachyOS repos (`yay` ships in the `cachyos` repo; on plain Arch install it from the AUR). Zinit and its plugins clone themselves on the first shell start.

| Package                   | Used for                                                                       |
| ------------------------- | ------------------------------------------------------------------------------ |
| `starship`                | Prompt -- initialised unconditionally, so the shell errors without it          |
| `atuin`                   | Shell history and **Ctrl+r** search                                            |
| `fzf`                     | `fzf-tab`, **Ctrl+t**, **Ctrl+g**, and every `fzf*` / `*pkg` function          |
| `zoxide`                  | `cd` / `j` / `ji`, **Ctrl+f**                                                  |
| `eza`, `bat`, `btop`      | `ls`, `cat` / `less` / `man`, `top` replacements                               |
| `fd`                      | Faster file listing for `fzfdel` and **Ctrl+g** (falls back to `find`)         |
| `trash-cli`               | `rm` alias and `fzfdel`                                                        |
| `xclip`                   | `copy`, and clipboard output in `serve` / `hb`                                 |
| `jq`                      | `hb`                                                                           |
| `libnotify`               | `notify-send` for `zsh-auto-notify`                                            |
| `pacman-contrib`          | `pactree` reverse-deps preview in `removepkg`                                  |
| `ttf-jetbrains-mono-nerd` | Icons in `eza`, Starship and Alacritty                                         |
| `yay`                     | AUR results in `installpkg` / `updatepkg` / `sysinfo` (falls back to `pacman`) |
| `yt-dlp`, `aria2`         | `ytdl` (`aria2` optional, speeds up downloads)                                 |
| `libreoffice-fresh`       | `topdf`                                                                        |
| `nmap`                    | `portscan`                                                                     |
| `lm_sensors`              | CPU temperature in `sysinfo`                                                   |
| `unzip`, `unrar`, `7zip`  | `extract`                                                                      |

---

## Zsh

`zsh/.zshrc` -- the core of this setup (~1100 lines). Targets **CachyOS** and other Arch-based distros; package management is `pacman` plus `yay` only.

**Shell** -- case-insensitive completion with menu select, `**` recursive globbing, spelling correction, flow control disabled (`stty -ixon`).

**History** -- [Atuin](https://atuin.sh/) is the single source of truth. Zsh keeps only a 10,000-entry in-memory buffer (for autosuggestions) and writes no `.zsh_history`. Commands starting with a space are not recorded.

**Environment** -- `EDITOR=nano`, `VISUAL=code -w`, XDG base directories. PATH adds `~/.local/bin`, `~/.cargo/bin`, and the Flatpak export dirs.

### Plugins

Managed by [zinit](https://github.com/zdharma-continuum/zinit), which self-installs on first run:

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

| Alias    | Replacement                    | Fallback          |
| -------- | ------------------------------ | ----------------- |
| `ls`     | `eza` (icons, dirs first, git) | `ls --color=auto` |
| `cat`    | `bat` (plain, no pager)        | `cat`             |
| `less`   | `bat` (full style, paged)      | `less`            |
| `top`    | `btop`                         | `top`             |
| `rm`     | `trash -v` (recoverable)       | `rm`              |
| `cd`     | `j` (zoxide, frecency-based)   | `cd`              |
| `reload` | `exec zsh`                     | --                |

Also `cp -i` / `mv -i` (confirm overwrite), `mkdir -p`, `copy` (xclip), `openports` (`ss -tulnp`), `checkcommand` (`whence -w`), `myip` (`whatsmyip`), `reboot`, and `ls` variants `ll`, `la`, `lt`, `lk`, `lx`, `lr`, `lw`, `lf`, `ldir`, `ltree`.

### Functions

| Function          | Description                                                           |
| ----------------- | --------------------------------------------------------------------- |
| `installpkg`      | `fzf` picker over repos + AUR, installs the selection (**Ctrl+y**)    |
| `removepkg`       | `fzf` picker over installed packages; preview shows reverse deps      |
| `updatepkg`       | `fzf` picker limited to packages with updates available               |
| `fzfkill`         | `fzf` process picker sorted by CPU, with signal choice                |
| `fzfdel`          | `fzf` file picker, moves selection to trash (**Ctrl+x**)              |
| `sysinfo`         | System health dashboard -- CPU, memory, disk, network, units, updates |
| `extract <file>`  | Universal archive extractor (tar, zip, rar, 7z, gz, bz2, zst, ...)    |
| `topdf`           | Convert `.docx` / `.pptx` in the current directory to PDF             |
| `serve [port]`    | HTTP server in the current directory (python3, python, or php)        |
| `ytdl [url]`      | Download a video to `~/Videos` via `yt-dlp`                           |
| `whatsmyip`       | Show internal and external IP addresses                               |
| `weather [city]`  | Terminal weather forecast via `wttr.in`                               |
| `hb <file>`       | Upload a file to Hastebin and copy the URL (plain HTTP)               |
| `openremote`      | Open the current repo's `origin` URL in the browser                   |
| `portscan <host>` | Full TCP port scan via `nmap`                                         |
| `linutil`         | Run Chris Titus' Linux utility script (asks first)                    |
| `mkcd <dir>`      | Create a directory and `cd` into it                                   |
| `cpg` / `mvg`     | Copy / move a file, then `cd` into the destination if it's a dir      |
| `up <n>`          | Go up N directory levels                                              |
| `gl` / `gs`       | Pretty git log (graph, all branches) / short git status               |
| `keybinds`        | Print the custom keybinding table below                               |

### Keybindings

| Key        | Action                                          |
| ---------- | ----------------------------------------------- |
| **Ctrl+f** | Zoxide interactive -- fuzzy directory jump      |
| **Ctrl+y** | `installpkg` -- fuzzy package installer         |
| **Ctrl+r** | Atuin history search                            |
| **Ctrl+t** | Fuzzy file search (inserts path at cursor)      |
| **Ctrl+g** | Fuzzy directory search (inserts path at cursor) |
| **Ctrl+x** | `fzfdel` -- fuzzy file deletion                 |

[FZF](https://github.com/junegunn/fzf) shell integration loads after the plugins (supplies Ctrl+t and Alt+c). Initialised at the end of the file: [Starship](https://starship.rs/) (prompt, always), [Zoxide](https://github.com/ajeetdsouza/zoxide) (as `j` / `ji`, aliased to `cd`, if installed), and [Atuin](https://atuin.sh/) (if installed). Atuin loads last so its Ctrl+r binding overrides fzf's.

---

## Atuin

`atuin/.config/atuin/config.toml` -- only sets `sync_address` to a self-hosted sync server (`http://edoras:8899`); everything else is Atuin's defaults. Run `atuin login` (or `atuin register`) once, then `atuin sync`.

---

## Starship

`starship/.config/starship.toml` -- powerline prompt with a dark gradient theme and Nerd Font icons.

Segments left to right: Python venv, username, directory (3 levels, icon substitutions), git branch and status, language versions (C, Go, Rust, Node, Java, ...), Docker context, time.

## Alacritty

`alacritty/.config/alacritty/alacritty.toml` -- GPU-accelerated terminal.

JetBrainsMono Nerd Font 12, opacity 0.9, beam cursor without blink, starts maximized, 10,000-line scrollback, shell `/bin/zsh`.

## Tmux

`tmux/.tmux.conf` -- dark minimal theme.

Plugins via [TPM](https://github.com/tmux-plugins/tpm): `tmux-sensible`, `tmux-resurrect` + `tmux-continuum` (sessions saved and auto-restored), `tmux-yank`. TPM isn't self-installing -- clone it with `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`, then press `prefix + I`.

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
├── atuin/          # Shell history sync config
├── fastfetch/      # System info display
├── nano/           # Text editor config
├── starship/       # Shell prompt theme
├── tmux/           # Terminal multiplexer config
└── zsh/            # Zsh shell config
```

Each directory mirrors the structure of `$HOME`.

---

*Disclaimer: This README was mostly generated by AI because I hate making READMEs.*
