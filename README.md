# tmux-tpad

A lightweight floating window manager for tmux that allows you to create customizable popup sessions for different workflows.

![tpad](https://github.com/user-attachments/assets/b2c0e701-e9dd-45a8-9849-ae6328a6f933)

## Features

- Create multiple named popup sessions with different configurations
- Customize appearance, size, and position of each popup
- Run specific commands automatically when opening a popup
- Set custom working directories per popup
- Support for custom key bindings and tmux prefix keys

## Installation

### Using TPM (recommended)

1. Install [Tmux Plugin Manager (TPM)](https://github.com/tmux-plugins/tpm) if you haven't already
2. Add the following to your `~/.tmux.conf`:
   ```tmux
   set -g @plugin 'Subbeh/tmux-tpad'
   ```
3. Press `prefix` + <kbd>I</kbd> to install the plugin

## Configuration

TPad sessions are configured using tmux options in the format: `@tpad-<session_name>-<option>`.

### Required Options
| Option | Description |
|--------|-------------|
| bind   | Key binding to toggle the popup session (e.g., "C-p" for Ctrl+P) |

### Appearance Options
| Option        | Default | Description |
|---------------|---------|-------------|
| title         | `#[fg=magenta,bold] 󱂬 TPad: @instance@ ` | Popup window title |
| width         | 60%     | Popup width (percentage or columns) |
| height        | 60%     | Popup height (percentage or rows) |
| style         | fg=blue | Popup window style |
| border_style  |         | Border style (e.g., "fg=cyan") |
| border_lines  | rounded | Border line style (rounded/none/etc) |
| pos_x         |         | Horizontal position (optional) |
| pos_y         |         | Vertical position (optional) |

### Behavior Options
| Option  | Default | Description |
|---------|---------|-------------|
| dir     | $HOME   | Working directory for the session |
| cmd     |         | Command to execute when popup opens |
| prefix  |         | Custom tmux prefix for the session |
| env     |         | Additional environment variables |

## Example Configuration

Here's a comprehensive example showing different use cases:

```tmux
# Simple scratchpad
set -g @tpad-scratchpad-bind    "C-p"

# Git management with lazygit
set -g @tpad-git-bind           "C-g"
set -g @tpad-git-dir           "#{pane_current_path}"
set -g @tpad-git-cmd           "lazygit"
set -g @tpad-git-style         "fg=yellow"

# Notes with Neovim
set -g @tpad-notes-bind        "C-n"
set -g @tpad-notes-dir         "${NOTES_DIR}"
set -g @tpad-notes-cmd         "nvim -c NvimTreeOpen"
set -g @tpad-notes-prefix      "None"
set -g @tpad-notes-width       "80%"
set -g @tpad-notes-height      "80%"

# Task management
set -g @tpad-tasks-bind        "C-t"
set -g @tpad-tasks-style       "fg=green"
set -g @tpad-tasks-height      "40%"
set -g @tpad-tasks-width       "40%"
set -g @tpad-tasks-cmd         "taskwarrior-tui"
```

## Usage

1. Configure your popup sessions in `tmux.conf` as shown above
2. Press your tmux prefix key (default: <kbd>Ctrl</kbd>+<kbd>b</kbd>)
3. Press the configured key binding to toggle the popup (e.g., <kbd>Ctrl</kbd>+<kbd>g</kbd> for the git session)
4. The popup will close automatically when the command exits

### Full-screen mode

Full-screen mode can be toggled by pressing the tmux prefix key with <kbd>Ctrl</kbd>+<kbd>f</kbd> from within a tpad session

## Roadmap

- [ ] Window controls (resize, maximize, minimize)
- [ ] Image support for terminals with kitty protocol
- [ ] Session persistence options
- [ ] Multiple popup layouts/splits

## Credits

This project was inspired by:
- [Dismissable Popup Shell in tmux](https://willhbr.net/2023/02/07/dismissable-popup-shell-in-tmux/)
- [omerxx/tmux-floax](https://github.com/omerxx/tmux-floax)

## License

MIT
