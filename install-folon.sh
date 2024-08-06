#!/usr/bin/env bash
# Fallout London Proton Installer

# TODO: Allow setting paths interactively
# TODO: Add argument parsing for required values
export STEAMLIBRARY="${STEAMLIBRARY:-$HOME/.steam/steam}"
export FALLOUT4_ID="377160"
export FALLOUT4_PFX="${STEAMLIBRARY}/steamapps/compatdata/${FALLOUT4_ID}/pfx"
FOLON_DIR="${FOLON_DIR}"

# Downgrader variables
export GAME_DIR="${GAME_DIR:-${STEAMLIBRARY}/steamapps/common/Fallout 4}"
export LOCALE_CODE="${LOCALE_CODE}"
export STEAM_USERNAME="${STEAM_USERNAME}"
export OWNS_AUTOMATRON="${OWNS_AUTOMATRON}"

function check_paths() {
  if [[ ! -d "${FOLON_DIR}" ]]; then
    echo "Fallout London dir does not exist: ${FOLON_DIR}"
    exit 1
  fi
  if [[ ! -d "${GAME_DIR}" ]]; then
    echo "Fallout 4 does not exist: ${GAME_DIR}"
    exit 1
  fi 
  if [[ ! -d "${FALLOUT4_PFX}" ]]; then
    echo "Fallout 4 Proton prefix does not exist: ${FALLOUT4_PFX}"
    exit 1
  fi
}

function check_cmds() {
  echo "Checking required commands"

  if ! type steamcmd >/dev/null 2>&1; then
    echo "steamcmd - NOT found"
    exit 1
  else
    echo "steamcmd - FOUND"
  fi

  if ! type 7z >/dev/null 2>&1; then
    echo "7z - NOT found"
    exit 1
  else
    echo "7z - FOUND"
  fi
}

function downgrade_fallout4() {
  bash linux-fallout4-downgrader/downgrade.sh
}

function install_f4se() {
  echo "Installing F4SE"
  cp -v -r \
    "${FOLON_DIR}/CustomControlMap.txt" \
    "${FOLON_DIR}/f4se_loader.exe" \
    "${FOLON_DIR}/f4se_readme.txt" \
    "${FOLON_DIR}/f4se_whatsnew.txt" \
    "${FOLON_DIR}"/*.dll \
    "${GAME_DIR}"
  # TODO: Allow getting F4SE directly from GitHub?
  # F4SE_VERSION="0.6.23"
  # F4SE_VERSION_WITH_UNDERSCORES=$(echo "$F4SE_VERSION" | tr . _)
  # F4SE_RELEASE="https://github.com/ianpatt/f4se/releases/download/v${F4SE_VERSION}/f4se_${F4SE_VERSION_WITH_UNDERSCORES}.7z"
}

function make_folon_mod_archive() {
  # TODO: get paths from input
  # read -p "Where would you like to install the Fallout London mod archive?" modLocation
  echo "Creating FOLON mod archive"
  local buildId=$(grep -oP '"buildId": "\K.*?(?=")' "$FOLON_DIR/goggame-1491728574.info")
  local archivePath="FalloutLondon-${buildId}.7z"
  if [ -f "${archivePath}" ]; then
    echo "INFO: Archive for $buildId already exists, skipping"
    echo "$archivePath"
  else
    7z a "${archivePath}" "${FOLON_DIR}/Data"
  fi
}

function install_folon_data() {
  echo "WARN: Installing the mod archive is not automated, please install the archive using Mod Organizer 2 or your preferred mod manager..."
  read -p "Press enter to continue" ignored
}

function install_folon_config() {
  echo "Installing FOLON config files"
  # TODO: Handle MO2 profile-specific inis?
  local config_dest="${FALLOUT4_PFX}/drive_c/users/steamuser/My Documents/My Games/Fallout4"
  mkdir -p "${config_dest}"
  cp -v "${FOLON_DIR}/__Config"/* \
    "${config_dest}"
}

function install_folon_appdata() {
  echo "Installing FOLON AppData files"
  local appdata_dest="${FALLOUT4_PFX}/drive_c/users/steamuser/AppData/Local/Fallout4"
  mkdir -p "${appdata_dest}"
  cp -v "${FOLON_DIR}/__AppData/"* "${appdata_dest}"
}

check_paths
check_cmdss
downgrade_fallout4
install_f4se
make_folon_mod_archive
install_folon_data
install_folon_config
install_folon_appdata