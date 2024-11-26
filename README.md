# tmux-tpad

A simple floating window manager for Tmux.

![tpad](https://github.com/user-attachments/assets/b2c0e701-e9dd-45a8-9849-ae6328a6f933)

# Installation

Make sure you have [TPM](https://github.com/tmux-plugins/tpm) installed, and add the following line to your `tmux.conf` configuration file:

```bash
set -g @plugin 'Subbeh/tmux-tpad'
```

Press prefix + I (capital i, as in Install) to fetch the plugin.

# Configuration

TPad sessions are defined wtih `@tpad-<session_name>-<option>` options. As long as there is at least one option defined, the TPad session will be created.

### Options

See `:man tmux` and search for `display-popup` for more information

| Option       | Default                                  | Explanation                         |
| ------------ | ---------------------------------------- | ----------------------------------- |
| bind         |                                          | Keybinding to open session          |
| prefix       | None                                     | Tmux prefix key assigned to session |
| title        | `#[fg=magenta,bold] 󱂬 TPad: @instance@ ` | Popup title                         |
| dir          | `$HOME`                                  | Startup directory                   |
| width        | 60%                                      | Popup width                         |
| height       | 60%                                      | Popup height                        |
| style        | `fg=blue`                                | Popup formatting style              |
| border_style |                                          | Popup border formatting style       |
| border_lines | rounded                                  | Popup border line formatting        |
| pos_x        |                                          | X position of popup                 |
| pos_y        |                                          | Y position of popup                 |
| env          |                                          | Environement variable for session   |
| cmd          |                                          | Command to execute in session       |

#### Example:

```sh
set -g @tpad-scratchpad-bind    'C-p'
set -g @tpad-scratchpad-prefix  'C-s'

set -g @tpad-notes-bind         'C-n'
set -g @tpad-notes-style        'fg=yellow'
set -g @tpad-notes-dir          "${NOTES_DIR}"
set -g @tpad-notes-cmd          "nvim"

set -g @tpad-tasks-bind         'C-t'
set -g @tpad-tasks-style        'fg=green'
set -g @tpad-tasks-height       '40%'
set -g @tpad-tasks-width        '40%'
set -g @tpad-tasks-cmd          "taskwarrior-tui"
```

This will create 3 separate sessions -- `scratchpad`, `notes`, and `tasks`.

# Usage

Press the prefix key, followed by the key binding defined with the `@tpad-<session>-bind` option to toggle the popup.

# Todo

- [ ] Window controls (resize, maximize, etc.)

# Acknowledgments

[Dismissable Popup Shell in tmux](https://willhbr.net/2023/02/07/dismissable-popup-shell-in-tmux/)

[omerxx/tmux-floax](https://github.com/omerxx/tmux-floax)
