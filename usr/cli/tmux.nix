#MC # tmux
{ config, pkgs, stdenv, lib, ... }:
let
  opt = import ../../opt.nix;
in {
  home.packages = [pkgs.tmux];
  #MC ## bash config for tmux
  #MC
  #MC Auto start tmux in non-GUI device.
  #MC mkAfter ensure the tmux config is appended to the tail of .bashrc.
  programs.bash.bashrcExtra = lib.mkAfter (lib.optionalString (!opt.isGui) ''
    # Auto start tmux
    # see: https://unix.stackexchange.com/questions/43601/how-can-i-set-my-default-shell-to-start-up-tmux
    # ~~1. tmux exists on the system~~, nix ensure that tmux does exist
    # 2. we're in an interactive shell, and
    # 3. tmux doesn't try to run within itself
    if [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
      exec tmux
    fi
  '');
  #MC ## tmux config file
  home.file.tmux = {
    text = ''
      # display status at top
      set -g status-position top
      set -g status-right ""

      # status bar
      ## display title on terminal
      set -g set-titles on
      set -g window-status-format "#F#I #W #{=/-20/…:pane_title}"
      set -g window-status-current-format "🐶#F#I #W #{=/-20/…:pane_title}"
      ## hide status bar when only one window
      ### refer to
      ### https://www.reddit.com/r/tmux/comments/6lwb07/is_it_possible_to_hide_the_status_bar_in_only_a/
      ### It not good, since its global!
      # if -F "#{==:#{session_windows},1}" "set -g status off" "set -g status on"
      # set-hook -g window-linked 'if -F "#{==:#{session_windows},1}" "set -g status off" "set -g status on"'
      # set-hook -g window-unlinked 'if -F "#{==:#{session_windows},1}" "set -g status off" "set -g status on"'
      ## color
      ### colour256的前10个和终端(gnome-terminal tango)的配色一致
      set -g status-style "bg=white fg=black"
      set -g window-status-last-style "bg=white fg=green bold"
      set -g window-status-current-style "bg=black fg=green bold"
      # set -g window-status-separator "|"

      # enable mouse scroll
      set -g mouse on

      # window index start from 1
      set -g base-index 1
      setw -g pane-base-index 1

      # auto re-number
      set -g renumber-windows on

      # Set new panes to open in current directory
      bind c new-window -c "#{pane_current_path}"
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # alt-num select window
      bind-key -n M-1 select-window -t 1
      bind-key -n M-2 select-window -t 2
      bind-key -n M-3 select-window -t 3
      bind-key -n M-4 select-window -t 4
      bind-key -n M-5 select-window -t 5
      bind-key -n M-6 select-window -t 6
      bind-key -n M-7 select-window -t 7
      bind-key -n M-8 select-window -t 8
      bind-key -n M-9 select-window -t 9
      # ctrl-t new window
      bind-key -n C-t new-window -c "#{pane_current_path}"

      # vi key bindings
      set -g mode-keys vi
      set -g status-keys vi

      # Home, End key not work in nix-on-droid
      # https://stackoverflow.com/questions/18600188/home-end-keys-do-not-work-in-tmux
      bind-key -n Home send Escape "OH"
      bind-key -n End send Escape "OF"

      set -g allow-passthrough on
    '';
    target = ".tmux.conf";
  };
}
