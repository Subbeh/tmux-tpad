#!/usr/bin/env bash
set -x

exec &>>"${XDG_CACHE_HOME:-$HOME/.cache}/tpad.log"

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TPAD="${CURRENT_DIR}/tpad.tmux"

declare -A DEFAULTS=(
  [title]="#[fg=magenta,bold] 󱂬 TPad: @instance@ "
  [dir]="$HOME"
  [width]="60%"
  [height]="60%"
  [style]="fg=blue"
  [border_lines]="rounded"
)

main() {
  if [ "$1" = "" ]; then
    tmux show-options -g | awk -v FS="-" '/^@tpad/{ print $2}' | sort -u | while read -r instance; do
      bind_key "$instance"
    done
  else
    case "$1" in
    toggle) toggle_popup "$2" ;;
    esac
  fi
}

toggle_popup() {
  session="tpad_$1"

  if [ "$(tmux display-message -p '#{session_name}')" = "$session" ]; then
    tmux detach
  else
    if ! tmux has -t "$session" 2>/dev/null; then
      session_id="$(tmux new-session -dP -s "$session" -F '#{session_id}')"

      tmux set-option -s -t "$session_id" default-terminal "$TERM"
      tmux set-option -s -t "$session_id" key-table "$session"
      tmux set-option -s -t "$session_id" status off
      tmux set-option -s -t "$session_id" detach-on-destroy on

      prefix="$(get_val "$1" prefix)"
      [[ "$prefix" ]] && tmux set-option -s -t "$session_id" prefix "$prefix"

      cmd="$(get_val "$1" cmd)"
      [[ "$cmd" ]] && tmux send-keys -t "$session_id" "$cmd" C-m
      session="$session_id"
    fi
    exec tmux attach -t "$session" >/dev/null
  fi
}

get_val() {
  var="@tpad-$1-$2"
  val=$(tmux show-option -gqv "$var")
  if [ "$val" = "" ]; then
    val=${DEFAULTS[$2]/@instance@/${1^}}
  fi
  echo "$val"
}

get_opts() {
  for opt in T-title S-style s-border_style b-border_lines h-height w-width x-pos_x y-pos_y d-dir e-env; do
    IFS=- read -r o v <<<"$opt"
    val=$(get_val "$1" "$v")
    if [ "$val" != "" ]; then
      opts+=" -$o \"$val\""
    fi
  done

  echo "$opts"
}

bind_key() {
  session="tpad_$1"
  key=$(get_val "$1" bind)
  if [[ "$key" ]]; then
    eval "tmux bind \"$key\" display-popup $(get_opts "$1") -E \"$TPAD toggle $1\""
    tmux bind -T "$session" "$key" run-shell "$TPAD toggle $1"
  fi
}

main "$@"
