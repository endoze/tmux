#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $current_dir/utils.sh

main() {
  datafile=/tmp/.dracula-tmux-data

  # set configuration option variables
  show_fahrenheit=$(get_tmux_option "@dracula-show-fahrenheit" true)
  show_location=$(get_tmux_option "@dracula-show-location" true)
  fixed_location=$(get_tmux_option "@dracula-fixed-location")
  show_powerline=$(get_tmux_option "@dracula-show-powerline" false)
  show_flags=$(get_tmux_option "@dracula-show-flags" false)
  show_left_icon=$(get_tmux_option "@dracula-show-left-icon" smiley)
  show_left_icon_padding=$(get_tmux_option "@dracula-left-icon-padding" 1)
  show_military=$(get_tmux_option "@dracula-military-time" false)
  show_timezone=$(get_tmux_option "@dracula-show-timezone" true)
  show_left_sep=$(get_tmux_option "@dracula-show-left-sep" )
  show_right_sep=$(get_tmux_option "@dracula-show-right-sep" )
  show_border_contrast=$(get_tmux_option "@dracula-border-contrast" false)
  show_day_month=$(get_tmux_option "@dracula-day-month" false)
  show_refresh=$(get_tmux_option "@dracula-refresh-rate" 5)
  time_format=$(get_tmux_option "@dracula-time-format" "%Y-%m-%d(%a) %H:%M")
  show_kubernetes_context_label=$(get_tmux_option "@dracula-kubernetes-context-label" "")
  IFS=' ' read -r -a plugins <<<$(get_tmux_option "@dracula-plugins" "battery network weather")
  show_empty_plugins=$(get_tmux_option "@dracula-show-empty-plugins" true)

  # allow customization of colors used in statusline
  black=$(get_tmux_option "@dracula-color-black", "#073642")
  white=$(get_tmux_option "@dracula-color-white" "#f8f8f2")
  gray=$(get_tmux_option "@dracula-color-gray" "#44475a")
  dark_gray=$(get_tmux_option "@dracula-color-dark-gray" "#282a36")
  light_purple=$(get_tmux_option "@dracula-color-light-purple" "#bd93f9")
  dark_purple=$(get_tmux_option "@dracula-color-dark-purple" "#6272a4")
  cyan=$(get_tmux_option "@dracula-color-cyan" "#8be9fd")
  green=$(get_tmux_option "@dracula-color-green" "#50fa7b")
  orange=$(get_tmux_option "@dracula-color-orange" "#ffb86c")
  red=$(get_tmux_option "@dracula-color-red" "#ff5555")
  pink=$(get_tmux_option "@dracula-color-pink" "#ff79c6")
  yellow=$(get_tmux_option "@dracula-color-yellow" "#f1fa8c")
  blue=$(get_tmux_option "@dracula-color-blue" "#268bd2")

  darkmode=$(get_tmux_option "@dracula-dark-mode" true)

  if $darkmode; then
    previous_black=$black
    black=$white
    white=$previous_black
  fi

  status_bg=$white
  status_fg=$black

  # Handle left icon configuration
  case $show_left_icon in
  smiley)
    left_icon="☺"
    ;;
  session)
    left_icon="#S"
    ;;
  window)
    left_icon="#W"
    ;;
  *)
    left_icon=$show_left_icon
    ;;
  esac

  # Handle left icon padding
  padding=""
  if [ "$show_left_icon_padding" -gt "0" ]; then
    padding="$(printf '%*s' $show_left_icon_padding)"
  fi
  left_icon="$left_icon$padding"

  # Handle powerline option
  if $show_powerline; then
    right_sep="$show_right_sep"
    left_sep="$show_left_sep"
  fi

  # start weather script in background
  if [[ "${plugins[@]}" =~ "weather" ]]; then
    $current_dir/sleep_weather.sh $show_fahrenheit $show_location $fixed_location &
  fi

  # Set timezone unless hidden by configuration
  case $show_timezone in
  false)
    timezone=""
    ;;
  true)
    timezone="#(date +%Z)"
    ;;
  esac

  case $show_flags in
  false)
    flags=""
    current_flags=""
    ;;
  true)
    flags="#{?window_flags,#[fg=${dark_gray}]#{window_flags},}"
    current_flags="#{?window_flags,#[fg=${black}]#{window_flags},}"
    ;;
  esac

  # sets refresh interval to every 5 seconds
  tmux set-option -g status-interval $show_refresh

  # set the prefix + t time format
  if $show_military; then
    tmux set-option -g clock-mode-style 24
  else
    tmux set-option -g clock-mode-style 12
  fi

  # set length
  tmux set-option -g status-left-length 100
  tmux set-option -g status-right-length 100

  # pane border styling
  if $show_border_contrast; then
    tmux set-option -g pane-active-border-style "fg=${pink}"
  else
    tmux set-option -g pane-active-border-style "fg=${dark_purple}"
  fi
  tmux set-option -g pane-border-style "fg=${gray}"

  # message styling
  tmux set-option -g message-style "bg=${gray},fg=${white}"

  # status bar
  tmux set-option -g status-style "bg=${gray},fg=${white}"

  # Status left
  if $show_powerline; then
    tmux set-option -g status-left "#[bg=${blue},fg=${white}]#{?client_prefix,#[bg=${yellow}],} ${left_icon} #[fg=${blue},bg=${white}]#{?client_prefix,#[fg=${yellow}],}${left_sep}"
    powerbg=${white}
  else
    tmux set-option -g status-left "#[bg=${green},fg=${dark_gray}]#{?client_prefix,#[bg=${yellow}],} ${left_icon}"
  fi

  # Status right
  tmux set-option -g status-right ""

  for plugin in "${plugins[@]}"; do

    if [ $plugin = "cwd" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-cwd-colors" "dark_gray white")
      tmux set-option -g status-right-length 250
      script="#($current_dir/cwd.sh)"

    elif [ $plugin = "git" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-git-colors" "green dark_gray")
      tmux set-option -g status-right-length 250
      script="#($current_dir/git.sh)"

    elif [ $plugin = "battery" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-battery-colors" "pink dark_gray")
      script="#($current_dir/battery.sh)"

    elif [ $plugin = "gpu-usage" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-gpu-usage-colors" "pink dark_gray")
      script="#($current_dir/gpu_usage.sh)"

    elif [ $plugin = "cpu-usage" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-cpu-usage-colors" "orange dark_gray")
      script="#($current_dir/cpu_info.sh)"

    elif [ $plugin = "ram-usage" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-ram-usage-colors" "cyan dark_gray")
      script="#($current_dir/ram_info.sh)"

    elif [ $plugin = "network" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-network-colors" "cyan dark_gray")
      script="#($current_dir/network.sh)"

    elif [ $plugin = "network-bandwidth" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-network-bandwidth-colors" "cyan dark_gray")
      tmux set-option -g status-right-length 250
      script="#($current_dir/network_bandwidth.sh)"

    elif [ $plugin = "network-ping" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-network-ping-colors" "cyan dark_gray")
      script="#($current_dir/network_ping.sh)"

    elif [ $plugin = "network-vpn" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-network-vpn-colors" "cyan dark_gray")
      script="#($current_dir/network_vpn.sh)"

    elif [ $plugin = "attached-clients" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-attached-clients-colors" "cyan dark_gray")
      script="#($current_dir/attached_clients.sh)"

    elif [ $plugin = "spotify-tui" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-spotify-tui-colors" "green dark_gray")
      script="#($current_dir/spotify-tui.sh)"

    elif [ $plugin = "kubernetes-context" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-kubernetes-context-colors" "cyan dark_gray")
      script="#($current_dir/kubernetes_context.sh $show_kubernetes_context_label)"

    elif [ $plugin = "weather" ]; then
      # wait unit $datafile exists just to avoid errors
      # this should almost never need to wait unless something unexpected occurs
      while [ ! -f $datafile ]; do
        sleep 0.01
      done

      IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-weather-colors" "orange dark_gray")
      script="#(cat $datafile)"

    elif [ $plugin = "time" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@dracula-time-colors" "dark_purple white")
      if [ ${time_format:+1} ]; then
        script=${time_format}
      else
        if $show_day_month && $show_military; then # military time and dd/mm
          script="%a %d/%m %R ${timezone} "
        elif $show_military; then # only military time
          script="%a %m/%d %R ${timezone} "
        elif $show_day_month; then # only dd/mm
          script="%a %d/%m %I:%M %p ${timezone} "
        else
          script="%a %m/%d %I:%M %p ${timezone} "
        fi
      fi

    else
      continue
    fi

    if $show_powerline; then
      if $show_empty_plugins; then
        tmux set-option -ga status-right "#[fg=${!colors[0]},bg=${powerbg},nobold,nounderscore,noitalics]${right_sep}#[fg=${!colors[1]},bg=${!colors[0]}] $script "
      else
        tmux set-option -ga status-right "#{?#{==:$script,},,#[fg=${!colors[0]},nobold,nounderscore,noitalics]${right_sep}#[fg=${!colors[1]},bg=${!colors[0]}] $script }"
      fi
      powerbg=${!colors[0]}
    else
      if $show_empty_plugins; then
        tmux set-option -ga status-right "#[fg=${!colors[1]},bg=${!colors[0]}] $script "
      else
        tmux set-option -ga status-right "#{?#{==:$script,},,#[fg=${!colors[1]},bg=${!colors[0]}] $script }"
      fi
    fi
  done

  # Window option
  if $show_powerline; then
    tmux set-window-option -g window-status-current-format "#[fg=${white},bg=${blue}]${left_sep}#[fg=${white},bg=${blue}] #I #W${current_flags} #[fg=${blue},bg=${white}]${left_sep}"
  else
    tmux set-window-option -g window-status-current-format "#[fg=${gray},bg=${blue}] #I #W${current_flags} "
  fi

  tmux set-window-option -g window-status-format "#[fg=${gray}]#[bg=${white}] #I #W${flags}"
  tmux set-window-option -g window-status-activity-style "bold"
  tmux set-window-option -g window-status-bell-style "bold"
  tmux set -g status-bg "${status_bg}"
  tmux set -g status-fg "${status_fg}"
}

# run main function
main
