#!/usr/bin/env bash
# Fallout London Proton Installer
# TODO: Allow setting paths interactively

FALLOUT4_STEAM_ID="377160"
FOLON_GOG_ID="1491728574"

# Downgrader variables
SKIP_DOWNGRADE="false"
export STEAM_APP_PATH="${STEAM_APP_PATH}"
export LOCALE_CODE="${LOCALE_CODE}"
export STEAM_USERNAME="${STEAM_USERNAME}"
export OWNS_AUTOMATRON=${OWNS_AUTOMATRON:-0}

function help() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -h, --help                                    Display this help message and exit"
  echo "  --f4-app-path <path>                          Path to the Fallout 4 Steam installation directory"
  echo "  --f4-prefix <path>                            Path for the Fallout 4 Proton prefix"
  echo "  --folon-path <path>                           Path to the Fallout London installation directory"
  echo "  --skip-downgrade                              Skip the Fallout 4 downgrader script"
  echo "  -l <code>, --locale <code>                    Downgrader: Locale code for Fallout 4 depots (e.g., 'en', 'es', 'fr')"
  echo "  -u <username>, --steam-username <username>    Downgrader: Your Steam username for steamcmd"
  echo "  --owns-automatron                             Downgrader: Set this flag if you own the Automatron DLC"
  echo "  --steamcmd-root <path>                        Downgrader: Specify steamcmd STEAMROOT. Defaults to ~/.steam/steamcmd"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --f4-app-path)
      export STEAM_APP_PATH="$2"
      shift 2 ;;
    --f4-prefix)
      FALLOUT4_PFX="$2"
      shift 2 ;;
    --folon-path)
      FOLON_PATH="$2"
      shift 2 ;;
    --skip-downgrade)
      SKIP_DOWNGRADE="true"
      shift 1 ;;
    -l|--locale)  
      export LOCALE_CODE="$2"
      shift 2 ;;
    -u|--steam-username)
      export STEAM_USERNAME="$2"
      shift 2 ;;
    --owns-automatron)
      export OWNS_AUTOMATRON=1
      shift 1 ;;
    --steamcmd-root)
      export STEAMCMD_STEAMROOT="$2"
      shift 2 ;;
    -h|--help)
      help
      exit 0 ;;
    *)
      echo "Unknown argument: $1"
      help
      exit 1
      ;;
  esac
done

function detect_f4_path() {
  detected_path=$(protontricks --no-runtime --no-bwrap -c "echo \$STEAM_APP_PATH" $FALLOUT4_STEAM_ID)
  if [[ ! -d "$detected_path" ]]; then
    return 1
  fi
  echo "$detected_path"
}

function detect_f4_pfx() {
  detected_pfx=$(protontricks --no-runtime --no-bwrap -c "echo \$WINEPREFIX" $FALLOUT4_STEAM_ID)
  if [[ ! -d "$detected_pfx" ]]; then
    return 1
  fi
  echo "$detected_pfx"
  export FALLOUT4_PFX="$detected_pfx"
}

function detect_folon_path() {
  # Heroic
  local installedJson="${XDG_CONFIG_HOME:-$HOME/.config}/heroic/gog_store/installed.json"
  detected_folon=$(jq -r ".installed[] | select(.appName == \"$FOLON_GOG_ID\") | .install_path" "$installedJson")
  if [[ ! -d "$detected_folon" ]]; then
    return 1
  fi
  echo "$detected_folon"
}

function check_paths() {
  if [[ ! -d "${FOLON_PATH}" ]]; then
    echo "Attempting to detect Fallout London installation"
    FOLON_PATH="$(detect_folon_path)"
    status=$?
    if [[ $status -ne 0 ]]; then
      echo "Fallout London dir could not be detected"
      exit 1
    fi
  fi
  if [[ ! -d "${STEAM_APP_PATH}" ]]; then
    echo "Attempting to detect Fallout 4 installation"
    STEAM_APP_PATH="$(detect_f4_path)"
    status=$?
    if [[ $status -ne 0 ]]; then
      echo "Fallout 4 app path could not be detected"
      exit 1
    fi
    # export for use in downgrader script
    export STEAM_APP_PATH
  fi 
  if [[ ! -d "${FALLOUT4_PFX}" ]]; then
    echo "Attempting to detect Fallout 4 Proton prefix"
    FALLOUT4_PFX="$(detect_f4_pfx)"
    status=$?
    if [[ $status -ne 0 ]]; then
      echo "Fallout 4 Proton prefix could not be detected"
      exit 1
    fi
  fi
  echo "Configured paths:"
  echo "FOLON_PATH=$FOLON_PATH"
  echo "STEAM_APP_PATH=$STEAM_APP_PATH"
  echo "FALLOUT4_PFX=$FALLOUT4_PFX"
}

