# Fallout London Proton Installer

An unofficial installer for [Fallout London](https://fallout4london.com/) for the Steam/Proton version of Fallout 4.

## Prerequisites

- p7zip
- [steamcmd](https://developer.valvesoftware.com/wiki/SteamCMD)
- Steam for Linux with Fallout 4 installed
- Fallout London installed via GOG/Heroid Games Launcher

## Instructions

1. Ensure all prerequisites are met.
2. Run `./install-folon.sh` and answer all prompts.
3. Verify that the script completes successfully.
4. Install the FalloutLondon-$BUILD_ID.7z file using your preferred mod manager.
   - [rockerbacon/modorganizer2-linux-installer](https://github.com/rockerbacon/modorganizer2-linux-installer) - provides an automated way to install MO2 for Proton games
   - If using MO2 - ensure that you either disable profile-specific INIS or copy the recommended configurations into the profile
5. Launch the game via f4se_loader.exe

## References

- [Fallout London Release instructions](https://fallout4london.com/release/)
- [juliamertz/linux-fallout4-downgrader](https://github.com/juliamertz/linux-fallout4-downgrader)