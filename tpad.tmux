#!/usr/bin/env bash
set -eo pipefail

# Configuration
if [[ "$(tmux show-options -gqv @tpad-debug)" == "true" ]]; then
  LOG_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/tpad.log"
  exec &>>"$LOG_FILE"

  set -x
fi

readonly CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TPAD_SCRIPT="${CURRENT_DIR}/tpad.tmux"

declare -A DEFAULTS=(
  [title]="#[fg=magenta,bold] 󱂬 TPad: @instance@ "
  [dir]="$HOME"
  [width]="60%"
  [height]="60%"
  [style]="fg=blue"
  [border_style]="fg=cyan,rounded"
)

main() {
  check_dependencies
  case "${1:-}" in
    toggle) toggle_popup "$2" ;;
    fullscreen) toggle_fullscreen ;;
    "") initialize_instances ;;
    *)
      show_help
      exit 1
      ;;
  esac
}

initialize_instances() {
  tmux bind-key "C-f" run-shell "$TPAD_SCRIPT fullscreen"
  tmux show-options -g | awk -v FS="-" '/^@tpad/{ print $2}' | sort -u | while read -r instance; do
    bind_key "$instance"
  done
}

toggle_popup() {
  local instance="$1"
  local session="tpad_${instance}"
  local current_session="$(tmux display-message -p '#{session_name}')"

  if [[ "$current_session" == "$session" ]]; then
    if tmux show-env -g TPAD_ZOOMED | grep -q "$session"; then
      tmux setenv -g -u TPAD_ZOOMED
      tmux switch-client -t "$(tmux show-env -g TPAD_PARENT_SESSION | cut -d= -f2)"
    else
      tmux detach
    fi
  else
    if [[ "$current_session" =~ tpad_* ]]; then
      tmux detach
    fi
    tmux setenv -g TPAD_PARENT_SESSION "$current_session"
    create_session_if_needed "$instance" "$session"
    local popup_opts=()
    while IFS= read -r opt; do
      popup_opts+=("$opt")
    done < <(build_popup_options "$instance")

    tmux display-popup "${popup_opts[@]}" -E "tmux attach -t $session"
  fi
}

create_session_if_needed() {
  local instance="$1"
  local session="$2"
  tmux has-session -t "$session" 2>/dev/null && return

  local dir="$(get_config "$instance" dir)"
  local session_id="$(tmux new-session -dP -s "$session" -c "$dir" -F '#{session_id}')"
  configure_session "$instance" "$session_id"
}

configure_session() {
  local instance="$1"
  local session_id="$2"
  apply_session_config "$instance" "$session_id"

  local cmd="$(get_config "$instance" cmd)"
  if [[ -n "$cmd" ]]; then
    tmux send-keys -t "$session_id" "$cmd; exit" C-m
  fi
}

apply_session_config() {
  local instance="$1"
  local session_id="$2"
  tmux set -t "$session_id" default-terminal "$TERM"
  tmux set -t "$session_id" key-table "tpad_$instance"
  tmux set -t "$session_id" status off
  tmux set -t "$session_id" detach-on-destroy on
  set_opts "$instance" "$session_id"

  local prefix="$(get_config "$instance" prefix)"
  if [[ -n "$prefix" ]]; then
    tmux set -t "$session_id" prefix "$prefix"
  fi
}

set_opts() {
  local instance="$1"
  local session_id="$2"
  local opts="$(get_config "$instance" opts)"
  [[ -z "$opts" ]] && return

  while IFS=';' read -r opt; do
    [[ -n "$opt" ]] && tmux set-option -t "$session_id" $opt
  done <<<"$opts"
}

get_config() {
  local instance="$1"
  local key="$2"
  local tmux_var="@tpad-${instance}-${key}"
  local val="$(tmux show-option -gqv "$tmux_var")"

  if [[ -z "$val" ]]; then
    val="${DEFAULTS[$key]/@instance@/${instance^}}"
  fi

  echo "$val"
}

bind_key() {
  local instance="$1"
  local key="$(get_config "$instance" bind)"
  [[ -z "$key" ]] && return

  tmux bind-key "$key" run-shell "$TPAD_SCRIPT toggle $instance"
  tmux bind-key -T "tpad_$instance" "$key" run-shell "$TPAD_SCRIPT toggle $instance"
}

build_popup_options() {
  local instance="$1"
  declare -A opt_map=(
    [T]="title"
    [S]="style"
    [s]="border_style"
    [b]="border_lines"
    [h]="height"
    [w]="width"
    [x]="pos_x"
    [y]="pos_y"
    [d]="dir"
    [e]="env"
  )

  for opt in "${!opt_map[@]}"; do
    local val="$(get_config "$instance" "${opt_map[$opt]}")"
    [[ -n "$val" ]] && echo "-${opt}" "${val}"
  done
}

check_dependencies() {
  if ! command -v tmux &>/dev/null; then
    echo "Error: tmux is required but not installed" >&2
    exit 1
  fi
}

toggle_fullscreen() {
  local current_session="$(tmux display-message -p '#{session_name}')"
  local parent_session="$(tmux show-env -g TPAD_PARENT_SESSION | cut -d= -f2)"
  local instance="${current_session#tpad_}"

  if [[ "$current_session" =~ tpad_* ]]; then
    local zoomed_session="$(tmux show-env -g TPAD_ZOOMED | cut -d= -f2)"
    if [[ -n "$zoomed_session" ]]; then
      # Exiting fullscreen mode - clear fullscreen settings and restore config
      tmux setenv -g -u TPAD_ZOOMED
      tmux set -u -t "$current_session" status-left
      tmux set -u -t "$current_session" status-right
      tmux set -u -t "$current_session" status-justify
      tmux set -u -t "$current_session" status-position
      tmux set -u -t "$current_session" status-style
      apply_session_config "$instance" "$current_session"
      tmux switch-client -t "$parent_session"
      toggle_popup "$instance"
    else
      # Entering fullscreen mode
      tmux setenv -g TPAD_ZOOMED "$current_session"
      tmux detach
      tmux switch-client -t "$current_session"

      local title="$(get_config "$instance" title)"
      tmux set -t "$current_session" status on
      tmux set -t "$current_session" status-justify centre
      tmux set -t "$current_session" status-position top
      tmux set -t "$current_session" status-left ""
      tmux set -t "$current_session" status-right "${title} [FULLSCREEN]"
      tmux set -t "$current_session" status-style "bg=terminal,fg=terminal"
    fi
  fi
}

show_help() {
  cat <<EOF
TPad - Tmux Popup Manager

Usage:
  tpad.tmux [command]

Commands:
  (no command)  Initialize all configured instances
  toggle        Toggle a popup instance
EOF
}

main "$@"