function check_cmds() {
  echo "Checking required commands"
  if ! type 7z >/dev/null 2>&1; then
    echo "7z - NOT found"
    exit 1
  else
    echo "7z - FOUND"
  fi
  if ! type jq >/dev/null 2>&1; then
    echo "jq - NOT found"
    exit 1
  else
    echo "jq - FOUND"
  fi
  if ! type protontricks >/dev/null 2>&1; then
    echo "protontricks - NOT found"
    exit 1
  else
    echo "protontricks - FOUND"
  fi
  if ! type steamcmd >/dev/null 2>&1; then
    echo "steamcmd - NOT found"
    exit 1
  else
    echo "steamcmd - FOUND"
  fi
}

function downgrade_fallout4() {
  if [[ "$SKIP_DOWNGRADE" != "true" ]]; then
    linux-fallout4-downgrader/downgrade.sh
    status=$?
    if [[ $status -ne 0 ]]; then
      echo "Failed to downgrade Fallout 4 successfully"
      exit 1
    fi
  else
    echo "Skipping downgrade"
  fi
}

function install_f4se() {
  echo "Installing F4SE"
  cp -v -r \
    "${FOLON_PATH}/CustomControlMap.txt" \
    "${FOLON_PATH}/f4se_loader.exe" \
    "${FOLON_PATH}/f4se_readme.txt" \
    "${FOLON_PATH}/f4se_whatsnew.txt" \
    "${FOLON_PATH}"/*.dll \
    "${STEAM_APP_PATH}"
  status=$?
  if [[ $status -ne 0 ]]; then
    echo "ERROR: Failed to install F4SE files"
    exit 1
  fi
}

function make_folon_mod_archive() {
  local buildId
  buildId=$(jq -r '.buildId' "$FOLON_PATH/goggame-$FOLON_GOG_ID.info")
  local archivePath="$FOLON_PATH/FalloutLondon-${buildId}.7z"
  # Only create zip if archive for buildId doesn't exist
  if [[ ! -f "${archivePath}" ]]; then
    output=$(7z a "${archivePath}" "${FOLON_PATH}/f4se_loader.exe")
    status=$?
    if [[ $status -ne 0 ]]; then
      echo "$output"
      return 1
    fi
  fi
  echo "$archivePath"
}

function install_folon_data() {
  echo "WARN: Installing the mod archive is not automated, please install the archive using Mod Organizer 2 or your preferred mod manager..."
}

function install_folon_config() {
  echo "Installing FOLON config files"
  # TODO: Handle MO2 profile-specific inis?
  local config_dest="${FALLOUT4_PFX}/drive_c/users/steamuser/My Documents/My Games/Fallout4"
  mkdir -p "${config_dest}"
  cp -v "${FOLON_PATH}/__Config"/* \
    "${config_dest}"
  status=$?
  if [[ $status -ne 0 ]]; then
    echo "ERROR: Failed to install Fallout London Config files"
    exit 1
  fi
}

function install_folon_appdata() {
  echo "Installing FOLON AppData files"
  local appdata_dest="${FALLOUT4_PFX}/drive_c/users/steamuser/AppData/Local/Fallout4"
  mkdir -p "${appdata_dest}"
  cp -v "${FOLON_PATH}/__AppData/"* "${appdata_dest}"
  status=$?
  if [[ $status -ne 0 ]]; then
    echo "ERROR: Failed to install Fallout London AppData files"
    exit 1
  fi
}

# Check environment first
check_cmds
check_paths

# F4 Downgrade
downgrade_fallout4

# Create mod archive
mod_archive_output="$(make_folon_mod_archive)"
status=$?
if [[ $status -ne 0 ]]; then
  echo "Error while creating Fallout London archive"
  echo "$mod_archive_output"
  exit 1
fi
install_folon_data

# Install other assets
install_f4se
install_folon_config
install_folon_appdata

echo "Successfully installed Fallout London!"
echo "Mod archive created at: $mod_archive_output"
# FIXME: Reprint warning that mod is not automatically installed
install_folon_data
