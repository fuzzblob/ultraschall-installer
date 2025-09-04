#!/usr/bin/env bash

set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command failed with exit code $?."' EXIT

###############################################################################
# Program Functions
###############################################################################

_print_help() {
  cat <<HEREDOC

Ultraschall installer

Run without arguments to install the Ultraschall configuration into the default path at "${HOME}/.config/REAPER"
Pass a path to your (portable) REAPER install if you want to install Ultraschall paralell to another REAPER install.

Usage:
  ${_ME} [custom install path]
  ${_ME} -h | --help

Options:
  -h --help  Show this screen.
HEREDOC
}

_check_path() {
  DEFAULT_PATH="$HOME/.config/REAPER"
  INSTALL_PATH="$1"

  if [ "$INSTALL_PATH" != "" ]; then
    if [ -d "$INSTALL_PATH" ]; then
      if [ -f "$INSTALL_PATH/reaper.ini" ]; then
        echo "custom install path \"$INSTALL_PATH\" seems valid."
        return
      else
        echo "custom install path \"$INSTALL_PATH\" does not contain a \"reaper.ini\" file."
        INSTALL_PATH=""
        return
      fi
    else
      echo "custom install path \"$INSTALL_PATH\" does not seem to exist."
      echo "use default path \"$DEFAULT_PATH\"?"
      read -p "y/Y: " -n 1 -r
      echo    # (optional) move to a new line
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        # set default path
        INSTALL_PATH="$DEFAULT_PATH"
        return
      else
        echo "aborting install."
        INSTALL_PATH=""
        return
      fi
    fi
  else
    # no custom path passed to install script
    # set default path
    INSTALL_PATH="$DEFAULT_PATH"
    return
  fi
}

_backup() {
  BACKUP_TIMESTAMP=$(date -u "+%Y%m%dT%H%M%S")
  BACKUP_FOLDER="$INSTALL_PATH../ultraschall/backups/$BACKUP_TIMESTAMP"
  mkdir -p "$BACKUP_FOLDER"
  cp -r "$INSTALL_PATH" "$BACKUP_FOLDER"
  if [ $? -eq 0 ]; then
    ## TODO: make path output prittier (not relative)
    echo "Your current REAPER configuration has been saved to $BACKUP_FOLDER."
  fi
}

_install() {
  _check_path $1

  if [ "$INSTALL_PATH" == "" ]; then
    return
  fi

  if [ -d "$INSTALL_PATH" ]; then
    _backup

    echo "Installing the Ultraschall REAPER Theme..."
    tar xf ./themes/ultraschall-theme.tar -C "$INSTALL_PATH"
    echo "Done."

    echo "Installing the Ultraschall REAPER Plug-ins..."
    cp -fr ./plugins/* "$INSTALL_PATH/UserPlugins"
    echo "Done."

    echo "Installing the Ultraschall StudioLink plugin..."
    mkdir -p "$HOME/.vst3"
    rm -rf "$HOME/.vst3/studio-link-plugin.vst"
    cp -fr ./custom-plugins/studio-link-plugin.vst "$HOME/.vst3"
    echo "Done."

    echo "Installing the Ultraschall StudioLink OnAir plugin..."
    mkdir -p "$HOME/.lv2"
    rm -rf "$HOME/.lv2/studio-link-onair.lv2"
    cp -fr ./custom-plugins/studio-link-onair.lv2 "$HOME/.lv2"
    echo "Done."

    echo "Installing the Ultraschall Soundboard plugin..."
    mkdir -p "$HOME/.vst3"
    rm -rf "$HOME/.vst3/Soundboard.vst3"
    cp -fr ./custom-plugins/Soundboard.vst3 "$HOME/.vst3"
    echo "Done."

    echo "Installing the Ultraschall REAPER Scripts..."
    cp -fr ./scripts/* "$INSTALL_PATH/Scripts"
    echo "Done."

    echo "Installing Liberation fonts..."
    if [ -d "$HOME/.fonts" ]; then
      rm -f "$HOME/.fonts/LiberationMono*.ttf"
      rm -f "$HOME/.fonts/LiberationSans*.ttf"
      rm -f "$HOME/.fonts/LiberationSerif*.ttf"
    else
      mkdir -p "$HOME/.fonts"
    fi
    cp -f ./fonts/LiberationMono*.ttf "$HOME/.fonts"
    cp -f ./fonts/LiberationSans*.ttf "$HOME/.fonts"
    cp -f ./fonts/LiberationSerif*.ttf "$HOME/.fonts"
    fc-cache -f
    echo "Done."
  else
    echo ""
    echo "Utraschall tried to install to \"$INSTALL_PATH\" but failed."
    echo "Please open REAPER first to set it up, then run this installer again."
    echo "This will create an initial configuration which Ulktraschall will modify."
  fi
}

###############################################################################
# Main Function
###############################################################################

_main() {
  if [[ "${1:-}" =~ ^-h|--help$  ]]; then
    _print_help
    return 0
  else
    _install "$1"
    return 0
  fi
}

###############################################################################
# Main execution
###############################################################################

# Call `_main` after everything has been defined.
_main "$@"

trap - DEBUG
trap - EXIT
