#!/usr/bin/env bash

SCRIPT_ROOT=$(cd "$(dirname "$BASH_SOURCE")"; pwd -P)
FOLON_INSTALLER="${SCRIPT_ROOT}/../install-folon.sh"

# shellcheck source=test/bach.sh
source "${SCRIPT_ROOT}/bach.sh"

@setup {
  export FALLOUT4_PFX="/mock/steam/steamapps/common/"
  export FOLON_PATH="/mock/folon-test-path"
  export FOLON_GOG_ID="123456789"
  export FALLOUT4_STEAM_ID="377160"
  export MOCK_FOLON_BUILD_ID="123456"
}

test-check-cmds:-success() {
  @load_function "${FOLON_INSTALLER}" check_cmds
  @mocktrue type
  @ignore echo
  check_cmds
}

test-check-cmds:-success-assert() {
  type 7z
  type jq
  type protontricks
  type steamcmd
}

test-ASSERT-FAIL-check-cmds:-all-missing() {
  @load_function "${FOLON_INSTALLER}" check_cmds
  @mockfalse type 7z
  @mockfalse type jq
  @mockfalse type protontricks
  @mockfalse type steamcmd

  check_cmds
}

test-make-folon:-success() {
  @load_function "${FOLON_INSTALLER}" make_folon_mod_archive
  @mock jq -r '.buildId' "$FOLON_PATH/goggame-$FOLON_GOG_ID.info" === @stdout $MOCK_FOLON_BUILD_ID
  @mocktrue 7z

  make_folon_mod_archive
}

test-make-folon:-success-assert() {
  7z a $FOLON_PATH/FalloutLondon-$MOCK_FOLON_BUILD_ID.7z $FOLON_PATH/f4se_loader.exe
  echo $FOLON_PATH/FalloutLondon-$MOCK_FOLON_BUILD_ID.7z

}

test-ASSERT-FAIL-make-folon:-7z-failure() {
  @load_function "${FOLON_INSTALLER}" make_folon_mod_archive
  @mock jq -r '.buildId' "$FOLON_PATH/goggame-$FOLON_GOG_ID.info" === @stdout $MOCK_FOLON_BUILD_ID
  @mockfalse 7z a  $FOLON_PATH/FalloutLondon-$MOCK_FOLON_BUILD_ID.7z  $FOLON_PATH/f4se_loader.exe
  @ignore echo

  make_folon_mod_archive
}


test-folon-config:-success() {
  @load_function "${FOLON_INSTALLER}" install_folon_config
  @ignore echo
  @ignore mkdir
  install_folon_config
}

test-folon-config:-success-assert() {
    cp -v "${FOLON_PATH}/__Config"/* "${FALLOUT4_PFX}/drive_c/users/steamuser/My Documents/My Games/Fallout4"
}

test-folon-appdata:-success() {
  @load_function "${FOLON_INSTALLER}" install_folon_appdata
  @ignore echo
  @ignore mkdir
  install_folon_appdata
}

test-folon-appdata:-success-assert() {
    cp -v "${FOLON_PATH}/__AppData"/* "${FALLOUT4_PFX}/drive_c/users/steamuser/AppData/Local/Fallout4"
}