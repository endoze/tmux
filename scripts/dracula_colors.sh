#!/usr/bin/env bash
# Dracula Color Configuration
#
# This file defines all color palette and UI element variables.
# It is sourced from dracula.sh after config options are loaded.
#
# Every variable can be overridden via tmux options:
#   - Palette colors: @dracula-color-<name> (e.g., @dracula-color-blue)
#   - Element colors: @dracula-<element> (e.g., @dracula-left-icon-bg)

# ── Color Resolution ─────────────────────────────────────────────────────────
# Resolves a color name (e.g. "blue") to its palette variable ($blue), or
# passes through hex values and other literals unchanged.  This gives element
# overrides the same indirect-expansion behaviour that plugin widget colors
# already get via ${!colors[0]}.
resolve_color() {
  local value="$1"
  if [[ "$value" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] && [[ -n "${!value+x}" ]]; then
    echo "${!value}"
  else
    echo "$value"
  fi
}

# ── Base Palette ──────────────────────────────────────────────────────────────
white=$(get_tmux_option "@dracula-color-white" "#f8f8f2")
gray=$(get_tmux_option "@dracula-color-gray" "#44475a")
dark_gray=$(get_tmux_option "@dracula-color-dark-gray" "#282a36")
light_purple=$(get_tmux_option "@dracula-color-light-purple" "#bd93f9")
dark_purple=$(get_tmux_option "@dracula-color-dark-purple" "#6272a4")
cyan=$(get_tmux_option "@dracula-color-cyan" "#8be9fd")
green=$(get_tmux_option "@dracula-color-green" "#50fa7b")
orange=$(get_tmux_option "@dracula-color-orange" "#ffb86c")
red=$(get_tmux_option "@dracula-color-red" "#ff5555")
purple=$(get_tmux_option "@dracula-color-purple" "#b166cc")
pink=$(get_tmux_option "@dracula-color-pink" "#ff79c6")
yellow=$(get_tmux_option "@dracula-color-yellow" "#f1fa8c")
black=$(get_tmux_option "@dracula-color-black" "#073642")
blue=$(get_tmux_option "@dracula-color-blue" "#268bd2")

# ── Dark Mode ─────────────────────────────────────────────────────────────────
# darkmode=$(get_tmux_option "@dracula-dark-mode" false)
# if $darkmode; then
#   _tmp=$black
#   black=$white
#   white=$_tmp
# fi

# ── Element Variables ─────────────────────────────────────────────────────────
# Each element defaults to the upstream dracula color but can be individually
# overridden via tmux options.

# Status bar (status_bg depends on bg_color — defined after transparency block)
status_fg=$(resolve_color "$(get_tmux_option "@dracula-status-fg" "${white}")")

# Window flags
flags_fg=$(resolve_color "$(get_tmux_option "@dracula-flags-fg" "${dark_purple}")")
current_flags_fg=$(resolve_color "$(get_tmux_option "@dracula-current-flags-fg" "${light_purple}")")

# Pane borders
if $show_border_contrast; then
  _pane_active_default=${light_purple}
else
  _pane_active_default=${dark_purple}
fi
pane_active_border_fg=$(resolve_color "$(get_tmux_option "@dracula-pane-active-border-fg" "${_pane_active_default}")")
pane_border_fg=$(resolve_color "$(get_tmux_option "@dracula-pane-border-fg" "${gray}")")

# Message bar
message_bg=$(resolve_color "$(get_tmux_option "@dracula-message-bg" "${gray}")")
message_fg=$(resolve_color "$(get_tmux_option "@dracula-message-fg" "${white}")")

# Left icon (powerline mode)
left_icon_bg=$(resolve_color "$(get_tmux_option "@dracula-left-icon-bg" "${green}")")
left_icon_fg=$(resolve_color "$(get_tmux_option "@dracula-left-icon-fg" "${dark_gray}")")
left_icon_prefix_bg=$(resolve_color "$(get_tmux_option "@dracula-left-icon-prefix-bg" "${yellow}")")

# Left icon (non-powerline mode)
left_icon_npl_bg=$(resolve_color "$(get_tmux_option "@dracula-left-icon-npl-bg" "${green}")")
left_icon_npl_fg=$(resolve_color "$(get_tmux_option "@dracula-left-icon-npl-fg" "${dark_gray}")")

# Current window tab
win_current_fg=$(resolve_color "$(get_tmux_option "@dracula-win-current-fg" "${white}")")
win_current_bg=$(resolve_color "$(get_tmux_option "@dracula-win-current-bg" "${dark_purple}")")

# Inactive window tab (win_bg depends on bg_color — defined after transparency block)
win_fg=$(resolve_color "$(get_tmux_option "@dracula-win-fg" "${white}")")

# Transparency block colors (used by the transparency conditional in dracula.sh)
sep_color=$(resolve_color "$(get_tmux_option "@dracula-sep-color" "${dark_purple}")")
bg_base=$(resolve_color "$(get_tmux_option "@dracula-bg-base" "${gray}")")

window_sep_color=$(resolve_color "$(get_tmux_option "@dracula-window-sep-color" "${gray}")")
